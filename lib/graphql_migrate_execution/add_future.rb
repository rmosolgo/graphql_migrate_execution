# frozen_string_literal: true
module GraphqlMigrateExecution
  class AddFuture < Action
    def run
      super
      call_method_on_strategy(:add_future)
    end
  end
end
