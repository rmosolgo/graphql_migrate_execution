# frozen_string_literal: true
module GraphqlMigrateExecution
  class ResolveBatch < Strategy
    self.color = :GREEN

    def add_future(field_definition, new_source)
      raise "Not implemented yet -- this doesn't actually migrate code, just cleans up old code."
    end

    def remove_legacy(field_definition, new_source)
      remove_field_keyword(new_source, field_definition, :resolver_method)
      remove_resolver_method(new_source, field_definition)
    end
  end
end
