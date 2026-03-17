# frozen_string_literal: true
require "test_helper"

describe "AddFuture Action" do
  it "produces new source code" do
    path = "test/graphql_migrate_execution/fixtures/product.rb"
    source = File.read(path)
    action = GraphqlMigrateExecution::AddFuture.new(OpenStruct.new(colorable: nil), path, source)
    action.run
    assert_equal File.read("test/graphql_migrate_execution/fixtures/product.migrated.rb"), action.result_source
  end

  it "produces new source code with dataloader usage" do
    path = "test/graphql_migrate_execution/fixtures/dataload.rb"
    source = File.read(path)
    action = GraphqlMigrateExecution::AddFuture.new(OpenStruct.new(colorable: nil), path, source)
    action.run
    expected_path = "test/graphql_migrate_execution/fixtures/dataload.migrated.rb"
    assert_equal File.read(expected_path), action.result_source, "Output for #{path} matches #{expected_path}"
  end
end
