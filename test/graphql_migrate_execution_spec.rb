# frozen_string_literal: true
require "test_helper"
require "open3"

describe "GraphqlMigrateExecution" do
  it "runs as a script" do
    stderr_and_stdout, status = Open3.capture2e(%|bin/graphql_migrate_execution|)
    assert_equal 1, status.exitstatus
    assert_equal "graphql_migrate_execution requires a filename or path as a first argument, please pass one.\n", stderr_and_stdout
  end

  it "has the help output in the readme" do
    readme_contents = File.read("./readme.md")
    help_text, _status = Open3.capture2e("bin/graphql_migrate_execution --help")
    assert_includes readme_contents, help_text
  end
end
