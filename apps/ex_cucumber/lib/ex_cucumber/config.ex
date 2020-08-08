defmodule ExCucumber.Config do
  @moduledoc false
  @external_resource "config/config.exs"

  @macro_styles [:def, :module]
  @error_detail_levels [:brief, :verbose]
  @all_best_practices %{
    disallow_gherkin_token_usage_mismatch?: [true, false],
    enforce_context?: [true, false]
  }

  @full_env Application.get_all_env(:ex_cucumber)
  @feature_dir Application.get_env(:ex_cucumber, :feature_dir)
  @project_root Application.get_env(:ex_cucumber, :project_root)
  @macro_style Application.get_env(:ex_cucumber, :macro_style, :module)
  @error_detail_level Application.get_env(:ex_cucumber, :error_detail_level)
  @best_practices Application.get_env(:ex_cucumber, :best_practices, %{})

  alias ExCucumber.Exceptions.ConfigurationError
  use ExDebugger.Manual

  def default_env, do: example_env(project_root: File.cwd!(), feature_dir: "features")

  def example_env(project_root: project_root, feature_dir: feature_dir) do
    [
      macro_style: :module,
      error_detail_level: :brief,
      best_practices: %{disallow_gherkin_token_usage_mismatch?: true, enforce_context?: false},
      feature_dir: "#{project_root}/#{feature_dir}",
      project_root: project_root
    ]
  end

  def current_env, do: @full_env
  def macro_styles, do: @macro_styles
  def macro_styles(:counterparts), do: Enum.reject(@macro_styles, &Kernel.==(&1, @macro_style))

  def error_detail_levels, do: @error_detail_levels
  def feature_dir, do: @feature_dir
  def project_root, do: @project_root
  def macro_style, do: @macro_style
  def macro_style(:counterpart), do: :counterparts |> macro_styles |> List.first()
  def error_detail_level, do: @error_detail_level

  def all_best_practices, do: @all_best_practices
  def best_practices, do: @best_practices

  def feature_path(nil),
    do: ConfigurationError.raise(%{supplied: nil}, :feature_attribute_missing)

  def feature_path(feature_file_name) when is_binary(feature_file_name) do
    full_feature_path = "#{feature_dir()}/#{feature_file_name}"
    dd(:feature_path)

    if File.exists?(full_feature_path) do
      full_feature_path
    else
      ConfigurationError.raise(%{supplied: full_feature_path}, :feature_file_not_found)
    end
  end

  @after_compile __MODULE__

  defmacro __after_compile__(_, _) do
    quote do
      unless File.dir?(to_string(@feature_dir)) do
        ConfigurationError.raise(%{supplied: @feature_dir}, :invalid_feature_dir)
      end

      unless File.dir?(to_string(@project_root)) do
        ConfigurationError.raise(%{supplied: @project_root}, :invalid_project_root)
      end

      unless @macro_style in @macro_styles do
        ConfigurationError.raise(:incorrect_macro_style)
      end

      unless @error_detail_level in @error_detail_levels do
        ConfigurationError.raise(:incorrect_error_level_detail)
      end

      if is_map(@best_practices) do
        @best_practices
        |> Enum.reject(fn {key, value} ->
          Map.has_key?(@all_best_practices, key) && value in Map.fetch!(@all_best_practices, key)
        end)
        |> Kernel.==([])
        |> case do
          true -> :ok
          false -> ConfigurationError.raise(@best_practices, :best_practices_incomplete)
        end
      else
        ConfigurationError.raise(@best_practices, :best_practices_incomplete)
      end
    end
  end
end
