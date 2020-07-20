defmodule ExCucumber.Exceptions.Messages.InvalidProjectRoot do
  @moduledoc false
  alias ExCucumber.Exceptions.ConfigurationError
  alias ExCucumber.Exceptions.Messages.Common

  def render(%ConfigurationError{error_code: :invalid_project_root}, :brief) do
    """
    Ensure `project_root` has a valid value.
    """
  end

  def render(%ConfigurationError{error_code: :invalid_project_root}, :verbose) do
    """
    # Invalid Value For Project Root Specified
    ## Summary
    `config.exs` contains a non-existent project root directory

    ## Quick Fix
    Add following to `config.exs`:
    #{Common.render(:config_option, :project_root, "/your/project/root/path")}
    """
  end
end
