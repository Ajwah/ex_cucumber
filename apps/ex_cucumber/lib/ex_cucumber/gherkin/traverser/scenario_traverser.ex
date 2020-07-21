defmodule ExCucumber.Gherkin.Traverser.Scenario do
  @moduledoc false

  alias ExCucumber.Gherkin.Traverser.Ctx
  alias ExCucumber.Gherkin.Traverser, as: MainTraverser
  alias ExGherkin.AstNdjson.Examples

  def run(%ExGherkin.AstNdjson.Scenario{} = s, acc, parse_tree) do
    s
    |> relevant_examples
    |> Enum.each(fn {tags, rows} ->
      rows
      |> Enum.each(fn row ->
        s.steps
        |> Enum.reduce(Ctx.extra(acc, scenario_meta(s, tags, row)), fn
          %ExGherkin.AstNdjson.Step{} = step, a -> MainTraverser.run(step, a, parse_tree)
        end)
      end)
    end)
  end

  defp example_tables(nil), do: [{nil, [%{}]}]
  defp example_tables([]), do: [{nil, [%{}]}]
  defp example_tables(examples), do: Enum.map(examples, &Examples.table_to_tagged_map/1)

  defp relevant_examples(scenario) do
    {tags, rows} = example_tables(scenario.examples) |> List.first()
    [{tags, rows}]
  end

  defp scenario_meta(scenario, example_tags, example_row) when is_map(example_row) do
    scenario_details =
      if scenario.parsed_sentence do
        title =
          scenario.parsed_sentence.vars
          |> Enum.reduce(scenario.parsed_sentence.template, fn
            var, template ->
              example = Map.fetch!(example_row, var)
              String.replace(template, "%", "#{example}", global: false)
          end)

        %{
          raw: scenario.name,
          title: title,
          location: Map.from_struct(scenario.location),
          keyword: scenario.keyword,
          tags: scenario.tags
        }
      else
        %{
          raw: scenario.name,
          title: scenario.name,
          location: Map.from_struct(scenario.location),
          keyword: scenario.keyword,
          tags: scenario.tags
        }
      end

    %{
      history: [],
      scenario: scenario_details,
      examples: %{tags: example_tags, row: example_row}
    }
  end
end
