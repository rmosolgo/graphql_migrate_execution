# frozen_string_literal: true
module GraphqlMigrateExecution
  class Action
    def initialize(migration, filepath, ruby_source)
      @migration = migration
      @filepath = filepath
      @ruby_source = ruby_source
      @message = "".dup
      @result_source = @ruby_source.dup
      @strategy_name_padding = nil
    end

    attr_reader :message, :result_source, :migration, :filepath, :strategy_name_padding, :field_name_padding

    def run
      parse_result = Prism.parse(@ruby_source, filepath: @filepath)
      type_definitions = Hash.new { |h, k| h[k] = TypeDefinition.new(k) }
      visitor = Visitor.new(@ruby_source, type_definitions)
      visitor.visit(parse_result.value)
      total_field_definitions = 0
      field_definitions_by_strategy = Hash.new { |h, k| h[k] = [] }
      type_definitions.each do |name, type_defn|
        type_defn.field_definitions.each do |f_name, f_defn|
          total_field_definitions += 1
          f_defn.check_for_resolver_method
          field_definitions_by_strategy[f_defn.migration_strategy] << f_defn
        end
      end

      @message << "Found #{total_field_definitions} field definition#{total_field_definitions == 1 ? "" : "s"}:\n"
      @strategy_name_padding = field_definitions_by_strategy.each_key.map { |sc| sc.strategy_name.size }.max
      @field_name_padding = field_definitions_by_strategy.each_value.flat_map { |fds| fds.map { |fd| fd.path.size } }.max
      field_definitions_by_strategy.each do |strategy_class, field_definitions|
        strategy = strategy_class.new(self, field_definitions)
        strategy.run
      end
    end
  end
end
