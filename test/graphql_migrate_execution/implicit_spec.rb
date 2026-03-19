# frozen_string_literal: true
require "test_helper"

describe "Implicit migration strategy" do
  include MigrationHelpers

  it "Adds symbol or string hash keys" do
    input = <<~RUBY
    module Mutations
      class DoSomething < Mutations::BaseMutation
        field :result, String
        field :error, String

        def resolve
          Call.something.else
        end
      end
    end
    RUBY


    expected_analyze_result = <<-TEXT
app.rb: Found 2 field definitions:

Implicit (2):

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
          Call.something.else
        end
      end
    end
    RUBY

    assert_equal expected_migrate_result, migrate(input, implicit: "hash_key")

    expected_migrate_string_result = <<~RUBY
    module Mutations
      class DoSomething < Mutations::BaseMutation
        field :result, String, hash_key: "result"
        field :error, String, hash_key: "error"

        def resolve
          Call.something.else
        end
      end
    end
    RUBY

    assert_equal expected_migrate_string_result, migrate(input, implicit: "hash_key_string")
  end

  it "can ignore" do
    input = <<~RUBY
    module Mutations
      class DoSomething < Mutations::BaseMutation
        field :result, String
        field :error, String

        def resolve
          Call.something.else
        end
      end
    end
    RUBY

    expected_analyze_result = <<-TEXT
app.rb: Found 2 field definitions:

DoNothing (2):

  - DoSomething.result   (nil -> nil) @ app.rb:3
  - DoSomething.error    (nil -> nil) @ app.rb:4

    TEXT

    assert_equal expected_analyze_result, analyze(input, implicit: "ignore")
    expected_migrate_ignore_result = <<~RUBY
    module Mutations
      class DoSomething < Mutations::BaseMutation
        field :result, String
        field :error, String

        def resolve
          Call.something.else
        end
      end
    end
    RUBY

    assert_equal expected_migrate_ignore_result, migrate(input, implicit: "ignore")
  end
end
