# frozen_string_literal: true
module GraphqlMigrateExecution
  # These fields use GraphQL-Ruby's default, implicit resolution behavior. It's changing in the future, please audit these fields and choose a migration strategy:
  #
  #   - `--implicit=ignore`: Don't add any new configuration; use GraphQL-Ruby's future direct method send behavior (ie `object.public_send(field_name, **arguments)`)
  #   - `--implicit=hash_key`: Add a Symbol `hash_key: ...` configuration
  #   - `--implicit=hash_key_string`: Add a String `hash_key: ...` configuration
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
