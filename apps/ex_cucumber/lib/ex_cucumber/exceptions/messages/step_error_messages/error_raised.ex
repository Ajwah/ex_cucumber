defmodule ExCucumber.Exceptions.Messages.ErrorRaised do
  @moduledoc false
  alias ExCucumber.{
    Exceptions.StepError,
    Utils
  }

  alias ExCucumber.Exceptions.Messages.Common, as: CommonMessages

  def render(%StepError{error_code: :error_raised} = e, _) do
    # {_, [line: line], _} = e.ctx.extra.raised_error.expr

    """
    Feature File: #{CommonMessages.render(:feature_file, e.ctx)}
    #{inspect(e.ctx.module) |> to_string |> String.trim_leading("Elixir.")}: #{
      CommonMessages.render(:module_file, e.ctx.module_file, e.ctx.extra.def_meta.line, 0)
    }
    Step: #{
      Utils.backtick(
        CommonMessages.render(:macro_usage_heading, e.ctx, e.ctx.extra.cucumber_expression)
      )
    }
    Error:
    #{CommonMessages.render(:code_block, Exception.format(:error, e.ctx.extra.raised_error, []))}

    State:
    #{CommonMessages.render(:code_block, e.ctx.extra.state)}
    """
  end
end
