// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/validate_command.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('test validate_command pubignore logic', () {
    late CommandRunner<void> runner;
    late ValidateCommand command;
    late Directory packagesDir;

    setUp(() {
      final mockPlatform = MockPlatform();
      final ({
        Directory packagesDir,
        RecordingProcessRunner processRunner,
        RecordingProcessRunner gitProcessRunner,
        GitDir gitDir,
      })
      mocks = configureBaseCommandMocks(platform: mockPlatform);
      packagesDir = mocks.packagesDir;
      final Directory repoRoot = packagesDir.parent;
      setToolConfig(repoRoot, minDartVersion: '1.0.0');

      command = ValidateCommand(
        packagesDir,
        processRunner: mocks.processRunner,
        platform: mockPlatform,
        gitDir: mocks.gitDir,
        targetedValidators: {Validator.pubspec},
      );
      runner = CommandRunner<void>('validate_command', 'Test for validate_command');
      runner.addCommand(command);
    });

    test('skips packages ignored by .pubignore', () async {
      final RepositoryPackage plugin = createFakePlugin('a_plugin', packagesDir);
      plugin.directory.childFile('.pubignore').writeAsStringSync('ignored_dir/');

      final Directory ignoredDir = plugin.directory.childDirectory('ignored_dir')..createSync();
      createFakePlugin('ignored_plugin', ignoredDir);

      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate', '--packages', 'a_plugin'],
        errorHandler: (Error e) {
          // Swallow the ToolExit caused by a_plugin having an invalid pubspec
        },
      );

      expect(output, containsAllInOrder(<Matcher>[contains('SKIPPING: Ignored by .pubignore')]));
    });
  });
}
