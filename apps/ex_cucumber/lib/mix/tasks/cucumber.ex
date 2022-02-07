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

  import ExCucumber.Utils.ProjectCompiler
  @shortdoc "Run cucumber framework"
  @impl Mix.Task
  def run(opts) do
    Code.compiler_options(ignore_module_conflict: true)
    recompile(ExCucumber.Config)
    recompile(ExCucumber)
    recompile(ExCucumber.Gherkin.Keywords)

    Code.compiler_options(ignore_module_conflict: false)

    Mix.Task.run("app.start")
    {line_nr, files} = opts(opts)

    report =
      files
      |> Enum.reduce(Report.new(), fn e, a = %Report{} ->
        try do
          Application.put_env(:ex_cucumber, :line, line_nr)
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

  defp opts([]), do: {false, "#{ExCucumber.Config.feature_dir()}/*.exs" |> Path.wildcard()}

  defp opts([file]) do
    file
    |> String.split(":")
    |> case do
      [file, line_nr] ->
        line_nr = line_nr |> Decimal.new() |> Decimal.to_integer()

        IO.puts(
          "Only running block corresponding to line: #{line_nr} inside corresponding feature file"
        )

        {line_nr, ["#{ExCucumber.Config.feature_dir()}/#{file}"]}

      [file] ->
        {false, ["#{ExCucumber.Config.feature_dir()}/#{file}"]}
    end
  end
end
