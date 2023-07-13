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

  Future<void> testInjection(String before, String source, String after,
      {bool failOnChange = false}) async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    package.readmeFile.writeAsStringSync(before);
    package.directory.childFile('main.dart').writeAsStringSync(source);
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
    const String readme = '''
Example:

<?code-excerpt "main.dart (SomeSection)"?>
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
    await testInjection(readme, source, readme);
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
    await testInjection(
      '''
Example:

<?code-excerpt "main.dart (SomeSection)"?>
```dart
X Y Z
```
''',
      '''
FAIL
// #docregion SomeSection
A B C
// #enddocregion SomeSection
FAIL
''',
      '''
Example:

<?code-excerpt "main.dart (SomeSection)"?>
```dart
A B C
```
''',
    );
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
    const String readme = '''
Example:

<?code-excerpt "main.dart (aa)"?>
```dart
A
```
<?code-excerpt "main.dart (bb)"?>
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
      failOnChange: true,
    );
  });

  test('indents the plaster', () async {
    await testInjection(
      '''
Example:

<?code-excerpt "main.dart (SomeSection)"?>
```dart
```
''',
      '''
// #docregion SomeSection
A
  // #enddocregion SomeSection
// #docregion SomeSection
B
// #enddocregion SomeSection
''',
      '''
Example:

<?code-excerpt "main.dart (SomeSection)"?>
```dart
A
  // ···
B
```
''',
    );
  });

  test('does not unindent blocks if plaster will not unindent', () async {
    await testInjection(
      '''
Example:

<?code-excerpt "main.dart (SomeSection)"?>
```dart
```
''',
      '''
// #docregion SomeSection
  A
// #enddocregion SomeSection
// #docregion SomeSection
    B
// #enddocregion SomeSection
''',
      '''
Example:

<?code-excerpt "main.dart (SomeSection)"?>
```dart
  A
// ···
    B
```
''',
    );
  });

  test('unindents blocks', () async {
    await testInjection(
      '''
Example:

<?code-excerpt "main.dart (SomeSection)"?>
```dart
```
''',
      '''
  // #docregion SomeSection
  A
  // #enddocregion SomeSection
    // #docregion SomeSection
    B
    // #enddocregion SomeSection
''',
      '''
Example:

<?code-excerpt "main.dart (SomeSection)"?>
```dart
A
// ···
  B
```
''',
    );
  });

  test('unindents blocks and plaster', () async {
    await testInjection(
      '''
Example:

<?code-excerpt "main.dart (SomeSection)"?>
```dart
```
''',
      '''
  // #docregion SomeSection
  A
    // #enddocregion SomeSection
    // #docregion SomeSection
    B
    // #enddocregion SomeSection
''',
      '''
Example:

<?code-excerpt "main.dart (SomeSection)"?>
```dart
A
  // ···
  B
```
''',
    );
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
}

void main() {
  runAllTests(MockPlatform());
  runAllTests(MockPlatform(isWindows: true));
}
