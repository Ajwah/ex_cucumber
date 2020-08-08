defmodule Helpers.Assertions do
  defmacro assert_specific_raise(exception, error_code, function) do
    quote do
      try do
        unquote(function).()
      rescue
        # IO.inspect(raised_error, label: :raised_error)
        raised_error in [unquote(exception)] ->
          assert raised_error.error_code == unquote(error_code)

        e ->
          flunk(
            "Expected exception #{inspect(unquote(exception))} but #{inspect(e, pretty: true)} was raised instead"
          )
      else
        raised_error ->
          flunk("Expected exception #{inspect(unquote(exception))} but nothing was raised")
      end
    end
  end

  defmacro refute_raise(function) do
    quote do
      try do
        unquote(function).()
      rescue
        error ->
          flunk(
            "This is not supposed to raise yet it did: #{
              inspect(error, pretty: true, limit: :infinity)
            }"
          )
      end
    end
  end
end
