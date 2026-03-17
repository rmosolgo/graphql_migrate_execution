# frozen_string_literal: true
module GraphqlMigrateExecution
  class ResolverMethod
    def initialize(name, node)
      @name = name
      @node = node
      @parameter_names = if node.parameters
        node.parameters.keywords.map(&:name)
      else
        []
      end
      @self_sends = Set.new
      @calls_object = false
      @calls_context = false
      @calls_class = false
      @calls_dataloader = false
      @dataloader_call = false
      @uses_current_path = false
      @dataload_association = nil
      @dataload_record = nil
      @dataload_record_using = nil
      @dataload_record_find_by = nil
      @return_expressions = nil
    end

    attr_reader :name, :node, :parameter_names, :self_sends

    attr_reader :source_class_node, :source_arg_nodes, :load_arg_node, :dataload_association, :dataload_record, :dataload_record_using, :dataload_record_find_by

    attr_accessor :calls_object, :calls_context, :calls_class, :calls_dataloader, :uses_current_path

    attr_accessor :dataloader_call

    def source
      node.location.slice_lines
    end

    def migration_strategy
      calls_to_self = self_sends.to_a
      if @calls_context
        calls_to_self.delete(:context)
      end
      if @calls_object
        calls_to_self.delete(:object)
      end

      calls_to_self.delete(:dataloader)
      calls_to_self.delete(:dataload_association)
      calls_to_self.delete(:dataload_record)
      calls_to_self.delete(:dataload)
      calls_to_self.delete(:dataload_all)

      # Global-ish methods:
      calls_to_self.delete(:raise)

      # Locals:
      calls_to_self -= @parameter_names

      if calls_to_self.empty?
        if calls_dataloader
          if !dataloader_call
            return DataloaderManual
          end

          call_node = node.body.body.first
          case call_node.name
          when :dataload
            @source_class_node = call_node.arguments.arguments.first
            @source_arg_nodes = call_node.arguments.arguments[1...-1]
            @load_arg_node = call_node.arguments.arguments.last
          when :dataload_association
            if (assoc_args = call_node.arguments.arguments).size == 1 &&
                ((assoc_arg = assoc_args.first).is_a?(Prism::SymbolNode))
              assoc_sym = assoc_arg.unescaped.to_sym
              @dataload_association = assoc_sym == name ? true : assoc_sym
            end
          when :dataload_record
            if (record_args = call_node.arguments.arguments) &&
                (record_arg = record_args.first) &&
                (record_arg.is_a?(Prism::ConstantReadNode) || record_arg.is_a?(Prism::ConstantPathNode)) &&
                (using_arg = record_args[1]) &&
                # Must be `object.{something}`
                (using_arg.is_a?(Prism::CallNode)) &&
                (using_arg.receiver.is_a?(Prism::CallNode) && using_arg.receiver.name == :object)
              @dataload_record = record_arg.full_name
              @dataload_record_using = using_arg.name

              if (kwargs = record_args.last).is_a?(Prism::KeywordHashNode) && (find_by_kwarg = kwargs.elements.find { |el| el.key.is_a?(Prism::SymbolNode) && el.key.unescaped == "find_by" })
                find_by_node = find_by_kwarg.value
                @dataload_record_find_by = find_by_node.unescaped.to_sym # Assumes a SymbolNode
              end
            end
          else
            if (source_call = call_node.receiver) # eg dataloader.with(...).load(...)
              @source_class_node = source_call.arguments.arguments.first
              @source_arg_nodes = source_call.arguments.arguments[1..-1]
              @load_arg_node = call_node.arguments.arguments.last
            end
          end

          input_is_object = @load_arg_node.is_a?(Prism::CallNode) && @load_arg_node.name == :object
          # Guess whether these args are free of runtime context:
          shortcutable_source_args = @source_arg_nodes && (@source_arg_nodes.empty? || (@source_arg_nodes.all? { |a| Visitor.constant_node?(a) }))
          source_ref_is_constant = @source_class_node.is_a?(Prism::ConstantPathNode) || @source_class_node.is_a?(Prism::ConstantReadNode)
          if source_ref_is_constant && shortcutable_source_args && input_is_object
            DataloaderShorthand
          else
            case call_node.name
            when :load, :request, :dataload
              DataloaderAll
            when :load_all, :request_all, :dataload_all
              DataloaderBatch
            when :dataload_association, :dataload_record
              DataloaderShorthand
            else
              DataloaderManual
            end
          end
        elsif calls_object
          ResolveEach
        else
          ResolveStatic
        end
      else
        p [calls_to_self]
        NotImplemented
      end
    end

    def returns_hash?
      return_expressions.all? { |exp_node| exp_node.is_a?(Prism::HashNode) || (exp_node.is_a?(Prism::CallNode) && exp_node.name == :new && exp_node.receiver.is_a?(Prism::ConstantReadNode) && exp_node.receiver.name == :Hash) }
    end

    def return_expressions
      if @return_expressions.nil?
        @return_expressions = []
        find_return_expressions(@node)
      end
      @return_expressions
    end

    def returns_string_hash?
      return_expressions.any? { |exp_node| exp_node.is_a?(Prism::HashNode) && exp_node.elements.all? { |el| el.key.is_a?(Prism::StringNode) } }
    end

    private

    def find_return_expressions(node)
      case node
      when Prism::DefNode
        find_return_expressions(node.body)
      when Prism::StatementsNode
        find_return_expressions(node.body.last)
      when Prism::IfNode # TODO else, `?`, case
        find_return_expressions(node.statements)
        find_return_expressions(node.subsequent)
      when Prism::ElseNode, Prism::WhenNode
        find_return_expressions(node.statements)
      when Prism::UnlessNode
        find_return_expressions(node.statements)
        find_return_expressions(node.else_clause)
      when Prism::CaseNode
        node.conditions.each do |cond_node|
          find_return_expressions(cond_node)
        end
      when Prism::ReturnNode
        find_return_expressions(node.arguments.first)
      when Prism::LocalVariableReadNode
        if (lv_write_node = @node.body.body.find { |n| n.is_a?(Prism::LocalVariableWriteNode) && n.name == node.name })
          find_return_expressions(lv_write_node.value)
        else
          # Couldn't find assignment :'(
          @return_expressions << node
        end
      else
        # This is an expression that produces a return value
        @return_expressions << node
      end
    end
  end
end
