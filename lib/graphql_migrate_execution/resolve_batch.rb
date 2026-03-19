# frozen_string_literal: true
module GraphqlMigrateExecution
  # This is just used for cleaning up code.
  class ResolveBatch < Strategy
    self.color = :GREEN

    def migrate(field_definition)
      raise "Not implemented yet -- this doesn't actually migrate code, just cleans up old code."
    end

    def cleanup(field_definition)
      remove_field_keyword(field_definition, :resolver_method)
      remove_resolver_method(field_definition)
    end
  end
end
