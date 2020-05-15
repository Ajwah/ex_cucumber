defmodule CucumberExpressions.Parser.ValidationError do
  @moduledoc false
  import Kernel, except: [raise: 2]
  defexception [:message, :violator, :error_code]

  @impl true
  def exception({msg, error_code, violator}) do
    struct(__MODULE__, %{
      message: msg,
      violator: violator,
      error_code: error_code
    })
  end

  def raise(msg, error_code, violator) do
    Kernel.raise(__MODULE__, {msg, error_code, violator})
  end
end
