# frozen_string_literal: true
require_relative "./dataloader_all"

module GraphqlMigrateExecution
  # These fields can be rewritten to dataload in a `resolve_batch:` method.

  class DataloaderBatch < DataloaderAll
    self.color = :GREEN

    def migrate(field_definition)
      inject_resolve_keyword(field_definition, :resolve_batch)
      inject_batch_dataloader_method(field_definition, [:request_all, :load_all], :dataload_all, "flat_map")
    end

    def cleanup(field_definition)
      remove_resolver_method(field_definition)
    end
  end
end
