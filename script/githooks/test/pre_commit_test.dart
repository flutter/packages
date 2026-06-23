// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:githooks/src/pre_commit_command.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('pre-commit hook', () {
    test('passes when both format and analyze succeed', () async {
      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git') {
                return ProcessResult(0, 0, 'script/githooks/lib/githooks.dart\n', '');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isTrue);

      final String repoRoot = Directory.current.parent.parent.path;
      final String toolScript = '$repoRoot/script/tool/bin/flutter_plugin_tools.dart';

      // Verify the exact arguments passed to format and analyze
      expect(
        executedArguments,
        anyElement(
          equals(['run', toolScript, 'format', '--custom-files=script/githooks/lib/githooks.dart', '--fail-on-change']),
        ),
      );
      expect(
        executedArguments,
        anyElement(equals(['run', toolScript, 'analyze', '--custom-files=script/githooks/lib/githooks.dart', '--dart'])),
      );
    });

    test('fails when formatting fails', () async {
      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git') {
                return ProcessResult(0, 0, 'script/githooks/lib/githooks.dart\n', '');
              }
              if (arguments.isNotEmpty && arguments.length > 2 && arguments[2] == 'format') {
                return ProcessResult(0, 1, 'bad_file.dart', '');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isFalse);

      final String repoRoot = Directory.current.parent.parent.path;
      final String toolScript = '$repoRoot/script/tool/bin/flutter_plugin_tools.dart';

      expect(
        executedArguments,
        anyElement(
          equals(['run', toolScript, 'format', '--custom-files=script/githooks/lib/githooks.dart', '--fail-on-change']),
        ),
      );
    });

    test('fails when analysis fails', () async {
      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git') {
                return ProcessResult(0, 0, 'script/githooks/lib/githooks.dart\n', '');
              }
              if (arguments.isNotEmpty && arguments.length > 2 && arguments[2] == 'analyze') {
                return ProcessResult(0, 1, 'error in file.dart', '');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isFalse);

      final String repoRoot = Directory.current.parent.parent.path;
      final String toolScript = '$repoRoot/script/tool/bin/flutter_plugin_tools.dart';

      expect(
        executedArguments,
        anyElement(equals(['run', toolScript, 'analyze', '--custom-files=script/githooks/lib/githooks.dart', '--dart'])),
      );
    });

    test('ignores non-dart files', () async {
      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git') {
                return ProcessResult(0, 0, 'README.md\n', '');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isTrue);

      // Verify that dart format and analyze were NEVER called.
      expect(executedArguments.any((args) => args.contains('format')), isFalse);
      expect(executedArguments.any((args) => args.contains('analyze')), isFalse);
    });
    test('runs format and analyze when files are staged in a valid package', () async {
      final String repoRoot = Directory.current.parent.parent.path;
      final String toolScript = '$repoRoot/script/tool/bin/flutter_plugin_tools.dart';

      final Directory pkgDir = Directory(path.join(repoRoot, 'packages', 'pkg'));
      pkgDir.createSync(recursive: true);
      File(path.join(pkgDir.path, 'pubspec.yaml')).writeAsStringSync('name: pkg');
      addTearDown(() => pkgDir.deleteSync(recursive: true));

      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git') {
                return ProcessResult(0, 0, 'packages/pkg/ios/Classes/Foo.m\n', '');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isTrue);

      expect(
        executedArguments,
        anyElement(
          equals(['run', toolScript, 'format', '--custom-files=packages/pkg/ios/Classes/Foo.m', '--fail-on-change']),
        ),
      );
      expect(
        executedArguments,
        anyElement(equals(['run', toolScript, 'analyze', '--custom-files=packages/pkg/ios/Classes/Foo.m', '--dart'])),
      );
    });
  });
}
