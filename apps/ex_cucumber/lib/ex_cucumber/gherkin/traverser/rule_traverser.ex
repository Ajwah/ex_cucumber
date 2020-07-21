defmodule ExCucumber.Gherkin.Traverser.Rule do
  @moduledoc false

  alias ExCucumber.Gherkin.Traverser.Ctx
  alias ExCucumber.Gherkin.Traverser, as: MainTraverser

  alias ExGherkin.AstNdjson.Background

  def run(%ExGherkin.AstNdjson.Rule{} = r, acc, parse_tree) do
    {background, children} = background(r.children)

    acc = Ctx.extra(acc, rule_meta(r))

    children
    |> Enum.each(fn child ->
      acc = MainTraverser.run(background, acc, parse_tree)

      child
      |> case do
        %{scenario: scenario} -> MainTraverser.run(scenario, acc, parse_tree)
      end
    end)
  end

  defp background([]), do: {nil, []}
  defp background([%{background: b = %Background{}}]), do: {b, []}
  defp background([%{background: b = %Background{}} | tl]), do: {b, tl}
  defp background(ls), do: {nil, ls}

  defp rule_meta(rule) do
    %{
      rule: %{
        title: rule.name,
        location: Map.from_struct(rule.location),
        keyword: rule.keyword
      }
    }
  end
end
