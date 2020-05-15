defmodule CucumberExpressions.ParameterType.Validator do
  @moduledoc false

  alias CucumberExpressions.ParameterType.SyntaxError
  defstruct paradigm: [%Regex{}, {:atom, :atom, :integer}]

  def new(nil), do: nil

  def new(r = %Regex{}) do
    struct(__MODULE__, %{paradigm: r})
  end

  def new(module) when is_atom(module), do: new({module, :run, 2})
  def new({module, function}), do: new({module, function, 2})

  def new(mfa = {module, function, arity}) do
    Code.ensure_loaded(module)

    if :erlang.function_exported(module, function, arity) do
      struct(__MODULE__, %{paradigm: mfa})
    else
      raise_error("non-existent", :non_existent)
    end
  end

  def new(_) do
    raise_error("invalid", :invalid)
  end

  def run(%__MODULE__{paradigm: %Regex{} = r}, str) do
    if Regex.match?(r, str) do
      {:ok, str}
    else
      {:error, {:regex_mismatch, {r, str}}}
    end
  end

  def run(%__MODULE__{paradigm: {module, function, 2}}, str) do
    module
    |> apply(function, [str, :ctx])
    |> case do
      ok = {:ok, _} ->
        ok

      error = {:error, _} ->
        error

      unknown_format ->
        raise_error(
          "returning an incompatible format: #{inspect(unknown_format)}",
          :incompatible_format
        )
    end
  end

  def run(nil, str), do: {:ok, str}

  def raise_error(error_description, error_code) do
    """
    Validator supplied for `ParameterType` is #{error_description}.
    Kindly specify either a `%Regex{}` or either a remote function:
    `{module, function, arity}` where arity is always `2`.

    The first argument to validate the parameter value.
    The second argument for additional context.

    The return value a tuple:
      * {:ok, str}
      * {:error, {error_code, _}}
    """
    |> SyntaxError.raise(error_code)
  end
end
