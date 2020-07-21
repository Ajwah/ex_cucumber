defmodule CucumberExpressions.Parser.ParseTree do
  @moduledoc false
  use ExDebugger.Manual

  def subtree(parse_tree, key) do
    parse_tree
    |> Map.get(key, :key_not_present)
    |> case do
      :key_not_present ->
        if parse_tree[:params] do
          {:process_until_next_match, parse_tree.params.next_key}
        else
          :key_not_present
        end

      subtree ->
        subtree
    end
  end

  def param_subtree(parse_tree, current_key: current_key, next_key: next_key) do
    parse_tree.params
    |> Map.get(current_key, :current_key_not_present)
    |> case do
      :current_key_not_present ->
        :current_key_not_present

      first_subtree ->
        first_subtree
        |> Map.get(next_key, :next_key_not_present)
        |> case do
          :next_key_not_present ->
            if nested_params = first_subtree[:params] do
              Map.get(nested_params, next_key, :next_key_not_present)
            else
              :next_key_not_present
            end

          subtree ->
            if next_key == :end do
              first_subtree
            else
              subtree
            end
        end
    end

    # |> dd(:parse_tree)
  end

  def next_key_match(parse_tree, potential_key) do
    parse_tree
    |> Map.get(potential_key, :key_not_present)
    |> case do
      :key_not_present ->
        :key_not_present

      previous_key ->
        {:potential_param_to_value_match, {:matching_key, potential_key},
         {:previous_key, previous_key}}
    end
  end

  # Accumulates all the cucumber expressions under `:end` key
  def endings(parse_tree, acc \\ []) do
    cond do
      is_map(parse_tree) and parse_tree[:end] ->
        [parse_tree[:end] | acc]

      is_map(parse_tree) ->
        endings(Map.values(parse_tree), acc)

      is_list(parse_tree) ->
        parse_tree
        |> Enum.reduce(acc, fn e, a ->
          endings(e, a)
        end)

      true ->
        acc
    end
  end
end
