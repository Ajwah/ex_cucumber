defmodule ExCucumber.Exceptions.Messages.InvalidFeatureDir do
  @moduledoc false
  alias ExCucumber.Exceptions.ConfigurationError
  alias ExCucumber.Exceptions.Messages.Common

  def render(%ConfigurationError{error_code: :invalid_feature_dir}, :brief) do
    """
    Ensure `feature_dir` has a valid value.
    """
  end

  def render(%ConfigurationError{error_code: :invalid_feature_dir} = e, :verbose) do
    IO.inspect(e.ctx)
    """
    # Invalid Value For Feature Directory Specified
    ## Summary
    `config.exs` contains a non-existent feature directory

    ## Quick Fix
    Add following to `config.exs`:
    #{Common.render(:config_option, :feature_dir, "some/path/to/your/feature/files")}

    ## Details
    The recommended location is `/features` under root of your `app`; not under `test` as this is a collaboration
    framework; not a testing framework. See: #{
      ExCucumber.DocumentationResources.link(:worlds_most_misunderstood_collaboration_tool)
    }
    """
  end
end
