# frozen_string_literal: true
require_relative "./dataloader_all"

module GraphqlMigrateExecution
  class DataloaderBatch < DataloaderAll
    DESCRIPTION = <<~DESC
    These fields can be rewritten to dataload in a `resolve_batch:` method.
    DESC

    self.color = :GREEN

    def add_future(field_definition, new_source)
      inject_resolve_keyword(new_source, field_definition, :resolve_batch)
      inject_batch_dataloader_method(field_definition, new_source, [:request_all, :load_all], :dataload_all, "flat_map")
    end

    def remove_legacy(field_definition, new_source)
      remove_resolver_method(new_source, field_definition)
    end
  end
end
