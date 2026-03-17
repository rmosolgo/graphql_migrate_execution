module GraphqlMigrateExecution
  class UnsupportedExtra < Strategy
    DESCRIPTION = "These use a field `extra` which isn't supported. Remove this configuration and refactor the field, then try migrating again.\n\n(Currently, only :ast_node and :lookahead are currently supported. Please open an issue on GraphQL-Ruby if this is a problem for you.)"
    self.color = :RED
  end
end
