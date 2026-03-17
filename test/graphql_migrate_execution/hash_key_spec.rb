# frozen_string_literal: true
require "test_helper"
require_relative "./strategy_helpers"

describe "HashKey migration strategy" do
  include GraphQLMigrateExecutionStrategyHelpers

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


    expected_analyze_result = <<-TEXT.chomp
Found 2 field definitions:

HashKey (2):

  These can be future-proofed with `hash_key: ...` configurations

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

    assert_equal expected_migrate_result, add_future(input)
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


    expected_analyze_result = <<-TEXT.chomp
Found 2 field definitions:

HashKey (2):

  These can be future-proofed with `hash_key: ...` configurations

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

    assert_equal expected_migrate_result, add_future(input)
    assert_equal expected_migrate_result, add_future(expected_migrate_result), "It doesn't re-add the configuration"
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


    expected_analyze_result = <<-TEXT.chomp
Found 2 field definitions:

Implicit (2):

  These fields use GraphQL-Ruby's default, implicit resolution behavior. It's changing in the future, please audit these fields and choose a migration strategy:

    - `--preserve-implicit`: Don't add any new configuration; use GraphQL-Ruby's future direct method send behavior (ie `object.public_send(field_name, **arguments)`)
    - `--shim-implicit`: Add a method to preserve GraphQL-Ruby's previous dynamic implicit behavior (ie, checking for `respond_to?` and `key?`)

  - DoSomething.result   (nil -> nil) @ app.rb:3
  - DoSomething.error    (nil -> nil) @ app.rb:4
    TEXT

    assert_equal expected_analyze_result, analyze(input)
  end
end
