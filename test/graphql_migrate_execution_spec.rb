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

  it "modifies files, except when --dry-run" do
    starting_content = File.read("test/graphql_migrate_execution/fixtures/dataload.rb")
    FileUtils.mkdir_p("tmp")
    File.write("tmp/dataload.rb", starting_content)
    text, _status = Open3.capture2e("bin/graphql_migrate_execution --migrate --dry-run tmp/dataload.rb")
    expected_output = <<~TXT

DataloaderShorthand Something.dataload_assoc        @ tmp/dataload.rb:6
                    Something.dataload_object_1     @ tmp/dataload.rb:12
                    Something.dataload_rec          @ tmp/dataload.rb:24
                    Something.dataload_rec_2        @ tmp/dataload.rb:30

DataloaderAll       Something.dataload_object_2     @ tmp/dataload.rb:18

DataloaderManual    Something.dataload_complicated  @ tmp/dataload.rb:36

DataloaderBatch     Something.dataload_things       @ tmp/dataload.rb:43
                    Something.dataload_more_things  @ tmp/dataload.rb:49
    TXT

    assert_equal starting_content, File.read("tmp/dataload.rb")
    assert_equal expected_output, text

    text, _status = Open3.capture2e("bin/graphql_migrate_execution --migrate tmp/dataload.rb")

    migrated_content = File.read("test/graphql_migrate_execution/fixtures/dataload.migrated.rb")
    assert_equal migrated_content, File.read("tmp/dataload.rb")
    assert_equal expected_output, text
  end
end
