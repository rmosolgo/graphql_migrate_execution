# GraphqlMigrateExecution

[![Test](https://github.com/rmosolgo/graphql_migrate_execution/actions/workflows/ci.yaml/badge.svg)](https://github.com/rmosolgo/graphql_migrate_execution/actions/workflows/ci.yaml) [![Gem Version](https://badge.fury.io/rb/graphql_migrate_execution.svg)](https://badge.fury.io/rb/graphql_migrate_execution)

A command-line development tool to update your Ruby source code to support [GraphQL::Execution::Next](https://graphql-ruby.org/execution/next), then clean up unused legacy configs after you don't need them anymore.

## Install

```
bundle add graphql_migrate_execution
```

## Use

```
Usage: graphql_migrate_execution glob [options]

A development tool for adopting GraphQL-Ruby's new runtime module, GraphQL::Execution::Next

Inspect the files matched by `glob` and ...

- (default) print an analysis result for what can be updated
- `--migrate`: update files with new configuration
- `--cleanup`: remove legacy configuration and instance methods

Options:

        --migrate                    Update the files with future-compatible configuration
        --cleanup                    Remove resolver instance methods for GraphQL-Ruby's old runtime
        --dry-run                    Don't actually modify files
        --implicit [MODE]            Handle implicit field resolution this way (ignore / hash_key / hash_key_string)
```

## Supported Field Resolution Patterns

Check out the docs for refactors implemented by this tool:

- Dataloader-based fields:
  - [`DataloaderShorthand`](https://rmosolgo.github.io/graphql_migrate_execution/GraphqlMigrateExecution/DataloaderShorthand.html): use the new `dataload: ...` field configuration shorthand
  - [`DataloaderAll`](https://rmosolgo.github.io/graphql_migrate_execution/GraphqlMigrateExecution/DataloaderAll.html): use a `dataload_all(...)` call to fetch data for a batch of objects
  - [`DataloaderBatch`](https://rmosolgo.github.io/graphql_migrate_execution/GraphqlMigrateExecution/DataloaderBatch.html): Fetch a list of results _for each object_ (2-layer list)
  - [`DataloaderManual`](https://rmosolgo.github.io/graphql_migrate_execution/GraphqlMigrateExecution/DataloaderManual.html): 💔 Identifies dataloader usage which can't be migrated
- Migrate method:
  - These identify Ruby code in the method which only uses `context` and `object` and migrates it to a suitable class method. Then, it updates the instance method to call the new class method and adds the suitable future-compatible config.
  - [`ResolveBatch`](https://rmosolgo.github.io/graphql_migrate_execution/GraphqlMigrateExecution/ResolveBatch.html)
  - [`ResolveEach`](https://rmosolgo.github.io/graphql_migrate_execution/GraphqlMigrateExecution/ResolveEach.html)
  - [`ResolveStatic`](https://rmosolgo.github.io/graphql_migrate_execution/GraphqlMigrateExecution/ResolveStatic.html)
- 💔 Not migratable:
  - [`NotImplemented`](https://rmosolgo.github.io/graphql_migrate_execution/GraphqlMigrateExecution/NotImplemented.html): This field couldn't be matched to a refactor
  - [`UnsupportedCurrentPath`](https://rmosolgo.github.io/graphql_migrate_execution/GraphqlMigrateExecution/UnsupportedCurrentPath.html): uses `context[:current_path]` which isn't supported anymore - [`UnsupportedExtra`](https://rmosolgo.github.io/graphql_migrate_execution/GraphqlMigrateExecution/UnsupportedExtra.html): as at least one `extras: ...` configuration which isn't supported anymore
- Configuration:
  - [`DoNothing`](https://rmosolgo.github.io/graphql_migrate_execution/GraphqlMigrateExecution/DoNothing.html): Already includes future-compatible configuration
  - [`HashKey`](https://rmosolgo.github.io/graphql_migrate_execution/GraphqlMigrateExecution/HashKey.html): Can be migrated using `hash_key:` (especially useful for Resolvers and Mutations)
  - [`Implicit`](https://rmosolgo.github.io/graphql_migrate_execution/GraphqlMigrateExecution/Implicit.html): ⚠️ GraphQL-Ruby's default field resolution is changing, see the doc

## Unsupported Field Resolution Patterns

Here are a few fields in my app that this tool didn't handle automatically, along with my manual migrations:

- __Working with a dataloaded value__:

  This resolver called arbitrary code _after_ using Dataloader:

  ```ruby
  field :is_locked_to_viewer, Boolean, null: false

  def is_locked_to_viewer
    status = dataload(Sources::GrowthTaskStatusForUserSource, context[:current_user], object)
    status == :LOCKED
  end
  ```

  I _could_ have handled this by refactoring the dataload call to return `true|false`. Then it could have been auto-migrated. Instead, I migrated it like this:

  ```ruby
  field :is_locked_to_viewer, Boolean, null: false, resolve_batch: true

  def self.is_locked_to_viewer(objects, context)
    statuses = context.dataload_all(Sources::GrowthTaskStatusForUserSource, context[:current_user], objects)
    statuses.map { |s| s == :LOCKED }
  end

  def is_locked_to_viewer
    self.class.is_locked_to_viewer([ object ], context).first
  end
  ```

- __Conditional dataloader call__:

  This field only called dataloader in some cases:

  ```ruby
  field :viewer_growth_task_submission, GrowthTaskSubmissionType

  def viewer_growth_task_submission
    if object.frequency.present?
      # TODO should not include a recurring submission whose duration has passed
      nil
    else
      context.dataloader.with(Sources::GrowthTaskForViewerSource, context[:current_user]).request(object.id)
    end
  end
  ```

  It _could_ have been auto-migrated if I made two refactors:

  - Update the Source to receive `object` instead of `object.id`
  - Update the Source's `#fetch` to return `nil` based on `object.frequency.present?`

  But I didn't do that. Instead, I migrated it manually:

  ```ruby
  field :viewer_growth_task_submission, GrowthTaskSubmissionType, resolve_batch: true

  def self.viewer_growth_task_submission(objects, context)
    requests = objects.map do |object|
      if object.frequency.present?
        # TODO should not include a recurring submission whose duration has passed
        nil
      else
        context.dataloader.with(Sources::GrowthTaskForViewerSource, context[:current_user]).request(object.id)
      end
    end
    requests.map { |l| l&.load }
  end

  def viewer_growth_task_submission
    self.class.viewer_growth_task_submission([ object ], context).first
  end
  ```

- __Resolver that calls another resolver:__

  The tool just gives up when it sees calls on `self`. It didn't handle this:

  ```ruby
  field :current_user, Types::UserType

  def current_user
    context[:current_user]
  end

  field :unread_notification_count, Integer, null: false

  def unread_notification_count
    # vvvvvvvvv Calls the resolver method above
    current_user ? current_user.notification_events.unread.count : 0
  end
  ```

  I migrated it manually:

  ```ruby
  field :unread_notification_count, Integer, null: false, resolve_static: true

  def self.unread_notification_count(context)
    if (cu = current_user(context))
      cu.notification_events.unread.count
    else
      0
    end
  end

  def unread_notification_count
    self.class.unread_notification_count(context)
  end
  ```

- __Single-line method definition__:

  The tool's heavy-handed Ruby source generation botched this:

  ```ruby
  field :growth_levels, Types::GrowthLevelType.connection_type, null: false, resolve_each: true
  def growth_levels; object.growth_levels.by_sequence; end;
  ```

  This tool could be improved to properly handle single-line methods -- open an issue if you need this.

## Develop

```
bundle exec rake test # TEST=test/...
```


## TODO

- [ ] Does `--cleanup` work on my app? I haven't run it yet.
