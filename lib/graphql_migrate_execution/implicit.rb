# frozen_string_literal: true
module GraphqlMigrateExecution
  # These fields use GraphQL-Ruby's default, implicit resolution behavior. It's changing in the future, please audit these fields and choose a migration strategy:
  #
  #   - `--preserve-implicit`: Don't add any new configuration; use GraphQL-Ruby's future direct method send behavior (ie `object.public_send(field_name, **arguments)`)
  #   - `--shim-implicit`: Add a method to preserve GraphQL-Ruby's previous dynamic implicit behavior (ie, checking for `respond_to?` and `key?`)
  class Implicit < Strategy

    self.color = :YELLOW
  end
end
