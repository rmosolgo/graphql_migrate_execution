# frozen_string_literal: true
require_relative "./dataloader_all"

module GraphqlMigrateExecution
  # These fields return an array of values using Dataloader, based on a method or attribute of `object`. They can be migrated to `dataloader_all` calls, using `object.flat_map`.
  #
  # **TODO**: This is not quite right yet. It returns a single array instead of an array of arrays.
  #
  # Instead, this should create an Array of arrays using `dataloader.request_all`.
  class DataloaderBatch < DataloaderAll
    self.color = :GREEN

    def migrate(field_definition)
      raise "This isn't properly implemented yet"
      inject_resolve_keyword(field_definition, :resolve_batch)
      inject_batch_dataloader_method(field_definition, [:request_all, :load_all], :dataload_all, "flat_map")
    end

    def cleanup(field_definition)
      remove_resolver_method(field_definition)
    end
  end
end
