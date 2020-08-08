defmodule ExCucumber.DocumentationResources do
  @moduledoc false
  @todo :to_do_include_link

  @links %{
    worlds_most_misunderstood_collaboration_tool:
      "https://cucumber.io/blog/collaboration/the-worlds-most-misunderstood-collaboration-tool/",
    duplicate_step_definition:
      "https://cucumber.io/docs/community/faq/#duplicate-step-definition",
    duplicate_step_definition_reason: "https://cucumber.io/docs/gherkin/reference/#steps",
    gherkin_token_mismatch: "https://github.com/cucumber/cucumber/issues/768",
    gherkin_spec: %{
      homonyms: @todo
    }
  }

  def link(key), do: Map.fetch!(@links, key)
  def link(key, subkey), do: @links |> Map.fetch!(key) |> Map.fetch!(subkey)

  def full_description_this_library do
    """
    # Basic Setup
    For basic usage, kindly consult the [README](https://github.com/Ajwah/ex_cucumber)

    # Full Mastery Level
    Following below represents all the various options you are empowered with
    in yielding this library. This has already been depicted in the [README](https://github.com/Ajwah/ex_cucumber)
    to facilitate a copy-paste-and-get-stuff-done-setup. In order to facilitate
    the attainment of full mastery of this library, each configuration item
    will be discussed in more detail.

    ## Full Configuration
    ```elixir
    config :ex_cucumber,
      feature_dir: "#\{cwd\}/apps/ex_cucumber/test/support/features",
      project_root: cwd,
      # [:def, :module]
      macro_style: :module,
      # [:brief, :verbose]
      error_detail_level: :verbose,
      best_practices: %{
        disallow_gherkin_token_usage_mismatch?: false,
        enforce_context?: false,
      },
    ```

    ### feature_dir
    This represents the directory in which you embed all the documentation
    as `.feature` files together with their implementation. As this is a
    [collaboration tool](https://cucumber.io/blog/collaboration/the-worlds-most-misunderstood-collaboration-tool), it would not make sense
    to house this under the canonical test-folder.
    The test folder is to house your various unit tests etc., whereas the
    focus of this folder is the development of the [ubiquitous language](https://martinfowler.com/bliki/UbiquitousLanguage.html)
    of your domain while holding your code base accountable in expressing
    the same so you may attain a 1 to 1 mapping between the conceptual
    framework that represents your domain and the implementation thereof.

    At the time of implementing the `.feature`-file, you will employ the
    module attribute: `@feature` to refer to the feature file in question.
    For instance, say that you opt for `feature_dir` to point to the
    directory `features` nested in the root of your project. When you have
    the feature file: `features/cucumber_day_and_night.feature` then you
    could implement that in the file: `features/my_amazing_implementation.exs`
    as follows:
    ```elixir
    defmodule MyAmazingImplementation do
      use ExCucumber
      @feature "cucumber_day_and_night.feature"
    end
    ```

    ### project_root
    This is to be removed soon

    ### macro_style
    This library allows you to express your verbiage in two ways:
    * Module Based: `Given._` etc. Supply: `:module`
    * Def Based: `defgiven` etc. Supply: `:def`

    ### error_detail_level
    Cucumber has a learning curve to it; especially for junior developers
    of your organization. In order to accommodate every background, the
    ambition of this project is to provide highly detailed error messages
    under the format of documentation. If you feel you have a need for
    this, then you may supply the option: `:verbose`. If the pedantic
    amount of detail becomes disruptive to your workflow, then you may
    supply the option `:brief` instead.
    Kindly note that this is something I am experimenting with at the
    moment to strive for finding the best way of alleviating confusion.

    ### best_practices
    As the author of this library, I have my personal opinions on what
    constitutes best practices that may go against cucumber.io and how
    the developer experience has been coined in different language
    implementations. I incorporate such deviations into this option so
    you may exercise your personal preference.

    #### best_practices.disallow_gherkin_token_usage_mismatch?
    This pertains to the usage of `GWT`-keywords in a `.feature` file vs
    the implementation thereof. Traditionally, the people behind `Cucumber`
    were of the opinion that `GWT` are mere `keywords` that do not
    contribute to the meaning of your feature lines in out of themselves.
    As such, when it comes to matching a line in a feature file against any
    of the implemented cucumber expressions; their sentiment is that they
    should not be taken into account at all as you can read [here](https://cucumber.io/docs/gherkin/reference/#steps) in more
    detail. However, this could lead to a documentation drift where in the
    feature file you express a line with `Given` whereas in your
    implementation you are employing the macro `defand` instead.
    Setting the option to `true` means that you do not tollerate such
    discrepancies.

    #### best_practices.enforce_context?
    This pertains to the usage of `context` keywords, such as:
    * `background`
    * `rule`
    * `scenario`

    inside your implementation as macros. It is easier to demonstrate by
    fleshing out [the example in the README](https://github.com/Ajwah/ex_cucumber#feature-file) as below

    ```elixir
    defmodule MonsterFeature do
      use ExCucumber
      @feature "monster.feature"

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
          attack_monster(args)
        end

        Then._ "the monster should be alive", args do
          assert args.state.monster.alive?
        end

        Then._ "it should die", args do
          assert_die(args)
        end
      end

      rule "Battle with preemptive attack" do
        background do
          Given._ "I attack the monster and do {int} points damage", args do
            massive_attack_monster(args)
          end
        end

        example "battle" do
          When._ "I attack it", args do
            attack_monster(args)
          end

          Then._ "it should die", args do
            assert_die(args)
          end
        end
      end

      rule "Battle with preemptive critical attack" do
        background do
          Given._ "I attack the monster and do {int} points damage", args do
            massive_attack_monster(args)
          end
        end

        example "battle" do
          Then._ "it should die", args do
            assert_die(args)
          end
        end
      end

      def massive_attack_monster(args), do: {:ok, %{monster: Monster.take_hit(args.state.monster, Keyword.fetch!(args.params, :int))}}
      def attack_monster(args), do: {:ok, %{monster: Monster.take_hit(args.state.monster)}}
      def assert_die(args), do: refute args.state.monster.alive?
    end
    ```

    When setting this option to true, then the usage of the context block-macros
    allows you to specify the same step definition multiple times. This is to
    alleviate these feature file implementations from becoming a confusing
    maze where repairing a broken scenario ends up in a witch hunt to locate
    where a particular step has been implemented.

    Concretely speaking, in the corresponding `feature` file we can see that
    the step `Then it should die` has been reused multiple times in different
    contexts, nl.:
    * Scenario: Battle
    * Rule: Battle with preemptive attack/Example: battle
    * Rule: Battle with preemptive critical attack/Example: battle

    Likewise there are other reused steps.

    Traditionally, other cucumber implementations would limit you with only
    allowing to implement them once. This makes sense from the perspective
    that these steps should be agnostic from context as much as possible so
    as to encourage maximum reusability. The downside to this can be that
    in a very long and elaborate `module`, it becomes a challenge to understand
    the flow where you can no longer look at the implementation and suffice
    on it to understand how your steps are progressing. This necessitates
    the indirection of referring to the corresponding `feature` file and
    locating the relevant steps therein.
    Next is the element of finding the implemented step in all your
    step_definitions; e.g. the witch hunt referred to above which is
    exacerbated when many step definition files are imported in one and
    the same module.
    For a junior developer, this may not be contributive to developer
    happiness.

    With this option, the implementation can fully reflect the style and
    nesting of the original feature file where code duplication is
    eliminated by means of descriptive helper functions as exemplified
    above.

    The next step of ambition here is that this would also facilitate
    the localization of setup definitions. This is still a feature that is
    due; so be on the outlook for that!

    Lastly, the only ones implemented so far are:
    * `background`
    * `rule`
    * `scenario`

    Those three suffice to express all the rest; e.g. `example` can be
    expressed as `scenario` as they are synonyms. The ambition is to
    include distinct macros for them as well; so a PR is always welcome.

    ## Cucumber Expressions
    In the example above, you have encountered `cucumber expressions` in
    all their glory without a formal introduction to them. Make sure to
    take a look at the [corresponding README](https://github.com/Ajwah/ex_cucumber/tree/master/apps/cucumber_expressions)
    to familiarize yourself with them.

    The main exciting feature to discuss here is that of `params`!
    Instead of leveraging ugly `regex` to extract specific values out of
    feature lines, you can resort to parameters instead.
    There are a few that are available by standard, the canonical ones:
    * `{int}`
    * `{float}`
    * `{string}`
    * `{word}`

    Here is a concrete example:
    ```elixir
    Given._ "I daily eat {int} cucumbers", args do
      assert(Keyword.fetch!(args.params, :int) == 3))
    end
    ```
    These `params` are made available in the argument that you supply in
    the step definition; in this case: `args` under the key: `params` as a
    keyword list. This would allow you to capture multiple occurrences as:
    ```elixir
    Given._ "{int} {int} {int} Here I come!", args do
      assert [int: 1, int: 2, int: 3] == args.params
    end
    ```

    In the case you want to introduce your own custom params, then you may
    formally do so by implementing the behaviour: `@behaviour ExCucumber.CustomParameterType`
    Kindly refer accordingly for more details as well as examples.

    Defining `Custom Parameters` can be a pain. For this reason, in order
    to promote your happiness, you can resort to undeclared custom params.

    For instance, given the following feature file:
    ```gherkin
    Feature: Custom Params
    Scenario:
      Given I live in New York and need to travel to Istanbul arriving before Friday, 21 July 2017
       When I input all these details into the UI
       Then I will see: Take LHRL-OSL from New York to Istanbul on Wednesday, 19 July 2017 at 13:40 to arrive by Thursday, 20 July 2017 at 09:00 for a total flight time of 17 hours at a discounted price of 2500 USD in total
    ```

    You could without shame and being judged express yourself as:
    ```elixir
    Given._ "I live in {origin} and need to travel to {destination} arriving before {latest_arrival_time}", args do
      assert [origin: "New York", destination: "Istanbul", latest_arrival_time: "Friday, 21 July 2017"] == args.params
    end
    When._ "I input all these details into the UI", do: :ok
    Then._ "I will see: Take {flight} from {origin} to {destination} on {departure_date} at {departure_time} to arrive by {arrival_date} at {arrival_time} for a total flight time of {total_flight_time} at a discounted price of {price} in total", args do
      assert [
        flight: "LHRL-OSL",
        origin: "New York",
        destination: "Istanbul",
        departure_date: "Wednesday, 19 July 2017",
        departure_time: "13:40",
        arrival_date: "Thursday, 20 July 2017",
        arrival_time: "09:00",
        total_flight_time: "17 hours",
        price: "2500 USD"
      ] == args.params
    end
    ```

    Of course, if you feel like cursing your existence as a software developer when having to manually parse your values
    time and again, then a formal introduction of one ore multiple custom parameters may be warranted instead.

    ## Data Tables
    You can access a data table occurring in a feature file, e.g.:
    ```gherkin
    Given user wants to create an employee with the following attributes
    | id  | firstName | lastName | dateOfBirth | startDate  | employmentType | email               |
    | 100 | Rachel    | Green    | 1990-01-01  | 2018-01-01 | Permanent      | rachel.green@fs.com |
    ```
    as follows:

    ```elixir
    Given._ "user wants to create an employee with the following attributes", arg, do: assert(arg.data_table)
    ```

    ## Doc String
    Analogous to the above, specify the key: `doc_string` in `args`

    ## Scenario Outline
    Full support for scenario outlines. See this [implementation](https://github.com/Ajwah/ex_cucumber/blob/d17f714f1c1aa26920ea341fc400ce825c1579b6/apps/ex_cucumber/test/support/modules/create_employee_features/with_data_table.ex#L1-L14)
    of this [feature file](https://github.com/Ajwah/ex_cucumber/blob/5633c889bf177dc1e528c4d76eac4c8979b2f01e/apps/ex_cucumber/test/support/features/create_employee.feature#L18-L41)

    ## Rule
    The above Monster example demonstrates full usage of `Rule`

    ## Transferring state from one step to the next
    When you end a step implementation with the tuple: `{:ok, %{result: some_value}}` then the subsequent step can access
    the same under `args.state.result`. Kindly revert to the Monster example again for practical demonstration.
    """
  end
end
