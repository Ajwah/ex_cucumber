ExUnit.start()

defmodule TestHelper do
  defmacro assert_specific_raise(exception, error_code, function) do
    quote do
      try do
        unquote(function).()
      rescue
        raised_error in [unquote(exception)] ->
          assert raised_error.error_code == unquote(error_code)

        error ->
          raise error
      else
        _ -> flunk("Expected exception #{inspect(unquote(exception))} but nothing was raised")
      end
    end
  end
end
