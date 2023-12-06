// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/update_excerpts_command.dart';
import 'package:test/test.dart';

import 'common/package_command_test.mocks.dart';
import 'mocks.dart';
import 'util.dart';

void runAllTests(MockPlatform platform) {
  late FileSystem fileSystem;
  late Directory packagesDir;
  late CommandRunner<void> runner;

  setUp(() {
    fileSystem = MemoryFileSystem(
        style: platform.isWindows
            ? FileSystemStyle.windows
            : FileSystemStyle.posix);
    packagesDir = createPackagesDirectory(fileSystem: fileSystem);
    runner = CommandRunner<void>('', '')
      ..addCommand(UpdateExcerptsCommand(
        packagesDir,
        platform: platform,
        processRunner: RecordingProcessRunner(),
        gitDir: MockGitDir(),
      ));
  });

  Future<void> testInjection(
      String before, String source, String after, String fileName,
      {bool failOnChange = false}) async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    package.readmeFile.writeAsStringSync(before);
    package.directory.childFile(fileName).writeAsStringSync(source);
    Object? errorObject;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>[
        'update-excerpts',
        if (failOnChange) '--fail-on-change',
      ],
      errorHandler: (Object error) {
        errorObject = error;
      },
    );
    if (errorObject != null) {
      fail('Failed: $errorObject\n\nOutput from excerpt command:\n$output');
    }
    expect(package.readmeFile.readAsStringSync(), after);
  }

  test('succeeds when nothing has changed', () async {
    const String fileName = 'main.dart';

    const String readme = '''
Example:

<?code-excerpt "$fileName (SomeSection)"?>
```dart
A B C
```
''';
    const String source = '''
FAIL
// #docregion SomeSection
A B C
// #enddocregion SomeSection
FAIL
''';
    await testInjection(readme, source, readme, fileName);
  });

  test('fails if example injection fails', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    package.readmeFile.writeAsStringSync('''
Example:

<?code-excerpt "main.dart (UnknownSection)"?>
```dart
A B C
```
''');
    package.directory.childFile('main.dart').writeAsStringSync('''
FAIL
// #docregion SomeSection
A B C
// #enddocregion SomeSection
FAIL
''');

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['update-excerpts'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Injecting excerpts failed:'),
        contains(
            'main.dart: did not find a "// #docregion UnknownSection" pragma'),
      ]),
    );
  });

  test('updates files', () async {
    const String fileName = 'main.dart';

    await testInjection('''
Example:

<?code-excerpt "$fileName (SomeSection)"?>
```dart
X Y Z
```
''', '''
FAIL
// #docregion SomeSection
A B C
// #enddocregion SomeSection
FAIL
''', '''
Example:

<?code-excerpt "$fileName (SomeSection)"?>
```dart
A B C
```
''', fileName);
  });

  test('fails if READMEs are changed with --fail-on-change', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    package.readmeFile.writeAsStringSync('''
Example:

<?code-excerpt "main.dart (SomeSection)"?>
```dart
X Y Z
```
''');
    package.directory.childFile('main.dart').writeAsStringSync('''
FAIL
// #docregion SomeSection
A B C
// #enddocregion SomeSection
FAIL
''');

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['update-excerpts', '--fail-on-change'],
        errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output.join('\n'),
      contains('The following files have out of date excerpts:'),
    );
  });

  test('does not fail if READMEs are not changed with --fail-on-change',
      () async {
    const String fileName = 'main.dart';

    const String readme = '''
Example:

<?code-excerpt "$fileName (aa)"?>
```dart
A
```
<?code-excerpt "$fileName (bb)"?>
```dart
B
```
''';
    await testInjection(
      readme,
      '''
// #docregion aa
A
// #enddocregion aa
// #docregion bb
B
// #enddocregion bb
''',
      readme,
      fileName,
      failOnChange: true,
    );
  });

  test('indents the plaster', () async {
    const String fileName = 'main.dart';

    await testInjection('''
Example:

<?code-excerpt "$fileName (SomeSection)"?>
```dart
```
''', '''
// #docregion SomeSection
A
  // #enddocregion SomeSection
// #docregion SomeSection
B
// #enddocregion SomeSection
''', '''
Example:

<?code-excerpt "$fileName (SomeSection)"?>
```dart
A
  // ···
B
```
''', fileName);
  });

  test('does not unindent blocks if plaster will not unindent', () async {
    const String fileName = 'main.dart';

    await testInjection('''
Example:

<?code-excerpt "$fileName (SomeSection)"?>
```dart
```
''', '''
// #docregion SomeSection
  A
// #enddocregion SomeSection
// #docregion SomeSection
    B
// #enddocregion SomeSection
''', '''
Example:

<?code-excerpt "$fileName (SomeSection)"?>
```dart
  A
// ···
    B
```
''', fileName);
  });

  test('unindents blocks', () async {
    const String fileName = 'main.dart';

    await testInjection('''
Example:

<?code-excerpt "$fileName (SomeSection)"?>
```dart
```
''', '''
  // #docregion SomeSection
  A
  // #enddocregion SomeSection
    // #docregion SomeSection
    B
    // #enddocregion SomeSection
''', '''
Example:

<?code-excerpt "$fileName (SomeSection)"?>
```dart
A
// ···
  B
```
''', fileName);
  });

  test('unindents blocks and plaster', () async {
    const String fileName = 'main.dart';

    await testInjection('''
Example:

<?code-excerpt "$fileName (SomeSection)"?>
```dart
```
''', '''
  // #docregion SomeSection
  A
    // #enddocregion SomeSection
    // #docregion SomeSection
    B
    // #enddocregion SomeSection
''', '''
Example:

<?code-excerpt "$fileName (SomeSection)"?>
```dart
A
  // ···
  B
```
''', fileName);
  });

  test('relative path bases', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    package.readmeFile.writeAsStringSync('''
<?code-excerpt "main.dart (a)"?>
```dart
```
<?code-excerpt "test/main.dart (a)"?>
```dart
```
<?code-excerpt "test/test/main.dart (a)"?>
```dart
```
<?code-excerpt path-base="test"?>
<?code-excerpt "main.dart (a)"?>
```dart
```
<?code-excerpt "../main.dart (a)"?>
```dart
```
<?code-excerpt "test/main.dart (a)"?>
```dart
```
<?code-excerpt path-base="/packages/a_package"?>
<?code-excerpt "main.dart (a)"?>
```dart
```
<?code-excerpt "test/main.dart (a)"?>
```dart
```
''');
    package.directory.childFile('main.dart').writeAsStringSync('''
// #docregion a
X
// #enddocregion a
''');
    package.directory.childDirectory('test').createSync();
    package.directory
        .childDirectory('test')
        .childFile('main.dart')
        .writeAsStringSync('''
// #docregion a
Y
// #enddocregion a
''');
    package.directory
        .childDirectory('test')
        .childDirectory('test')
        .createSync();
    package.directory
        .childDirectory('test')
        .childDirectory('test')
        .childFile('main.dart')
        .writeAsStringSync('''
// #docregion a
Z
// #enddocregion a
''');
    await runCapturingPrint(runner, <String>['update-excerpts']);
    expect(package.readmeFile.readAsStringSync(), '''
<?code-excerpt "main.dart (a)"?>
```dart
X
```
<?code-excerpt "test/main.dart (a)"?>
```dart
Y
```
<?code-excerpt "test/test/main.dart (a)"?>
```dart
Z
```
<?code-excerpt path-base="test"?>
<?code-excerpt "main.dart (a)"?>
```dart
Y
```
<?code-excerpt "../main.dart (a)"?>
```dart
X
```
<?code-excerpt "test/main.dart (a)"?>
```dart
Z
```
<?code-excerpt path-base="/packages/a_package"?>
<?code-excerpt "main.dart (a)"?>
```dart
X
```
<?code-excerpt "test/main.dart (a)"?>
```dart
Y
```
''');
  });

  test('logs snippets checked', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    package.readmeFile.writeAsStringSync('''
Example:

<?code-excerpt "main.dart (SomeSection)"?>
```dart
A B C
```
''');
    package.directory.childFile('main.dart').writeAsStringSync('''
FAIL
// #docregion SomeSection
A B C
// #enddocregion SomeSection
FAIL
''');

    final List<String> output =
        await runCapturingPrint(runner, <String>['update-excerpts']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Checked 1 snippet(s) in README.md.'),
      ]),
    );
  });

  group('File type tests', () {
    const List<Map<String, String>> testCases = <Map<String, String>>[
      <String, String>{'fileName': 'main.cc'},
      <String, String>{'fileName': 'main.cpp', 'language': 'c++'},
      <String, String>{'fileName': 'main.dart'},
      <String, String>{'fileName': 'main.js'},
      <String, String>{'fileName': 'main.kt', 'language': 'kotlin'},
      <String, String>{'fileName': 'main.java'},
      <String, String>{'fileName': 'main.gradle', 'language': 'groovy'},
      <String, String>{'fileName': 'main.m', 'language': 'objectivec'},
      <String, String>{'fileName': 'main.swift'},
      <String, String>{
        'fileName': 'main.css',
        'prefix': '/* ',
        'suffix': ' */'
      },
      <String, String>{
        'fileName': 'main.html',
        'prefix': '<!--',
        'suffix': '-->'
      },
      <String, String>{
        'fileName': 'main.xml',
        'prefix': '<!--',
        'suffix': '-->'
      },
      <String, String>{'fileName': 'main.yaml', 'prefix': '# '},
      <String, String>{'fileName': 'main.sh', 'prefix': '# '},
      <String, String>{'fileName': 'main', 'language': 'txt', 'prefix': ''},
    ];

    void runTest(Map<String, String> testCase) {
      test('updates ${testCase['fileName']} files', () async {
        final String fileName = testCase['fileName']!;
        final String language = testCase['language'] ?? fileName.split('.')[1];
        final String prefix = testCase['prefix'] ?? '// ';
        final String suffix = testCase['suffix'] ?? '';

        await testInjection('''
Example:

<?code-excerpt "$fileName (SomeSection)"?>
```$language
X Y Z
```
''', '''
FAIL
$prefix#docregion SomeSection$suffix
A B C
$prefix#enddocregion SomeSection$suffix
FAIL
''', '''
Example:

<?code-excerpt "$fileName (SomeSection)"?>
```$language
A B C
```
''', fileName);
      });
    }

    // ignore: prefer_foreach
    for (final Map<String, String> testCase in testCases) {
      runTest(testCase);
    }
  });
}

void main() {
  runAllTests(MockPlatform());
  runAllTests(MockPlatform(isWindows: true));
}
