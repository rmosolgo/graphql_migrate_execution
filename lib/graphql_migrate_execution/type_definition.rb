# frozen_string_literal: true
module GraphqlMigrateExecution
  class TypeDefinition
    def initialize(name)
      @name = name
      @field_definitions = {}
      @resolver_methods = {}
      @is_resolver = false
    end

    attr_accessor :is_resolver

    attr_reader :resolver_methods, :name, :field_definitions

    def field_definition(name, node)
      @field_definitions[name] = FieldDefinition.new(self, name, node)
    end

    def resolver_method(name, node)
      @resolver_methods[name] = ResolverMethod.new(name, node)
    end

    def returns_hash?
      @resolver_methods.each_value.first.returns_hash?
    end

    def returns_string_hash?
      @resolver_methods.each_value.first.returns_string_hash?
    end
  end
end
