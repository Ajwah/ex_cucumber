defmodule ExCucumber.Gherkin.Keywords do
  @moduledoc false
  @external_resource "config/config.exs"
  
  alias ExCucumber.Gherkin.Traverser.Ctx
  alias ExCucumber.Config

  @mappings %{
    macro_names: %{
      given: :defgiven,
      when: :defwhen,
      and: :defand,
      but: :defbut,
      then: :defthen
    },
    modularized_macro_names: %{
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

  def extract(<<"given", _::binary>>), do: :given
  def extract(<<"when", _::binary>>), do: :when
  def extract(<<"and", _::binary>>), do: :and
  def extract(<<"but", _::binary>>), do: :but
  def extract(<<"then", _::binary>>), do: :then

  def extract(s),
    do: raise("Developer Error: This is impossible. Unable to extract Gherkin Keyword from: #{s}")

  def macro_style?(macro_style), do: Config.macro_style() == macro_style

  def section do
    Config.macro_style()
    |> case do
      :def -> :macro_names
      :module -> :modularized_macro_names
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
      :macro_names -> name_so_far
      :modularized_macro_names -> "#{name_so_far}._"
    end
  end

  @after_compile __MODULE__

  defmacro __after_compile__(_, _) do
    quote do
      :modularized_macro_names
      |> ExCucumber.Gherkin.Keywords.mappings()
      |> Enum.each(fn {gherkin_keyword, module_name} ->
        ast =
          if ExCucumber.Gherkin.Keywords.macro_style?(:module) do
            quote do
              def a, do: 1

              defmacro _(cucumber_expression, arg, do: block) do
                ExCucumber.define_gherkin_keyword_macro(
                  __CALLER__,
                  unquote(gherkin_keyword),
                  cucumber_expression,
                  [arg],
                  block
                )
              end

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
            quote do
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
