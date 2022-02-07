defmodule ExCucumber.Utils do
  @moduledoc false
  def smart_quotes(s), do: "“#{s}”"

  def bullitize(ls, mode \\ :as_atoms, padding \\ "  ") do
    ls
    |> Enum.map(&"#{padding}* #{bulletize_mode(&1, mode)}")
    |> Enum.join("\n")
  end

  def atomize(s, option \\ :use_backticks)
  def atomize(s, :no_backticks), do: ":#{s}"
  def atomize(s, :use_backticks), do: s |> atomize(:no_backticks) |> backtick
  def backtick(s) when is_binary(s), do: "`#{s}`"
  defp bulletize_mode(item, :as_atoms), do: item |> atomize
  defp bulletize_mode(item, :as_smart_quoted_strings), do: smart_quotes(item)
  defp bulletize_mode(item, _), do: "#{item}"

  defmodule ProjectCompiler do
    @moduledoc false

    def reset_env(original_app_env, extra \\ []) do
      [{:ex_cucumber, original_app_env |> Keyword.merge(extra)}]
      |> Application.put_all_env()

      recompile(ExCucumber.Config)
      recompile(ExCucumber)
      recompile(ExCucumber.Gherkin.Keywords)
    end

    def recompile(ctx: ctx) do
      ctx.test_module
      |> Code.ensure_loaded()
      |> case do
        _ -> Code.compile_file(ctx.test_module_file)
      end
    end

    def recompile(module) when is_atom(module) do
      recompile(ctx: %{test_module: module, test_module_file: module.file_path()})
    end
  end
end
