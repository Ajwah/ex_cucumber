defmodule ExCucumber.Gherkin.Traverser.Step do
  @moduledoc false

  # alias ExCucumber.Gherkin.Traverser, as: MainTraverser
  alias ExCucumber.Gherkin.Traverser.Ctx
  alias CucumberExpressions.{
    Matcher,
    ParameterType,
    # Parser
  }

  def run(%ExGherkin.AstNdjson.Step{} = s, acc, parse_tree) do
    m = Matcher.run(s.text, parse_tree, ParameterType.new, Ctx.update(acc, location: Map.from_struct(s.location), token: s.token, keyword: s.keyword))
    acc.module.execute_mfa(to_string(m.id), m.id, 1) |> IO.inspect
  end
end
