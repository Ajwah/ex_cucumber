defmodule CucumberExpressions.Parser.SyntaxError do
  @moduledoc false
  import Kernel, except: [raise: 2]
  defexception [:message, :full_sentence, :error_code]

  @impl true
  def exception({msg, error_code, full_sentence}) do
    struct(__MODULE__, %{
      message: msg,
      full_sentence: full_sentence,
      error_code: error_code
    })
  end

  def raise(msg, error_code, full_sentence) do
    Kernel.raise(__MODULE__, {msg, error_code, full_sentence})
  end
end
