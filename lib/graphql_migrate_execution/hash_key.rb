# frozen_string_literal: true
module GraphqlMigrateExecution
  class HashKey < Strategy
    DESCRIPTION = "These can be future-proofed with `hash_key: ...` configurations"
    self.color = :GREEN

    def migrate(field_definition)
      key = field_definition.type_definition.returns_string_hash? ? field_definition.name.to_s.inspect : field_definition.name.inspect
      inject_field_keyword(field_definition, :hash_key, key)
    end
  end
end
