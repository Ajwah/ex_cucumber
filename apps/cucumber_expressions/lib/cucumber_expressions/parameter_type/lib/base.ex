defmodule CucumberExpressions.ParameterType.Base do
  @moduledoc false
  defmacro __using__(_) do
    quote location: :keep do
      alias CucumberExpressions.ParameterType.{
        Disambiguator,
        Transformer,
        Validator
      }

      defstruct [:name, :type, :disambiguator, :validator, :transformer, :opts]

      def new(input = %{name: _, type: _}) do
        disambiguator = Disambiguator.new(input[:disambiguator])
        validator = Validator.new(input[:validator])

        struct(__MODULE__, %{
          name: input.name,
          type: input.type,
          disambiguator: disambiguator,
          validator: validator,
          transformer: setup_transformer(input)
          # opts: input[:opts],
        })
      end

      def setup_transformer(input) do
        if transformer = Transformer.new(input[:transformer]) do
          %{transformer.stage => transformer}
        else
          %{pre: nil, post: nil}
        end
      end
    end
  end
end

# @name_type_description "%ParameterType{}.name is to be a string that encompasses a human friendly name"
# @type_type_description """
# %ParameterType{}.type represents the return type and is to be either a struct or either an atom for any of the simple
# types:
#   :integer
#   :string
#   :float
# """
# @validator_type_description """
# %ParameterType{}.validator is used to validate the parameter value that corresponds to a cucumber expression and
# is to be either a `%Regex{}` or either a remote function: `{module, function, arity}` where arity is always `2`.
# """
# @transformer_type_description """
# %ParameterType{}.transformer transforms the parameter value that corresponds to a cucumber expression to the desired
# return type as discussed under: %ParameterType{}.type
# This needs to be a remote function: `{module, function, arity}` where arity is always `2`.
# """
# @opts_type_description """
# %ParameterType{}.opts houses various user defined options and is to be supplied as a map with any of the following
# key(s):
#   * use_for_snippets: Defaults to true. That means this parameter type will be used to generate snippets for undefined steps.
#                       If the regexp frequently matches text you don't intend to be used as arguments, disable its use
#                       for snippets with false.
#   * prefer_for_regexp_match: Defaults to false. Set to true if you have step definitions that use regular expressions,
#                              and you want this parameter type to take precedence over others during a match.
# """

#
# @typedoc @name_type_description
# @type name :: binary
# def new(input = %{name: _, type: _}) do
#   with {_, true} <- {{:name, @name_type_description, :string}, is_binary(input.name)},
#     {_, true} <- {{:type, @type_type_description, :atom}, is_binary(input.type)},
#     {_, true} <- {{:validator, @validator_type_description, :atom}, input[:validator] || is_binary(input.validator)},
#     {_, true} <- {{:transformer, @transformer_type_description, :atom}, input[:transformer] || is_binary(input.transformer)},
#     {_, true} <- {{:opts, @opts_type_description, :atom}, input[:opts] || is_binary(input.opts)} do
#       struct(__MODULE__, input)
#   end
# end
