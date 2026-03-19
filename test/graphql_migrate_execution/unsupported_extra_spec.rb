# frozen_string_literal: true
require "test_helper"

describe "UnsupportedExtra migration strategy" do
  include MigrationHelpers

  it "Identifies unsupported extras" do
    input = <<-RUBY # Don't use squiggles to check leading whitespace preservation
    class Thing < Types::BaseObject
      field :user_points, Int, extras: [ :something_else, :ast_node ]

      def user_points
        context.dataloader.with(Sources::UserPoints).load(object)
      end
    end
    RUBY


    expected_result = <<-TEXT
app.rb: Found 1 field definition:

UnsupportedExtra (1):

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


    expected_result = <<-TEXT
app.rb: Found 1 field definition:

DoNothing (1):

  - Thing.user_points   (:object_direct_method -> :points) @ app.rb:2

    TEXT

    assert_equal expected_result, analyze(input)
  end
end
