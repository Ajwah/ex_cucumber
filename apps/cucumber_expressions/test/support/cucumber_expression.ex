defmodule Support.CucumberExpression do
  @moduledoc false
  defstruct expression: "",
            template: "",
            template_to_expression_diff: [],
            instances: [],
            params_list: []

  import ExUnit.Assertions

  def prepare_all(test_data) do
    test_data
    |> Enum.reduce(%{all: []}, fn {name, cucumber_expr, params}, a ->
      a
      |> Map.put(name, Support.CucumberExpression.new(cucumber_expr, params))
      |> Map.put(:all, [cucumber_expr | a.all])
    end)
  end

  def new(expression, [hd | _] = params_list) when is_binary(expression) and is_list(hd) do
    template = template(expression, hd)
    template_to_expression_diff = String.myers_difference(template, expression)

    struct(__MODULE__, %{
      expression: expression,
      template: template,
      template_to_expression_diff: template_to_expression_diff,
      instances: instances(expression, params_list, {template, template_to_expression_diff}),
      params_list: params_list
    })
  end

  def new(expression, parameters) when is_binary(expression) and is_list(parameters) do
    new(expression, [parameters])
  end

  def template(expression, parameters) when is_binary(expression) and is_list(parameters) do
    parameters
    |> Enum.reduce({1, expression}, fn {k, _}, {counter, template} ->
      parameter_type_to_replace = custom_parameter_type(k)
      replacement = placeholder(counter)

      {counter + 1, String.replace(template, parameter_type_to_replace, replacement)}
    end)
    |> elem(1)
  end

  def instances(expression, [hd | _] = params_list, template_to_expression_diff)
      when is_binary(expression) and is_list(hd) do
    params_list
    |> Enum.map(&instance(expression, &1, template_to_expression_diff))
    |> alternatives
  end

  def instance(expression, parameters, {template, template_to_expression_diff})
      when is_binary(expression) and is_list(parameters) do
    instance =
      parameters
      |> Enum.reduce(expression, fn {k, v}, instantiated_cucumber_expression ->
        parameter_type_to_replace = custom_parameter_type(k)
        replacement = value(v)

        String.replace(instantiated_cucumber_expression, parameter_type_to_replace, replacement,
          global: false
        )
      end)

    template_to_instance_diff = String.myers_difference(template, instance)

    if Enum.count(template_to_expression_diff) != Enum.count(template_to_instance_diff) do
      IO.inspect(
        %{
          expression: expression,
          template: template,
          instance: instance,
          template_to_expression_diff: template_to_expression_diff,
          template_to_instance_diff: template_to_instance_diff
        },
        label: :should_be_eql_length
      )

      assert Enum.count(template_to_expression_diff) == Enum.count(template_to_instance_diff)
    end

    inferred_params =
      [
        template_to_expression_diff,
        template_to_instance_diff
      ]
      |> List.zip()
      |> Enum.reject(fn {a, b} -> a == b end)
      |> Enum.map(fn {{:ins, parameter_type}, {:ins, value}} ->
        {parameter_name(parameter_type), value}
      end)

    assert Enum.map(parameters, fn {k, v} -> {k, to_string(v)} end) == inferred_params

    %{
      parameters: %{
        original: parameters,
        inferred: inferred_params,
        both: [parameters, inferred_params]
      },
      instance: instance
    }
  end

  def alternatives(instances) do
    instances
    |> Enum.reduce([], fn %{parameters: ps, instance: instance}, a ->
      instance
      |> optionals_to_alternatives
      |> String.split()
      |> Enum.map(&String.split(&1, "/"))
      |> Enum.reduce([[]], fn
        e, a when is_binary(e) ->
          Enum.map(a, &Kernel.++(&1, [e]))

        ls, a when is_list(ls) ->
          Enum.reduce(a, [], fn growing_list, growing_lists ->
            Enum.map(ls, &Kernel.++(growing_list, [&1])) ++ growing_lists
          end)
      end)
      |> Enum.map(&Enum.join(&1, " "))
      |> Enum.map(&%{parameters: ps, instance: &1})
      |> Kernel.++(a)
    end)
  end

  # Modify "X(s) A B(s) C" -> "X/Xs A B/Bs C"
  def optionals_to_alternatives(instance) do
    String.replace(instance, ~r/([a-zA-Z0-9]*)\(s\)/, "\\1\/\\1s")
  end

  defp placeholder(_), do: "%"
  # defp placeholder(counter), do: "%#{counter}"
  defp value(v), do: "#{v}"
  defp custom_parameter_type(parameter_name), do: "{#{parameter_name}}"

  defp parameter_name(<<"{", remainder::binary>>),
    do: String.trim_trailing(remainder, "}") |> String.to_atom()
end
