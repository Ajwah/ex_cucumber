defmodule CucumberExpressions do
  @moduledoc """
  Kindly consult documentation for CucumberExpressions:
    * https://cucumber.io/docs/cucumber/cucumber-expressions/
    * https://cucumber.io/blog/open-source/announcing-cucumber-expressions/
  """

  alias __MODULE__.Parser
  alias Utils

  def parse(sentence, collected_sentences, id \\ Utils.id(:fixed))

  def parse(sentence, nil, id), do: parse(sentence, %{}, id)

  def parse(sentence, %CucumberExpressions.Parser{result: result}, id),
    do: parse(sentence, result, id)

  # def parse(sentences, collected_sentences, id) when is_list(sentences) do
  #   sentences
  #   |> Enum.
  #   |> Parser.run(collected_sentences, id)
  #   |> Parser.result()
  # end
  def parse(sentence, collected_sentences, id) do
    sentence
    |> Parser.run(collected_sentences, id)
    |> Parser.result()
  end
end
