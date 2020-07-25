defmodule ExCucumber.Exceptions.Messages.IncorrectMacroStyle do
  @moduledoc false
  alias ExCucumber.{
    Config,
    Exceptions.ConfigurationError,
    Utils
  }

  def render(%ConfigurationError{error_code: :incorrect_macro_style}, :brief) do
    """
    Valid options are: #{Config.macro_styles() |> Enum.join(", ")}
    """
  end

  def render(%ConfigurationError{error_code: :incorrect_macro_style}, :verbose) do
    """
    # Incorrect Macro Style Selected
    ## Summary
    `config.exs` contains a non-existent macro style

    Valid options are:
    #{Utils.bullitize(Config.macro_styles())}

    ## Quick Fix
    Add following

    ## Details
    """
  end
end
