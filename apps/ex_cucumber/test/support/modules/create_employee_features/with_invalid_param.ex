defmodule Support.CreateEmployeeFeatures.WithInvalidParam do
  use ExCucumber
  @feature "create_employee.feature"

  Given._("user wants to create an {int} with the following attributes", arg, do: arg)
end
