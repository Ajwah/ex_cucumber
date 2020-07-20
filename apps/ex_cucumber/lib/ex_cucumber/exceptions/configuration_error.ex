defmodule ExCucumber.Exceptions.ConfigurationError do
  @moduledoc false
  import Kernel, except: [raise: 2]
  alias ExCucumber.Exceptions.Messages

  defexception error_code: "",
               ctx: %{}

  @impl true
  def exception({error_code, ctx}) do
    struct(__MODULE__, %{
      error_code: error_code,
      ctx: ctx
    })
  end

  @impl true
  def message(%__MODULE__{} = e) do
    Messages.render(e)
  end

  def raise(error_code) do
    Kernel.raise(__MODULE__, {error_code, nil})
  end

  def raise(ctx, error_code) do
    Kernel.raise(__MODULE__, {error_code, ctx})
  end
end
