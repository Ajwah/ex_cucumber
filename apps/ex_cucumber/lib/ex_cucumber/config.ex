defmodule ExCucumber.Config do
  @moduledoc false
  @macro_styles [:def, :module]
  @error_detail_levels [:brief, :verbose]

  @feature_dir Application.get_env(:ex_cucumber, :feature_dir)
  @project_root Application.get_env(:ex_cucumber, :project_root)
  @macro_style Application.get_env(:ex_cucumber, :macro_style, :module)
  @error_detail_level Application.get_env(:ex_cucumber, :error_detail_level, :module)

  def macro_styles, do: @macro_styles
  def macro_styles(:counterparts), do: Enum.reject(@macro_styles, &Kernel.==(&1, @macro_style))

  def error_detail_levels, do: @error_detail_levels
  def feature_dir, do: @feature_dir
  def project_root, do: @project_root
  def macro_style, do: @macro_style
  def macro_style(:counterpart), do: :counterparts |> macro_styles |> List.first
  def error_detail_level, do: @error_detail_level

  def feature_path(feature_file_name), do: "#{feature_dir()}/#{feature_file_name}"

  @after_compile __MODULE__

  defmacro __after_compile__(_, _) do
    quote do
      alias __MODULE__.ConfigurationError

      unless @macro_style in @macro_styles do
        ConfigurationError.raise(:incorrect_macro_style)
      end

      unless @error_detail_level in @error_detail_levels do
        ConfigurationError.raise(:incorrect_error_level_detail)
      end
    end
  end

end
