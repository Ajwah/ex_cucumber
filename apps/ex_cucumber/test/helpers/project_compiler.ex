defmodule Helpers.ProjectCompiler do
  @moduledoc false

  def reset_env(original_app_env, extra \\ []) do
    [{:ex_cucumber, original_app_env |> Keyword.merge(extra)}]
    |> Application.put_all_env()

    IEx.Helpers.r(ExCucumber.Config)
    IEx.Helpers.r(ExCucumber)
    IEx.Helpers.r(ExCucumber.Gherkin.Keywords)
  end

  def recompile(ctx) do
    ctx.test_module
    |> Code.ensure_loaded()
    |> case do
      {:error, :nofile} -> Code.compile_file(ctx.test_module_file)
      _ -> IEx.Helpers.r(ctx.test_module)
    end
  end
end
