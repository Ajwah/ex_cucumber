defmodule ConfigTest do
  use ExUnit.Case, async: false

  alias ExCucumber.Config

  alias ExCucumber.Exceptions.{
    ConfigurationError,
    UsageError
  }

  alias Support.{
    CreateEmployeeFeatures
  }

  require Helpers.Assertions
  import Helpers.Assertions
  import Helpers.ProjectCompiler

  @non_existent_option_to_bypass_test_setup :non_existent_option_to_bypass_test_setup
  @invalid_value "This is an absolutely invalid value"
  @support_module_dir "test/support/modules"
  @support_module_files %{
    CreateEmployeeFeatures.WithModuleMacroStyle =>
      "#{@support_module_dir}/create_employee_features/with_module_macro_style.ex",
    CreateEmployeeFeatures.WithDefMacroStyle =>
      "#{@support_module_dir}/create_employee_features/with_def_macro_style.ex",
    CreateEmployeeFeatures.WithGherkinTokenMismatch =>
      "#{@support_module_dir}/create_employee_features/with_gherkin_token_mismatch.ex",
    CreateEmployeeFeatures.WithFeatureModuleAttribute.Missing =>
      "#{@support_module_dir}/create_employee_features/with_feature_module_attribute_missing.ex",
    CreateEmployeeFeatures.WithFeatureModuleAttribute.PointingToMissingFile =>
      "#{@support_module_dir}/create_employee_features/with_feature_module_attribute_pointing_to_missing_file.ex"
  }

  setup_all do
    Code.compiler_options(ignore_module_conflict: true)
    original_app_env = Application.get_all_env(:ex_cucumber)

    on_exit(fn ->
      reset_env(original_app_env)
      Code.compiler_options(ignore_module_conflict: false)
    end)

    {:ok, %{original_app_env: original_app_env}}
  end

  describe "Elixir Fundamentals\n" do
    setup ctx do
      reset_env(ctx.original_app_env, [{ctx.key, ctx.value}])
      :ok
    end

    @tag key: :macro_style, value: :def, test_module: Config
    test "Reloading module during tests refreshes underlying module attributes", ctx do
      assert apply(ctx.test_module, ctx.key, []) == ctx.value
    end
  end

  describe "Macro Style\n" do
    setup ctx do
      if ctx.key != @non_existent_option_to_bypass_test_setup do
        reset_env(ctx.original_app_env, [{ctx.key, ctx.value}])

        test_module_file = Map.fetch!(@support_module_files, ctx.test_module)
        {:ok, %{test_module_file: test_module_file}}
      else
        reset_env(ctx.original_app_env)
        :ok
      end
    end

    @tag key: :macro_style,
         value: :module,
         test_module: CreateEmployeeFeatures.WithModuleMacroStyle
    test "When set to: `module` then user can employ module-style-macros when formulating `Cucumber Expressions`",
         ctx do
      refute_raise(fn ->
        recompile(ctx)
      end)
    end

    @tag key: :macro_style, value: :def, test_module: CreateEmployeeFeatures.WithModuleMacroStyle
    test "When set to: `def` will raise when user employs module-style-macros instead", ctx do
      assert_specific_raise(ConfigurationError, :macro_style_mismatch, fn ->
        recompile(ctx)
      end)
    end

    @tag key: :macro_style, value: :def, test_module: CreateEmployeeFeatures.WithDefMacroStyle
    test "When set to: `def` then user can employ def-style-macros when formulating `Cucumber Expressions`",
         ctx do
      refute_raise(fn ->
        recompile(ctx)
      end)
    end

    @tag key: :macro_style, value: :module, test_module: CreateEmployeeFeatures.WithDefMacroStyle
    test "When set to: `module` will raise when user employs def-style-macros instead", ctx do
      assert_specific_raise(ConfigurationError, :macro_style_mismatch, fn ->
        recompile(ctx)
      end)
    end

    @tag key: @non_existent_option_to_bypass_test_setup
    test "invalid option raises", _ctx do
      assert_specific_raise(ConfigurationError, :incorrect_macro_style, fn ->
        Application.put_env(:ex_cucumber, :macro_style, @invalid_value)
        IEx.Helpers.r(Config)
      end)
    end
  end

  describe "Error Detail Level\n" do
    setup ctx do
      if ctx.key != @non_existent_option_to_bypass_test_setup do
        reset_env(ctx.original_app_env, [{ctx.key, ctx.value}, {:macro_style, :module}])

        test_module_file = Map.fetch!(@support_module_files, ctx.test_module)
        {:ok, %{test_module_file: test_module_file}}
      else
        reset_env(ctx.original_app_env)
        :ok
      end
    end

    @tag key: :error_detail_level,
         value: :verbose,
         test_module: CreateEmployeeFeatures.WithModuleMacroStyle
    test ":verbose is a valid option", ctx do
      refute_raise(fn ->
        recompile(ctx)
      end)
    end

    @tag key: :error_detail_level,
         value: :brief,
         test_module: CreateEmployeeFeatures.WithModuleMacroStyle
    test ":brief is a valid option", ctx do
      refute_raise(fn ->
        recompile(ctx)
      end)
    end

    @tag key: @non_existent_option_to_bypass_test_setup
    test "invalid option raises", _ctx do
      assert_specific_raise(ConfigurationError, :incorrect_error_level_detail, fn ->
        Application.put_env(:ex_cucumber, :error_detail_level, @invalid_value)
        IEx.Helpers.r(Config)
      end)
    end
  end

  describe "Best Practices\n" do
    setup ctx do
      if ctx.key != @non_existent_option_to_bypass_test_setup do
        reset_env(ctx.original_app_env, [{ctx.key, ctx.value}, {:macro_style, :module}])

        test_module_file = Map.fetch!(@support_module_files, ctx.test_module)
        {:ok, %{test_module_file: test_module_file}}
      else
        reset_env(ctx.original_app_env)
        :ok
      end
    end

    @tag key: :best_practices,
         value: %{disallow_gherkin_token_usage_mismatch?: true},
         test_module: CreateEmployeeFeatures.WithGherkinTokenMismatch
    test "disallow_gherkin_token_usage_mismatch?: true will raise an error when there is a mismatch",
         ctx do
      assert_specific_raise(UsageError, :gherkin_token_mismatch, fn ->
        recompile(ctx)
      end)
    end

    @tag key: :best_practices,
         value: %{disallow_gherkin_token_usage_mismatch?: false},
         test_module: CreateEmployeeFeatures.WithGherkinTokenMismatch
    test "disallow_gherkin_token_usage_mismatch?: false will not raise an error even though there is a mismatch",
         ctx do
      refute_raise(fn ->
        recompile(ctx)
      end)
    end

    @tag key: @non_existent_option_to_bypass_test_setup
    test "invalid option raises", _ctx do
      assert_specific_raise(ConfigurationError, :best_practices_incomplete, fn ->
        Application.put_env(:ex_cucumber, :best_practices, @invalid_value)
        IEx.Helpers.r(Config)
      end)
    end
  end

  describe "Feature File Location\n" do
    setup ctx do
      if !ctx[:key] || ctx.key != @non_existent_option_to_bypass_test_setup do
        reset_env(
          ctx.original_app_env,
          [{ctx[:key], ctx[:value]}, {:macro_style, :module}]
          |> Enum.reject(fn
            {nil, nil} -> true
            _ -> false
          end)
        )

        test_module_file = Map.fetch!(@support_module_files, ctx.test_module)
        {:ok, %{test_module_file: test_module_file}}
      else
        reset_env(ctx.original_app_env)
        :ok
      end
    end

    @tag key: @non_existent_option_to_bypass_test_setup
    test "Option: `feature_dir` invalid", _ctx do
      assert_specific_raise(ConfigurationError, :invalid_feature_dir, fn ->
        Application.put_env(:ex_cucumber, :feature_dir, @invalid_value)
        IEx.Helpers.r(Config)
      end)
    end

    @tag key: @non_existent_option_to_bypass_test_setup
    test "Option: `project_root` invalid", _ctx do
      assert_specific_raise(ConfigurationError, :invalid_project_root, fn ->
        Application.put_env(:ex_cucumber, :project_root, @invalid_value)
        IEx.Helpers.r(Config)
      end)
    end

    @tag test_module: CreateEmployeeFeatures.WithFeatureModuleAttribute.Missing
    test "Module Attribute: `@feature` missing", ctx do
      assert_specific_raise(ConfigurationError, :feature_attribute_missing, fn ->
        recompile(ctx)
      end)
    end

    @tag test_module: CreateEmployeeFeatures.WithFeatureModuleAttribute.PointingToMissingFile
    test "Module Attribute: `@feature` pointing to missing file", ctx do
      assert_specific_raise(ConfigurationError, :feature_file_not_found, fn ->
        recompile(ctx)
      end)
    end
  end
end
