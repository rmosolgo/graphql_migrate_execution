# frozen_string_literal: true
module GraphqlMigrateExecution
  # This field calls dataloader with some property of `object`. It can be migrated to use `dataload_all(...)` and `objects.map { |object| ... }`.
  #
  # ```ruby
  # # Previous:
  # def my_field
  #   dataload(Sources::GetThing, object.some_attribute)
  # end
  #
  # # New:
  # def self.my_field(objects, context)
  #   context.dataload_all(Sources::GetThing, objects.map { |object| object.some_attribute })
  # end
  # ```
  class DataloaderAll < Strategy
    self.color = :GREEN

    def migrate(field_definition)
      inject_resolve_keyword(field_definition, :resolve_batch)
      inject_batch_dataloader_method(field_definition, [:request, :load], :dataload, "map")
    end

    def cleanup(field_definition)
      remove_resolver_method(field_definition)
    end

    private

    def inject_batch_dataloader_method(field_definition, longhand_methods, shorthand_method, map_method)
      def_node = field_definition.resolver_method.node
      call_node = def_node.body.body.first
      case call_node.name
      when *longhand_methods
        load_arg_node = call_node.arguments.arguments.first
        with_node = call_node.receiver
        source_class_node, *source_args_nodes = with_node.arguments
      when shorthand_method
        source_class_node, *source_args_nodes, load_arg_node = call_node.arguments.arguments
      else
        raise ArgumentError, "Unexpected DataloadAll method name: #{def_node.name.inspect}"
      end

      old_load_arg_s = load_arg_node.slice
      new_load_arg_s = case old_load_arg_s
      when "object"
        "objects"
      when /object((\.|\[)[:a-zA-Z0-9_\.\"\'\[\]]+)/
        call_chain = $1
        if /^\.[a-z0-9_A-Z]+$/.match?(call_chain)
          "objects.#{map_method}(&:#{call_chain[1..-1]})"
        else
          "objects.#{map_method} { |obj| obj#{call_chain} }"
        end
      when /([A-Z][a-zA-Z_0-9]*(\.|\[)[:a-zA-Z0-9_\.\"\'\[\]]+)/
        # Constant call
        "objects.#{map_method} { |_obj| #{$1} }"
      else
        raise ArgumentError, "Failed to transform Dataloader argument: #{old_load_arg_s.inspect}"
      end
      new_args = [
        source_class_node.slice,
        *source_args_nodes.map(&:slice),
        new_load_arg_s
      ].join(", ")

      old_method_source = def_node.slice_lines
      new_method_source = old_method_source.sub(/def ([a-z_A-Z0-9]+)(\(|$| )/) do
        is_adding_args = $2.size == 0
        "def self.#{$1}#{is_adding_args ? "(" : $2}objects, context#{is_adding_args ? ")" : ", "}"
      end
      new_method_source.sub!(call_node.slice, "context.dataload_all(#{new_args})")

      combined_new_source = new_method_source + "\n" + old_method_source
      @result_source.sub!(old_method_source, combined_new_source)
    end
  end
end
