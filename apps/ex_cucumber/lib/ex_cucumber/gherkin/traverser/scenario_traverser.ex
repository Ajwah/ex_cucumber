defmodule ExCucumber.Gherkin.Traverser.Scenario do
  @moduledoc false

  alias ExCucumber.Gherkin.Traverser.Ctx
  alias ExCucumber.Gherkin.Traverser, as: MainTraverser

  def run(%ExGherkin.AstNdjson.Scenario{} = s, acc, parse_tree) do
    # IO.inspect(s, label: :s)
    s.steps
    |> Enum.reduce(Ctx.extra(acc, %{history: []}), fn
      %ExGherkin.AstNdjson.Step{} = step, a ->
        MainTraverser.run(step, a, parse_tree)
    end)
  end
end
