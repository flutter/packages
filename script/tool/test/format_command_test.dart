// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/file_utils.dart';
import 'package:flutter_plugin_tools/src/format_command.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

const String _languageVersion = '3.8';
const String _dartConstraint = '^$_languageVersion.0';

void main() {
  late MockPlatform mockPlatform;
  late Directory packagesDir;
  late RecordingProcessRunner processRunner;
  late FormatCommand analyzeCommand;
  late CommandRunner<void> runner;
  late String javaFormatPath;
  late String kotlinFormatPath;

  setUp(() {
    mockPlatform = MockPlatform();
    final GitDir gitDir;
    (:packagesDir, :processRunner, gitProcessRunner: _, :gitDir) =
        configureBaseCommandMocks(platform: mockPlatform);
    analyzeCommand = FormatCommand(
      packagesDir,
      processRunner: processRunner,
      platform: mockPlatform,
      gitDir: gitDir,
    );

    // Create the Java and Kotlin formatter files that the command checks for,
    // to avoid a download.
    final p.Context path = analyzeCommand.path;
    javaFormatPath = path.join(path.dirname(path.fromUri(mockPlatform.script)),
        'google-java-format-1.3-all-deps.jar');
    packagesDir.fileSystem.file(javaFormatPath).createSync(recursive: true);
    kotlinFormatPath = path.join(
        path.dirname(path.fromUri(mockPlatform.script)),
        'ktfmt-0.46-jar-with-dependencies.jar');
    packagesDir.fileSystem.file(kotlinFormatPath).createSync(recursive: true);

    runner = CommandRunner<void>('format_command', 'Test for format_command');
    runner.addCommand(analyzeCommand);
  });

  /// Creates the .dart_tool directory for [package] to simulate (as much as
  /// this command requires) `pub get` having been run.
  void fakePubGet(RepositoryPackage package,
      {String languageVersion = _languageVersion}) {
    final File configFile = package.directory
        .childDirectory('.dart_tool')
        .childFile('package_config.json');
    configFile.createSync(recursive: true);
    configFile.writeAsStringSync('''
{
  "packages": [
    {
      "name": "some_other_package",
      "languageVersion": "2.18"
    },
    {
      "name": "${package.directory.basename}",
      "languageVersion": "$languageVersion"
    }
  ]
}
''');
  }

  /// Returns a modified version of a list of [relativePaths] that are relative
  /// to [package] to instead be relative to [packagesDir].
  List<String> getPackagesDirRelativePaths(
      RepositoryPackage package, List<String> relativePaths) {
    final p.Context path = analyzeCommand.path;
    final String relativeBase =
        path.relative(package.path, from: packagesDir.path);
    return relativePaths
        .map((String relativePath) => path.join(relativeBase, relativePath))
        .toList();
  }

  /// Returns a list of [count] relative paths to pass to [createFakePlugin]
  /// or [createFakePackage] such that each path will be 99 characters long
  /// relative to the package directory.
  ///
  /// This is for each of testing batching, since it means each file will
  /// consume 100 characters of the batch length.
  List<String> get99CharacterPathExtraFiles(int count) {
    const int padding = 99 -
        1 - // the path separator after the padding
        10; // the file name
    const int filenameBase = 10000;

    final p.Context path = analyzeCommand.path;
    return <String>[
      for (int i = filenameBase; i < filenameBase + count; ++i)
        path.join('a' * padding, '$i.dart'),
    ];
  }

  group('dart format', () {
    test('formats .dart files', () async {
      const List<String> files = <String>[
        'lib/a.dart',
        'lib/src/b.dart',
        'lib/src/c.dart',
      ];
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
        extraFiles: files,
        dartConstraint: _dartConstraint,
      );
      fakePubGet(plugin);

      await runCapturingPrint(runner, <String>['format']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                'dart', const <String>['format', ...files], plugin.path),
          ]));
    });

    test('does not format .dart files with pragma', () async {
      const List<String> formattedFiles = <String>[
        'lib/a.dart',
        'lib/src/b.dart',
        'lib/src/c.dart',
      ];
      const String unformattedFile = 'lib/src/d.dart';
      final RepositoryPackage plugin = createFakePlugin('a_plugin', packagesDir,
          extraFiles: <String>[
            ...formattedFiles,
            unformattedFile,
          ],
          dartConstraint: _dartConstraint);
      fakePubGet(plugin);

      final p.Context posixContext = p.posix;
      childFileWithSubcomponents(
              plugin.directory, posixContext.split(unformattedFile))
          .writeAsStringSync(
              '// copyright bla bla\n// This file is hand-formatted.\ncode...');

      await runCapturingPrint(runner, <String>['format']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall('dart', const <String>['format', ...formattedFiles],
                plugin.path),
          ]));
    });

    test('fails if dart format fails', () async {
      const List<String> files = <String>[
        'lib/a.dart',
        'lib/src/b.dart',
        'lib/src/c.dart',
      ];
      final RepositoryPackage plugin = createFakePlugin('a_plugin', packagesDir,
          extraFiles: files, dartConstraint: _dartConstraint);
      fakePubGet(plugin);

      processRunner.mockProcessesForExecutable['dart'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['format'])
      ];
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['format'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Failed to format Dart files: exit code 1.'),
          ]));
    });

    test('skips dart if --no-dart flag is provided', () async {
      const List<String> files = <String>[
        'lib/a.dart',
      ];
      final RepositoryPackage plugin = createFakePlugin('a_plugin', packagesDir,
          extraFiles: files, dartConstraint: _dartConstraint);
      fakePubGet(plugin);

      await runCapturingPrint(runner, <String>['format', '--no-dart']);
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('runs pub get if it has not been run', () async {
      const List<String> files = <String>[
        'lib/a.dart',
        'lib/src/b.dart',
        'lib/src/c.dart',
      ];
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
        extraFiles: files,
        dartConstraint: _dartConstraint,
      );

      await runCapturingPrint(runner, <String>['format']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
              'flutter',
              const <String>['pub', 'get'],
              plugin.directory.path,
            ),
            ProcessCall(
                'dart', const <String>['format', ...files], plugin.path),
          ]));
    });

    test('runs pub get in subpackages if it has not been run', () async {
      const List<String> files = <String>[
        'lib/a.dart',
        'lib/src/b.dart',
        'lib/src/c.dart',
      ];
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
        extraFiles: files,
        dartConstraint: _dartConstraint,
      );
      final RepositoryPackage subpackage = createFakePackage(
          'subpackage', plugin.directory.childDirectory('extras'));

      await runCapturingPrint(runner, <String>['format']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
              'flutter',
              const <String>['pub', 'get'],
              plugin.directory.path,
            ),
            ProcessCall(
              'dart',
              const <String>['pub', 'get'],
              subpackage.directory.path,
            ),
            ProcessCall(
                'dart', const <String>['format', ...files], plugin.path),
          ]));
    });

    test('runs pub get if the resolved language version is stale', () async {
      const List<String> files = <String>[
        'lib/a.dart',
        'lib/src/b.dart',
        'lib/src/c.dart',
      ];
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
        extraFiles: files,
        dartConstraint: _dartConstraint,
      );
      fakePubGet(plugin, languageVersion: '3.0');

      await runCapturingPrint(runner, <String>['format']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
              'flutter',
              const <String>['pub', 'get'],
              plugin.directory.path,
            ),
            ProcessCall(
                'dart', const <String>['format', ...files], plugin.path),
          ]));
    });
  });

  test('formats .java files', () async {
    const List<String> files = <String>[
      'android/src/main/java/io/flutter/plugins/a_plugin/a.java',
      'android/src/main/java/io/flutter/plugins/a_plugin/b.java',
    ];
    final RepositoryPackage plugin = createFakePlugin(
      'a_plugin',
      packagesDir,
      extraFiles: files,
    );
    fakePubGet(plugin);

    await runCapturingPrint(runner, <String>['format']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          const ProcessCall('java', <String>['-version'], null),
          ProcessCall(
              'java',
              <String>[
                '-jar',
                javaFormatPath,
                '--replace',
                ...getPackagesDirRelativePaths(plugin, files)
              ],
              packagesDir.path),
        ]));
  });

  test('fails with a clear message if Java is not in the path', () async {
    const List<String> files = <String>[
      'android/src/main/java/io/flutter/plugins/a_plugin/a.java',
      'android/src/main/java/io/flutter/plugins/a_plugin/b.java',
    ];
    final RepositoryPackage plugin =
        createFakePlugin('a_plugin', packagesDir, extraFiles: files);
    fakePubGet(plugin);

    processRunner.mockProcessesForExecutable['java'] = <FakeProcessInfo>[
      FakeProcessInfo(MockProcess(exitCode: 1), <String>['-version'])
    ];
    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['format'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Unable to run "java". Make sure that it is in your path, or '
              'provide a full path with --java-path.'),
        ]));
  });

  test('fails if Java formatter fails', () async {
    const List<String> files = <String>[
      'android/src/main/java/io/flutter/plugins/a_plugin/a.java',
      'android/src/main/java/io/flutter/plugins/a_plugin/b.java',
    ];
    final RepositoryPackage plugin =
        createFakePlugin('a_plugin', packagesDir, extraFiles: files);
    fakePubGet(plugin);

    processRunner.mockProcessesForExecutable['java'] = <FakeProcessInfo>[
      FakeProcessInfo(
          MockProcess(), <String>['-version']), // check for working java
      FakeProcessInfo(MockProcess(exitCode: 1), <String>['-jar']), // format
    ];
    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['format'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Failed to format Java files: exit code 1.'),
        ]));
  });

  test('honors --java-path flag', () async {
    const List<String> files = <String>[
      'android/src/main/java/io/flutter/plugins/a_plugin/a.java',
      'android/src/main/java/io/flutter/plugins/a_plugin/b.java',
    ];
    final RepositoryPackage plugin = createFakePlugin(
      'a_plugin',
      packagesDir,
      extraFiles: files,
    );
    fakePubGet(plugin);

    await runCapturingPrint(
        runner, <String>['format', '--java-path=/path/to/java']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          const ProcessCall('/path/to/java', <String>['--version'], null),
          ProcessCall(
              '/path/to/java',
              <String>[
                '-jar',
                javaFormatPath,
                '--replace',
                ...getPackagesDirRelativePaths(plugin, files)
              ],
              packagesDir.path),
        ]));
  });

  test('skips Java if --no-java flag is provided', () async {
    const List<String> files = <String>[
      'android/src/main/java/io/flutter/plugins/a_plugin/a.java',
    ];
    final RepositoryPackage plugin =
        createFakePlugin('a_plugin', packagesDir, extraFiles: files);
    fakePubGet(plugin);

    await runCapturingPrint(runner, <String>['format', '--no-java']);
    expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
  });

  test('formats c-ish files', () async {
    const List<String> files = <String>[
      'ios/Classes/Foo.h',
      'ios/Classes/Foo.m',
      'linux/foo_plugin.cc',
      'macos/Classes/Foo.h',
      'macos/Classes/Foo.mm',
      'windows/foo_plugin.cpp',
    ];
    final RepositoryPackage plugin = createFakePlugin(
      'a_plugin',
      packagesDir,
      extraFiles: files,
    );
    fakePubGet(plugin);

    await runCapturingPrint(runner, <String>['format']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          const ProcessCall('clang-format', <String>['--version'], null),
          ProcessCall(
              'clang-format',
              <String>[
                '-i',
                '--style=file',
                ...getPackagesDirRelativePaths(plugin, files)
              ],
              packagesDir.path),
        ]));
  });

  test('fails with a clear message if clang-format is not in the path',
      () async {
    const List<String> files = <String>[
      'linux/foo_plugin.cc',
      'macos/Classes/Foo.h',
    ];
    final RepositoryPackage plugin =
        createFakePlugin('a_plugin', packagesDir, extraFiles: files);
    fakePubGet(plugin);

    processRunner.mockProcessesForExecutable['clang-format'] =
        <FakeProcessInfo>[FakeProcessInfo(MockProcess(exitCode: 1))];
    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['format'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Unable to run "clang-format". Make sure that it is in your '
              'path, or provide a full path with --clang-format-path.'),
        ]));
  });

  test('falls back to working clang-format in the path', () async {
    const List<String> files = <String>[
      'linux/foo_plugin.cc',
      'macos/Classes/Foo.h',
    ];
    final RepositoryPackage plugin = createFakePlugin(
      'a_plugin',
      packagesDir,
      extraFiles: files,
    );
    fakePubGet(plugin);

    processRunner.mockProcessesForExecutable['clang-format'] =
        <FakeProcessInfo>[FakeProcessInfo(MockProcess(exitCode: 1))];
    processRunner.mockProcessesForExecutable['which'] = <FakeProcessInfo>[
      FakeProcessInfo(
          MockProcess(
              stdout:
                  '/usr/local/bin/clang-format\n/path/to/working-clang-format'),
          <String>['-a', 'clang-format'])
    ];
    processRunner.mockProcessesForExecutable['/usr/local/bin/clang-format'] =
        <FakeProcessInfo>[FakeProcessInfo(MockProcess(exitCode: 1))];
    await runCapturingPrint(runner, <String>['format']);

    expect(
        processRunner.recordedCalls,
        containsAll(<ProcessCall>[
          const ProcessCall(
              '/path/to/working-clang-format', <String>['--version'], null),
          ProcessCall(
              '/path/to/working-clang-format',
              <String>[
                '-i',
                '--style=file',
                ...getPackagesDirRelativePaths(plugin, files)
              ],
              packagesDir.path),
        ]));
  });

  test('honors --clang-format-path flag', () async {
    const List<String> files = <String>[
      'windows/foo_plugin.cpp',
    ];
    final RepositoryPackage plugin = createFakePlugin(
      'a_plugin',
      packagesDir,
      extraFiles: files,
    );
    fakePubGet(plugin);

    await runCapturingPrint(runner,
        <String>['format', '--clang-format-path=/path/to/clang-format']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          const ProcessCall(
              '/path/to/clang-format', <String>['--version'], null),
          ProcessCall(
              '/path/to/clang-format',
              <String>[
                '-i',
                '--style=file',
                ...getPackagesDirRelativePaths(plugin, files)
              ],
              packagesDir.path),
        ]));
  });

  test('fails if clang-format fails', () async {
    const List<String> files = <String>[
      'linux/foo_plugin.cc',
      'macos/Classes/Foo.h',
    ];
    final RepositoryPackage plugin =
        createFakePlugin('a_plugin', packagesDir, extraFiles: files);
    fakePubGet(plugin);

    processRunner.mockProcessesForExecutable['clang-format'] =
        <FakeProcessInfo>[
      FakeProcessInfo(MockProcess(),
          <String>['--version']), // check for working clang-format
      FakeProcessInfo(MockProcess(exitCode: 1), <String>['-i']), // format
    ];
    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['format'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Failed to format C, C++, and Objective-C files: exit code 1.'),
        ]));
  });

  test('skips clang-format if --no-clang-format flag is provided', () async {
    const List<String> files = <String>[
      'linux/foo_plugin.cc',
    ];
    final RepositoryPackage plugin =
        createFakePlugin('a_plugin', packagesDir, extraFiles: files);
    fakePubGet(plugin);

    await runCapturingPrint(runner, <String>['format', '--no-clang-format']);
    expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
  });

  group('kotlin-format', () {
    test('formats .kt files', () async {
      const List<String> files = <String>[
        'android/src/main/kotlin/io/flutter/plugins/a_plugin/a.kt',
        'android/src/main/kotlin/io/flutter/plugins/a_plugin/b.kt',
      ];
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
        extraFiles: files,
      );
      fakePubGet(plugin);

      await runCapturingPrint(runner, <String>['format']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            const ProcessCall('java', <String>['-version'], null),
            ProcessCall(
                'java',
                <String>[
                  '-jar',
                  kotlinFormatPath,
                  ...getPackagesDirRelativePaths(plugin, files)
                ],
                packagesDir.path),
          ]));
    });

    test('fails if Kotlin formatter fails', () async {
      const List<String> files = <String>[
        'android/src/main/kotlin/io/flutter/plugins/a_plugin/a.kt',
        'android/src/main/kotlin/io/flutter/plugins/a_plugin/b.kt',
      ];
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir, extraFiles: files);
      fakePubGet(plugin);

      processRunner.mockProcessesForExecutable['java'] = <FakeProcessInfo>[
        FakeProcessInfo(
            MockProcess(), <String>['-version']), // check for working java
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['-jar']), // format
      ];
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['format'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Failed to format Kotlin files: exit code 1.'),
          ]));
    });

    test('skips Kotlin if --no-kotlin flag is provided', () async {
      const List<String> files = <String>[
        'android/src/main/kotlin/io/flutter/plugins/a_plugin/a.kt',
      ];
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir, extraFiles: files);
      fakePubGet(plugin);

      await runCapturingPrint(runner, <String>['format', '--no-kotlin']);
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });
  });

  group('swift-format', () {
    test('formats Swift if --swift flag is provided', () async {
      mockPlatform.isMacOS = false;

      const List<String> files = <String>[
        'macos/foo.swift',
      ];
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
        extraFiles: files,
      );
      fakePubGet(plugin);

      await runCapturingPrint(runner, <String>[
        'format',
        '--swift',
      ]);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
              'xcrun',
              <String>[
                'swift-format',
                '-i',
                ...getPackagesDirRelativePaths(plugin, files)
              ],
              packagesDir.path,
            ),
            ProcessCall(
              'xcrun',
              <String>[
                'swift-format',
                'lint',
                '--parallel',
                '--strict',
                ...getPackagesDirRelativePaths(plugin, files),
              ],
              packagesDir.path,
            ),
          ]));
    });

    test('skips Swift if --no-swift flag is provided', () async {
      mockPlatform.isMacOS = true;

      const List<String> files = <String>[
        'macos/foo.swift',
      ];
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
        extraFiles: files,
      );
      fakePubGet(plugin);

      await runCapturingPrint(runner, <String>['format', '--no-swift']);

      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('fails if swift-format lint finds issues', () async {
      const List<String> files = <String>[
        'macos/foo.swift',
      ];
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir, extraFiles: files);
      fakePubGet(plugin);

      processRunner.mockProcessesForExecutable['xcrun'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['swift-format', '-i']),
        FakeProcessInfo(MockProcess(exitCode: 1), <String>[
          'swift-format',
          'lint',
          '--parallel',
          '--strict',
        ]),
      ];
      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'format',
        '--swift',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Swift linter found issues. See above for linter output.'),
          ]));
    });

    test('fails if swift-format lint fails', () async {
      const List<String> files = <String>[
        'macos/foo.swift',
      ];
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir, extraFiles: files);
      fakePubGet(plugin);

      processRunner.mockProcessesForExecutable['xcrun'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['swift-format', '-i']),
        FakeProcessInfo(MockProcess(exitCode: 99), <String>[
          'swift-format',
          'lint',
          '--parallel',
          '--strict',
        ]),
      ];
      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'format',
        '--swift',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Failed to lint Swift files: exit code 99.'),
          ]));
    });

    test('fails if swift-format fails', () async {
      const List<String> files = <String>[
        'macos/foo.swift',
      ];
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir, extraFiles: files);
      fakePubGet(plugin);

      processRunner.mockProcessesForExecutable['xcrun'] = <FakeProcessInfo>[
        FakeProcessInfo(
            MockProcess(exitCode: 1), <String>['swift-format', '-i']),
      ];
      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'format',
        '--swift',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Failed to format Swift files: exit code 1.'),
          ]));
    });
  });

  test('skips known non-repo files', () async {
    const List<String> skipFiles = <String>[
      '/example/build/SomeFramework.framework/Headers/SomeFramework.h',
      '/example/Pods/APod.framework/Headers/APod.h',
      '.dart_tool/internals/foo.cc',
      '.dart_tool/internals/Bar.java',
      '.dart_tool/internals/baz.dart',
    ];
    const List<String> clangFiles = <String>['ios/Classes/Foo.h'];
    const List<String> dartFiles = <String>['lib/a.dart'];
    const List<String> javaFiles = <String>[
      'android/src/main/java/io/flutter/plugins/a_plugin/a.java'
    ];
    final RepositoryPackage plugin = createFakePlugin(
      'a_plugin',
      packagesDir,
      extraFiles: <String>[
        ...skipFiles,
        // Include some files that should be formatted to validate that it's
        // correctly filtering even when running the commands.
        ...clangFiles,
        ...dartFiles,
        ...javaFiles,
      ],
    );
    fakePubGet(plugin);

    await runCapturingPrint(runner, <String>['format']);

    expect(
        processRunner.recordedCalls,
        containsAll(<ProcessCall>[
          ProcessCall(
              'clang-format',
              <String>[
                '-i',
                '--style=file',
                ...getPackagesDirRelativePaths(plugin, clangFiles)
              ],
              packagesDir.path),
          ProcessCall(
              'dart', const <String>['format', ...dartFiles], plugin.path),
          ProcessCall(
              'java',
              <String>[
                '-jar',
                javaFormatPath,
                '--replace',
                ...getPackagesDirRelativePaths(plugin, javaFiles)
              ],
              packagesDir.path),
        ]));
  });

  test('skips GeneratedPluginRegistrant.swift', () async {
    const String sourceFile = 'macos/Classes/Foo.swift';
    final RepositoryPackage plugin = createFakePlugin(
      'a_plugin',
      packagesDir,
      extraFiles: <String>[
        sourceFile,
        'example/macos/Flutter/GeneratedPluginRegistrant.swift',
      ],
    );
    fakePubGet(plugin);

    await runCapturingPrint(runner, <String>[
      'format',
      '--swift',
    ]);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            'xcrun',
            <String>[
              'swift-format',
              '-i',
              ...getPackagesDirRelativePaths(plugin, <String>[sourceFile])
            ],
            packagesDir.path,
          ),
          ProcessCall(
            'xcrun',
            <String>[
              'swift-format',
              'lint',
              '--parallel',
              '--strict',
              ...getPackagesDirRelativePaths(plugin, <String>[sourceFile]),
            ],
            packagesDir.path,
          ),
        ]));
  });

  test('fails if files are changed with --fail-on-change', () async {
    const List<String> files = <String>[
      'linux/foo_plugin.cc',
      'macos/Classes/Foo.h',
    ];
    final RepositoryPackage plugin =
        createFakePlugin('a_plugin', packagesDir, extraFiles: files);
    fakePubGet(plugin);

    const String changedFilePath = 'packages/a_plugin/linux/foo_plugin.cc';
    processRunner.mockProcessesForExecutable['git'] = <FakeProcessInfo>[
      FakeProcessInfo(
          MockProcess(stdout: changedFilePath), <String>['ls-files']),
    ];

    Error? commandError;
    final List<String> output =
        await runCapturingPrint(runner, <String>['format', '--fail-on-change'],
            errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('These files are not formatted correctly'),
          contains(changedFilePath),
          // Ensure the error message links to instructions.
          contains(
              'https://github.com/flutter/packages/blob/main/script/tool/README.md#format-code'),
          contains('patch -p1 <<DONE'),
        ]));

    // Ensure that both packages and third_party/packages are checked.
    final Directory thirdPartyDir = packagesDir.parent
        .childDirectory('third_party')
        .childDirectory('packages');
    expect(
        processRunner.recordedCalls,
        containsAllInOrder(<ProcessCall>[
          ProcessCall(
            'git',
            <String>[
              'ls-files',
              '--modified',
              packagesDir.path,
              thirdPartyDir.path
            ],
            packagesDir.parent.path,
          ),
        ]));
  });

  test('fails if git ls-files fails', () async {
    const List<String> files = <String>[
      'linux/foo_plugin.cc',
      'macos/Classes/Foo.h',
    ];
    final RepositoryPackage plugin =
        createFakePlugin('a_plugin', packagesDir, extraFiles: files);
    fakePubGet(plugin);

    processRunner.mockProcessesForExecutable['git'] = <FakeProcessInfo>[
      FakeProcessInfo(MockProcess(exitCode: 1), <String>['ls-files'])
    ];
    Error? commandError;
    final List<String> output =
        await runCapturingPrint(runner, <String>['format', '--fail-on-change'],
            errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Unable to determine changed files.'),
        ]));
  });

  test('reports git diff failures', () async {
    const List<String> files = <String>[
      'linux/foo_plugin.cc',
      'macos/Classes/Foo.h',
    ];
    final RepositoryPackage plugin =
        createFakePlugin('a_plugin', packagesDir, extraFiles: files);
    fakePubGet(plugin);

    const String changedFilePath = 'packages/a_plugin/linux/foo_plugin.cc';
    processRunner.mockProcessesForExecutable['git'] = <FakeProcessInfo>[
      FakeProcessInfo(
          MockProcess(stdout: changedFilePath), <String>['ls-files']),
      FakeProcessInfo(MockProcess(exitCode: 1), <String>['diff']),
    ];

    Error? commandError;
    final List<String> output =
        await runCapturingPrint(runner, <String>['format', '--fail-on-change'],
            errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('These files are not formatted correctly'),
          contains(changedFilePath),
          contains('Unable to determine diff.'),
        ]));
  });

  test('Batches moderately long file lists on Windows', () async {
    mockPlatform.isWindows = true;

    const String pluginName = 'a_plugin';
    // -1 since the command itself takes some length.
    const int batchSize = (windowsCommandLineMax ~/ 100) - 1;

    // Make the file list one file longer than would fit in the batch.
    final List<String> batch1 = get99CharacterPathExtraFiles(batchSize + 1);
    final String extraFile = batch1.removeLast();

    final RepositoryPackage package = createFakePlugin(
      pluginName,
      packagesDir,
      extraFiles: <String>[...batch1, extraFile],
      dartConstraint: _dartConstraint,
    );
    fakePubGet(package);

    await runCapturingPrint(runner, <String>['format']);

    // Ensure that it was batched...
    expect(processRunner.recordedCalls.length, 2);
    // ... and that the spillover into the second batch was only one file.
    expect(
        processRunner.recordedCalls,
        contains(
          ProcessCall(
              'dart',
              <String>[
                'format',
                extraFile,
              ],
              package.path),
        ));
  });

  // Validates that the Windows limit--which is much lower than the limit on
  // other platforms--isn't being used on all platforms, as that would make
  // formatting slower on Linux and macOS.
  test('Does not batch moderately long file lists on non-Windows', () async {
    const String pluginName = 'a_plugin';
    // -1 since the command itself takes some length.
    const int batchSize = (windowsCommandLineMax ~/ 100) - 1;

    // Make the file list one file longer than would fit in a Windows batch.
    final List<String> batch = get99CharacterPathExtraFiles(batchSize + 1);

    final RepositoryPackage plugin = createFakePlugin(
      pluginName,
      packagesDir,
      extraFiles: batch,
      dartConstraint: _dartConstraint,
    );
    fakePubGet(plugin);

    await runCapturingPrint(runner, <String>['format']);

    expect(processRunner.recordedCalls.length, 1);
  });

  test('Batches extremely long file lists on non-Windows', () async {
    const String pluginName = 'a_plugin';
    // -1 since the command itself takes some length.
    const int batchSize = (nonWindowsCommandLineMax ~/ 100) - 1;

    // Make the file list one file longer than would fit in the batch.
    final List<String> batch1 = get99CharacterPathExtraFiles(batchSize + 1);
    final String extraFile = batch1.removeLast();

    final RepositoryPackage package = createFakePlugin(
      pluginName,
      packagesDir,
      extraFiles: <String>[...batch1, extraFile],
      dartConstraint: _dartConstraint,
    );
    fakePubGet(package);

    await runCapturingPrint(runner, <String>['format']);

    // Ensure that it was batched...
    expect(processRunner.recordedCalls.length, 2);
    // ... and that the spillover into the second batch was only one file.
    expect(
        processRunner.recordedCalls,
        contains(
          ProcessCall(
              'dart',
              <String>[
                'format',
                extraFile,
              ],
              package.path),
        ));
  });
}
