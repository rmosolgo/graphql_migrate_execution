# frozen_string_literal: true
module GraphqlMigrateExecution
  # Turns `fallback_value: ...` into `resolve_static: true`
  class FallbackValue < Strategy
    self.color = :GREEN

    def migrate(field_definition)
      indent = field_definition.node.location.slice_lines[/^ +/]
      method_name = self.class.prefix_if_necessary(field_definition.name)
      is_interface = field_definition.type_definition.is_interface
      new_body = "\n".dup

      if is_interface
        method_prefix = "def #{method_name}"
        new_body << "#{indent}resolver_methods do\n"
        method_indent = indent + "  "
      else
        method_prefix = "def self.#{method_name}"
        method_indent = indent
      end

      new_body << "#{method_indent}#{method_prefix}(_context)\n"
      new_body << method_indent + "  #{field_definition.fallback_value}\n"
      new_body << method_indent + "end"

      if is_interface
        new_body << "\n#{indent}end"
      end

      @result_source.sub!(field_definition.source, field_definition.source + "\n" + new_body)
      keyword_v = method_name == field_definition.name.to_s ? true : method_name.to_sym.inspect
      inject_field_keyword(field_definition, :resolve_static, keyword_v)
    end

    def cleanup(field_definition)
      remove_field_keyword(field_definition, :fallback_value)
    end
  end
end
