# frozen_string_literal: true
require "test_helper"

describe "HashKey migration strategy" do
  include MigrationHelpers

  it "Identifies resolvers which should use symbol hash keys" do
    input = <<~RUBY
    module Mutations
      class DoSomething < Mutations::BaseMutation
        field :result, String
        field :error, String

        def resolve
          {
            result: get_result,
            error: get_error
          }
        end
      end
    end
    RUBY


    expected_analyze_result = <<-TEXT
app.rb: Found 2 field definitions:

HashKey (2):

  - DoSomething.result   (nil -> nil) @ app.rb:3
  - DoSomething.error    (nil -> nil) @ app.rb:4

    TEXT

    assert_equal expected_analyze_result, analyze(input)

    expected_migrate_result = <<~RUBY
    module Mutations
      class DoSomething < Mutations::BaseMutation
        field :result, String, hash_key: :result
        field :error, String, hash_key: :error

        def resolve
          {
            result: get_result,
            error: get_error
          }
        end
      end
    end
    RUBY

    assert_equal expected_migrate_result, migrate(input)
  end

  it "Identifies resolvers which should use String hash keys" do
    input = <<~RUBY
    module Mutations
      class DoSomething < Mutations::BaseMutation
        field :result, String
        field :error, String

        def resolve
          result = if went_wrong?
            { "error" => get_error }
          else
            { "result" => get_result }
          end
          result
        end
      end
    end
    RUBY


    expected_analyze_result = <<~TEXT
app.rb: Found 2 field definitions:

HashKey (2):

  - DoSomething.result   (nil -> nil) @ app.rb:3
  - DoSomething.error    (nil -> nil) @ app.rb:4

    TEXT

    assert_equal expected_analyze_result, analyze(input)

    expected_migrate_result = <<~RUBY
    module Mutations
      class DoSomething < Mutations::BaseMutation
        field :result, String, hash_key: "result"
        field :error, String, hash_key: "error"

        def resolve
          result = if went_wrong?
            { "error" => get_error }
          else
            { "result" => get_result }
          end
          result
        end
      end
    end
    RUBY

    assert_equal expected_migrate_result, migrate(input)
    assert_equal expected_migrate_result, migrate(expected_migrate_result), "It doesn't re-add the configuration"
  end


  it "skips resolvers which don't need hash keys" do
    input = <<~RUBY
    module Mutations
      class DoSomething < Mutations::BaseMutation
        field :result, String
        field :error, String

        def resolve
          not_result = if went_wrong?
            { "error" => get_error }
          else
            { "result" => get_result }
          end
          get_result(not_result)
        end
      end
    end
    RUBY


    expected_analyze_result = <<~TEXT
app.rb: Found 2 field definitions:

Implicit (2):

  - DoSomething.result   (nil -> nil) @ app.rb:3
  - DoSomething.error    (nil -> nil) @ app.rb:4

    TEXT

    assert_equal expected_analyze_result, analyze(input)
  end
end
