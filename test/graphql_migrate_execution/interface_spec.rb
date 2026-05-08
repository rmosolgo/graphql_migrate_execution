# frozen_string_literal: true
require "test_helper"

describe "Putting methods in resolver_methods blocks" do
  include MigrationHelpers

  it "adds new configs" do
    assert_file_action :migrate, "test/graphql_migrate_execution/fixtures/interface.rb"
  end

end
