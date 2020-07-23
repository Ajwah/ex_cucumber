# CucumberExpressions

`Cucumber Expressions` allow developers to match sentences occurring in
a feature file in a more readable way than `regex` is able to
communicate. It introduces 3 concepts:
  1. `Optionals`: `cucumber(s)`
  2. `Alternatives`: `apple/banana/oranges`
  3. `Parameter Types`: `{int}`

For more information, kindly consult:
  * https://cucumber.io/blog/open-source/announcing-cucumber-expressions/
  * https://cucumber.io/docs/cucumber/cucumber-expressions

## Terminologies

* `GWT`: Abbreviation to denote the typical `Gherkin Keywords`:
  * `Given`
  * `When`
  * `And`
  * `But`
  * `Then`
* `Sentence`: The words that make up a single line in a feature file
and are preceded with `GWT`. `GWT` is not part of the `sentence`
* `Params`: Occurrences of types as employed by `Cucumber Expressions`.
Syntactically they are expressed with curly brackets embracing the name
of its type used to refer to its corresponding `Parameter Type`.
Example: `{int}`.
* `Cucumber Expression`: A syntactic entity to `match` a `sentence`
against its `formulation`. A successful `match` results in the evaluation
of all the `params` it employs and returns them together with the
`Principal ID`.
* `Formulation`: As in formulating an expression. This naming is resorted
to to distinguish an expression at the time of evaluation vs its manifest
existence as a sentence(without backticks) outside the context of
evaluation.
* `Principal ID`: A random identifier provided to a `Cucumber Expression`
at the time of its parsing. This ultimately allows `ExCucumber` to
associate a particular `Cucumber Expression` with functionality.
* `Parameter Type`: A composite that references various functions/regular
expressions that allow for the identification, transformance and
validation of information embedded inside a `sentence`.

## Design
A `Cucumber Expression` is parsed to a tree so that we can `match` a
`sentence` against its `formulation`. For example, say that we
have the following `feature` file:
```gherkin
Feature: Sentences
  Scenario:
    Given This is a sentence
    Then This is another sentence
````

The following `Cucumber Expressions` are to match them literally:
  * `"This is a sentence"`
  * `"This is another sentence"`

This is achieved by first parsing the `formulation` into a tree-like
structure as below:
```elixir
%{
  "This" => %{
    " is" => %{
      " a" => %{
        " sentence" => %{
          %{
            end: %{
              principal_id: 10
            }
          }
        }
      " another" => %{
        " sentence" => %{
          %{
            end: %{
              principal_id: 11
            }
          }
        }
      }
    }
  }
}
```
This structure is the backbone to `match` a `sentence` against by breaking
it up word for word while recursively traversing the tree until the end
of the `sentence` is reached, at the point of which the `key` `:end`
should be present as well. If this is not the case, then we raise an
exception. Otherwise, we retrieve the `principal_id` and the `cucumber`
`expression` has been deemed to have been evaluated successfully.

There is slightly more involved when there are `params` involved, but
this is the essence.

In contrast to [ExGherkin](https://github.com/Ajwah/ex-gherkin), I have
opted not to write a `yecc` `parser` for this. I love the grammar
reference that can serve as documentation and that others can consult;
however `Cucumber Expressions` are simple enough that such documentation
does not provide much value.

This implementation was more motivated by curiosity and to serve as a
learning opportunity in an attempt to provide a more elegant solution
than the alternative solution explained below.

## Alternative Design
The alternative way would be by converting a `Cucumber Expression` into
`regex`. It is easy to see how this would work for `params` with their
`Parameter Types`. For instance, given the `sentence` as occurring in a
feature file: `I eat 3 cucumbers`, the corresponding `formulation` would
be: `I eat {int} cucumbers`. The `Parameter Type` corresponding to `int`
employs the `regex`: `~r/^[+-]?\d+$/` so we would need to convert the
`formulation` to: `~r/^I eat [+-]?\d+ cucumbers$/`. `Optionals` and
`Alternatives` also would need to be converted somehow. This approach
implies that in the case the user needs to write 10 different `Cucumber`
`Expressions` to match 10 or more `sentences`; that for every `sentence`
we need to evaluate each `regex` until we have found a match.

## Pros and Cons
The design of the tree approach should be computationally more efficient.
However, as much as it was an interesting learning opportunity, the
downside was the amount of time and code it took to realize the intended
design. On top of that, the computational superiority has very little
meaning when we need to brute force through a few handful expressions
only. Lastly, `regex` matching is generally implemented in a low level
langauge like `C` which already casts doubt on the benefit of my design.

At the end of the day, all of this is speculation without benchmarking;
an effort for which I currently am not motivated to diligently pursue.

## The Ugly
Currently it works but more labour is required in terms of refactoring.
I have a very elaborate test suite, but it lacks consistency. `Parser`
and especially `Matcher` have grown out to become rather complex to
reason about and need serious refactoring.
The other aspect is that I did not leverage the full efficiency of `BEAM`
in terms of [constructing and matching binaries](http://erlang.org/doc/efficiency_guide/binaryhandling.html)

## Conclusion
I am happy to have undertaken the educational initiative to explore this
part of the solution space and would love to further it. However, at the
moment I am curious to see how the alternative solution in practice pans
out.

## Contributers
I welcome contributions on any level:
  1. Educational feedback
  2. Alternative suggestions
  3. PRs



