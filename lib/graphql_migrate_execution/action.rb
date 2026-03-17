# frozen_string_literal: true
module GraphqlMigrateExecution
  class Action
    def initialize(migration, path, source)
      @migration = migration
      @path = path
      @source = source
      @type_definitions = Hash.new { |h, k| h[k] = TypeDefinition.new(k) }
      @field_definitions_by_strategy = Hash.new { |h, k| h[k] = [] }
      @total_field_definitions = 0
      @message = "".dup
      @result_source = @source.dup
    end

    attr_reader :type_definitions, :message, :result_source

    def run
      parse_result = Prism.parse(@source, filepath: @path)
      visitor = Visitor.new(@source, @type_definitions)
      visitor.visit(parse_result.value)
      @type_definitions.each do |name, type_defn|
        type_defn.field_definitions.each do |f_name, f_defn|
          @total_field_definitions += 1
          f_defn.check_for_resolver_method
          @field_definitions_by_strategy[f_defn.migration_strategy] << f_defn
        end
      end
      nil
    end

    private

    def call_method_on_strategy(method_name)
      indent_size = @field_definitions_by_strategy.each_key.map { |sc| sc.strategy_name.length }.max + 1
      indent = " " * indent_size
      indent2_size = @field_definitions_by_strategy.each_value.flat_map { |fdefns| fdefns.map { |fd| fd.path.size } }.max
      @field_definitions_by_strategy.each do |strategy_class, field_definitions|
        strategy = strategy_class.new
        @message << "\n#{color(strategy_class.strategy_name.ljust(indent_size), [:BOLD, strategy_class.color])}"
        first = true
        field_definitions.each do |field_defn|
          @message << "#{first ? "" : "#{indent}"}#{field_defn.path.ljust(indent2_size)}  @ #{@path}:#{field_defn.source_line}\n"
          first = false
          strategy.public_send(method_name, field_defn, @result_source)
        end
      end
    end


    private

    def color(str, color_or_colors)
      IRB::Color.colorize(str, Array(color_or_colors), colorable: @migration.colorable)
    end
  end
end
