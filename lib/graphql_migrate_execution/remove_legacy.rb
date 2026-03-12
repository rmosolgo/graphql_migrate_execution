# frozen_string_literal: true
module GraphqlMigrateExecution
  class RemoveLegacy < Action
    def run
      super
      call_method_on_strategy(:remove_legacy)
    end
  end
end
