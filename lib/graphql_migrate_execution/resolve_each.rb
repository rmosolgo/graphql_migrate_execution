# frozen_string_literal: true
module GraphqlMigrateExecution
  # These can be converted with `resolve_each:`. Dataloader was not detected in these resolver methods.
  class ResolveEach < Strategy
    self.color = :GREEN

    def migrate(field_definition)
      inject_resolve_keyword(field_definition, :resolve_each)
      replace_resolver_method(field_definition, "object, context")
    end

    def cleanup(field_definition)
      remove_field_keyword(field_definition, :resolver_method)
      remove_resolver_method(field_definition)
    end
  end
end
