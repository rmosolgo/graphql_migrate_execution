require "minitest/test_task"
require 'bundler/gem_tasks'
require "rdoc/task"

RDoc::Task.new do |rdoc|
  rdoc.main = "readme.md"
  rdoc.markup = "markdown"
  rdoc.rdoc_dir = "_site"
  rdoc.title = "GraphqlMigrateExecution"
end

Minitest::TestTask.create(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_globs = [ENV["TEST"] || "test/**/*_{test,spec}.rb"]
end

task :default => :test
