defmodule ExCucumber.Failure.Messages.Common do
  @moduledoc false
  alias ExCucumber.Gherkin.Keywords, as: GherkinKeywords
  alias ExCucumber.Gherkin.Traverser.Ctx

  def render(:macro_usage, %Ctx{} = ctx, cucumber_expression) do
    if macro_style = ctx.extra[:macro_style] do
      """
      ```elixir
      #{GherkinKeywords.macro_name(ctx, macro_style)} "#{cucumber_expression}", arg do
      end
      ```
      """
    else
      """
      ```elixir
      #{GherkinKeywords.macro_name(ctx)} "#{cucumber_expression}", arg do
      end
      ```
      """
    end
  end

  def render(:config_option, key, value) do
    """
    ```elixir
    config :ex_cucumber,
      #{key}: #{value}
    ```
    """
  end

  def render(:feature_file, %Ctx{} = ctx) do
    """
    `#{Exception.format_file_line(ctx.feature_file, ctx.location.line, ctx.location.column)}`
    """
  end

  def render(:module_file, %Ctx{} = ctx) do
    """
    `#{Exception.format_file_line(ctx.module_file, ctx.location.line, ctx.location.column)}`
    """
  end
end
