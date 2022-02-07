defmodule CucumberExpressions.Matcher do
  @moduledoc false

  alias CucumberExpressions.{
    ParameterType,
    Parser,
    Parser.ParseTree,
    Utils
  }

  alias __MODULE__.{
    Failure,
    Submatcher
  }

  import __MODULE__.Data

  use ExDebugger
  use ExDebugger.Manual

  def run(sentence, %Parser{} = p, %ParameterType{} = pt, ctx \\ %{}) when is_binary(sentence) do
    setting_this_to_true_handles_preceding_spaces = true
    dd(p, :check_parser_content)

    [
      current_word: "",
      only_spaces_so_far?: setting_this_to_true_handles_preceding_spaces,
      parameter_types: pt.collection,
      ctx: Map.put(ctx, :sentence, sentence)
    ]
    |> matcher
    |> process(sentence, p.result)
  end

  # Handle sequence of spaces
  defp process(
         m = matcher(current_word: current_word, only_spaces_so_far?: true),
         <<" ", rest::binary>>,
         parse_tree
       ) do
    m
    |> matcher(current_word: current_word <> " ")
    |> process(rest, parse_tree)
  end

  # Handle escaped spaces
  defp process(
         m = matcher(current_word: current_word),
         <<"\\ ", rest::binary>>,
         parse_tree
       ) do
    m
    |> matcher(current_word: current_word <> " ")
    |> process(rest, parse_tree)
  end

  # Full current word obtained. Potential key match to parse_tree
  defp process(
         m =
           matcher(
             current_word: current_word,
             params: params,
             only_spaces_so_far?: false,
             parameter_types: parameter_types,
             ctx: ctx
           ),
         <<" ", rest::binary>>,
         parse_tree
       ) do
    # dd({}, :matcher)

    parse_tree
    |> ParseTree.subtree(current_word)
    |> case do
      :key_not_present ->
        dd({:matcher0, :key_not_present}, :matcher)
        Failure.raise(ctx, :unable_to_match, m, parse_tree)

      {:process_until_next_match, next_keys} ->
        # dd({:matcher10, :process_until_next_match}, :matcher)

        {param_keys_so_far, remaining_param_keys} =
          next_keys
          # |> Map.merge(next_keys.p2p)
          |> Enum.reduce({[], Map.keys(Map.delete(parse_tree.params, :next_key))}, fn
            {:p2p, _}, a ->
              a

            {_, vs}, {param_keys, remaining_param_keys} when is_list(vs) ->
              {param_keys ++ [{:common_juncture_params, vs}],
               Enum.reject(remaining_param_keys, fn e -> e in vs end)}

            {_, v}, {param_keys, remaining_param_keys} ->
              {[{:independent_param, v} | param_keys],
               Enum.reject(remaining_param_keys, fn e -> e == v end)}
          end)

        remaining_param_keys
        |> Enum.map(&{:independent_param, &1})
        |> Kernel.++(param_keys_so_far)
        |> Enum.reduce_while({:no_disambiguator_to_enforce, []}, fn {_, param_key},
                                                                    acc =
                                                                      {_, failed_disambiguators} ->
          sentence_to_disambiguate = current_word <> " " <> rest

          parameter_types
          |> ParameterType.run(param_key, sentence_to_disambiguate)
          |> case do
            :reserved_keyword ->
              {:cont, acc}

            :parameter_type_not_present ->
              # IO.puts(
              #   "Unable to resort to a disambiguator for: #{inspect(param_key)} to resolve: #{
              #     sentence_to_disambiguate
              #   }. Continuing on in the hope it can be resolved alternatively."
              # )

              {:cont, acc}

            :inoperative_disambiguator ->
              # IO.puts(
              #   "Unable to resort to a disambiguator for: #{inspect(param_key)} to resolve: #{
              #     sentence_to_disambiguate
              #   }. Continuing on in the hope it can be resolved alternatively."
              # )

              {:cont, acc}

            {:ok, result} ->
              {:halt, result}

            {:error, failed_action, result} ->
              {:cont,
               {:failed_disambiguators,
                [{param_key, failed_action, result} | failed_disambiguators]}}
          end
        end)
        # |> dd(:matcher12)
        |> case do
          {:no_disambiguator_to_enforce, []} ->
            attempt_automated_submatch(next_keys, rest, parameter_types, m, parse_tree)

          {:failed_disambiguators, _} ->
            attempt_automated_submatch(next_keys, rest, parameter_types, m, parse_tree)

          {param_key, {match, remainder_sentence}} ->
            m
            |> matcher(
              params: [{param_key, match} | params],
              current_word: " ",
              only_spaces_so_far?: true
            )
            # |> dd(:matcher15)
            |> process(
              Utils.strip_leading_space(remainder_sentence),
              parse_tree.params[param_key]
            )
        end

      subtree ->
        # dd({:matcher40, :subtree}, :matcher)

        m
        |> matcher(current_word: " ", only_spaces_so_far?: true)
        |> process(rest, subtree)
    end
  end

  # End of sentence and no current_word remaining
  defp process(matcher(current_word: "", params: params), "", parse_tree) do
    empty_case = parse_tree[""]

    if empty_case do
      empty_case
    else
      parse_tree
    end
    |> Map.put(:params, params)
  end

  # End of sentence. current_word potential key match to parse_tree
  defp process(
         m =
           matcher(
             current_word: current_word,
             params: params,
             parameter_types: parameter_types,
             ctx: ctx
           ),
         "",
         parse_tree
       ) do
    parse_tree
    |> ParseTree.subtree(current_word)
    |> case do
      :key_not_present ->
        dd({:matcher50, :subtree, :end_of_sentence, :key_not_present}, :matcher)

        Failure.raise(ctx, :unable_to_match, m, parse_tree)

      {:process_until_next_match, next_key} ->
        # dd({:matcher53, :process_until_next_match, :end_of_sentence}, :matcher)

        [param_key] =
          next_key
          |> Map.delete(:p2p)
          |> Map.values()
          |> case do
            [e] ->
              [e]

            other ->
              # IO.inspect({other, parse_tree, m}, label: :anomaly)
              other |> Enum.uniq()
          end
          |> List.wrap()

        parameter_types
        |> ParameterType.run(param_key, Utils.strip_leading_space(current_word), false)
        |> case do
          {:error, stage, msg} ->
            Failure.raise(
              ctx,
              %{param_key: param_key, msg: msg, value: current_word, stage: stage},
              :unable_to_match_param,
              m,
              parse_tree
            )

          {:ok, {_, match}} ->
            parse_tree.params[param_key]
            |> Map.put(:params, [{param_key, match} | params])

          _ ->
            parse_tree.params[param_key]
            |> Map.put(:params, [{param_key, Utils.strip_leading_space(current_word)} | params])
        end

      subtree ->
        # dd({:matcher55, :subtree, :end_of_sentence}, :matcher)

        subtree
        |> Map.put(:params, params)
    end
  end

  # New character to append for current_word.
  defp process(m = matcher(current_word: current_word), <<char::utf8, rest::binary>>, parse_tree) do
    m
    |> matcher(current_word: current_word <> <<char::utf8>>, only_spaces_so_far?: false)
    |> process(rest, parse_tree)
  end

  defp attempt_automated_submatch(
         next_keys,
         rest,
         parameter_types,
         m = matcher(ctx: ctx),
         parse_tree
       ) do
    next_keys
    |> Submatcher.find(rest, parameter_types)
    |> case do
      :key_not_present ->
        dd({:matcher25, :submatcher, :key_not_present}, :matcher)

        Failure.raise(
          ctx,
          :unable_to_auto_match_param,
          m,
          parse_tree
        )

      {:potential_param_to_value_match, potential_match} ->
        potential_param_to_value_match(potential_match, m, parse_tree)
    end
  end

  defp potential_param_match(
         potential_match,
         m =
           matcher(
             current_word: current_word,
             params: params,
             parameter_types: parameter_types,
             ctx: ctx
           ),
         parse_tree
       ) do
    {
      {:matching_key, next_key},
      {:previous_key, current_key},
      {:subsentence_so_far, subsentence_until_next_key},
      {:remainder_sentence, remainder_sentence}
    } = potential_match

    # dd({:matcher30, :match}, :matcher)

    parse_tree
    |> ParseTree.param_subtree(current_key: current_key, next_key: next_key)
    |> case do
      error_code = :current_key_not_present ->
        if is_list(current_key) do
          """
          Unable to determine which param to apply: #{inspect(current_key)} in order to resolve: '#{current_word}'
          In the presence of multiple params colliding for a match, it is required that one ParameterType exists with a
          disambiguator that is able to match.
          Kindly manually check the supplied ParameterTypes on your part: #{inspect(parameter_types, pretty: true)} and determine
          which ParameterType is missing for any of: #{inspect(current_key)} with a disambiguator to distinguish accordingly
          """
          |> Failure.raise(:multiple_params_collision_ambiguity, m, parse_tree)
        else
          Failure.raise(
            "Parse tree unable to resolve #{[current_key: current_key, next_key: next_key]}",
            error_code,
            m,
            parse_tree
          )
        end

      error_code = :next_key_not_present ->
        Failure.raise(
          "Parse tree unable to resolve #{[current_key: current_key, next_key: next_key]}",
          error_code,
          m,
          parse_tree
        )

      subtree ->
        to_be_matched = current_word <> subsentence_until_next_key

        current_key
        |> update_params(
          to_be_matched,
          params,
          parameter_types
        )
        |> case do
          {:error, stage, error_msg} ->
            Failure.raise(
              ctx,
              %{param_key: current_key, value: to_be_matched, stage: stage, msg: error_msg},
              :unable_to_match_param,
              m,
              parse_tree
            )

          updated_params ->
            {:ok, subtree, remainder_sentence, updated_params}
        end
    end
  end

  defp potential_param_to_value_match(
         potential_match,
         m = matcher(),
         parse_tree
       ) do
    potential_match
    |> potential_param_match(m, parse_tree)
    |> case do
      {:ok, subtree, remainder_sentence, updated_params} ->
        m
        |> matcher(
          params: updated_params,
          current_word: "",
          only_spaces_so_far?: true
        )
        # |> dd(:matcher)
        |> process(remainder_sentence, subtree)
    end
  end

  defp update_params(
         current_key,
         current_word,
         params,
         parameter_types
       ) do
    current_word = Utils.strip_leading_space(current_word)

    parameter_types
    |> ParameterType.run(current_key, current_word, false)
    |> case do
      :parameter_type_not_present ->
        # IO.puts(
        #   "No parameter type defined: current_key: #{inspect(current_key)} current_word: #{
        #     inspect(current_word)
        #   } so resorted to auto-match instead."
        # )

        {:ok, {current_key, current_word}}

      result ->
        result
    end
    |> case do
      {:ok, {_, current_val}} -> [{current_key, current_val} | params]
      error -> error
    end

    # |> dd(:matcher)
  end
end
