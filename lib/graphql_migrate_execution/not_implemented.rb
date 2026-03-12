# frozen_string_literal: true
module GraphqlMigrateExecution
  class NotImplemented < Strategy
    DESCRIPTION = "GraphQL-Ruby doesn't have a migration strategy for these fields. Automated migration may be possible -- please open an issue on GitHub with the source for these fields to investigate."
    self.color = :RED
  end
end
