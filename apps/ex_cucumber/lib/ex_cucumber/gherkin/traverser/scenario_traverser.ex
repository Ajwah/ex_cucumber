defmodule ExCucumber.Gherkin.Traverser.Scenario do
  @moduledoc false

  alias ExCucumber.Gherkin.Traverser, as: MainTraverser

  def run(%ExGherkin.AstNdjson.Scenario{} = s, acc, parse_tree) do
    s.steps
    |> Enum.each(fn
      %ExGherkin.AstNdjson.Step{} = step -> MainTraverser.run(step, acc, parse_tree)
    end)
  end
end
