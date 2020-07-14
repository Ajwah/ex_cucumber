defmodule ExCucumber do
  @moduledoc """
  Documentation for ExCucumber.
  """
  defmacro __using__(_) do
    quote do
      require ExCucumber.Gherkin.Keywords.Given
      alias ExCucumber.Gherkin.Keywords.Given
      require ExCucumber.Gherkin.Keywords.When
      alias ExCucumber.Gherkin.Keywords.When
      require ExCucumber.Gherkin.Keywords.And
      alias ExCucumber.Gherkin.Keywords.And
      require ExCucumber.Gherkin.Keywords.But
      alias ExCucumber.Gherkin.Keywords.But
      require ExCucumber.Gherkin.Keywords.Then
      alias ExCucumber.Gherkin.Keywords.Then

      def execute_mfa(<<"has_arg", _rest::binary>>, fun, arg) do
        apply(__MODULE__, fun, [arg])
      end

      def execute_mfa(_, fun, arg) do
        apply(__MODULE__, fun, [])
      end

      import unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :cucumber_expressions, accumulate: true)

      @before_compile unquote(__MODULE__)
      @after_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_) do
    quote do
      @cucumber_expressions_parse_tree ExCucumber.CucumberExpression.parse(@cucumber_expressions)
    end
  end

  defmacro __after_compile__(env, _) do
    quote do
      @feature
      |> ExCucumber.Config.feature_path
      |> ExCucumber.Gherkin.run(__MODULE__, unquote(Macro.escape(env)).file, @cucumber_expressions_parse_tree)
    end
  end

  :macro_names
  |> ExCucumber.Gherkin.Keywords.mappings
  |> Enum.each(fn {gherkin_keyword, macro_name} ->
    if ExCucumber.Gherkin.Keywords.macro_style?(:def) do
      defmacro unquote(macro_name)(cucumber_expression, arg, do: block) do
        ExCucumber.define_gherkin_keyword_macro(__CALLER__, unquote(gherkin_keyword), cucumber_expression, [arg], block)
      end

      defmacro unquote(macro_name)(cucumber_expression, do: block) do
        ExCucumber.define_gherkin_keyword_macro(__CALLER__, unquote(gherkin_keyword), cucumber_expression, nil, block)
      end

    else
      defmacro unquote(macro_name)(cucumber_expression, _arg, _) do
        ExCucumber.define_gherkin_keyword_mismatch_macro(__CALLER__, unquote(gherkin_keyword), cucumber_expression)
      end
    end
  end)

  def define_gherkin_keyword_macro(caller = %Macro.Env{}, gherkin_keyword, cucumber_expression, arg, block) do
    if arg == nil do
      cucumber_expression = ExCucumber.CucumberExpression.new(cucumber_expression, caller, gherkin_keyword)
      func = cucumber_expression.meta.id

      quote do
        @cucumber_expressions unquote(Macro.escape(cucumber_expression))
        def unquote(func)(), do: unquote(block)
      end

    else
      cucumber_expression = ExCucumber.CucumberExpression.new(cucumber_expression, caller, gherkin_keyword, "has_arg")
      func = cucumber_expression.meta.id

      quote do
        @cucumber_expressions unquote(Macro.escape(cucumber_expression))
        def unquote(func)(unquote_splicing(arg)), do: unquote(block)
      end

    end
  end

  def define_gherkin_keyword_mismatch_macro(caller = %Macro.Env{}, gherkin_keyword, cucumber_expression) do
    quote bind_quoted: [caller: Macro.escape(caller), cucumber_expression: cucumber_expression, gherkin_keyword: gherkin_keyword] do

      @feature
      |> ExCucumber.Config.feature_path
      |> ExCucumber.Gherkin.Traverser.Ctx.new(caller.module, caller.file, %{column: 0, line: caller.line}, "", gherkin_keyword)
      |> ExCucumber.Gherkin.Traverser.Ctx.extra(%{cucumber_expression: cucumber_expression})
      |> ExCucumber.Config.ConfigurationError.raise(:macro_style_mismatch)
    end
  end
end
