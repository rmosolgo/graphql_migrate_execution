# frozen_string_literal: true
require "test_helper"

describe "Migration" do
  include MigrationHelpers
  it "removes legacy definitions" do
    assert_file_action :cleanup, "test/graphql_migrate_execution/fixtures/product.migrate.rb"
  end

  it "adds new configs" do
    assert_file_action :migrate, "test/graphql_migrate_execution/fixtures/product.rb"
  end

  it "produces new configs code with dataloader usage" do
    assert_file_action :migrate, "test/graphql_migrate_execution/fixtures/dataload.rb"
  end

  it "analyzes with dataloader usage" do
    assert_file_action :analyze, "test/graphql_migrate_execution/fixtures/dataload.rb"
  end

  it "analyzes future files" do
    assert_file_action :analyze, "test/graphql_migrate_execution/fixtures/product.cleanup.rb"
  end

  it "analyzes migrated files" do
    assert_file_action :analyze, "test/graphql_migrate_execution/fixtures/product.migrate.rb"
  end

  it "analyzes files" do
    assert_file_action :analyze, "test/graphql_migrate_execution/fixtures/product.rb"

  end
end
