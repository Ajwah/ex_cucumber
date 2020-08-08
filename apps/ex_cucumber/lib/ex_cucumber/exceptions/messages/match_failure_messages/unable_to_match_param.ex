defmodule ExCucumber.Exceptions.Messages.UnableToMatchParam do
  @moduledoc false
  alias CucumberExpressions.Parser.ParseTree

  alias ExCucumber.{
    Exceptions.MatchFailure,
    Utils
  }

  def render(%MatchFailure{error_code: :unable_to_match_param} = f, :brief) do
    """
    Unable To Match Param: #{f.extra.param_key} for the value: #{
      Utils.smart_quotes(f.extra.value)
    } while attemting to match the
    sentence: #{Utils.smart_quotes(f.ctx.sentence)} in `#{
      Exception.format_file_line(f.ctx.feature_file, f.ctx.location.line, f.ctx.location.column)
    }
    Error Message: #{f.extra.msg}`

    Source: #{extract_failing_custom_param_details(f)}
    """
  end

  def render(%MatchFailure{error_code: :unable_to_match_param} = f, :verbose) do
    endings = ParseTree.endings(f.extra.remaining_parse_tree)
    module_name = f.ctx.__struct__.module_name(f.ctx)

    """
    # Unable To Match Param: #{f.extra.param_key} for the value: #{
      Utils.smart_quotes(f.extra.value)
    }
    Error Message: #{Utils.smart_quotes(f.extra.msg)}

    Source: #{extract_failing_custom_param_details(f)}

    ## Summary
    #{extract_failing_custom_param_details(f)} has returned a tagged error tuple.

    ## Quick Fix
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

    The following `cucumber expressions` were narrowed down that could be responsible for this exception:
    #{Utils.bullitize(endings, :as_smart_quoted_strings)}
    """
  end

  defp extract_failing_custom_param_details(f) do
    custom_param = f.ctx.parameter_type.collection[f.extra.param_key]

    f.extra.stage
    |> case do
      :pre_transform -> custom_param.transformer.pre.paradigm
      :validator -> custom_param.validator.paradigm
    end
    |> case do
      {module, param, arity} -> "`#{inspect(module)}.#{param}/#{arity}`"
    end
  end
end
