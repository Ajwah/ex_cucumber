defmodule CucumberExpressions.Parser do
  @moduledoc """
  """
  import Record
  alias Utils

  defrecord :parser,
    remaining_sentence: "",
    current_word: "",
    original_sentence: "",
    collected_sentences: %{},
    "escaped_{?": false,
    "escaped_(?": false,
    only_spaces_so_far?: false,
    multiple_ids_allowed?: true,
    id: ""

  @type t() ::
          record(:parser,
            remaining_sentence: String.t(),
            current_word: String.t(),
            original_sentence: String.t(),
            collected_sentences: Map.t(),
            "escaped_{?": boolean,
            "escaped_(?": boolean,
            only_spaces_so_far?: boolean,
            multiple_ids_allowed?: true,
            id: Utils.Random.t()
          )

  alias __MODULE__.SyntaxError
  alias __MODULE__.ValidationError

  def new(
        remaining_sentence,
        current_word,
        original_sentence,
        collected_sentences \\ %{},
        id \\ Utils.id(:fixed),
        escaped_curly_bracket? \\ false,
        escaped_round_bracket? \\ false,
        only_spaces_so_far? \\ false,
        multiple_ids_allowed? \\ true
      ) do
    with {_, _, true} <- {:string, remaining_sentence, is_binary(remaining_sentence)},
         {_, _, true} <-
           {:string_or_atom, current_word, is_binary(current_word) || is_atom(current_word)},
         {_, _, true} <- {:string, original_sentence, is_binary(original_sentence)},
         {_, _, true} <- {:map, collected_sentences, is_map(collected_sentences)},
         {_, _, true} <- {:string, id, is_binary(id)},
         {_, _, true} <- {:boolean, escaped_curly_bracket?, is_boolean(escaped_curly_bracket?)},
         {_, _, true} <- {:boolean, escaped_round_bracket?, is_boolean(escaped_round_bracket?)},
         {_, _, true} <- {:boolean, only_spaces_so_far?, is_boolean(only_spaces_so_far?)},
         {_, _, true} <- {:boolean, multiple_ids_allowed?, is_boolean(multiple_ids_allowed?)} do
      parser(
        remaining_sentence: remaining_sentence,
        current_word: current_word,
        original_sentence: original_sentence,
        collected_sentences: collected_sentences,
        "escaped_{?": escaped_curly_bracket?,
        "escaped_(?": escaped_round_bracket?,
        only_spaces_so_far?: only_spaces_so_far?,
        multiple_ids_allowed?: multiple_ids_allowed?,
        id: id
      )
    else
      {type_constraint, violator, false} ->
        ValidationError.raise(
          "[#{__MODULE__}.new] Expected type: #{type_constraint}. Violator: #{violator}",
          :type_mismatch,
          violator
        )
    end
  end

  def run(sentence, collected_sentences, id \\ Utils.id(:fixed)) do
    {remaining_sentence, preceding_spaces} = handle_preceding_spaces(sentence, 0)

    remaining_sentence
    |> new(preceding_spaces, sentence, collected_sentences, id)
    |> process(remaining_sentence)
  end

  defp handle_preceding_spaces(<<" ", rest::binary>>, num_spaces) do
    handle_preceding_spaces(rest, num_spaces + 1)
  end

  defp handle_preceding_spaces(rest, num_spaces), do: {rest, String.duplicate(" ", num_spaces)}

  def format_ending(
        parser(current_word: current_word, original_sentence: original_sentence, id: id),
        incorporate: to_be_incorporated
      ) do
    %{current_word => %{:end => original_sentence, id: id} |> Map.merge(to_be_incorporated)}
  end

  def format_ending(
        parser(current_word: current_word, original_sentence: original_sentence, id: id)
      ) do
    %{current_word => %{:end => original_sentence, id: id}}
  end

  defp process(
         p =
           parser(
             # remaining_sentence: remaining_sentence,
             current_word: current_word,
             original_sentence: original_sentence,
             collected_sentences: collected_sentences,
             "escaped_{?": escaped_curly_bracket?,
             "escaped_(?": escaped_round_bracket?,
             only_spaces_so_far?: only_spaces_so_far?
           ),
         <<remaining_sentence::binary>>
       ) do
    remaining_sentence
    |> case do
      "" ->
        format_ending(p)

      <<"\\ ", rest::binary>> ->
        p
        |> parser(
          # remaining_sentence: rest,
          current_word: current_word <> " ",
          only_spaces_so_far?: false
        )
        |> process(rest)

      <<" ", rest::binary>> ->
        if only_spaces_so_far? do
          p
          |> parser(current_word: current_word <> " ")
          # |> parser(remaining_sentence: rest, current_word: current_word <> " ")
          |> process(rest)
        else
          if current_word == " " do
            p
            |> parser(current_word: "  ", only_spaces_so_far?: true)
            # |> parser(remaining_sentence: rest, current_word: "  ", only_spaces_so_far?: true)
            |> process(rest)
          else
            subset = Map.get(collected_sentences, current_word, %{})

            p = parser(p, current_word: " ", collected_sentences: subset)

            Map.merge(collected_sentences, %{current_word => Map.merge(subset, process(p, rest))})
          end
        end

      <<"}", rest::binary>> ->
        if escaped_curly_bracket? do
          p
          |> parser(
            # remaining_sentence: rest,
            current_word: current_word <> "}",
            "escaped_{?": false,
            "escaped_(?": false,
            only_spaces_so_far?: false
          )
          |> process(rest)
        else
          SyntaxError.raise(
            "Non Opening Param: #{current_word}",
            :non_opening_param,
            original_sentence
          )
        end

      <<")", rest::binary>> ->
        if escaped_round_bracket? do
          p
          |> parser(
            # remaining_sentence: rest,
            current_word: current_word <> ")",
            "escaped_{?": false,
            "escaped_(?": false,
            only_spaces_so_far?: false
          )
          |> process(rest)
        else
          SyntaxError.raise(
            "Non Opening Optional Text Bracket: #{current_word}",
            :non_opening_optional_text_bracket,
            original_sentence
          )
        end

      <<"\\{", rest::binary>> ->
        p
        |> parser(
          # remaining_sentence: rest,
          current_word: current_word <> "{",
          "escaped_{?": true,
          only_spaces_so_far?: false
        )
        |> process(rest)

      <<"\\(", rest::binary>> ->
        p
        |> parser(
          # remaining_sentence: rest,
          current_word: current_word <> "(",
          "escaped_(?": true,
          only_spaces_so_far?: false
        )
        |> process(rest)

      <<"\\/", rest::binary>> ->
        p
        |> parser(
          # remaining_sentence: rest,
          current_word: current_word <> "/",
          only_spaces_so_far?: false
        )
        |> process(rest)

      <<"{", rest::binary>> ->
        params = Map.get(collected_sentences, :params, %{next_key: %{}})

        p =
          parser(p,
            # remaining_sentence: rest,
            collected_sentences: params,
            only_spaces_so_far?: false,
            "escaped_{?": false,
            "escaped_(?": false
          )

        Map.merge(collected_sentences, handle_parameter(p, rest))

      <<"(", rest::binary>> ->
        {rest, augmented_word} =
          handle_optional_text(rest, current_word, %{
            original_sentence: parser(p, :original_sentence)
          })

        p
        |> parser(
          # remaining_sentence: rest,
          only_spaces_so_far?: false,
          "escaped_{?": false,
          "escaped_(?": false
        )
        |> process(rest)
        |> case do
          result ->
            [subset_to_be_duplicated] = Map.values(result) |> Enum.uniq()
            Map.put(result, augmented_word, subset_to_be_duplicated)
        end

      <<"/", rest::binary>> ->
        {rest, words} =
          handle_alternative_text(rest, "", [], %{
            original_sentence: parser(p, :original_sentence)
          })

        alternatives = words
        preceding_spaces = copy_preceding_spaces(current_word, 0)

        p
        |> parser(
          # remaining_sentence: rest,
          only_spaces_so_far?: false,
          "escaped_{?": false,
          "escaped_(?": false
        )
        |> process(rest)
        |> case do
          result ->
            [subset_to_be_duplicated] = Map.values(result)

            Enum.reduce(
              alternatives,
              result,
              &Map.put(&2, preceding_spaces <> &1, subset_to_be_duplicated)
            )
        end

      <<char::utf8, rest::binary>> ->
        p
        |> parser(
          # remaining_sentence: rest,
          current_word: current_word <> <<char::utf8>>,
          only_spaces_so_far?: false
        )
        |> process(rest)
    end
  end

  def copy_preceding_spaces(<<" ", rest::binary>>, num_spaces) do
    copy_preceding_spaces(rest, num_spaces + 1)
  end

  def copy_preceding_spaces(_, num_spaces), do: String.duplicate(" ", num_spaces)

  defp handle_alternative_text(<<"\\ ", rest::binary>>, alternative_text_so_far, acc, flags) do
    handle_alternative_text(rest, alternative_text_so_far <> " ", acc, flags)
  end

  defp handle_alternative_text(<<"\\(", rest::binary>>, alternative_text_so_far, acc, flags) do
    updated_flags =
      Map.merge(flags, %{
        "escaped_(?": true
      })

    handle_alternative_text(rest, alternative_text_so_far <> "(", acc, updated_flags)
  end

  defp handle_alternative_text(
         remainder = <<" ", _rest::binary>>,
         alternative_text_so_far,
         acc,
         flags
       ) do
    if flags[:"unclosed_(?"] do
      SyntaxError.raise(
        "Non Closing Optional Text Bracket: #{alternative_text_so_far}",
        :non_closing_optional_text_bracket,
        flags.original_sentence
      )
    else
      {remainder, [alternative_text_so_far | acc]}
    end
  end

  defp handle_alternative_text("", alternative_text_so_far, acc, flags) do
    if flags[:"unclosed_(?"] do
      SyntaxError.raise(
        "Non Closing Optional Text Bracket: #{alternative_text_so_far}",
        :non_closing_optional_text_bracket,
        flags.original_sentence
      )
    else
      {"", [alternative_text_so_far | acc]}
    end
  end

  defp handle_alternative_text(<<"(", rest::binary>>, alternative_text_so_far, acc, flags) do
    if flags[:"unclosed_(?"] do
      SyntaxError.raise(
        "Nested Optional Text Bracket: #{alternative_text_so_far}",
        :nested_optional_text_bracket,
        flags.original_sentence
      )
    else
      updated_flags =
        Map.merge(flags, %{
          "unclosed_(?": true
        })

      handle_alternative_text(
        rest,
        alternative_text_so_far,
        [alternative_text_so_far | acc],
        updated_flags
      )
    end
  end

  defp handle_alternative_text(<<") ", rest::binary>>, alternative_text_so_far, acc, flags) do
    if flags[:"unclosed_(?"] do
      updated_flags =
        Map.merge(flags, %{
          "unclosed_(?": false
        })

      handle_alternative_text(<<" ", rest::binary>>, alternative_text_so_far, acc, updated_flags)
    else
      SyntaxError.raise(
        "Non Opening Optional Text Bracket: #{alternative_text_so_far}",
        :non_opening_optional_text_bracket,
        flags.original_sentence
      )
    end
  end

  defp handle_alternative_text(<<")", rest::binary>>, alternative_text_so_far, acc, flags) do
    if flags[:"unclosed_(?"] do
      updated_flags =
        Map.merge(flags, %{
          "unclosed_(?": false
        })

      handle_alternative_text(rest, "", [alternative_text_so_far | acc], updated_flags)
    else
      SyntaxError.raise(
        "Non Opening Optional Text Bracket: #{alternative_text_so_far}",
        :non_opening_optional_text_bracket,
        flags.original_sentence
      )
    end
  end

  defp handle_alternative_text(<<"/", rest::binary>>, alternative_text_so_far, acc, flags) do
    if flags[:"unclosed_(?"] do
      SyntaxError.raise(
        "Non Closing Optional Text Bracket: #{alternative_text_so_far}",
        :non_closing_optional_text_bracket_when_starting_alternative_text,
        flags.original_sentence
      )
    else
      updated_flags =
        Map.merge(flags, %{
          "unclosed_(?": false
        })

      handle_alternative_text(rest, "", [alternative_text_so_far | acc], updated_flags)
    end
  end

  defp handle_alternative_text(<<char::utf8, rest::binary>>, alternative_text_so_far, acc, flags) do
    handle_alternative_text(rest, alternative_text_so_far <> <<char::utf8>>, acc, flags)
  end

  defp handle_optional_text(<<")", rest::binary>>, optional_text_so_far, _flags) do
    {rest, optional_text_so_far}
  end

  defp handle_optional_text(<<"\\ ", rest::binary>>, optional_text_so_far, flags) do
    handle_optional_text(rest, optional_text_so_far <> " ", flags)
  end

  defp handle_optional_text(<<" ", _rest::binary>>, optional_text_so_far, flags) do
    SyntaxError.raise(
      "Non Closing Optional Text Bracket: #{optional_text_so_far}",
      :non_closing_optional_text_bracket,
      flags.original_sentence
    )
  end

  defp handle_optional_text(<<"(", _rest::binary>>, optional_text_so_far, flags) do
    SyntaxError.raise(
      "Nested Optional Text Bracket: #{optional_text_so_far}",
      :nested_optional_text_bracket,
      flags.original_sentence
    )
  end

  defp handle_optional_text(<<char::utf8, rest::binary>>, optional_text_so_far, flags) do
    handle_optional_text(rest, optional_text_so_far <> <<char::utf8>>, flags)
  end

  # defp handle

  defp handle_parameter(
         #  parser(remaining_sentence: <<"any}", _::binary>>, original_sentence: original_sentence)
         parser(original_sentence: original_sentence),
         <<"any}", _::binary>>
       ) do
    SyntaxError.raise("Reserved Param: :any", :reserved_param, original_sentence)
  end

  defp handle_parameter(
         #  p = parser(remaining_sentence: rest, original_sentence: original_sentence)
         p = parser(original_sentence: original_sentence),
         rest
       ) do
    rest
    |> handle_parameter_chars("")
    |> case do
      {:ok, {param, rest}} ->
        result = process(parser(p, current_word: param), rest)

        next_words =
          result[param]
          |> Map.keys()
          |> case do
            [:params | _] ->
              Map.keys(result[param][:params])

            rs = [r | _] ->
              [r, :next_key]
              rs
          end
          |> Enum.filter(fn e -> e != :params and e != :next_key and e != :id end)

        params =
          Map.put(
            result,
            :next_key,
            result[:next_key]
            |> case do
              nil ->
                Enum.reduce(next_words, %{}, fn e, a -> Map.put(a, e, param) end)

              mapping ->
                # mapping[next_word]
                # |> case do
                #   nil -> Map.put(mapping, next_word, param)
                #   ls when is_list(ls) -> Map.put(mapping, next_word, [param | ls])
                #   e -> Map.put(mapping, next_word, [param, e])
                # end

                Enum.reduce(next_words, mapping, fn e, a ->
                  a[e]
                  |> case do
                    nil ->
                      Map.put(a, e, param)

                    ls when is_list(ls) ->
                      if param in ls do
                        a
                      else
                        Map.put(a, e, [param | ls])
                      end

                    el ->
                      if param == el do
                        a
                      else
                        Map.put(a, e, [param, el])
                      end
                  end
                end)
            end
          )

        %{params: params}

      {:error, {msg, error_code}} ->
        SyntaxError.raise(msg, error_code, original_sentence)
    end
  end

  defp handle_parameter_chars("", non_closing_param),
    do: {:error, {"Non Closing Param: #{non_closing_param}", :non_closing_param}}

  defp handle_parameter_chars(<<"{", _rest::binary>>, param_so_far),
    do: {:error, {"Nested Param: #{param_so_far}", :nested_param}}

  defp handle_parameter_chars(<<"}", rest::binary>>, ""), do: {:ok, {:any, rest}}

  defp handle_parameter_chars(<<"}", rest::binary>>, chars) do
    {:ok, {chars |> String.to_atom(), rest}}
  end

  defp handle_parameter_chars(<<char::utf8, rest::binary>>, chars) do
    handle_parameter_chars(rest, chars <> <<char::utf8>>)
  end
end
