defmodule ExCucumber.Exceptions.Messages.UnableToMatchParam do
  @moduledoc false
  alias CucumberExpressions.Parser.ParseTree

  alias ExCucumber.{
    Exceptions.MatchFailure,
    Utils,
  }
  alias ExCucumber.Exceptions.Messages.Common, as: CommonMessages

  def render(%MatchFailure{error_code: :unable_to_match_param} = f, :brief) do
    """
    Unable To Match Param: #{f.extra.param_key} for the value: #{
      Utils.smart_quotes(f.extra.value)
    } while attemting to match the
    sentence: #{Utils.smart_quotes(f.ctx.sentence)} in `#{
      Exception.format_file_line(f.ctx.feature_file, f.ctx.location.line, f.ctx.location.column)
    }`
    """
  end

  def render(%MatchFailure{error_code: :unable_to_match_param} = f, :verbose) do
    endings = ParseTree.endings(f.extra.remaining_parse_tree)
    module_name = f.ctx.__struct__.module_name(f.ctx)

    """
    # Unable To Match Param: #{f.extra.param_key} for the value: #{
      Utils.smart_quotes(f.extra.value)
    }
    ## Summary
    This exception is raised on account of the closest matching `cucumber expression` defined employs a `parameter` that
    fails to match the value as encountered in the feature file.

    ## Quick Fix
    Either consult the details below to fix the `cucumber expression` responsible or either introduce a more specific
    one to alleviate the ambiguity:
    #{CommonMessages.render(:macro_usage, f.ctx, f.ctx.sentence)}

    ## Details
    * Module: `#{module_name}`
    * Module File: `#{f.ctx.module_file}`
    * Feature File: `#{
      Exception.format_file_line(f.ctx.feature_file, f.ctx.location.line, f.ctx.location.column)
    }`
    * Gherkin Keyword: #{f.ctx.keyword}
    * Sentence: #{Utils.smart_quotes(f.ctx.sentence)}
    * Parameter Type: `#{f.extra.param_key}`
    * Failing Value: #{Utils.smart_quotes(f.extra.value)}

    To help you narrow down the issue; here are the relevant details for the `Parameter Type` in question:
    #{
      CommonMessages.render(
        :code_block,
        "#{inspect(f.ctx.parameter_type.collection[f.extra.param_key], pretty: true)}"
      )
    }

    The following `cucumber expressions` were narrowed down that could be responsible for this exception:
    #{Utils.bullitize(endings, :as_smart_quoted_strings)}
    """
  end
end
