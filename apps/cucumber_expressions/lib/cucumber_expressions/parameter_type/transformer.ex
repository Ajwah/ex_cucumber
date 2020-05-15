defmodule CucumberExpressions.ParameterType.Transformer do
  @moduledoc false

  alias CucumberExpressions.ParameterType.SyntaxError

  @stages [:pre, :post]
  defstruct paradigm: {:atom, :atom, :integer},
            stage: @stages

  def new(nil), do: nil
  def new(module) when is_atom(module), do: new({module, :run, 2}, :pre)
  def new({module, function}), do: new({module, function, 2}, :pre)

  def new(_) do
    raise_error("is invalid", :invalid)
  end

  def new(mfa = {module, function, arity}, stage) do
    Code.ensure_loaded(module)

    if :erlang.function_exported(module, function, arity) do
      if stage in @stages do
        struct(__MODULE__, %{paradigm: mfa, stage: stage})
      else
        raise_error(
          "has an invalid stage: #{stage}. Valid ones are: #{inspect(@stages)}",
          :invalid_stage
        )
      end
    else
      raise_error("is non-existent", :non_existent)
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
          "returns an incompatible format: #{inspect(unknown_format)}",
          :incompatible_format
        )
    end
  end

  def run(nil, str), do: {:ok, str}

  def raise_error(error_description, error_code) do
    """
    Transformer supplied for `ParameterType` #{error_description}.
    Kindly specify a remote function:
    `{module, function, arity}` where arity is always `2`.
    """
    |> SyntaxError.raise(error_code)
  end
end
