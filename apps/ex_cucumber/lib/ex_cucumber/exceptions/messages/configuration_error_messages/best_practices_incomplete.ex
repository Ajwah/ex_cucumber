defmodule ExCucumber.Exceptions.Messages.BestPracticesIncomplete do
  @moduledoc false
  alias ExCucumber.Config
  alias ExCucumber.Exceptions.ConfigurationError
  alias ExCucumber.Exceptions.Messages.Common

  def render(%ConfigurationError{error_code: :best_practices_incomplete}, :brief) do
    """
    Make following adjustment in `config.exs`:
    #{Common.render(:config_option, :best_practices, Config.all_best_practices())}
    """
  end

  def render(%ConfigurationError{error_code: :best_practices_incomplete} = ce, :verbose) do
    """
    # Incorrect Best Practices Provided
    ## Summary
    `config.exs` needs to specify valid values for `:best_practices`

    Instead provided:
    #{Common.render(:config_option, :best_practices, ce.ctx)}

    ## Quick Fix
    Incorporate following to `config.exs`
    #{Common.render(:config_option, :best_practices, Config.all_best_practices())}

    ## Details
    This option allows you to configure the level of commitment that makes sense
    for your use case.
    """
  end
end
