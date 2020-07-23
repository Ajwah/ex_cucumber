defmodule ExCucumber.Exceptions.Messages.IncorrectErrorLevelDetail do
  @moduledoc false
  alias ExCucumber.{
    Config,
    Exceptions.ConfigurationError,
    Utils,
  }

  def render(%ConfigurationError{error_code: :incorrect_error_level_detail}, :brief) do
    """
    Valid options are: #{Config.error_detail_levels() |> Enum.join(", ")}
    """
  end

  def render(%ConfigurationError{error_code: :incorrect_error_level_detail}, :verbose) do
    """
    # Incorrect Error Level Detail Provided
    ## Summary
    `config.exs` contains a non-existent verbosity level for error messages.

    Valid options are:
    #{Utils.bullitize(Config.error_detail_levels())}

    ## Quick Fix
    Add following

    ## Details
    """
  end
end
