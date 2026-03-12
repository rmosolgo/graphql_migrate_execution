# frozen_string_literal: true
module GraphqlMigrateExecution
  class DoNothing < Strategy
    DESCRIPTION = "These field definitions are already future-compatible. No migration is required."
  end
end
