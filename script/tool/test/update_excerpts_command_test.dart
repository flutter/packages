// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/update_excerpts_command.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void runAllTests(MockPlatform platform) {
  late Directory packagesDir;
  late CommandRunner<void> runner;

  setUp(() {
    final RecordingProcessRunner processRunner;
    final GitDir gitDir;
    (:packagesDir, :processRunner, gitProcessRunner: _, :gitDir) =
        configureBaseCommandMocks(platform: platform);
    runner = CommandRunner<void>('', '')
      ..addCommand(UpdateExcerptsCommand(
        packagesDir,
        platform: platform,
        processRunner: processRunner,
        gitDir: gitDir,
      ));
  });

  Future<void> testInjection(
      {required String before,
      required String source,
      required String after,
      required String filename,
      bool failOnChange = false}) async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    package.readmeFile.writeAsStringSync(before);
    package.directory.childFile(filename).writeAsStringSync(source);
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
    const String filename = 'main.dart';

    const String readme = '''
Example:

<?code-excerpt "$filename (SomeSection)"?>
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
    await testInjection(
        before: readme, source: source, after: readme, filename: filename);
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
    const String filename = 'main.dart';

    const String before = '''
Example:

<?code-excerpt "$filename (SomeSection)"?>
```dart
X Y Z
```
''';

    const String source = '''
FAIL
// #docregion SomeSection
A B C
// #enddocregion SomeSection
FAIL
''';

    const String after = '''
Example:

<?code-excerpt "$filename (SomeSection)"?>
```dart
A B C
```
''';

    await testInjection(
        before: before, source: source, after: after, filename: filename);
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
    const String filename = 'main.dart';

    const String readme = '''
Example:

<?code-excerpt "$filename (aa)"?>
```dart
A
```
<?code-excerpt "$filename (bb)"?>
```dart
B
```
''';

    const String source = '''
// #docregion aa
A
// #enddocregion aa
// #docregion bb
B
// #enddocregion bb
''';

    await testInjection(
      before: readme,
      source: source,
      after: readme,
      filename: filename,
      failOnChange: true,
    );
  });

  test('indents the plaster', () async {
    const String filename = 'main.dart';

    const String before = '''
Example:

<?code-excerpt "$filename (SomeSection)"?>
```dart
```
''';

    const String source = '''
// #docregion SomeSection
A
  // #enddocregion SomeSection
// #docregion SomeSection
B
// #enddocregion SomeSection
''';

    const String after = '''
Example:

<?code-excerpt "$filename (SomeSection)"?>
```dart
A
  // ···
B
```
''';

    await testInjection(
        before: before, source: source, after: after, filename: filename);
  });

  test('does not unindent blocks if plaster will not unindent', () async {
    const String filename = 'main.dart';

    const String before = '''
Example:

<?code-excerpt "$filename (SomeSection)"?>
```dart
```
''';

    const String source = '''
// #docregion SomeSection
  A
// #enddocregion SomeSection
// #docregion SomeSection
    B
// #enddocregion SomeSection
''';

    const String after = '''
Example:

<?code-excerpt "$filename (SomeSection)"?>
```dart
  A
// ···
    B
```
''';

    await testInjection(
        before: before, source: source, after: after, filename: filename);
  });

  test('unindents blocks', () async {
    const String filename = 'main.dart';

    const String before = '''
Example:

<?code-excerpt "$filename (SomeSection)"?>
```dart
```
''';

    const String source = '''
  // #docregion SomeSection
  A
  // #enddocregion SomeSection
    // #docregion SomeSection
    B
    // #enddocregion SomeSection
''';

    const String after = '''
Example:

<?code-excerpt "$filename (SomeSection)"?>
```dart
A
// ···
  B
```
''';

    await testInjection(
        before: before, source: source, after: after, filename: filename);
  });

  test('unindents blocks and plaster', () async {
    const String filename = 'main.dart';

    const String before = '''
Example:

<?code-excerpt "$filename (SomeSection)"?>
```dart
```
''';

    const String source = '''
  // #docregion SomeSection
  A
    // #enddocregion SomeSection
    // #docregion SomeSection
    B
    // #enddocregion SomeSection
''';

    const String after = '''
Example:

<?code-excerpt "$filename (SomeSection)"?>
```dart
A
  // ···
  B
```
''';

    await testInjection(
        before: before, source: source, after: after, filename: filename);
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
      <String, String>{'filename': 'main.cc', 'language': 'c++'},
      <String, String>{'filename': 'main.cpp', 'language': 'c++'},
      <String, String>{'filename': 'main.dart'},
      <String, String>{'filename': 'main.js'},
      <String, String>{'filename': 'main.kt', 'language': 'kotlin'},
      <String, String>{'filename': 'main.java'},
      <String, String>{'filename': 'main.gradle', 'language': 'groovy'},
      <String, String>{'filename': 'main.m', 'language': 'objectivec'},
      <String, String>{'filename': 'main.swift'},
      <String, String>{
        'filename': 'main.css',
        'prefix': '/* ',
        'suffix': ' */'
      },
      <String, String>{
        'filename': 'main.html',
        'prefix': '<!--',
        'suffix': '-->'
      },
      <String, String>{
        'filename': 'main.xml',
        'prefix': '<!--',
        'suffix': '-->'
      },
      <String, String>{'filename': 'main.yaml', 'prefix': '# '},
      <String, String>{'filename': 'main.sh', 'prefix': '# '},
      <String, String>{'filename': 'main', 'language': 'txt', 'prefix': ''},
    ];

    void runTest(Map<String, String> testCase) {
      test('updates ${testCase['filename']} files', () async {
        final String filename = testCase['filename']!;
        final String language = testCase['language'] ?? filename.split('.')[1];
        final String prefix = testCase['prefix'] ?? '// ';
        final String suffix = testCase['suffix'] ?? '';

        final String before = '''
Example:

<?code-excerpt "$filename (SomeSection)"?>
```$language
X Y Z
```
''';

        final String source = '''
FAIL
$prefix#docregion SomeSection$suffix
A B C
$prefix#enddocregion SomeSection$suffix
FAIL
''';

        final String after = '''
Example:

<?code-excerpt "$filename (SomeSection)"?>
```$language
A B C
```
''';

        await testInjection(
            before: before, source: source, after: after, filename: filename);
      });
    }

    testCases.forEach(runTest);
  });
}

void main() {
  runAllTests(MockPlatform());
  runAllTests(MockPlatform(isWindows: true));
}
