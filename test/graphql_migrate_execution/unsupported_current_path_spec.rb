# frozen_string_literal: true
require "test_helper"
require_relative "./strategy_helpers"

describe "UnsupportedCurrentPath migration strategy" do
  include GraphQLMigrateExecutionStrategyHelpers
  before do
    @strategy_class = GraphqlMigrateExecution::UnsupportedCurrentPath
  end
 it "Reports Hash-style current_path usage" do
    input = <<~RUBY
    class Thing < Types::BaseObject
      field :user_points, Int

      def user_points
        context[:current_path]
      end
    end
    RUBY


    expected_result = <<~TEXT.chomp
Found 1 field definition:

UnsupportedCurrentPath (1):

  These use `context[:current_path]` or `context.current_path` which isn't supported. Refactor these fields then try migrating again. (Open an issue on GraphQL-Ruby's GitHub repo to discuss further.)

  - Thing.user_points   (:type_instance_method -> :user_points) @ app.rb:2
    TEXT

    assert_equal expected_result, analyze(input)
  end

 it "Reports Method-style current_path usage" do
    input = <<~RUBY
    class Thing < Types::BaseObject
      field :user_points, Int

      def user_points
        context.current_path
      end
    end
    RUBY


    expected_result = <<~TEXT.chomp
Found 1 field definition:

UnsupportedCurrentPath (1):

  These use `context[:current_path]` or `context.current_path` which isn't supported. Refactor these fields then try migrating again. (Open an issue on GraphQL-Ruby's GitHub repo to discuss further.)

  - Thing.user_points   (:type_instance_method -> :user_points) @ app.rb:2
    TEXT

    assert_equal expected_result, analyze(input)
  end
end
