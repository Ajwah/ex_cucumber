defmodule ExCucumber.Gherkin.Traverser do
  @moduledoc false
  alias __MODULE__.Ctx
  alias __MODULE__.Feature, as: FeatureTraverser
  alias __MODULE__.Background, as: BackgroundTraverser
  alias __MODULE__.Rule, as: RuleTraverser
  alias __MODULE__.Scenario, as: ScenarioTraverser
  alias __MODULE__.Step, as: StepTraverser

  alias CucumberExpressions.ParameterType

  def ctx(feature_file, module, module_path, parameter_type \\ ParameterType.new()) do
    Ctx.new(feature_file, module, module_path, parameter_type)
  end

  def run(nil, acc, _), do: acc

  def run(%ExGherkin.AstNdjson.Feature{} = f, acc, parse_tree),
    do: FeatureTraverser.run(f, acc, parse_tree)

  def run(%ExGherkin.AstNdjson.Background{} = f, acc, parse_tree),
    do: BackgroundTraverser.run(f, acc, parse_tree)

  def run(%ExGherkin.AstNdjson.Rule{} = f, acc, parse_tree),
    do: RuleTraverser.run(f, acc, parse_tree)

  def run(%ExGherkin.AstNdjson.Scenario{token: _} = f, acc, parse_tree),
    do: ScenarioTraverser.run(f, acc, parse_tree)

  def run(%ExGherkin.AstNdjson.Step{} = s, acc, parse_tree),
    do: StepTraverser.run(s, acc, parse_tree)
end
