defmodule ExCucumber.CustomParameterType do
  @moduledoc """

  """

  @callback disambiguator :: Regex.t()
  @callback pre_transformer(any, any) :: {:ok, any} | {:error, any}
  @callback validator :: Regex.t()
  @callback validator(any, any) :: {:ok, any} | {:error, any}
  @callback post_transformer(any, any) :: {:ok, any} | {:error, any}

  @optional_callbacks disambiguator: 0,
                      pre_transformer: 2,
                      validator: 0,
                      validator: 2,
                      post_transformer: 2
  @doc false
  def all_callbacks, do: @optional_callbacks |> List.first()

  defmodule Loader do
    @moduledoc false

    alias CucumberExpressions.ParameterType

    def run([]), do: ParameterType.new()

    def run(custom_params) when is_list(custom_params) do
      all_callbacks = MapSet.new(ExCucumber.CustomParameterType.all_callbacks())

      custom_params
      |> Enum.reduce(ParameterType.new(), fn {name, module}, acc ->
        cs = MapSet.new(module.__info__(:functions))

        built_map =
          all_callbacks
          |> MapSet.intersection(cs)
          |> MapSet.to_list()
          |> validate
          |> build(module, name, :any)

        ParameterType.add(acc, built_map)
      end)
    end

    def run(_incorrect_value), do: raise("Incorrect Param")

    defp validate([]), do: raise("At least one callback needs to be implemented")

    defp validate(ls) do
      callbacks = Enum.map(ls, &elem(&1, 0))

      callbacks
      |> Enum.uniq()
      |> Kernel.==(callbacks)
      |> case do
        true ->
          ls

        false ->
          raise "Ambiguity: Same callback has been implemented multiple times. #{inspect(ls)}"
      end
    end

    defp build(ls, module, name, type) do
      ls
      |> Enum.reduce(%{name: name, type: type}, fn
        {callback, 0}, a ->
          Map.put(a, callback, apply(module, callback, []))

        {:validator, 2}, a ->
          Map.put(a, :validator, {module, :validator})

        {:pre_transformer, 2}, a ->
          Map.update(a, :transformer, %{pre: {module, :pre_transformer}, post: nil}, fn e ->
            %{pre: {module, :pre_transformer}, post: e.post}
          end)

        {:post_transformer, 2}, a ->
          Map.update(a, :transformer, %{post: {module, :post_transformer}, pre: nil}, fn e ->
            %{post: {module, :post_transformer}, pre: e.pre}
          end)
      end)
    end
  end
end
