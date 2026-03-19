# frozen_string_literal: true
module GraphqlMigrateExecution
  # These fields use GraphQL-Ruby's default, implicit resolution behavior. It's changing in the future:
  #  - __Currently__, it tries a combination of method calls and hash key lookups
  #  - __In the future__, it will only try a method call: `object.public_send(field_name, **field_args)`
  #
  # If your field _sometimes_ uses a method call, and other times uses a hash key, you'll have to implement that logic in the field itself
  #
  #. If your field always uses a method call, use `--implicit=ignore` to disable the warning from this refactor. (Your field will be supported as-is).
  #
  # If your field always uses a hash key, use `--implicit=hash_key` (to add a Symbol-based `hash_key: ...` configuration) or `--implicit=hash_key_string` (to add a String-based one).
  class Implicit < Strategy

    self.color = :YELLOW

    def migrate(field_definition)
      case @migration.implicit
      when "ignore", nil
        # do nothing
      when "hash_key"
        inject_field_keyword(field_definition, :hash_key, field_definition.name.inspect)
      when "hash_key_string"
        inject_field_keyword(field_definition, :hash_key, field_definition.name.to_s.inspect)
      else
        raise ArgumentError, "Unexpected `--implicit` argument: #{@migration.implicit.inspect}"
      end
    end
  end
end
