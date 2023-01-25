# Flutter Migrate

## Overview

This is a tool that helps migrate legacy Flutter projects generated with old version of
Flutter to modern Flutter templates. This allows old apps to access new features, update
key dependenices and prevent slow bitrot of projects over time without domain knowledge
of individual platforms like Android and iOS.

## Prerequisites

This tool supports migrating apps generated with Flutter 1.0.0 and newer. However, projects
generated with older versions of Flutter (beta, alpha, etc) may still be compatible with
this tool, but results may vary and official support will not be provided.

Projects that contain heavy modifications to the project's platform directories (eg,
`android/`, `ios/`, `linux/`) may result in many conflicts.

Currently, only full Flutter apps are supported. This tool will not work properly with
plugins, or add-to-app Flutter apps.

The project must be a git repository with no uncommitted changes. Git is used to revert
any migrations that are broken.

## Usage

To run the tool enter the root directory of your flutter project and run:

  `dart run <path_to_flutter_migrate_package>/bin/flutter_migrate.dart <subcommand> [parameters]`

The core subcommand sequence to use is `start`, `apply`.

* `start` will generate a migration that will be staged in the `migration_staging_directory`
  in your project home. This command may take some time to complete depending on network speed.
  The generated migration may have conflicts that should be manually resolved or resolved with
  the `resolve-conflicts` subcommand.

* `apply` will apply staged changes to the actual project. Any merge conflicts should be resolved
  in the staging directory before applying

These additional commands help you manage and navigate the migration:

* `status` Prints the diffs of the staged changes as well as a list of the files with changes.
  Any files with conflicts will also be highlighted.

* `abandon` Abandons the existing migration by deleting the staging directory.

* `resolve-conflicts` Wizard that assists in resolving routine conflicts. The wizard will
  routinely show each conflict where the option to keep the old code, new code, or skip and
  resolve manually are presented.
