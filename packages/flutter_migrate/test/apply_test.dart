// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_migrate/src/base/context.dart';
import 'package:flutter_migrate/src/base/file_system.dart';
import 'package:flutter_migrate/src/base/io.dart';
import 'package:flutter_migrate/src/base/logger.dart';
import 'package:flutter_migrate/src/base/signals.dart';
import 'package:flutter_migrate/src/base/terminal.dart';
import 'package:flutter_migrate/src/commands/apply.dart';
import 'package:flutter_migrate/src/utils.dart';
import 'package:process/process.dart';

import 'src/common.dart';
import 'src/context.dart';
import 'src/test_flutter_command_runner.dart';

void main() {
  late FileSystem fileSystem;
  late BufferLogger logger;
  late Terminal terminal;
  late ProcessManager processManager;
  late Directory appDir;

  setUp(() {
    fileSystem = LocalFileSystem.test(signals: LocalSignals.instance);
    appDir = fileSystem.systemTempDirectory.createTempSync('apptestdir');
    logger = BufferLogger.test();
    terminal = Terminal.test();
    processManager = const LocalProcessManager();
  });

  tearDown(() async {
    tryToDelete(appDir);
  });

  testUsingContext(
    'Apply produces all outputs',
    () async {
      final ProcessResult result = await processManager.run(<String>[
        'flutter',
        '--version',
      ], workingDirectory: appDir.path);
      final String versionOutput = result.stdout as String;
      final List<String> versionSplit = versionOutput
          .substring(8, 14)
          .split('.');
      expect(versionSplit.length >= 2, true);
      if (!(int.parse(versionSplit[0]) > 3 ||
          int.parse(versionSplit[0]) == 3 && int.parse(versionSplit[1]) > 3)) {
        // Apply not supported on stable version 3.3 and below
        return;
      }

      final MigrateApplyCommand command = MigrateApplyCommand(
        verbose: true,
        logger: logger,
        fileSystem: fileSystem,
        terminal: terminal,
        processManager: processManager,
      );
      final Directory workingDir = appDir.childDirectory(
        kDefaultMigrateStagingDirectoryName,
      );
      appDir.childFile('lib/main.dart').createSync(recursive: true);
      final File pubspecOriginal = appDir.childFile('pubspec.yaml');
      pubspecOriginal.createSync();
      pubspecOriginal.writeAsStringSync('''
name: originalname
description: A new Flutter project.
version: 1.0.0+1
environment:
  sdk: '>=2.18.0-58.0.dev <3.0.0'
dependencies:
  flutter:
    sdk: flutter
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  uses-material-design: true''', flush: true);

      final File gitignore = appDir.childFile('.gitignore');
      gitignore.createSync();
      gitignore.writeAsStringSync(
        kDefaultMigrateStagingDirectoryName,
        flush: true,
      );

      logger.clear();
      await createTestCommandRunner(command).run(<String>[
        'apply',
        '--staging-directory=${workingDir.path}',
        '--project-directory=${appDir.path}',
        '--flutter-subcommand',
      ]);
      expect(
        logger.statusText,
        contains(
          'Project is not a git repo. Please initialize a git repo and try again.',
        ),
      );

      await processManager.run(<String>[
        'git',
        'init',
      ], workingDirectory: appDir.path);

      logger.clear();
      await createTestCommandRunner(command).run(<String>[
        'apply',
        '--staging-directory=${workingDir.path}',
        '--project-directory=${appDir.path}',
        '--flutter-subcommand',
      ]);
      expect(logger.statusText, contains('No migration in progress'));

      final File pubspecModified = workingDir.childFile('pubspec.yaml');
      pubspecModified.createSync(recursive: true);
      pubspecModified.writeAsStringSync('''
name: newname
description: new description of the test project
version: 1.0.0+1
environment:
  sdk: '>=2.18.0-58.0.dev <3.0.0'
dependencies:
  flutter:
    sdk: flutter
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  uses-material-design: false
  # EXTRALINE:''', flush: true);

      final File addedFile = workingDir.childFile('added.file');
      addedFile.createSync(recursive: true);
      addedFile.writeAsStringSync('new file contents');

      final File manifestFile = workingDir.childFile('.migrate_manifest');
      manifestFile.createSync(recursive: true);
      manifestFile.writeAsStringSync('''
merged_files:
  - pubspec.yaml
conflict_files:
  - conflict/conflict.file
added_files:
  - added.file
deleted_files:
''');

      // Add conflict file
      final File conflictFile = workingDir
          .childDirectory('conflict')
          .childFile('conflict.file');
      conflictFile.createSync(recursive: true);
      conflictFile.writeAsStringSync('''
line1
<<<<<<< /conflcit/conflict.file
line2
=======
linetwo
>>>>>>> /var/folders/md/gm0zgfcj07vcsj6jkh_mp_wh00ff02/T/flutter_tools.4Xdep8/generatedTargetTemplatetlN44S/conflict/conflict.file
line3
''', flush: true);

      final File conflictFileOriginal = appDir
          .childDirectory('conflict')
          .childFile('conflict.file');
      conflictFileOriginal.createSync(recursive: true);
      conflictFileOriginal.writeAsStringSync('''
line1
line2
line3
''', flush: true);

      logger.clear();
      await createTestCommandRunner(command).run(<String>[
        'apply',
        '--staging-directory=${workingDir.path}',
        '--project-directory=${appDir.path}',
        '--flutter-subcommand',
      ]);
      expect(
        logger.statusText,
        contains(r'''
Added files:
  - added.file
Modified files:
  - pubspec.yaml
Unable to apply migration. The following files in the migration working directory still have unresolved conflicts:
  - conflict/conflict.file
Conflicting files found. Resolve these conflicts and try again.
Guided conflict resolution wizard:

    $ flutter migrate resolve-conflicts'''),
      );

      conflictFile.writeAsStringSync('''
line1
linetwo
line3
''', flush: true);

      logger.clear();
      await createTestCommandRunner(command).run(<String>[
        'apply',
        '--staging-directory=${workingDir.path}',
        '--project-directory=${appDir.path}',
        '--flutter-subcommand',
      ]);
      expect(
        logger.statusText,
        contains(
          'There are uncommitted changes in your project. Please git commit, abandon, or stash your changes before trying again.',
        ),
      );

      await processManager.run(<String>[
        'git',
        'add',
        '.',
      ], workingDirectory: appDir.path);
      await processManager.run(<String>[
        'git',
        'commit',
        '-m',
        'Initial commit',
      ], workingDirectory: appDir.path);

      logger.clear();
      await createTestCommandRunner(command).run(<String>[
        'apply',
        '--staging-directory=${workingDir.path}',
        '--project-directory=${appDir.path}',
        '--flutter-subcommand',
      ]);
      expect(
        logger.statusText,
        contains(
          r'''
Added files:
  - added.file
Modified files:
  - conflict/conflict.file
  - pubspec.yaml

Applying migration.
  Modifying 3 files.
Writing pubspec.yaml
Writing conflict/conflict.file
Writing added.file
Updating .migrate_configs
Migration complete. You may use commands like `git status`, `git diff` and `git restore <file>` to continue working with the migrated files.''',
        ),
      );

      expect(pubspecOriginal.readAsStringSync(), contains('# EXTRALINE'));
      expect(conflictFileOriginal.readAsStringSync(), contains('linetwo'));
      expect(appDir.childFile('added.file').existsSync(), true);
      expect(
        appDir.childFile('added.file').readAsStringSync(),
        contains('new file contents'),
      );
    },
    overrides: <Type, Generator>{
      FileSystem: () => fileSystem,
      ProcessManager: () => processManager,
    },
  );
}
