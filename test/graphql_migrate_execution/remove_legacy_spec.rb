# frozen_string_literal: true
require "test_helper"
describe "RemoveLegacy Action" do
  it "produces new source code" do
    path = "test/graphql_migrate_execution/fixtures/product.migrated.rb"
    source = File.read(path)
    new_source = GraphqlMigrateExecution::RemoveLegacy.new(nil, path, source).run
    assert_equal File.read("test/graphql_migrate_execution/fixtures/product.future.rb"), new_source
  end
end
