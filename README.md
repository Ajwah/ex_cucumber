# ExCucumber

STATUS: BETA Release
Currently I am using in my projects and cleaning up bugs as I go along.

An `Elixir` implemenation of the `Cucumber` framework to facilitate
[Behaviour-Driven Development(BDD)](https://cucumber.io/docs/bdd/)

For those who are not familiar with such a [collaboration tool](https://cucumber.io/blog/collaboration/the-worlds-most-misunderstood-collaboration-tool); kindly
consult [the official website](https://cucumber.io/docs/guides/10-minute-tutorial/)

Feature files are parsed with [ExGherkin](https://github.com/Ajwah/ex-gherkin)

This implementation uses `Cucumber Expressions` as opposed to `Regex`.
For those who are not familiar with `Cucumber Expressions`, kindly
consult the documentation on the official website:

- https://cucumber.io/blog/open-source/announcing-cucumber-expressions/
- https://cucumber.io/docs/cucumber/cucumber-expressions

In addition to the above, the [git log](https://github.com/Ajwah/ex_cucumber/commits/master) of this repo aptly summarizes
how these various tools work in tandem with each other.

## Basic Usage

### Context

Leveraging the feature file below, and the example app provided below
that, we can proceed to demonstrate basic usage.

#### **Feature File**

Assume you have the following feature file with the name `rule.feature`:

```gherkin
Feature: Gherkin 6 syntax
  Background:
    Given there is a monster with 2 hitpoints
  Scenario: Battle
    When I attack it
    Then the monster should be alive
    When I attack it
    Then it should die
  Rule: Battle with preemptive attack
    Background:
      Given I attack the monster and do 1 points damage
    Example: battle
      When I attack it
      Then it should die
  Rule: Battle with preemptive critical attack
    Background:
      Given I attack the monster and do 2 points damage
    Example: battle
      Then it should die
```

#### **The Amazing Monster App**

Assume that the following app represents the core of your trillion-dollar
multinational:

```elixir
defmodule Monster do
  @moduledoc """
  This is a dummy app to serve as context to demonstrate basic usage of
  `ExCucumber`
  """

  defstruct hitpoints: 0,
            alive?: false

  def new(hitpoints), do: __MODULE__ |> struct(%{hitpoints: hitpoints}) |> check_alive
  def take_hit(%__MODULE__{} = m, damage \\ 1),
    do: %{m | hitpoints: m.hitpoints - damage} |> check_alive
  defp check_alive(%__MODULE__{} = m), do: %{m | alive?: m.hitpoints > 0}
end
```

With the above context out of the way, this is how you would use this
library:

### Module-based Verbiage

In this style, you can leverage the following `macros`:

- `Given._`
- `And._`
- `When._`
- `Then._`
- `But._`

Practically it would look like this:

```elixir
defmodule MonsterFeature do
  use ExCucumber
  @feature "rule.feature"

  # Main Background
  Given._ "there is a monster with {int} hitpoints", args do
    {
      :ok,
      %{
        monster: Monster.new(Keyword.fetch!(args.params, :int))
      }
    }
  end
  # Scenario: Battle
  When._ "I attack it", args do
    {:ok, %{monster: Monster.take_hit(args.state.monster)}}
  end

  Then._ "the monster should be alive", args do
    assert args.state.monster.alive?
  end

  Then._ "it should die", args do
    refute args.state.monster.alive?
  end

  Given._ "I attack the monster and do {int} points damage", args do
    {:ok, %{monster: Monster.take_hit(args.state.monster, Keyword.fetch!(args.params, :int))}}
  end

end
```

### Definition-based Verbiage

In this style, you can leverage the following `macros`:

- `defgiven`
- `defand`
- `defwhen`
- `defthen`
- `defbut`

Practically it would look like this:

```elixir
defmodule MonsterFeature do
  use ExCucumber
  @feature "rule.feature"

  # Main Background
  defgiven "there is a monster with {int} hitpoints", args do
    {
      :ok,
      %{
        monster: Monster.new(Keyword.fetch!(args.params, :int))
      }
    }
  end
  # Scenario: Battle
  defwhen "I attack it", args do
    {:ok, %{monster: Monster.take_hit(args.state.monster)}}
  end

  defthen "the monster should be alive", args do
    assert args.state.monster.alive?
  end

  defthen "it should die", args do
    refute args.state.monster.alive?
  end

  defgiven "I attack the monster and do {int} points damage", args do
    {:ok, %{monster: Monster.take_hit(args.state.monster, Keyword.fetch!(args.params, :int))}}
  end
end
```

### Verbage Styles Pros/Cons

This has been discussed at length in [following commit message](https://github.com/Ajwah/ex_cucumber/commit/940579aa5f73539128773a062c8596ce15cb1838)
Your feedback would be highly appreciated.

### Configuration

The core configuration is

```elixir
import Config
config :ex_cucumber,
  # As this is not a testing framework; it would not make sense to embed
  # this under `/tests`
  feature_dir: "#{File.cwd!()}/features",
  project_root: File.cwd!(),
  macro_style: :module, # [:def, :module]
  error_detail_level: :verbose, # [:brief, :verbose]
  best_practices: %{
    disallow_gherkin_token_usage_mismatch?: false,
    enforce_context?: true,
  }
```

In addition to that `Cucumber` relies on a `Gherkin` parser which I have
build as a [separate repository](https://github.com/Ajwah/ex-gherkin).
Its configuration would be:

```
import Config
gherkin_languages = "gherkin-languages"

config :my_ex_gherkin,
  file: %{
    # to be downloaded. instructions below
    source: "#{gherkin_languages}.json",

    # to be generated with a mix task
    resource: "#{gherkin_languages}.few.terms"
  },
  homonyms: ["Агар ", "* ", "अनी ", "Tha ", "Þá ", "Ða ", "Þa "],

  # This is only beneficial for development purposes and can be skipped
  debug: %{
    tokenizer: false,
    prepare: false,
    parser: false,
    format_message: false,
    parser_raise: false
  }
```

Of important note is the need for `gherkin-languages.json` which you can
download from the [official cucumber repository](https://github.com/cucumber/gherkin/blob/main/gherkin-languages.json) and then you can use the `mix`
`tasks` of [ex_gherkin](https://github.com/Ajwah/ex-gherkin) to generate
the `.terms` file.

## Installation

```elixir
def deps do
  [
    {:ex_cucumber, "~> 0.1.0"}
  ]
end
```

## Docs

Above represents very basic usage to get up and running. For more
details, kindly consult the [docs](https://hexdocs.pm/ex_cucumber).

## Shoulders Of Giants

For a long time I have been using [white-bread](https://github.com/meadsteve/white-bread) to satisfy my diet of `Cucumber`.
Regretfully, development [seems to have halted](https://github.com/meadsteve/white-bread/issues/88#issuecomment-547807754) whereas a variety of essential features are missing:

- No multi-language support
- No support for `But`
- No support for `Background`
- No support for `Scenario Outline`
- No support for `Rule`

Regardless, it was one of the first packages that allowed developers to incorporate `BDD` into their development and I
am very grateful for that. I hope for this package to be able to carry the banner forward and be a source of
developer happiness to others like @meadsteve's package was to me for a number of years.

In addition to that, [cabbage](https://github.com/cabbage-ex/cabbage) is also worthy of consideration. Regretfully, it
too suffers from what I enumerated above.
