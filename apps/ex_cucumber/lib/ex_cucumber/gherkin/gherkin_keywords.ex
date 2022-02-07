defmodule ExCucumber.Gherkin.Keywords do
  @moduledoc false
  @external_resource "config/config.exs"

  alias ExCucumber.Gherkin.Traverser.Ctx
  alias ExCucumber.Config

  @mappings %{
    context_macros: %{
      regular: [
        :background,
        :scenario,
        :rule
      ],
      module_based: [
        background: __MODULE__.Background,
        scenario: __MODULE__.Scenario,
        rule: __MODULE__.Rule
      ]
    },
    def_based_gwt_macros: %{
      given: :defgiven,
      when: :defwhen,
      and: :defand,
      but: :defbut,
      then: :defthen
    },
    module_based_gwt_macros: %{
      given: __MODULE__.Given,
      when: __MODULE__.When,
      and: __MODULE__.And,
      but: __MODULE__.But,
      then: __MODULE__.Then
    },
    example_phrases: [
      given: "there are 3 ninjas",
      and: "there are more than one ninja alive",
      when: "2 ninjas meet, they will fight",
      then: "one ninja dies",
      but: "not me"
    ]
  }

  def file_path, do: "#{__DIR__}/gherkin_keywords.ex"

  def macro_style?(macro_style), do: Config.macro_style() == macro_style

  def section do
    Config.macro_style()
    |> case do
      :def -> :def_based_gwt_macros
      :module -> :module_based_gwt_macros
    end
  end

  def mappings, do: @mappings
  def mappings(section) when is_atom(section), do: @mappings |> Map.fetch!(section)

  def mappings(section_or_ctx, option \\ :discard_section)

  def mappings(%Ctx{} = ctx, option) do
    section = section()

    if option == :discard_section do
      mappings(section, ctx.token)
    else
      {section, mappings(section, ctx.token)}
    end
  end

  def mappings(section, keyword), do: section |> mappings |> Map.fetch!(keyword)

  def macro_name(%Ctx{} = ctx), do: macro_name(ctx, section())

  def macro_name(%Ctx{} = ctx, section) do
    mapping = mappings(section, ctx.token)

    name_so_far =
      mapping
      |> to_string
      |> String.split(".")
      |> List.last()

    section
    |> case do
      :def_based_gwt_macros -> name_so_far
      :module_based_gwt_macros -> "#{name_so_far}._"
    end
  end

  @after_compile __MODULE__

  defmacro __after_compile__(_, _) do
    quote location: :keep do
      :context_macros
      |> ExCucumber.Gherkin.Keywords.mappings()
      |> Map.fetch!(:module_based)
      |> Enum.each(fn {macro_ref, module_name} ->
        ast =
          quote location: :keep do
            @moduledoc false

            @doc false
            defmacro _(do: block) do
              ExCucumber.define_context_macro(
                __CALLER__,
                unquote(macro_ref),
                :no_title,
                nil,
                block
              )
            end

            @doc false
            defmacro _(title, do: block) do
              ExCucumber.define_context_macro(
                __CALLER__,
                unquote(macro_ref),
                title,
                nil,
                block
              )
            end
          end

        Module.create(module_name, ast, Macro.Env.location(__ENV__))
      end)

      :module_based_gwt_macros
      |> ExCucumber.Gherkin.Keywords.mappings()
      |> Enum.each(fn {gherkin_keyword, module_name} ->
        ast =
          if ExCucumber.Gherkin.Keywords.macro_style?(:module) do
            quote location: :keep do
              @moduledoc false

              @doc false
              defmacro _(cucumber_expression, arg, do: block) do
                ExCucumber.define_gherkin_keyword_macro(
                  __CALLER__,
                  unquote(gherkin_keyword),
                  cucumber_expression,
                  [arg],
                  block
                )
              end

              @doc false
              defmacro _(cucumber_expression, do: block) do
                ExCucumber.define_gherkin_keyword_macro(
                  __CALLER__,
                  unquote(gherkin_keyword),
                  cucumber_expression,
                  nil,
                  block
                )
              end
            end
          else
            quote location: :keep do
              defmacro _(cucumber_expression, _, _) do
                ExCucumber.define_gherkin_keyword_mismatch_macro(
                  __CALLER__,
                  unquote(gherkin_keyword),
                  cucumber_expression
                )
              end

              defmacro _(cucumber_expression, _) do
                ExCucumber.define_gherkin_keyword_mismatch_macro(
                  __CALLER__,
                  unquote(gherkin_keyword),
                  cucumber_expression
                )
              end
            end
          end

        Module.create(module_name, ast, Macro.Env.location(__ENV__))
      end)
    end
  end
end
