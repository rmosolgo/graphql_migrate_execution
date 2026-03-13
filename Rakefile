require "minitest/test_task"
require 'bundler/gem_tasks'

Minitest::TestTask.create(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_globs = [ENV["TEST"] || "test/**/*_{test,spec}.rb"]
end

task :default => :test
