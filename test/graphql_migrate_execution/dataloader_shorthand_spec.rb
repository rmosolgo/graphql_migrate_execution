# frozen_string_literal: true
require "test_helper"

describe "DataloaderShorthand migration strategy" do
  include MigrationHelpers

  it "turns single dataloader .load calls to field configs" do
    input = <<-RUBY # Don't use squiggles to check leading whitespace preservation
    class Thing < Types::BaseObject
      field :user_points, Int, null: false

      def user_points
        context.dataloader.with(Sources::UserPoints).load(object)
      end
    end
    RUBY


    expected_result = <<-RUBY
    class Thing < Types::BaseObject
      field :user_points, Int, null: false, dataload: Sources::UserPoints

      def user_points
        context.dataloader.with(Sources::UserPoints).load(object)
      end
    end
    RUBY

    assert_equal expected_result, migrate(input)
    assert input.end_with?("\n")
    assert migrate(input).end_with?("\n")

    assert_equal cleanup(expected_result), <<-RUBY
    class Thing < Types::BaseObject
      field :user_points, Int, null: false, dataload: Sources::UserPoints
    end
    RUBY
  end

  it "turns dataload to config when global source args" do
    expected_result = <<~RUBY
    module Thing
      include Types::BaseInterface
      field :user_points, Int, dataload: { with: Sources::UserPoints, by: [SomeConst, 1, false, nil, :stuff, A::B] }

      def user_points(mode:)
        dataload(Sources::UserPoints, SomeConst, 1, false, nil, :stuff, A::B, object)
      end
    end
    RUBY

    assert_equal expected_result, migrate(<<~RUBY)
    module Thing
      include Types::BaseInterface
      field :user_points, Int

      def user_points(mode:)
        dataload(Sources::UserPoints, SomeConst, 1, false, nil, :stuff, A::B, object)
      end
    end
    RUBY

    assert_equal cleanup(expected_result), <<~RUBY
    module Thing
      include Types::BaseInterface
      field :user_points, Int, dataload: { with: Sources::UserPoints, by: [SomeConst, 1, false, nil, :stuff, A::B] }
    end
    RUBY
  end

  it "handles dataload_association" do
    expected_result = <<~RUBY
    class Thing < BaseObject
      field :user_points, Int, dataload: { association: true }

      def user_points
        dataload_association(:user_points)
      end

      field :user_points_2, Int, dataload: { association: :user_points }

      def user_points_2
        dataload_association(:user_points)
      end
    end
    RUBY

    assert_equal expected_result, migrate(<<~RUBY)
    class Thing < BaseObject
      field :user_points, Int

      def user_points
        dataload_association(:user_points)
      end

      field :user_points_2, Int

      def user_points_2
        dataload_association(:user_points)
      end
    end
    RUBY

    assert_equal cleanup(expected_result), <<~RUBY
    class Thing < BaseObject
      field :user_points, Int, dataload: { association: true }

      field :user_points_2, Int, dataload: { association: :user_points }
    end
    RUBY
  end
end
