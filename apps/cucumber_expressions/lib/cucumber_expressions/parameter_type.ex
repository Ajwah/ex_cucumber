defmodule CucumberExpressions.ParameterType do
  @moduledoc false

  alias CucumberExpressions.ParameterType.{
    Disambiguator,
    Transformer,
    Validator
  }

  defstruct collection: %{}

  def new do
    struct(__MODULE__)
  end

  def new(input) do
    __MODULE__
    |> struct
    |> add(input)
  end

  def add(%__MODULE__{} = p, input) do
    custom_param_type = __MODULE__.Custom.new(input)

    %{p | collection: Map.put(p.collection, custom_param_type.name, custom_param_type)}
  end

  def run(collection, parameter_key, str, break_at_inoperative_disambiguator? \\ true)
  def run(_, :next_key, _, _), do: :reserved_keyword

  def run(collection, parameter_keys, str, true) when is_list(parameter_keys) do
    parameter_keys
    |> Enum.reduce_while(:common_juncture_params_without_disambiguator, fn parameter_key, _ ->
      collection
      |> run(parameter_key, str, true)
      |> case do
        ok = {:ok, _} -> {:halt, ok}
        rest -> {:cont, rest}
      end
    end)
  end

  def run(collection, parameter_key, str, break_at_inoperative_disambiguator?) do
    with {_, {:ok, parameter_type}} <-
           {:retrieve_parameter_type, Map.fetch(collection, parameter_key)},
         {_, {:ok, result = {_, _}}} <- disambiguate(parameter_type, str),
         {_, {:ok, result}, remainder_sentence} <-
           pre_transform(parameter_type, result, break_at_inoperative_disambiguator?),
         {_, {:ok, result}} <- validate(parameter_type, result) do
      if break_at_inoperative_disambiguator? do
        {:ok, {parameter_key, {result, remainder_sentence}}}
      else
        {:ok, {parameter_key, result}}
      end
    else
      {:retrieve_parameter_type, _} -> :parameter_type_not_present
      {failed_action, {:error, error}} -> {:error, failed_action, error}
      pipe_break -> pipe_break
    end
  end

  defp disambiguate(parameter_type, input) do
    action = :disambiguator

    result =
      parameter_type
      |> Map.fetch!(action)
      |> Disambiguator.run(input)

    {
      action,
      result
    }
  end

  defp pre_transform(
         parameter_type,
         {match, remainder_sentence},
         break_at_inoperative_disambiguator?
       ) do
    if break_at_inoperative_disambiguator? && remainder_sentence == :inoperative do
      :inoperative_disambiguator
    else
      result = transform(parameter_type, match, :pre)

      {
        :pre_transform,
        result,
        remainder_sentence
      }
    end
  end

  defp transform(parameter_type, match, transformer_stage) do
    action = :transformer

    parameter_type
    |> Map.fetch!(action)
    |> Map.fetch!(transformer_stage)
    |> Transformer.run(match)
  end

  defp validate(parameter_type, transformed) do
    action = :validator

    result =
      parameter_type
      |> Map.fetch!(action)
      |> Validator.run(transformed)

    {
      action,
      result
    }
  end
end
