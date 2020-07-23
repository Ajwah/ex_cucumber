defmodule CucumberExpressions do
  @moduledoc """
  This is mainly published for other packages within the cucumber eco-system
  to take benefit from; which are currently not that many. As such, the
  usage of this library is not being expanded upon for the time being.

  For general understanding as what Cucumber Expressions are and how
  you can use them within the context of [ExCucumber](); kindly consult
  the README.
  """

  alias __MODULE__.{
    Parser,
    Utils
  }

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
