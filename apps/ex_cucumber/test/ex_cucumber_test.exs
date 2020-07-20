defmodule ExCucumberTest do
  use ExUnit.Case, async: false

  require Helpers.Assertions
  import Helpers.Assertions
  import Helpers.ProjectCompiler

  alias ExCucumber.Exceptions.MatchFailure

  alias Support.{
    CreateEmployeeFeatures,
    OptionalsAlternatives,
    Params
  }

  @non_existent_option_to_bypass_test_setup :non_existent_option_to_bypass_test_setup
  # @invalid_value "This is an absolutely invalid value"
  @support_module_dir "test/support/modules"

  @support_module_files %{
    CreateEmployeeFeatures.WithStepOmitted =>
      "#{@support_module_dir}/create_employee_features/with_step_omitted.ex",
    CreateEmployeeFeatures.WithInvalidParam =>
      "#{@support_module_dir}/create_employee_features/with_invalid_param.ex",
    OptionalsAlternatives.WithAllRelevantCombinations =>
      "#{@support_module_dir}/optionals_alternatives_feature/with_all_relevant_combinations.ex",
    Params.Canonical => "#{@support_module_dir}/params/canonical.ex",
    Params.Custom => "#{@support_module_dir}/params/custom.ex"
  }

  setup_all do
    Code.compiler_options(ignore_module_conflict: true)
    original_app_env = Application.get_all_env(:ex_cucumber)

    reset_env(original_app_env, [{:macro_style, :module}, {:error_detail_level, :verbose}])

    on_exit(fn ->
      reset_env(original_app_env)
      Code.compiler_options(ignore_module_conflict: false)
    end)

    {:ok, %{original_app_env: original_app_env}}
  end

  describe "MatchFailure\n" do
    setup ctx do
      if !ctx[:key] || ctx.key != @non_existent_option_to_bypass_test_setup do
        reset_env_switch(ctx)
        test_module_file = Map.fetch!(@support_module_files, ctx.test_module)
        {:ok, %{test_module_file: test_module_file}}
      else
        :ok
      end
    end

    @tag test_module: CreateEmployeeFeatures.WithStepOmitted, error_code: :unable_to_match
    test "Omitting a step will raise a MatchFailure", ctx do
      assert_specific_raise(MatchFailure, ctx.error_code, fn ->
        recompile(ctx)
      end)
    end

    @tag test_module: CreateEmployeeFeatures.WithInvalidParam, error_code: :unable_to_match_param
    test "Employing an invalid parameter will raise a MatchFailure", ctx do
      assert_specific_raise(MatchFailure, ctx.error_code, fn ->
        recompile(ctx)
      end)
    end
  end

  describe "Functionality\n" do
    setup ctx do
      if !ctx[:key] || ctx.key != @non_existent_option_to_bypass_test_setup do
        reset_env_switch(ctx)
        test_module_file = Map.fetch!(@support_module_files, ctx.test_module)
        {:ok, %{test_module_file: test_module_file}}
      else
        :ok
      end
    end

    @tag key: :best_practices,
         value: %{disallow_gherkin_token_usage_mismatch?: false},
         test_module: OptionalsAlternatives.WithAllRelevantCombinations
    test "Handles optionals and alternatives", ctx do
      refute_raise(fn ->
        recompile(ctx)
      end)
    end

    @tag test_module: Params.Canonical
    test "Handles Canonical Params", ctx do
      refute_raise(fn ->
        recompile(ctx)
      end)
    end

    @tag test_module: Params.Custom
    test "Handles Custom Params", ctx do
      refute_raise(fn ->
        recompile(ctx)
      end)
    end
  end

  def reset_env_switch(ctx) do
    if ctx[:key], do: reset_env(ctx.original_app_env, [{ctx.key, ctx.value}])
  end
end
