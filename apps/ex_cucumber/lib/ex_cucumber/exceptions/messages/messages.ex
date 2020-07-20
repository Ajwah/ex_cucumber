defmodule ExCucumber.Exceptions.Messages do
  @moduledoc """
  Template:
    # Error Code
    ## Summary
    ## Quick Fix
    ## Details
  """

  alias __MODULE__.{
    BestPracticesIncomplete,
    GherkinTokenMismatch,
    IncorrectErrorLevelDetail,
    IncorrectMacroStyle,
    UnableToAutoMatchParam,
    UnableToMatch,
    UnableToMatchParam,
    MacroStyleMismatch,
    InvalidFeatureDir,
    InvalidProjectRoot,
    FeatureAttributeMissing,
    FeatureFileNotFound
  }

  use ExDebugger.Manual

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
  @configuration_error_heading "** (ExCucumber.Exceptions.ConfigurationError)"

  @delegation_mappings %{
    best_practices_incomplete: {BestPracticesIncomplete, @configuration_error_heading},
    unable_to_match: {UnableToMatch, @matcher_failure_heading},
    unable_to_match_param: {UnableToMatchParam, @matcher_failure_heading},
    unable_to_auto_match_param: {UnableToAutoMatchParam, @matcher_failure_heading},
    incorrect_error_level_detail: {IncorrectErrorLevelDetail, @configuration_error_heading},
    incorrect_macro_style: {IncorrectMacroStyle, @configuration_error_heading},
    macro_style_mismatch: {MacroStyleMismatch, @configuration_error_heading},
    gherkin_token_mismatch: {GherkinTokenMismatch, @configuration_error_heading},
    invalid_feature_dir: {InvalidFeatureDir, @configuration_error_heading},
    invalid_project_root: {InvalidProjectRoot, @configuration_error_heading},
    feature_attribute_missing: {FeatureAttributeMissing, @configuration_error_heading},
    feature_file_not_found: {FeatureFileNotFound, @configuration_error_heading}
  }

  def render(f) do
    error_detail_level = ExCucumber.Config.error_detail_level()
    dd(:render)

    if error_detail_level == :verbose do
      {heading, body} = render(f, detail_level: :verbose)
      IO.ANSI.Docs.print_heading(heading, @default_options)
      IO.ANSI.Docs.print(body, @default_options)

      exit(:shutdown)
    else
      {_, body} = render(f, detail_level: :brief)

      """
      #{body}
      """
    end
  end

  def render(%_{error_code: error_code} = f, detail_level: detail_level) do
    {module, heading} = Map.fetch!(@delegation_mappings, error_code)

    {
      heading,
      module.render(f, detail_level)
    }
  end
end
