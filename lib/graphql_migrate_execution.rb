# frozen_string_literal: true
require "graphql_migrate_execution/action"
require "graphql_migrate_execution/add_future"
require "graphql_migrate_execution/remove_legacy"
require "graphql_migrate_execution/analyze"
require "graphql_migrate_execution/field_definition"
require "graphql_migrate_execution/resolver_method"
require "graphql_migrate_execution/type_definition"
require "graphql_migrate_execution/visitor"
require "graphql_migrate_execution/strategy"
require "graphql_migrate_execution/implicit"
require "graphql_migrate_execution/do_nothing"
require "graphql_migrate_execution/resolve_each"
require "graphql_migrate_execution/resolve_static"
require "graphql_migrate_execution/not_implemented"
require "graphql_migrate_execution/dataloader_all"
require "graphql_migrate_execution/dataloader_batch"
require "graphql_migrate_execution/dataloader_manual"
require "graphql_migrate_execution/dataloader_shorthand"
require "graphql_migrate_execution/hash_key"
require "graphql_migrate_execution/unsupported_extra"
require "graphql_migrate_execution/unsupported_current_path"
require "graphql_migrate_execution/not_implemented"
require "irb"

module GraphqlMigrateExecution
  class Migration
    def initialize(glob, concise: false, migrate: false, cleanup: false, only: nil, implicit: nil, colorable: IRB::Color.colorable?)
      @glob = glob
      @skip_description = concise
      @colorable = colorable
      @only = only
      @implicit = implicit
      @action_class = if migrate
        AddFuture
      elsif cleanup
        RemoveLegacy
      else
        Analyze
      end
    end

    attr_reader :skip_description, :colorable


    def run
      Dir.glob(@glob).each do |filepath|
        source = File.read(filepath)
        file_migrate = @action_class.new(self, filepath, source)
        puts file_migrate.run
      end
    end
  end
end
