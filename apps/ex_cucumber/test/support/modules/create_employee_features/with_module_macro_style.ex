defmodule Support.CreateEmployeeFeatures.WithModuleMacroStyle do
  use ExCucumber
  @feature "create_employee.feature"

  Given._("user wants to create an employee with the following attributes", _arg, do: 1)
  And._("with the following phone numbers", do: 2)

  When._("user saves the new employee {testCase}", do: 5)
  Then._("the save {expectedResult}", do: 6)
end
