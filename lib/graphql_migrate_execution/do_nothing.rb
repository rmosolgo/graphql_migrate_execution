# frozen_string_literal: true
module GraphqlMigrateExecution
  # These field definitions are already future-compatible. No migration is required.
  class DoNothing < Strategy
    self.color = :GREEN
  end
end
