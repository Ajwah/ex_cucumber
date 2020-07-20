defmodule Support.CreateEmployeeFeatures.WithStepOmitted do
  use ExCucumber
  @feature "create_employee.feature"

  Given._("user wants to create an employee with the following attributes", arg, do: arg)
end
