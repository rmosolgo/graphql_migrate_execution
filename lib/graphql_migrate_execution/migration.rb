# frozen_string_literal: true
module GraphqlMigrateExecution
  # A run of this tool, called by `bin/graphql_migrate_execution`.
  class Migration
    def initialize(glob, dry_run: false, migrate: false, cleanup: false, implicit: nil, colorable: IRB::Color.colorable?)
      @glob = glob
      @dry_run = dry_run || (migrate == false && cleanup == false)
      @colorable = colorable
      @implicit = implicit
      @action_method = if migrate
        :migrate
      elsif cleanup
        :cleanup
      else
        :analyze
      end
    end

    attr_reader :colorable, :action_method, :implicit

    def run
      Dir.glob(@glob).each do |filepath|
        source = File.read(filepath)
        action = Action.new(self, filepath, source)
        action.run

        if !@dry_run
          File.write(filepath, action.result_source)
        end

        puts action.message
      end
    end
  end
end
