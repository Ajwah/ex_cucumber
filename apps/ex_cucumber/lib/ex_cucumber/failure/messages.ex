defmodule ExCucumber.Failure.Messages do
@moduledoc """
Template:
  # Error Code
  ## Summary
  ## Quick Fix
  ## Details
"""
  alias CucumberExpressions.Matcher.Failure
  alias ExCucumber.Config.ConfigurationError
  alias __MODULE__.{
    IncorrectErrorLevelDetail,
    IncorrectMacroStyle,
    UnableToMatch,
    MacroStyleMismatch,
  }

  @default_options [
      enabled: true,
      doc_bold: [:bright],
      doc_code: [:blue],
      doc_headings: [:red, :underline],
      doc_metadata: [:yellow],
      doc_quote: [:light_black],
      doc_inline_code: [:cyan],
      doc_table_heading: [:reverse],
      doc_title: [:red_background, :yellow],
      doc_underline: [:underline],
      width: 120
    ]

  @matcher_failure_heading "** (CucumberExpressions.Matcher.Failure)"
  @configuration_error_heading "** (ExCucumber.Config.ConfigurationError)"

  @headings %{
    unable_to_match: @matcher_failure_heading,
    incorrect_error_level_detail: @configuration_error_heading,
    incorrect_macro_style: @configuration_error_heading,
    macro_style_mismatch: @configuration_error_heading,
  }

  def render(f) do
    IO.inspect(f, label: :render)

    if ExCucumber.Config.error_detail_level == :brief do
      {_, body} = render(f, detail_level: :brief)
      """
      #{body}
      """
    else
      {heading, body} = render(f, detail_level: :verbose)
      IO.ANSI.Docs.print_heading(heading, @default_options)
      IO.ANSI.Docs.print(body, @default_options)
      exit(:shutdown)
    end
  end

  def render(%Failure{error_code: error_code = :unable_to_match} = f, detail_level: detail_level) do
    {
      Map.fetch!(@headings, error_code),
      UnableToMatch.render(f, detail_level)
    }
  end

  def render(%ConfigurationError{error_code: error_code = :incorrect_error_level_detail} = f, detail_level: detail_level) do
    {
      Map.fetch!(@headings, error_code),
      IncorrectErrorLevelDetail.render(f, detail_level)
    }
  end

  def render(%ConfigurationError{error_code: error_code = :incorrect_macro_style} = f, detail_level: detail_level) do
    {
      Map.fetch!(@headings, error_code),
      IncorrectMacroStyle.render(f, detail_level)
    }
  end

  def render(%ConfigurationError{error_code: error_code = :macro_style_mismatch} = f, detail_level: detail_level) do
    {
      Map.fetch!(@headings, error_code),
      MacroStyleMismatch.render(f, detail_level)
    }
  end
end
