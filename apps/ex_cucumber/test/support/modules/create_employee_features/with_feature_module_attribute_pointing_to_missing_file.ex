defmodule Support.CreateEmployeeFeatures.WithFeatureModuleAttribute.PointingToMissingFile do
  use ExCucumber
  @feature "this is a non existent file"

  Given._("user wants to create an employee with the following attributes", arg, do: arg)
  And._("with the following phone numbers", do: 2)
  When._("user saves the new employee 'WITH ALL REQUIRED FIELDS'", do: 3)
  Then._("the save 'IS SUCCESSFUL'", do: 4)

  When._("user saves the new employee '<testCase>'", do: 5)
  Then._("the save '<expectedResult>'", do: 6)
end
