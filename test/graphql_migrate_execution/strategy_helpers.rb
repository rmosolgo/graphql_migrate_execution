
module GraphQLMigrateExecutionStrategyHelpers
  def add_future(ruby_src)
    apply_action_method(ruby_src, GraphqlMigrateExecution::AddFuture)
  end

  def remove_legacy(ruby_src)
    apply_action_method(ruby_src, GraphqlMigrateExecution::RemoveLegacy)
  end

  def analyze(ruby_src)
    action = GraphqlMigrateExecution::Analyze.new(OpenStruct.new(colorable: false), "app.rb", ruby_src)
    action.run
    action.message
  end

  def apply_action_method(ruby_src, action_class)
    migration = OpenStruct.new(colorable: false, dry_run: true)
    action = action_class.new(migration, "app.rb", ruby_src)
    action.run
    action.result_source
  end
end
