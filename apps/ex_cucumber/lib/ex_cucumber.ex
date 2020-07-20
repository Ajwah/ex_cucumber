defmodule ExCucumber do
  @moduledoc """
  Documentation for ExCucumber.
  """

  alias CucumberExpressions.ParameterType
  use ExDebugger.Manual

  defmacro __using__(_) do
    quote location: :keep do
      import ExUnit.Assertions

      require ExCucumber.Gherkin.Keywords.Given
      require ExCucumber.Gherkin.Keywords.When
      require ExCucumber.Gherkin.Keywords.And
      require ExCucumber.Gherkin.Keywords.But
      require ExCucumber.Gherkin.Keywords.Then

      alias ExCucumber.Gherkin.Keywords, as: GherkinKeywords

      alias GherkinKeywords.{
        Given,
        When,
        And,
        But,
        Then
      }

      import unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :cucumber_expressions, accumulate: true)
      Module.register_attribute(__MODULE__, :meta, accumulate: false)
      Module.register_attribute(__MODULE__, :feature, accumulate: false)
      Module.register_attribute(__MODULE__, :custom_param_types, accumulate: false)

      Module.put_attribute(__MODULE__, :meta, %{})
      Module.put_attribute(__MODULE__, :custom_param_types, [])

      @before_compile unquote(__MODULE__)
      @after_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_) do
    quote location: :keep do
      @cucumber_expressions_parse_tree ExCucumber.CucumberExpression.parse(@cucumber_expressions)

      alias ExCucumber.Gherkin.Traverser.Ctx
      alias ExCucumber.Gherkin.Keywords, as: GherkinKeywords

      def execute_mfa(%Ctx{} = ctx, arg) do
        actual_gherkin_token_as_parsed_from_feature_file = ctx.token
        def_meta = @meta[ctx.extra.fun]

        gherkin_token_mismatch? =
          actual_gherkin_token_as_parsed_from_feature_file != def_meta.macro_usage_gherkin_keyword

        arg =
          if def_meta.has_arg? do
            [arg]
          else
            []
          end

        # dd({arg, @meta, ctx}, :execute_mfa)

        if ExCucumber.Config.best_practices().disallow_gherkin_token_usage_mismatch? &&
             gherkin_token_mismatch? do
          ExCucumber.Exceptions.UsageError.raise(
            Ctx.extra(ctx, %{
              def_line: def_meta.line,
              wrong_token: def_meta.macro_usage_gherkin_keyword
            }),
            :gherkin_token_mismatch
          )
        else
          {apply(__MODULE__, ctx.extra.fun, arg), def_meta}
        end
      end
    end
  end

  defmacro __after_compile__(env, _) do
    quote do
      custom_param_types = ExCucumber.CustomParameterType.Loader.run(@custom_param_types)

      @feature
      |> ExCucumber.Config.feature_path()
      |> ExCucumber.Gherkin.run(
        __MODULE__,
        unquote(Macro.escape(env)).file,
        @cucumber_expressions_parse_tree,
        custom_param_types
      )
    end
  end

  :macro_names
  |> ExCucumber.Gherkin.Keywords.mappings()
  |> Enum.each(fn {gherkin_keyword, macro_name} ->
    if ExCucumber.Gherkin.Keywords.macro_style?(:def) do
      defmacro unquote(macro_name)(cucumber_expression, arg, do: block) do
        ExCucumber.define_gherkin_keyword_macro(
          __CALLER__,
          unquote(gherkin_keyword),
          cucumber_expression,
          [arg],
          block
        )
      end

      defmacro unquote(macro_name)(cucumber_expression, do: block) do
        ExCucumber.define_gherkin_keyword_macro(
          __CALLER__,
          unquote(gherkin_keyword),
          cucumber_expression,
          nil,
          block
        )
      end
    else
      defmacro unquote(macro_name)(cucumber_expression, _arg, _) do
        ExCucumber.define_gherkin_keyword_mismatch_macro(
          __CALLER__,
          unquote(gherkin_keyword),
          cucumber_expression
        )
      end

      defmacro unquote(macro_name)(cucumber_expression, _arg) do
        ExCucumber.define_gherkin_keyword_mismatch_macro(
          __CALLER__,
          unquote(gherkin_keyword),
          cucumber_expression
        )
      end
    end
  end)

  def define_gherkin_keyword_macro(
        caller = %Macro.Env{},
        gherkin_keyword,
        cucumber_expression,
        arg,
        block
      ) do
    line = caller.line

    cucumber_expression =
      ExCucumber.CucumberExpression.new(cucumber_expression, caller, gherkin_keyword)

    func = cucumber_expression.meta.id
    has_arg? = arg != nil

    module_attrs_ast =
      quote bind_quoted: [
              cucumber_expression: Macro.escape(cucumber_expression),
              func: func,
              meta:
                Macro.escape(%{
                  has_arg?: has_arg?,
                  line: line,
                  macro_usage_gherkin_keyword: gherkin_keyword,
                  cucumber_expression: cucumber_expression
                })
            ] do
        @cucumber_expressions cucumber_expression
        @meta Map.put(@meta, func, meta)
      end

    def_ast =
      if has_arg? do
        quote do
          def unquote(func)(unquote_splicing(arg)), do: unquote(block)
        end
      else
        quote do
          def unquote(func)(), do: unquote(block)
        end
      end

    [module_attrs_ast, def_ast]
  end

  def define_gherkin_keyword_mismatch_macro(
        caller = %Macro.Env{},
        gherkin_keyword,
        cucumber_expression
      ) do
    quote bind_quoted: [
            caller: Macro.escape(caller),
            cucumber_expression: cucumber_expression,
            gherkin_keyword: gherkin_keyword
          ] do
      ctx =
        @feature
        |> ExCucumber.Config.feature_path()
        |> ExCucumber.Gherkin.Traverser.Ctx.new(
          caller.module,
          caller.file,
          ParameterType.new(),
          %{column: 0, line: caller.line},
          "",
          gherkin_keyword
        )
        |> ExCucumber.Gherkin.Traverser.Ctx.extra(%{cucumber_expression: cucumber_expression})

      ExCucumber.Exceptions.ConfigurationError.raise(ctx, :macro_style_mismatch)
    end
  end
end
