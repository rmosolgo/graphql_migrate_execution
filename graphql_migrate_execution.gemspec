# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "graphql_migrate_execution/version"
require "date"

Gem::Specification.new do |s|
  s.name        = "graphql_migrate_execution"
  s.version     = GraphqlMigrateExecution::VERSION
  s.date        = Date.today.to_s
  s.summary     = "A development script for migrating to GraphQL-Ruby's new runtime engine"
  s.description = "A development script for migrating to GraphQL-Ruby's new runtime engine"
  s.homepage    = "https://github.com/rmosolgo/graphql_migrate_execution"
  s.authors     = ["Robert Mosolgo"]
  s.email       = ["rdmosolgo@gmail.com"]
  s.license     = "MIT"
  s.required_ruby_version = ">= 2.7.0"
  s.metadata    = {
    "homepage_uri" => "https://graphql-ruby.org",
    "changelog_uri" => "https://github.com/rmosolgo/graphql_migrate_execution",
    "source_code_uri" => "https://github.com/rmosolgo/graphql_migrate_execution",
    "bug_tracker_uri" => "https://github.com/rmosolgo/graphql_migrate_execution/issues",
    "mailing_list_uri"  => "https://buttondown.email/graphql-ruby",
    "rubygems_mfa_required" => "true",
  }

  s.files = Dir["{lib, bin}/**/*", "MIT-LICENSE", "readme.md"]

  s.add_runtime_dependency "irb"
  s.add_development_dependency "ostruct"
  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-focus"
end
