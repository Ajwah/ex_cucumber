defmodule ExCucumber.Exceptions.MatchFailure do
  @moduledoc false
  import Kernel, except: [raise: 2]
  alias ExCucumber.Exceptions.Messages
  alias CucumberExpressions.Matcher.Failure

  defexception error_code: "",
               extra: %{},
               ctx: %{}

  @impl true
  def exception({error_code, extra, ctx}) do
    struct(__MODULE__, %{
      error_code: error_code,
      extra: extra,
      ctx: ctx
    })
  end

  @impl true
  def message(%__MODULE__{} = e) do
    Messages.render(e)
  end

  def reraise(%Failure{} = f) do
    Kernel.raise(__MODULE__, {f.error_code, f.extra, f.ctx})
  end
end
