# frozen_string_literal: true
module GraphqlMigrateExecution
  class FieldDefinition
    def initialize(type_definition, name, node)
      @type_definition = type_definition
      @name = name.to_sym
      @node = node

      @resolve_mode = nil
      @hash_key = nil
      @resolver = nil
      @type_instance_method = nil
      @object_direct_method = nil
      @dig = nil
      @already_migrated = nil

      @resolver_method = nil
      @unknown_options = []
    end

    def migration_strategy
      if unsupported_extras?
        return UnsupportedExtra
      elsif resolver_method&.uses_current_path
        return UnsupportedCurrentPath
      end

      if @type_definition.is_resolver && @type_definition.returns_hash?
        return HashKey
      end

      case resolve_mode
      when nil, :implicit_resolve
        if @type_definition.migration.implicit == "ignore"
          DoNothing
        else
          Implicit
        end
      when :hash_key, :object_direct_method, :dig
        DoNothing
      when :already_migrated
        case @already_migrated.keys.first
        when :resolve_each
          ResolveEach
        when :resolve_static
          ResolveStatic
        when :resolve_batch
          ResolveBatch
        when :resolve_legacy_instance_method
          DoNothing
        else
          raise ArgumentError, "Unexpected already_migrated: #{@already_migrated.inspect}"
        end
      when :type_instance_method
        resolver_method.migration_strategy
      when :resolver
        DoNothing
      else
        raise "No migration strategy for resolve_mode #{@resolve_mode.inspect}"
      end
    end

    attr_reader :name, :node, :unknown_options, :type_definition, :resolve_mode

    def source
      node.location.slice
    end

    def future_resolve_shorthand
      method_name = resolver_method.name
      name == method_name ? true : method_name
    end

    attr_writer :resolve_mode

    attr_accessor :hash_key, :object_direct_method, :type_instance_method, :resolver, :dig, :already_migrated

    def path
      @path ||= "#{type_definition.name}.#{@name}"
    end

    def source_line
      @node.location.start_line
    end

    def resolver_method
      case @resolver_method
      when nil
        method_name = @type_instance_method || @name
        @resolver_method = @type_definition.resolver_methods[method_name] || :NOT_FOUND
        resolver_method
      when :NOT_FOUND
        nil
      else
        @resolver_method
      end
    end

    def implicit_resolve
      @name
    end

    def resolve_mode_key
      resolve_mode && public_send(resolve_mode)
    end

    def check_for_resolver_method
      if resolve_mode.nil? && (resolver_method)
        @resolve_mode = :type_instance_method
        @type_instance_method = @name
      end
      nil
    end

    private

    def unsupported_extras?
      (kwargs = @node.arguments.arguments.last).is_a?(Prism::KeywordHashNode) &&
        (extras_el = kwargs.elements.find { |el| el.key.is_a?(Prism::SymbolNode) && el.key.unescaped == "extras" }) &&
        ((extras_val = extras_el.value).is_a?(Prism::ArrayNode)) &&
        (extras_val.elements.any? { |el| (!el.is_a?(Prism::SymbolNode)) || (el.unescaped != "ast_node" && el.unescaped != "lookahead")})
    end
  end
end
