defmodule ExCucumber.Gherkin do
  @moduledoc false
  alias __MODULE__.Traverser
  alias ExCucumber.Failure.Messages, as: FailureMessages

  use ExDebugger.Manual

  def run_all(path) do
    "#{path}/*.feature"
    |> Path.wildcard()
    |> Enum.map(&execute/1)
  end

  #def run(feature_path, module, module_path, parse_tree) do
   # feature_path
    #|> execute
    #|> Traverser.run(Traverser.ctx(feature_path, module, module_path), parse_tree)
  #end
  def run(feature_path, module, module_path, parse_tree) do
    try do
      feature_path
      |> execute
      |> Traverser.run(Traverser.ctx(feature_path, module, module_path), parse_tree)
    rescue
      e in [CucumberExpressions.Matcher.Failure] -> FailureMessages.render(e)
      error -> IO.inspect(error)
        raise "Uncaught Error"
    end
  end

  def execute(path) do
    [path: path]
    |> ExGherkin.prepare
    |> ExGherkin.run
    |> elem(1)
    |> dd(:raw_feature)
    |> ExGherkin.AstNdjson.run
    |> dd(:run)
  end
end
