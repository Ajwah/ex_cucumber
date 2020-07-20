defmodule CucumberExpressions.ParameterType.SyntaxError do
  @moduledoc false
  import Kernel, except: [raise: 2]
  defexception [:message, :error_code]

  @impl true
  def exception({msg, error_code}) do
    struct(__MODULE__, %{
      message: msg,
      error_code: error_code
    })
  end

  def raise(msg, error_code) do
    Kernel.raise(__MODULE__, {msg, error_code})
  end
end
