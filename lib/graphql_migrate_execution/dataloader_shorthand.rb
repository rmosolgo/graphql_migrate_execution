# frozen_string_literal: true
module GraphqlMigrateExecution
  # These fields can use a `dataload: ...` configuration. They use a single, simple dataloader call:
  #
  # - `dataload_assocation(...)`
  # - `dataload_record(...)`
  # - `dataload(...)` or `dataloader.with(...).load(...)`
  #
  # and they don't make calls on `self` inside those expressions (except for `object` and `context`).
  class DataloaderShorthand < Strategy
    self.color = :GREEN

    def migrate(field_definition)
      rm = field_definition.resolver_method
      if (da = rm.dataload_association)
        dataload_config = "{ association: #{da.inspect} }"
      elsif (dr = rm.dataload_record)
        dataload_config = "{ model: #{dr}".dup
        if (dr_using = rm.dataload_record_using)
          dataload_config << ", using: #{dr_using.inspect}"
        end
        if (fb = rm.dataload_record_find_by)
          dataload_config << ", find_by: #{fb.inspect}"
        end
        dataload_config << " }"
      elsif rm.source_arg_nodes.empty?
        dataload_config = rm.source_class_node.full_name
      else
        dataload_config = "{ with: #{rm.source_class_node.full_name}, by: [#{rm.source_arg_nodes.map { |n| Visitor.source_for_constant_node(n) }.join(", ")}] }"
      end
      inject_field_keyword(field_definition, :dataload, dataload_config)
    end

    def cleanup(field_definition)
      remove_resolver_method(field_definition)
    end
  end
end
