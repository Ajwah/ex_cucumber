defmodule ExCucumberTest do
  use ExUnit.Case

  defmodule T do
    use ExCucumber
    @feature "100-create-employee.feature"

    Given._ "user wants to create an employee with the following attributes", arg, do: arg
    And._ "with the following phone numbers", arg, do: 2
    When._ "user saves the new employee 'WITH ALL REQUIRED FIELDS'", arg, do: 3
    Then._ "the save 'IS SUCCESSFUL'", do: 4

    When._ "user saves the new employee '<testCase>'", arg, do: 5
    Then._ "the save '<expectedResult>'", arg, do: 6
    # defgiven "user wants to create an employee with the following attributes", arg, do: arg
    # defand "with the following phone numbers", do: 2
    # defwhen "user saves the new employee 'WITH ALL REQUIRED FIELDS'", arg, do: 3
    # defthen "the save 'IS SUCCESSFUL'", arg, do: 4

    # defwhen "user saves the new employee '<testCase>'", arg, do: 5
    # defthen "the save '<expectedResult>'", arg, do: 6
  end
end
