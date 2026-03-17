# frozen_string_literal: true
require "test_helper"
require_relative "./strategy_helpers"

describe "UnsupportedExtra migration strategy" do
  include GraphQLMigrateExecutionStrategyHelpers
  before do
    @strategy_class = GraphqlMigrateExecution::UnsupportedExtra
  end

  it "Identifies unsupported extras" do
    input = <<-RUBY # Don't use squiggles to check leading whitespace preservation
    class Thing < Types::BaseObject
      field :user_points, Int, extras: [ :something_else, :ast_node ]

      def user_points
        context.dataloader.with(Sources::UserPoints).load(object)
      end
    end
    RUBY


    expected_result = <<-TEXT.chomp
Found 1 field definition:

UnsupportedExtra (1):

  These use a field `extra` which isn't supported. Remove this configuration and refactor the field, then try migrating again.

  (Currently, only :ast_node and :lookahead are currently supported. Please open an issue on GraphQL-Ruby if this is a problem for you.)

  - Thing.user_points   (:type_instance_method -> :user_points) @ app.rb:2
    TEXT

    assert_equal expected_result, analyze(input)
  end

  it "Allows supported extras" do
    input = <<-RUBY
    class Thing < Types::BaseObject
      field :user_points, Int, method: :points, extras: [ :lookahead, :ast_node ]
    end
    RUBY


    expected_result = <<-TEXT.chomp
Found 1 field definition:

DoNothing (1):

  These field definitions are already future-compatible. No migration is required.

  - Thing.user_points   (:object_direct_method -> :points) @ app.rb:2
    TEXT

    assert_equal expected_result, analyze(input)
  end
end
