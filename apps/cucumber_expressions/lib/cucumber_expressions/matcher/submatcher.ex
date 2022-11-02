defmodule CucumberExpressions.Matcher.Submatcher do
  @moduledoc false

  alias CucumberExpressions.Parser.ParseTree

  import Record
  # use ExDebugger
  # use ExDebugger.Manual

  defrecord :submatcher,
    current_word: "",
    previous_subsentence: "",
    only_spaces_so_far?: false,
    parameter_types: %{},
    potential_submatches: %{}

  def find(potential_submatches, remaining_sentence, parameter_types, current_word \\ " ") do
    [
      current_word: current_word,
      previous_subsentence: "",
      only_spaces_so_far?: true,
      parameter_types: parameter_types,
      potential_submatches: potential_submatches
    ]
    |> submatcher
    |> retrieve(remaining_sentence)
  end

  defp retrieve(
         s = submatcher(current_word: current_word, only_spaces_so_far?: true),
         <<" ", rest::binary>>
       ) do
    s
    |> submatcher(current_word: current_word <> " ")
    # |> dd(:submatcher)
    |> retrieve(rest)
  end

  defp retrieve(
         s =
           submatcher(
             potential_submatches: potential_submatches,
             previous_subsentence: previous_subsentence,
             current_word: current_word,
             only_spaces_so_far?: false
           ),
         remainder_sentence = <<" ", rest::binary>>
       ) do
    potential_submatches
    |> ParseTree.next_key_match(current_word)
    |> case do
      :key_not_present ->
        {:key_not_present, s, rest}
        # |> dd(:submatcher)

        s
        |> submatcher(
          current_word: " ",
          previous_subsentence: previous_subsentence <> current_word
        )
        |> retrieve(rest)

      {:potential_param_to_value_match, matching_key, previous_key} ->
        {:potential_param_to_value_match,
         {matching_key, previous_key, {:subsentence_so_far, previous_subsentence},
          {:remainder_sentence, remainder_sentence}}}

      {
        :potential_param_to_param_matches,
        params_to_check,
        param_value
      } ->
        {
          :potential_param_to_param_matches,
          {
            params_to_check,
            param_value,
            {:subsentence_so_far, previous_subsentence},
            {:remainder_sentence, remainder_sentence}
          }
        }
    end
  end

  defp retrieve(
         #         s =
         submatcher(
           potential_submatches: potential_submatches,
           previous_subsentence: previous_subsentence,
           current_word: current_word
         ),
         ""
       ) do
    potential_submatches
    |> ParseTree.next_key_match(current_word)
    |> case do
      :key_not_present ->
        if key = potential_submatches[:end] do
          {:potential_param_to_value_match,
           {{:matching_key, :end}, {:previous_key, key},
            {:subsentence_so_far, previous_subsentence <> current_word},
            {:remainder_sentence, ""}}}

          # |> dd(:submatcher)
        else
          :key_not_present
        end

      {:potential_param_to_value_match, matching_key, previous_key} ->
        {:potential_param_to_value_match,
         {matching_key, previous_key, {:subsentence_so_far, previous_subsentence},
          {:remainder_sentence, ""}}}

      {
        :potential_param_to_param_matches,
        params_to_check,
        param_value
      } ->
        {
          :potential_param_to_param_matches,
          {
            params_to_check,
            param_value,
            {:subsentence_so_far, previous_subsentence},
            {:remainder_sentence, ""}
          }
        }

        # {:match, matching_key, previous_key} ->
        #   {:match, matching_key, previous_key, {:subsentence_so_far, previous_subsentence},
        #    {:remainder_sentence, ""}}
    end
  end

  defp retrieve(s = submatcher(current_word: current_word), <<char::utf8, rest::binary>>) do
    s
    |> submatcher(current_word: current_word <> <<char::utf8>>, only_spaces_so_far?: false)
    |> retrieve(rest)
  end
end
