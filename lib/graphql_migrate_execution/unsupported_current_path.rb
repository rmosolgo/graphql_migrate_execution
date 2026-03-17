module GraphqlMigrateExecution
  class UnsupportedCurrentPath < Strategy
    DESCRIPTION = "These use `context[:current_path]` or `context.current_path` which isn't supported. Refactor these fields then try migrating again. (Open an issue on GraphQL-Ruby's GitHub repo to discuss further.)"
    self.color = :RED
  end
end
