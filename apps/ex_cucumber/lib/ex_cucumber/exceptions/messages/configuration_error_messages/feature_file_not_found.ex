defmodule ExCucumber.Exceptions.Messages.FeatureFileNotFound do
  @moduledoc false
  alias ExCucumber.Exceptions.ConfigurationError
  alias ExCucumber.Exceptions.Messages.Common

  def render(%ConfigurationError{error_code: :feature_file_not_found}, :brief) do
    """
    `@feature` pointing to non existent file
    """
  end

  def render(%ConfigurationError{error_code: :feature_file_not_found}, :verbose) do
    """
    # Feature File Not Found
    ## Summary
    Module requires `@feature` attribute pointing to an existent feature-file.

    ## Quick Fix
    Add `@feature` attribute like so:
    ```elixir
    defmodule IsItFridayYetOrSomeOtherDescriptiveName do
      @feature "is_it_friday_yet.feature"
    end
    ```

    ## Details
    The module attribute `@feature` together with the configuration option `feature_dir`
    under `config.exs` make up the full path to the feature file `ExCucumber` is to use
    to drive the desired implemented behaviour as defined in your `module`. For instance,
    if the full path of the feature file is:
    `/Users/ubuntu/amazing_elixir_project/features/is_it_friday_yet.feature`; then
    `feature_dir` would be configured to:
    #{Common.render(:config_option, :feature_dir, "\"\#{File.cwd!()}/features\"")}

    and the module attribute as above.
    """
  end
end
