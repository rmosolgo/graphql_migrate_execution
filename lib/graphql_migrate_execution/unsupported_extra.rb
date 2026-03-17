module GraphqlMigrateExecution
  # These use a field `extra` which isn't supported. Remove this configuration and refactor the field, then try migrating again.
  #
  # (Currently, only :ast_node and :lookahead are currently supported. Please open an issue on GraphQL-Ruby if this is a problem for you.)
  class UnsupportedExtra < Strategy
    self.color = :RED
  end
end
