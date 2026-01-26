// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter_plugin_tools/src/common/git_version_finder.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package_command_test.mocks.dart';

void main() {
  late List<List<String>?> gitDirCommands;
  late String gitDiffResponse;
  late MockGitDir gitDir;
  var mergeBaseResponse = '';

  setUp(() {
    gitDirCommands = <List<String>?>[];
    gitDiffResponse = '';
    gitDir = MockGitDir();
    when(
      gitDir.runCommand(any, throwOnError: anyNamed('throwOnError')),
    ).thenAnswer((Invocation invocation) {
      final arguments = invocation.positionalArguments[0]! as List<String>;
      gitDirCommands.add(arguments);
      String? gitStdOut;
      if (arguments[0] == 'diff') {
        gitStdOut = gitDiffResponse;
      } else if (arguments[0] == 'merge-base') {
        gitStdOut = mergeBaseResponse;
      }
      return Future<ProcessResult>.value(
        ProcessResult(0, 0, gitStdOut ?? '', ''),
      );
    });
  });

  test('No git diff should result no files changed', () async {
    final finder = GitVersionFinder(gitDir, baseSha: 'some base sha');
    final List<String> changedFiles = await finder.getChangedFiles();

    expect(changedFiles, isEmpty);
  });

  test('get correct files changed based on git diff', () async {
    gitDiffResponse = '''
file1/file1.cc
file2/file2.cc
''';
    final finder = GitVersionFinder(gitDir, baseSha: 'some base sha');
    final List<String> changedFiles = await finder.getChangedFiles();

    expect(changedFiles, equals(<String>['file1/file1.cc', 'file2/file2.cc']));
  });

  test('use correct base sha if not specified', () async {
    mergeBaseResponse = 'shaqwiueroaaidf12312jnadf123nd';
    gitDiffResponse = '''
file1/pubspec.yaml
file2/file2.cc
''';

    final finder = GitVersionFinder(gitDir);
    await finder.getChangedFiles();
    verify(
      gitDir.runCommand(<String>[
        'merge-base',
        '--fork-point',
        'main',
        'HEAD',
      ], throwOnError: false),
    );
    verify(
      gitDir.runCommand(<String>[
        'diff',
        '--name-only',
        mergeBaseResponse,
        'HEAD',
      ]),
    );
  });

  test('uses correct base branch to find base sha if specified', () async {
    mergeBaseResponse = 'shaqwiueroaaidf12312jnadf123nd';
    gitDiffResponse = '''
file1/pubspec.yaml
file2/file2.cc
''';

    final finder = GitVersionFinder(gitDir, baseBranch: 'upstream/main');
    await finder.getChangedFiles();
    verify(
      gitDir.runCommand(<String>[
        'merge-base',
        '--fork-point',
        'upstream/main',
        'HEAD',
      ], throwOnError: false),
    );
    verify(
      gitDir.runCommand(<String>[
        'diff',
        '--name-only',
        mergeBaseResponse,
        'HEAD',
      ]),
    );
  });

  test('use correct base sha if specified', () async {
    const customBaseSha = 'aklsjdcaskf12312';
    gitDiffResponse = '''
file1/pubspec.yaml
file2/file2.cc
''';
    final finder = GitVersionFinder(gitDir, baseSha: customBaseSha);
    await finder.getChangedFiles();
    verify(
      gitDir.runCommand(<String>['diff', '--name-only', customBaseSha, 'HEAD']),
    );
  });

  test('include uncommitted files if requested', () async {
    const customBaseSha = 'aklsjdcaskf12312';
    gitDiffResponse = '''
file1/pubspec.yaml
file2/file2.cc
''';
    final finder = GitVersionFinder(gitDir, baseSha: customBaseSha);
    await finder.getChangedFiles(includeUncommitted: true);
    // The call should not have HEAD as a final argument like the default diff.
    verify(gitDir.runCommand(<String>['diff', '--name-only', customBaseSha]));
  });
}
