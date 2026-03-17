# frozen_string_literal: true
module GraphqlMigrateExecution
  class DataloaderBatch < Strategy
    DESCRIPTION = <<~DESC
    These fields can be rewritten to dataload in a `resolve_batch:` method.
    DESC

    def add_future(field_definition, new_source)
      inject_resolve_keyword(new_source, field_definition, :resolve_batch)
    end

    def remove_legacy(field_definition, new_source)
      remove_resolver_method(new_source, field_definition)
    end
  end
end
