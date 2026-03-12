# frozen_string_literal: true
require "test_helper"

describe "AddFuture Action" do
  it "produces new source code" do
    path = "test/graphql_migrate_execution/fixtures/product.rb"
    source = File.read(path)
    new_source = GraphqlMigrateExecution::AddFuture.new(nil, path, source).run
    assert_equal File.read("test/graphql_migrate_execution/fixtures/product.migrated.rb"), new_source
  end

  it "produces new source code with dataloader usage" do
    path = "test/graphql_migrate_execution/fixtures/dataload.rb"
    source = File.read(path)
    new_source = GraphqlMigrateExecution::AddFuture.new(nil, path, source).run
    assert_equal File.read("test/graphql_migrate_execution/fixtures/dataload.migrated.rb"), new_source
  end
end
