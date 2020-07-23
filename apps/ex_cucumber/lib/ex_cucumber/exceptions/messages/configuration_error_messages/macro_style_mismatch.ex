defmodule ExCucumber.Exceptions.Messages.MacroStyleMismatch do
  @moduledoc false
  alias CucumberExpressions.ParameterType

  alias ExCucumber.{
    Config,
    Exceptions.ConfigurationError,
    Gherkin.Traverser.Ctx,
    Utils,
  }

  alias ExCucumber.Gherkin.Keywords, as: GherkinKeywords
  alias ExCucumber.Exceptions.Messages.Common, as: CommonMessages

  def render(%ConfigurationError{error_code: :macro_style_mismatch} = e, :brief) do
    """
    Macro Style Mismatch
    Use the `macro`: `#{GherkinKeywords.macro_name(e.ctx)}` instead at: #{
      CommonMessages.render(:module_file, e.ctx)
    }
    """
  end

  def render(%ConfigurationError{error_code: :macro_style_mismatch} = e, :verbose) do
    macro_style = Config.macro_style()
    counterpart = Config.macro_style(:counterpart)
    module_name = e.ctx.__struct__.module_name(e.ctx)

    """
    # Macro Style Mismatch
    ## Summary
    `config.exs` specifies #{Utils.atomize(macro_style)} as the macro style whereas you
    are using a `macro` belonging to macro style: #{Utils.atomize(counterpart)}.

    ## Quick Fix
    For the sake of consistency, you have two options:
      1. Either change the macro style in `config.exs` to: #{Utils.atomize(counterpart)}
      2. Either use the correct `macro` instead, e.g.: `#{GherkinKeywords.macro_name(e.ctx)}`

    ### Option 1

    #{
      CommonMessages.render(
        :config_option,
        :macro_style,
        "#{Utils.atomize(counterpart, :no_backticks)} # [:def, :module]"
      )
    }

    ### Option 2
    Inside the `module`: #{Utils.backtick(module_name)} at: #{
      CommonMessages.render(:module_file, e.ctx)
    },
    copy-paste the following:

    #{CommonMessages.render(:macro_usage, e.ctx, e.ctx.extra.cucumber_expression)}

    ## Details
    `ExCucumber` allows you to configure how you would prefer to express yourself.
    In the case that you like to employ the following macro styles:

    #{example_phrases(:macro_names)}

    Then you need to set the following config option:
    #{
      CommonMessages.render(
        :config_option,
        :macro_style,
        "#{Utils.atomize(:def, :no_backticks)} # [:def, :module]"
      )
    }

    In the case that you like to employ the following macro styles:

    #{example_phrases(:modularized_macro_names)}

    Then you need to set the following config option:
    #{
      CommonMessages.render(
        :config_option,
        :macro_style,
        "#{Utils.atomize(:module, :no_backticks)} # [:def, :module]"
      )
    }
    """
  end

  def example_phrases(macro_style) do
    :example_phrases
    |> GherkinKeywords.mappings()
    |> Enum.map(fn {token, phrase} ->
      ctx =
        ""
        |> Ctx.new(:module, "", ParameterType.new(), :none, "", token)
        |> Ctx.extra(%{macro_style: macro_style})

      :macro_usage
      |> CommonMessages.render(ctx, phrase)
    end)
    |> Enum.join("")
  end
end
