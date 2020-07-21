defmodule Support.RuleFeature.DemonstrateRuleUsage do
  use ExCucumber
  @feature "rule.feature"

  defmodule Monster do
    defstruct hitpoints: 0,
              alive?: false

    def new(hitpoints), do: __MODULE__ |> struct(%{hitpoints: hitpoints}) |> check_alive

    def take_hit(%__MODULE__{} = m, damage \\ 1),
      do: %{m | hitpoints: m.hitpoints - damage} |> check_alive

    defp check_alive(%__MODULE__{} = m), do: %{m | alive?: m.hitpoints > 0}
  end

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
