defmodule ExCucumber.Gherkin.Traverser.Feature do
  @moduledoc false

  alias ExCucumber.Gherkin.Traverser, as: MainTraverser

  def run(%ExGherkin.AstNdjson.Feature{} = f, acc, parse_tree) do
    f.children
    |> Enum.each(fn
      %{scenario: scenario} -> MainTraverser.run(scenario, acc, parse_tree)
    end)
  end
end
