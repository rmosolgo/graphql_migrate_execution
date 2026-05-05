# frozen_string_literal: true
require "test_helper"

describe "FallbackValue migration strategy" do
  include MigrationHelpers

  it "Identifies fallback_value" do
    input = <<-RUBY # Don't use squiggles to check leading whitespace preservation
    class Thing < Types::BaseObject
      field :user_points, Int, fallback_value: 100

      field :user_ranking, Int, fallback_value: TOP_20
    end
    RUBY


    expected_result = <<-TEXT
app.rb: Found 2 field definitions:

FallbackValue (2):

  - Thing.user_points    (:fallback_value -> 100) @ app.rb:2
  - Thing.user_ranking   (:fallback_value -> "TOP_20") @ app.rb:4

    TEXT
    assert_equal expected_result, analyze(input)


    expected_migration = <<-RUBY
    class Thing < Types::BaseObject
      field :user_points, Int, fallback_value: 100, resolve_static: true

      def self.user_points(context)
        100
      end

      field :user_ranking, Int, fallback_value: TOP_20, resolve_static: true

      def self.user_ranking(context)
        TOP_20
      end
    end
    RUBY

    assert_equal expected_migration, migrate(input)

    expected_cleanup = <<-RUBY
    class Thing < Types::BaseObject
      field :user_points, Int, resolve_static: true

      def self.user_points(context)
        100
      end

      field :user_ranking, Int, resolve_static: true

      def self.user_ranking(context)
        TOP_20
      end
    end
    RUBY
    assert_equal expected_cleanup, cleanup(expected_migration)
  end
end
