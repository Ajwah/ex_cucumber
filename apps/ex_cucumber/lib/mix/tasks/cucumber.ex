defmodule Mix.Tasks.Cucumber do
  @moduledoc """
  Mix Task that runs cucumber framework against your feature files.
  """
  use Mix.Task
  alias ExCucumber.Report
  alias ExCucumber.Exceptions.Messages

  alias ExCucumber.Exceptions.{
    ConfigurationError,
    MatchFailure,
    StepError,
    UsageError
  }

  @cucumber_related_error_types [
    ConfigurationError,
    MatchFailure,
    StepError,
    UsageError
  ]

  @shortdoc "Run cucumber framework"
  @impl Mix.Task
  def run(opts) do
    Code.compiler_options(ignore_module_conflict: true)
    IEx.Helpers.r(ExCucumber.Config)
    IEx.Helpers.r(ExCucumber)
    IEx.Helpers.r(ExCucumber.Gherkin.Keywords)

    Code.compiler_options(ignore_module_conflict: false)

    Mix.Task.run("app.start")
    _ = opts(opts)

    report =
      "#{ExCucumber.Config.feature_dir()}/*.exs"
      |> Path.wildcard()
      |> Enum.reduce(Report.new(), fn e, a = %Report{} ->
        try do
          Code.compile_file(e)
          Report.record(a, :passed)
        rescue
          error in @cucumber_related_error_types -> Report.record(a, %{file: e, error: error})
        end
      end)

    report.failed
    |> Enum.each(&(Messages.render(&1.error, false) |> IO.inspect()))

    IO.puts("""
    Total: #{report.total}
    Passed: #{report.passed}
    Failed: #{Enum.count(report.failed)}
    """)
  end

  defp opts(opts) do
    opts
    # |> OptionParser.parse
  end
end
