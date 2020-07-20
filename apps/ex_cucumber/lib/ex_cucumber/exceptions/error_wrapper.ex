defmodule ExCucumber.Exceptions.ErrorWrapper do
  @moduledoc false
  import Kernel, except: [raise: 2]
  alias ExCucumber.Exceptions.Messages

  defexception exception: %{}

  @impl true
  def exception(exception) do
    struct(__MODULE__, %{
      exception: exception
    })
  end
end
