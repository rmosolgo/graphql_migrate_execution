require "minitest/test_task"
require 'bundler/gem_tasks'
require "rdoc/task"

RDoc::Task.new do |rdoc|
  rdoc.main = "readme.md"
  rdoc.markup = "markdown"
  rdoc.rdoc_dir = "_site"
  rdoc.title = "GraphqlMigrateExecution"
end
# footer_content:
#   GRAPHQL:
#     GraphQL-Ruby: https://graphql-ruby.org
#   RESOURCES:
#     GitHub Repository: https://github.com/rmosolgo/graphql_migrate_execution
#     Issue Tracker: https://github.com/rmosolgo/graphql_migrate_execution

Minitest::TestTask.create(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_globs = [ENV["TEST"] || "test/**/*_{test,spec}.rb"]
end

task :default => :test
