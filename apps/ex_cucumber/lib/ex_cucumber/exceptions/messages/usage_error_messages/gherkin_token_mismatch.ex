defmodule ExCucumber.Exceptions.Messages.GherkinTokenMismatch do
  @moduledoc false
  alias ExCucumber.Config
  alias ExCucumber.Exceptions.UsageError
  alias ExCucumber.Gherkin.Keywords, as: GherkinKeywords
  alias ExCucumber.Exceptions.Messages.Common, as: CommonMessages
  alias ExCucumber.DocumentationResources

  def render(%UsageError{error_code: :gherkin_token_mismatch} = e, :brief) do
    """
    Use the `macro`: `#{GherkinKeywords.macro_name(e.ctx)}` instead.
    """
  end

  def render(%UsageError{error_code: :gherkin_token_mismatch} = e, :verbose) do
    module_name = e.ctx.__struct__.module_name(e.ctx)

    """
    # Gherkin Token Mismatch
    ## Summary
    `config.exs` specifies that the macro used in step definitions are to correspond
    to the Gherkin Keywords specified in the feature file:

    #{CommonMessages.render(:config_option, :best_practices, Config.best_practices())}

    ## Quick Fix
    For the sake of consistency, you have two options:
      1. Either relax the setting in `config.exs`
      2. Either use the correct `macro` instead, e.g.: `#{GherkinKeywords.macro_name(e.ctx)}`

    ### Option 1
    #{
      CommonMessages.render(:config_option, :best_practices, %{
        disallow_gherkin_token_usage_mismatch?: false
      })
    }

    ### Option 2
    Inside the `module`: #{Utils.backtick(module_name)} at: #{
      CommonMessages.render(:module_file, e.ctx.module_file, e.ctx.extra.def_line, 3)
    },
    adjust to the following:

    #{CommonMessages.render(:macro_usage, e.ctx, e.ctx.extra.cucumber_expression)}

    ## Details
    `Cucumber` does not distinguish between Gherkin Keywords:
    * #{DocumentationResources.link(:duplicate_step_definition)}
    * #{DocumentationResources.link(:duplicate_step_definition_reason)}

    This practically means that the actual text only is taken into consideration when matching a `cucumber expression`
    against it; and thus technically speaking even though one used `Given` as a keyword, one could coin the `cucumber`
    `expression` with a `When` keyword instead. This discrepancy could lead to documentation drift and thus to account
    for this; one could leverage `disallow_gherkin_token_usage_mismatch?: true`.

    Kindly see this issue for more details:
    * #{DocumentationResources.link(:gherkin_token_mismatch)}

    #{extra_detail(e)}
    """
  end

  defp extra_detail(%UsageError{ctx: %{keyword: "* "}}) do
    """
    ## Extra Details
    The feature file you are using leverages the homonym: "* " as a Gherkin Keyword to match upon. This means that although it may
    seem that the same keyword is being employed; in reality every next usage will cause the underlying Gherkin Keyword to change
    as mentioned in the Gherkin Spec: #{DocumentationResources.link(:gherkin_spec, :homonyms)}.
    """
  end

  defp extra_detail(_), do: ""
end
