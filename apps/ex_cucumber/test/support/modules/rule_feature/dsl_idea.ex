defmodule Support.RuleFeature.DslIdea do
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

  background do
    Given._ "there is a monster with {int} hitpoints", args do
      {
        :ok,
        %{
          monster: Monster.new(Keyword.fetch!(args.params, :int))
        }
      }
    end
  end

  scenario "Battle" do
    When._ "I attack it", args do
      {:ok, %{monster: Monster.take_hit(args.state.monster)}}
    end

    Then._ "the monster should be alive", args do
      assert args.state.monster.alive?
    end

    Then._ "it should die", args do
      refute args.state.monster.alive?
    end
  end

  rule "Battle with preemptive attack" do
    background do
      Given._ "I attack the monster and do {int} points damage", args do
        {:ok, %{monster: Monster.take_hit(args.state.monster, Keyword.fetch!(args.params, :int))}}
      end
    end

    example "battle" do
      When.delegate "I attack it"
      Then.delegate "it should die"
    end
  end

  rule "Battle with preemptive critical attack" do
    def setup do
      :setup_db
    end

    background do
      def setup do
        :source_additional_state
      end

      Given.delegate "I attack the monster and do {int} points damage"
    end

    example "battle" do
      def setup do
        :source_additional_state
      end

      Then.delegate "it should die"
    end
  end
end
