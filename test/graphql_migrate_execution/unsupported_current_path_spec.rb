# frozen_string_literal: true
require "test_helper"

describe "UnsupportedCurrentPath migration strategy" do
  include MigrationHelpers

 it "Reports Hash-style current_path usage" do
    input = <<~RUBY
    class Thing < Types::BaseObject
      field :user_points, Int

      def user_points
        context[:current_path]
      end
    end
    RUBY


    expected_result = <<~TEXT
app.rb: Found 1 field definition:

UnsupportedCurrentPath (1):

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


    expected_result = <<~TEXT
app.rb: Found 1 field definition:

UnsupportedCurrentPath (1):

  - Thing.user_points   (:type_instance_method -> :user_points) @ app.rb:2

    TEXT

    assert_equal expected_result, analyze(input)
  end
end
