# frozen_string_literal: true
module GraphqlMigrateExecution
  # Turns `fallback_value: ...` into `resolve_static: true`
  class FallbackValue < Strategy
    self.color = :GREEN

    def migrate(field_definition)
      indent = field_definition.node.location.slice_lines[/^ +/]
      method_name = self.class.prefix_if_necessary(field_definition.name)
      new_body = "\n" + indent + "def self.#{method_name}(_context)\n"
      new_body << indent + "  #{field_definition.fallback_value}\n"
      new_body << indent + "end"

      @result_source.sub!(field_definition.source, field_definition.source + "\n" + new_body)
      keyword_v = method_name == field_definition.name.to_s ? true : method_name.to_sym.inspect
      inject_field_keyword(field_definition, :resolve_static, keyword_v)
    end

    def cleanup(field_definition)
      remove_field_keyword(field_definition, :fallback_value)
    end
  end
end
