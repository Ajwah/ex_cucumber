defmodule Support.CreateEmployeeFeatures.WithDefMacroStyle do
  use ExCucumber
  @feature "create_employee.feature"

  defgiven "user wants to create an employee with the following attributes", arg, do: arg
  defand "with the following phone numbers", do: 2
  defwhen "user saves the new employee 'WITH ALL REQUIRED FIELDS'", do: 3
  defthen "the save 'IS SUCCESSFUL'", do: 4

  defwhen "user saves the new employee '<testCase>'", do: 5
  defthen "the save '<expectedResult>'", do: 6
end
