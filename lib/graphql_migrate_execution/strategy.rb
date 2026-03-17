# frozen_string_literal: true
module GraphqlMigrateExecution
  class Strategy
    def initialize(action, field_definitions)
      @action = action
      @migration = action.migration
      @filepath = action.filepath
      @action_method = @migration.action_method
      @message = action.message
      @result_source = action.result_source
      @field_definitions = field_definitions
    end

    def migrate(field_definition)
    end

    def cleanup(field_definition)
    end

    def run
      case @action_method
      when :analyze
        @message << "\n#{colorize("#{colorize(self.class.strategy_name, self.class.color)} (#{@field_definitions.size})", :BOLD)}:\n"
        if !@migration.skip_description
          @message << "\n#{self.class::DESCRIPTION.split("\n").map { |l| l.length > 0 ? "  #{l}" : l }.join("\n")}\n"
        end
        max_path = @field_definitions.map { |f| f.path.size }.max + 2
        @field_definitions.each do |field_defn|
          name = field_defn.path.ljust(max_path)
          @message << "\n  - #{name} (#{field_defn.resolve_mode.inspect} -> #{field_defn.resolve_mode_key.inspect}) @ #{@filepath}:#{field_defn.source_line}"
        end
        @message << "\n"
      when :migrate,  :cleanup
        indent_size = @action.strategy_name_padding + 1
        indent = " " * indent_size
        indent2_size = @action.field_name_padding
        @message << "\n#{colorize(self.class.strategy_name, self.class.color).ljust(indent_size)}"
        first = true
        @field_definitions.each do |field_defn|
          @message << "#{first ? "" : "#{indent}"}#{field_defn.path.ljust(indent2_size)}  @ #{@filepath}:#{field_defn.source_line}\n"
          first = false
          public_send(@action_method, field_defn)
        end
      end
    end

    def self.strategy_name
      name.split("::").last
    end

    class << self
      attr_accessor :color
    end

    private

    def colorize(str, color_or_colors)
      IRB::Color.colorize(str, Array(color_or_colors), colorable: @migration.colorable)
    end

    def inject_resolve_keyword(field_definition, keyword)
      value = field_definition.future_resolve_shorthand.inspect
      inject_field_keyword(field_definition, keyword, value)
    end

    def inject_field_keyword(field_definition, keyword, value)
      field_definition_source = field_definition.source
      pair = "#{keyword}: #{value}"
      if field_definition_source.include?(pair)
        # Pass, don't re-add it
      elsif field_definition_source.include?("#{keyword}:")
        raise "Can't re-inject #{keyword} because it's already present in the definition:\n\n#{field_definition_source}"
      else
        new_definition_source = if field_definition_source[/ [a-z_]+:/] # Does it already have keywords?
          field_definition_source.sub(/(field.+?)((?: do)|(?: {)|$)/, "\\1, #{pair}\\2")
        else
          field_definition_source + ", #{pair}"
        end
        @result_source.sub!(field_definition_source, new_definition_source)
      end
    end


    def remove_field_keyword(field_definition, keyword)
      field_definition_source = field_definition.source
      new_definition_source = field_definition_source.sub(/, #{keyword}: \S+(,|$)/, "\\1")
      @result_source.sub!(field_definition_source, new_definition_source)
    end

    def replace_resolver_method(field_definition, new_params)
      resolver_method = field_definition.resolver_method
      method_name = resolver_method.name
      old_method = resolver_method.source
      new_class_method = old_method
        .sub("def ", 'def self.')

      if resolver_method.parameter_names.empty?
        new_class_method.sub!(method_name.to_s, "#{method_name}(#{new_params})")
      else
        new_class_method.sub!("def self.#{method_name}(", "def self.#{method_name}(#{new_params}, ")
      end

      old_lines = old_method.split("\n")
      new_body = old_lines.first[/^ +/] + "  self.class.#{method_name}(#{new_params}#{resolver_method.parameter_names.map { |n| ", #{n}: #{n}"}.join})"
      new_inst_method = [old_lines.first, new_body, old_lines.last].join("\n")

      new_double_definition = new_class_method + "\n" + new_inst_method + "\n"
      @result_source.sub!(old_method, new_double_definition)
    end

    def remove_resolver_method(field_definition)
      src_pattern = /(\n*)(#{Regexp.quote(field_definition.resolver_method.source)})(\n*)/
      @result_source.sub!(src_pattern) do
        # $2 includes a newline, too
        "#{$1.length > 1 ? "\n" : ""}#{$3.length > 0 ? "\n" : ""}"
      end
    end
  end
end
