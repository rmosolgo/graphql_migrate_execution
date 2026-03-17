require "minitest/autorun"
require "minitest/focus"
require "graphql_migrate_execution"
require "ostruct"

module MigrationHelpers
  def migrate(ruby_src, filename = "app.rb", implicit: nil)
    action = run_action(ruby_src, filename, :migrate, implicit: implicit)
    action.result_source
  end

  def cleanup(ruby_src, filename = "app.rb")
    action = run_action(ruby_src, filename, :cleanup)
    action.result_source
  end

  def assert_file_action(action_method, source_file)
    starting_source = File.read(source_file)
    modified_source = public_send(action_method, starting_source, source_file)
    if action_method == :analyze
      file_ext = "txt"
      file_replace = /\.rb\Z/
    else
      file_ext = "rb"
      file_replace = /(\.[a-z]+)?\.rb\Z/
    end
    expected_file = source_file.sub(file_replace, ".#{action_method}.#{file_ext}")
    expected_source = File.read(expected_file)
    assert_equal expected_source, modified_source, "#{action_method} causes #{source_file} to match #{expected_file}"
  end

  def analyze(ruby_src, filename = "app.rb", implicit: nil)
    action = run_action(ruby_src, filename, :analyze, implicit: implicit)
    action.message
  end

  def run_action(ruby_src, filename, action_method, implicit: nil)
    action = GraphqlMigrateExecution::Action.new(OpenStruct.new(colorable: false, action_method: action_method, implicit: implicit), filename, ruby_src)
    action.run
    action
  end
end
