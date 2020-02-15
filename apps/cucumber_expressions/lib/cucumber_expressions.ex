defmodule CucumberExpressions do
  @moduledoc """
  Kindly consult documentation for CucumberExpressions:
    * https://cucumber.io/docs/cucumber/cucumber-expressions/
    * https://cucumber.io/blog/open-source/announcing-cucumber-expressions/

  """

  alias __MODULE__.Parser

  @doc """
  Hello world.

  ## Examples

      iex> CucumberExpressions.hello()
      :world

  """
  def hello do
    :world
  end

  defdelegate parse(sentence, collected_sentences), to: Parser, as: :run
  defdelegate parse(sentence, collected_sentences, id), to: Parser, as: :run
end
