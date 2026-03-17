# frozen_string_literal: true
require "irb"
module GraphqlMigrateExecution
  class Analyze < Action
    def run
      super
      message = "Found #{@total_field_definitions} field definition#{@total_field_definitions == 1 ? "" : "s"}:".dup

      @field_definitions_by_strategy.each do |strategy_class, definitions|
        message << "\n\n#{color("#{color(strategy_class.name.split("::").last, strategy_class.color)} (#{definitions.size})", :BOLD)}:\n"
        if !@migration.skip_description
          message << "\n#{strategy_class::DESCRIPTION.split("\n").map { |l| l.length > 0 ? "  #{l}" : l }.join("\n")}\n"
        end
        max_path = definitions.map { |f| f.path.size }.max + 2
        definitions.each do |field_defn|
          name = field_defn.path.ljust(max_path)
          message << "\n  - #{name} (#{field_defn.resolve_mode.inspect} -> #{field_defn.resolve_mode_key.inspect}) @ #{@path}:#{field_defn.source_line}"
        end
      end

      message
    end

    private

    def color(str, color_or_colors)
      IRB::Color.colorize(str, Array(color_or_colors), colorable: @migration.colorable)
    end
  end
end
