defmodule ExCucumber.Gherkin.Traverser.Feature do
  @moduledoc false

  alias ExCucumber.Gherkin.Traverser.Ctx
  alias ExCucumber.Gherkin.Traverser, as: MainTraverser

  alias ExGherkin.AstNdjson.Background

  def run(%ExGherkin.AstNdjson.Feature{} = f, acc, parse_tree) do
    {background, children} = background(f.children)

    acc = Ctx.extra(acc, Map.merge(feature_meta(f), %{state: %{}, history: []}))

    children
    |> Enum.each(fn child ->
      acc = MainTraverser.run(background, acc, parse_tree)

      child
      |> case do
        %{scenario: scenario} -> MainTraverser.run(scenario, acc, parse_tree)
        %{rule: rule} -> MainTraverser.run(rule, acc, parse_tree)
      end
    end)
  end

  defp background([]), do: {nil, []}
  defp background([%{background: b = %Background{}}]), do: {b, []}
  defp background([%{background: b = %Background{}} | tl]), do: {b, tl}
  defp background(ls), do: {nil, ls}

  defp feature_meta(feature) do
    %{
      feature: %{
        language: feature.language,
        title: feature.name,
        location: Map.from_struct(feature.location),
        keyword: feature.keyword,
        tags: feature.tags
      }
    }
  end
end
