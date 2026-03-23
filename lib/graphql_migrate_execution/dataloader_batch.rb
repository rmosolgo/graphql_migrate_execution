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
      inject_resolve_keyword(field_definition, :resolve_batch)
      # inject_batch_dataloader_method(field_definition, [:request_all, :load_all], :dataload_all, "flat_map")

      def_node = field_definition.resolver_method.node
      call_node = def_node.body.body.first
      case call_node.name
      when :request_all, :load_all
        load_arg_node = call_node.arguments.arguments.first
        with_node = call_node.receiver
        source_class_node, *source_args_nodes = with_node.arguments
      when :dataload_all
        source_class_node, *source_args_nodes, load_arg_node = call_node.arguments.arguments
      else
        raise ArgumentError, "Unexpected DataloadAll method name: #{def_node.name.inspect}"
      end

      old_load_arg_s = load_arg_node.slice
      new_load_arg_s = case old_load_arg_s
      when "object"
        "object"
      when /object((\.|\[)[:a-zA-Z0-9_\.\"\'\[\]]+)/
        call_chain = $1
        "object#{call_chain}"
      else
        raise ArgumentError, "Failed to transform Dataloader argument: #{old_load_arg_s.inspect}"
      end
      new_source_args = [
        source_class_node.slice,
        *source_args_nodes.map(&:slice)
      ].join(", ")

      old_method_source = def_node.slice_lines
      new_method_source = old_method_source.sub(/def ([a-z_A-Z0-9]+)(\(|$| )/) do
        is_adding_args = $2.size == 0
        "def self.#{$1}#{is_adding_args ? "(" : $2}objects, context#{is_adding_args ? ")" : ", "}"
      end

      old_source_lines = call_node.slice_lines
      leading_whitespace = old_source_lines[/^\s+/]

      new_method_body = <<~RUBY
        #{leading_whitespace}requests = objects.map { |object| context.dataloader.with(#{new_source_args}).request_all(#{new_load_arg_s}) }
        #{leading_whitespace}requests.map! { |reqs| reqs.map!(&:load) } # replace dataloader requests with loaded data
        #{leading_whitespace}requests
      RUBY

      new_method_source.sub!(old_source_lines, new_method_body)

      combined_new_source = new_method_source + "\n" + old_method_source
      @result_source.sub!(old_method_source, combined_new_source)
    end

    def cleanup(field_definition)
      remove_resolver_method(field_definition)
    end
  end
end
