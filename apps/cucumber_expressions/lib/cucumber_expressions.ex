defmodule CucumberExpressions do
  @moduledoc """
  Kindly consult documentation for CucumberExpressions:
    * https://cucumber.io/docs/cucumber/cucumber-expressions/
    * https://cucumber.io/blog/open-source/announcing-cucumber-expressions/
  """

  alias __MODULE__.Parser
  alias Utils

  def parse(sentence, collected_sentences, id \\ Utils.id(:fixed)) do
    sentence
    |> Parser.run(collected_sentences, id)
    |> Parser.result()
  end
end
