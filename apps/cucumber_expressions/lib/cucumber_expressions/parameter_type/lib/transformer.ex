defmodule CucumberExpressions.ParameterType.Transformer do
  @moduledoc false

  alias CucumberExpressions.ParameterType.SyntaxError

  @stages [:pre, :post]
  defstruct paradigm: {:atom, :atom, :integer},
            stage: @stages

  def new(a, stage \\ :pre)
  def new(nil, _), do: %{pre: nil, post: nil}
  def new(module, stage) when is_atom(module), do: new({module, :run, 2}, stage)
  def new({module, function}, stage), do: new({module, function, 2}, stage)

  def new(%{pre: pre, post: post}, _) do
    %{pre: new(pre, :pre).pre, post: new(post, :post).post}
  end

  def new(mfa = {module, function, arity}, stage) do
    Code.ensure_loaded(module)

    if :erlang.function_exported(module, function, arity) do
      if stage in @stages do
        %{
          flip_stage(stage) => nil,
          stage => struct(__MODULE__, %{paradigm: mfa, stage: stage})
        }
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

  def new(_, _) do
    raise_error("is invalid", :invalid)
  end

  defp flip_stage(:pre), do: :post
  defp flip_stage(:post), do: :pre

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

  def raise_error(msg, error_code = :incompatible_format) do
    """
    Transformer supplied for `ParameterType` #{msg}.
    Kindly return a tagged tuple:
      * {:ok, result}
      * {:error, error}
    """
    |> SyntaxError.raise(error_code)
  end

  def raise_error(msg, error_code) do
    """
    Transformer supplied for `ParameterType` #{msg}.
    Kindly specify a remote function:
    `{module, function, arity}` where arity is always `2`.
    """
    |> SyntaxError.raise(error_code)
  end
end
