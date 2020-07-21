defmodule Support.CreateEmployeeFeatures.WithDataTable do
  use ExCucumber
  @feature "create_employee.feature"

  Given._ "user wants to create an employee with the following attributes", arg, do: assert arg.data_table
  And._ "with the following phone numbers", arg, do: assert arg.data_table

  When._ "user saves the new employee {testCase}", do: 5
  Then._ "the save {expectedResult}", do: 6
end
