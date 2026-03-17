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

        --migrate                    Update the files with future-compatibile configuration
        --cleanup                    Remove resolver instance methods for GraphQL-Ruby's old runtime
        --concise                    Don't print migration strategy descriptions
        --dry-run                    Don't actually modify files
        --implicit MODE              Handle implicit field resolution using MODE
        --only PATTERN               Only analyze or update fields whose path (`Type.field`) matches /PATTERN/
```

## Develop

```
bundle exec rake test # TEST=test/...
```
