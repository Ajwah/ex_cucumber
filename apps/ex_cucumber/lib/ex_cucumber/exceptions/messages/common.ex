defmodule ExCucumber.Exceptions.Messages.Common do
  @moduledoc false
  alias ExCucumber.Gherkin.Keywords, as: GherkinKeywords
  alias ExCucumber.Gherkin.Traverser.Ctx

  @opts [
    limit: :infinity,
    printable_limit: :infinity,
    pretty: true,
    width: 120,
    syntax_colors: [
      atom: :light_blue,
      binary: :green,
      boolean: :light_blue,
      list: :blink_rapid,
      map: :yellow,
      number: :magenta,
      regex: :blue,
      string: :green,
      tuple: :cyan
    ]
  ]

  # ARITY 2
  def render(:code_block, str) when is_binary(str) do
    """
    ```elixir
    #{str}
    ```
    """
  end

  def render(:code_block, any) do
    """
    ```elixir
    #{inspect(any, @opts)}
    ```
    """
  end

  def render(:feature_file, %Ctx{} = ctx) do
    """
    `#{Exception.format_file_line(ctx.feature_file, ctx.location.line, ctx.location.column)}`
    """
  end

  def render(:module_file, %Ctx{} = ctx),
    do: render(:module_file, ctx.module_file, ctx.location.line, ctx.location.column)

  # ARITY 3
  def render(:macro_usage_heading, %Ctx{} = ctx, cucumber_expression) do
    if macro_style = ctx.extra[:macro_style] do
      """
      #{GherkinKeywords.macro_name(ctx, macro_style)} "#{cucumber_expression}", arg do
      """
    else
      """
      #{GherkinKeywords.macro_name(ctx)} "#{cucumber_expression}", arg do
      """
    end
  end

  def render(:macro_usage, %Ctx{} = ctx, cucumber_expression) do
    r = """
    #{render(:macro_usage_heading, ctx, cucumber_expression)}
    end
    """

    render(:code_block, r)
  end

  def render(:config_option, key, value) do
    r = """
    config :ex_cucumber,
      #{key}: #{inspect(value, pretty: true)}
    """

    render(:code_block, r)
  end

  # ARITY 4
  def render(:module_file, module_file, line, column) do
    """
    `#{Exception.format_file_line(module_file, line, column)}`
    """
  end
end
