# frozen_string_literal: true
require "test_helper"
describe "RemoveLegacy Action" do
  it "produces new source code" do
    path = "test/graphql_migrate_execution/fixtures/product.migrated.rb"
    source = File.read(path)
    action = GraphqlMigrateExecution::RemoveLegacy.new(OpenStruct.new(colorable: nil, dry_run: true), path, source)
    action.run
    assert_equal File.read("test/graphql_migrate_execution/fixtures/product.future.rb"), action.result_source
  end
end
