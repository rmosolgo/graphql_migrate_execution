require "ostruct"
module GraphQLMigrateExecutionStrategyHelpers
  def add_future(ruby_src)
    apply_action_method(ruby_src, :add_future)
  end

  def remove_legacy(ruby_src)
    apply_action_method(ruby_src, :remove_legacy)
  end

  def analyze(ruby_src)
    action = GraphqlMigrateExecution::Analyze.new(OpenStruct.new(colorable: false), "app.rb", ruby_src)
    action.run
  end

  def apply_action_method(ruby_src, action_method)
    action = GraphqlMigrateExecution::Action.new(nil, "app.rb", ruby_src)
    action.run
    new_source = ruby_src.dup
    type_defn = action.type_definitions.each_value.find { |td| td.field_definitions.any? }
    type_defn.field_definitions.each_value do |field_definition|
      @strategy_class.new.public_send(action_method, field_definition, new_source)
    end
    new_source
  end
end
