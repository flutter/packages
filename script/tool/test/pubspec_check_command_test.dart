// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/pubspec_check_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

/// Returns the top section of a pubspec.yaml for a package named [name].
///
/// By default it will create a header that includes all of the expected
/// values, elements can be changed via arguments to create incorrect
/// entries.
///
/// If [includeRepository] is true, by default the path in the link will
/// be "packages/[name]"; a different "packages"-relative path can be
/// provided with [repositoryPackagesDirRelativePath].
String _headerSection(
  String name, {
  String repository = 'flutter/packages',
  bool includeRepository = true,
  String repositoryBranch = 'main',
  String? repositoryPackagesDirRelativePath,
  bool includeHomepage = false,
  bool includeIssueTracker = true,
  bool publishable = true,
  String? description,
}) {
  final String repositoryPath = repositoryPackagesDirRelativePath ?? name;
  final List<String> repoLinkPathComponents = <String>[
    repository,
    'tree',
    repositoryBranch,
    'packages',
    repositoryPath,
  ];
  final String repoLink =
      'https://github.com/${repoLinkPathComponents.join('/')}';
  final String issueTrackerLink = 'https://github.com/flutter/flutter/issues?'
      'q=is%3Aissue+is%3Aopen+label%3A%22p%3A+$name%22';
  description ??= 'A test package for validating that the pubspec.yaml '
      'follows repo best practices.';
  return '''
name: $name
description: $description
${includeRepository ? 'repository: $repoLink' : ''}
${includeHomepage ? 'homepage: $repoLink' : ''}
${includeIssueTracker ? 'issue_tracker: $issueTrackerLink' : ''}
version: 1.0.0
${publishable ? '' : "publish_to: 'none'"}
''';
}

String _environmentSection({
  String dartConstraint = '>=2.17.0 <4.0.0',
  String? flutterConstraint = '>=3.0.0',
}) {
  return <String>[
    'environment:',
    '  sdk: "$dartConstraint"',
    if (flutterConstraint != null) '  flutter: "$flutterConstraint"',
    '',
  ].join('\n');
}

String _flutterSection({
  bool isPlugin = false,
  String? implementedPackage,
  Map<String, Map<String, String>> pluginPlatformDetails =
      const <String, Map<String, String>>{},
}) {
  String pluginEntry = '''
  plugin:
${implementedPackage == null ? '' : '    implements: $implementedPackage'}
    platforms:
''';

  for (final MapEntry<String, Map<String, String>> platform
      in pluginPlatformDetails.entries) {
    pluginEntry += '''
      ${platform.key}:
''';
    for (final MapEntry<String, String> detail in platform.value.entries) {
      pluginEntry += '''
        ${detail.key}: ${detail.value}
''';
    }
  }

  return '''
flutter:
${isPlugin ? pluginEntry : ''}
''';
}

String _dependenciesSection(
    [List<String> extraDependencies = const <String>[]]) {
  return '''
dependencies:
  flutter:
    sdk: flutter
${extraDependencies.map((String dep) => '  $dep').join('\n')}
''';
}

String _devDependenciesSection(
    [List<String> extraDependencies = const <String>[]]) {
  return '''
dev_dependencies:
  flutter_test:
    sdk: flutter
${extraDependencies.map((String dep) => '  $dep').join('\n')}
''';
}

String _topicsSection([List<String> topics = const <String>['a-topic']]) {
  return '''
topics:
${topics.map((String topic) => '  - $topic').join('\n')}
''';
}

String _falseSecretsSection() {
  return '''
false_secrets:
  - /lib/main.dart
''';
}

void main() {
  group('test pubspec_check_command', () {
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;
    late FileSystem fileSystem;
    late MockPlatform mockPlatform;
    late Directory packagesDir;

    setUp(() {
      fileSystem = MemoryFileSystem();
      mockPlatform = MockPlatform();
      packagesDir = fileSystem.currentDirectory.childDirectory('packages');
      createPackagesDirectory(parentDir: packagesDir.parent);
      processRunner = RecordingProcessRunner();
      final PubspecCheckCommand command = PubspecCheckCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
      );

      runner = CommandRunner<void>(
          'pubspec_check_command', 'Test for pubspec_check_command');
      runner.addCommand(command);
    });

    test('passes for a plugin following conventions', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection()}
${_falseSecretsSection()}
''');

      plugin.getExamples().first.pubspecFile.writeAsStringSync('''
${_headerSection(
        'plugin_example',
        publishable: false,
        includeRepository: false,
        includeIssueTracker: false,
      )}
${_environmentSection()}
${_dependenciesSection()}
${_flutterSection()}
''');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'pubspec-check',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin...'),
          contains('Running for plugin/example...'),
          contains('No issues found!'),
        ]),
      );
    });

    test('passes for a Flutter package following conventions', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection()}
${_dependenciesSection()}
${_devDependenciesSection()}
${_flutterSection()}
${_topicsSection()}
${_falseSecretsSection()}
''');

      package.getExamples().first.pubspecFile.writeAsStringSync('''
${_headerSection(
        'a_package',
        publishable: false,
        includeRepository: false,
        includeIssueTracker: false,
      )}
${_environmentSection()}
${_dependenciesSection()}
${_flutterSection()}
''');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'pubspec-check',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for a_package...'),
          contains('Running for a_package/example...'),
          contains('No issues found!'),
        ]),
      );
    });

    test('passes for a minimal package following conventions', () async {
      final RepositoryPackage package =
          createFakePackage('package', packagesDir, examples: <String>[]);

      package.pubspecFile.writeAsStringSync('''
${_headerSection('package')}
${_environmentSection()}
${_dependenciesSection()}
${_topicsSection()}
''');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'pubspec-check',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for package...'),
          contains('No issues found!'),
        ]),
      );
    });

    test('fails when homepage is included', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin', includeHomepage: true)}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Found a "homepage" entry; only "repository" should be used.'),
        ]),
      );
    });

    test('fails when repository is missing', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin', includeRepository: false)}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Missing "repository"'),
        ]),
      );
    });

    test('fails when homepage is given instead of repository', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin', includeHomepage: true, includeRepository: false)}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Found a "homepage" entry; only "repository" should be used.'),
        ]),
      );
    });

    test('fails when repository package name is incorrect', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin', repositoryPackagesDirRelativePath: 'different_plugin')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('The "repository" link should end with the package path.'),
        ]),
      );
    });

    test('fails when repository uses master instead of main', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin', repositoryBranch: 'master')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('The "repository" link should start with the repository\'s '
              'main tree: "https://github.com/flutter/packages/tree/main"'),
        ]),
      );
    });

    test('fails when repository is not flutter/packages', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin', repository: 'flutter/plugins')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('The "repository" link should start with the repository\'s '
              'main tree: "https://github.com/flutter/packages/tree/main"'),
        ]),
      );
    });

    test('fails when issue tracker is missing', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin', includeIssueTracker: false)}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('A package should have an "issue_tracker" link'),
        ]),
      );
    });

    test('fails when description is too short', () async {
      final RepositoryPackage plugin = createFakePlugin(
          'a_plugin', packagesDir.childDirectory('a_plugin'),
          examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin', description: 'Too short')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('"description" is too short. pub.dev recommends package '
              'descriptions of 60-180 characters.'),
        ]),
      );
    });

    test(
        'allows short descriptions for non-app-facing parts of federated plugins',
        () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin', description: 'Too short')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('"description" is too short. pub.dev recommends package '
              'descriptions of 60-180 characters.'),
        ]),
      );
    });

    test('fails when description is too long', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      const String description = 'This description is too long. It just goes '
          'on and on and on and on and on. pub.dev will down-score it because '
          'there is just too much here. Someone shoul really cut this down to just '
          'the core description so that search results are more useful and the '
          'package does not lose pub points.';
      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin', description: description)}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('"description" is too long. pub.dev recommends package '
              'descriptions of 60-180 characters.'),
        ]),
      );
    });

    test('fails when topics section is missing', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('A published package should include "topics".'),
        ]),
      );
    });

    test('fails when topics section is empty', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection(<String>[])}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('A published package should include "topics".'),
        ]),
      );
    });

    test('fails when federated plugin topics do not include plugin name',
        () async {
      final RepositoryPackage plugin = createFakePlugin(
          'some_plugin_ios', packagesDir.childDirectory('some_plugin'),
          examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'A federated plugin package should include its plugin name as a topic. '
              'Add "some-plugin" to the "topics" section.'),
        ]),
      );
    });

    test('fails when topic name contains a space', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection(<String>['plugin a'])}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Invalid topic(s): plugin a in "topics" section. '),
        ]),
      );
    });

    test('fails when topic a topic name contains double dash', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection(<String>['plugin--a'])}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Invalid topic(s): plugin--a in "topics" section. '),
        ]),
      );
    });

    test('fails when topic a topic name starts with a number', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection(<String>['1plugin-a'])}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Invalid topic(s): 1plugin-a in "topics" section. '),
        ]),
      );
    });

    test('fails when topic a topic name contains uppercase', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection(<String>['plugin-A'])}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Invalid topic(s): plugin-A in "topics" section. '),
        ]),
      );
    });

    test('fails when there are more than 5 topics', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection(<String>[
            'plugin-a',
            'plugin-a',
            'plugin-a',
            'plugin-a',
            'plugin-a',
            'plugin-a'
          ])}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              '  A published package should have maximum 5 topics. See https://dart.dev/tools/pub/pubspec#topics.'),
        ]),
      );
    });

    test('fails if a topic name is longer than 32 characters', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection(<String>['foobarfoobarfoobarfoobarfoobarfoobarfoo'])}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Invalid topic(s): foobarfoobarfoobarfoobarfoobarfoobarfoo in "topics" section. '),
        ]),
      );
    });

    test('fails if a topic name is longer than 2 characters', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection(<String>['a'])}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Invalid topic(s): a in "topics" section. '),
        ]),
      );
    });

    test('fails if a topic name ends in a dash', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection(<String>['plugin-'])}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Invalid topic(s): plugin- in "topics" section. '),
        ]),
      );
    });

    test('Invalid topics section has expected error message', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection(<String>['plugin-A', 'Plugin-b'])}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Invalid topic(s): plugin-A, Plugin-b in "topics" section. '
              'Topics must consist of lowercase alphanumerical characters or dash (but no double dash), '
              'start with a-z and ending with a-z or 0-9, have a minimum of 2 characters '
              'and have a maximum of 32 characters.'),
        ]),
      );
    });

    test('fails when environment section is out of order', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_environmentSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Major sections should follow standard repository ordering:'),
        ]),
      );
    });

    test('fails when flutter section is out of order', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_flutterSection(isPlugin: true)}
${_environmentSection()}
${_dependenciesSection()}
${_devDependenciesSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Major sections should follow standard repository ordering:'),
        ]),
      );
    });

    test('fails when dependencies section is out of order', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_devDependenciesSection()}
${_dependenciesSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Major sections should follow standard repository ordering:'),
        ]),
      );
    });

    test('fails when dev_dependencies section is out of order', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_environmentSection()}
${_devDependenciesSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Major sections should follow standard repository ordering:'),
        ]),
      );
    });

    test('fails when false_secrets section is out of order', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_falseSecretsSection()}
${_devDependenciesSection()}
${_topicsSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Major sections should follow standard repository ordering:'),
        ]),
      );
    });

    test('fails when an implemenation package is missing "implements"',
        () async {
      final RepositoryPackage plugin = createFakePlugin(
          'plugin_a_foo', packagesDir.childDirectory('plugin_a'),
          examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin_a_foo')}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Missing "implements: plugin_a" in "plugin" section.'),
        ]),
      );
    });

    test('fails when an implemenation package has the wrong "implements"',
        () async {
      final RepositoryPackage plugin = createFakePlugin(
          'plugin_a_foo', packagesDir.childDirectory('plugin_a'),
          examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin_a_foo')}
${_environmentSection()}
${_flutterSection(isPlugin: true, implementedPackage: 'plugin_a_foo')}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Expecetd "implements: plugin_a"; '
              'found "implements: plugin_a_foo".'),
        ]),
      );
    });

    test('passes for a correct implemenation package', () async {
      final RepositoryPackage plugin = createFakePlugin(
          'plugin_a_foo', packagesDir.childDirectory('plugin_a'),
          examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection(
        'plugin_a_foo',
        repositoryPackagesDirRelativePath: 'plugin_a/plugin_a_foo',
      )}
${_environmentSection()}
${_flutterSection(isPlugin: true, implementedPackage: 'plugin_a')}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection(<String>['plugin-a'])}
''');

      final List<String> output =
          await runCapturingPrint(runner, <String>['pubspec-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin_a_foo...'),
          contains('No issues found!'),
        ]),
      );
    });

    test('fails when a "default_package" looks incorrect', () async {
      final RepositoryPackage plugin = createFakePlugin(
          'plugin_a', packagesDir.childDirectory('plugin_a'),
          examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection(
        'plugin_a',
        repositoryPackagesDirRelativePath: 'plugin_a/plugin_a',
      )}
${_environmentSection()}
${_flutterSection(
        isPlugin: true,
        pluginPlatformDetails: <String, Map<String, String>>{
          'android': <String, String>{'default_package': 'plugin_b_android'}
        },
      )}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              '"plugin_b_android" is not an expected implementation name for "plugin_a"'),
        ]),
      );
    });

    test(
        'fails when a "default_package" does not have a corresponding dependency',
        () async {
      final RepositoryPackage plugin = createFakePlugin(
          'plugin_a', packagesDir.childDirectory('plugin_a'),
          examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection(
        'plugin_a',
        repositoryPackagesDirRelativePath: 'plugin_a/plugin_a',
      )}
${_environmentSection()}
${_flutterSection(
        isPlugin: true,
        pluginPlatformDetails: <String, Map<String, String>>{
          'android': <String, String>{'default_package': 'plugin_a_android'}
        },
      )}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('The following default_packages are missing corresponding '
              'dependencies:\n  plugin_a_android'),
        ]),
      );
    });

    test('passes for an app-facing package without "implements"', () async {
      final RepositoryPackage plugin = createFakePlugin(
          'plugin_a', packagesDir.childDirectory('plugin_a'),
          examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection(
        'plugin_a',
        repositoryPackagesDirRelativePath: 'plugin_a/plugin_a',
      )}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection(<String>['plugin-a'])}
''');

      final List<String> output =
          await runCapturingPrint(runner, <String>['pubspec-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin_a/plugin_a...'),
          contains('No issues found!'),
        ]),
      );
    });

    test('passes for a platform interface package without "implements"',
        () async {
      final RepositoryPackage plugin = createFakePlugin(
          'plugin_a_platform_interface', packagesDir.childDirectory('plugin_a'),
          examples: <String>[]);

      plugin.pubspecFile.writeAsStringSync('''
${_headerSection(
        'plugin_a_platform_interface',
        repositoryPackagesDirRelativePath:
            'plugin_a/plugin_a_platform_interface',
      )}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_topicsSection(<String>['plugin-a'])}
''');

      final List<String> output =
          await runCapturingPrint(runner, <String>['pubspec-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin_a_platform_interface...'),
          contains('No issues found!'),
        ]),
      );
    });

    test('validates some properties even for unpublished packages', () async {
      final RepositoryPackage plugin = createFakePlugin(
          'plugin_a_foo', packagesDir.childDirectory('plugin_a'),
          examples: <String>[]);

      // Environment section is in the wrong location.
      // Missing 'implements'.
      plugin.pubspecFile.writeAsStringSync('''
${_headerSection('plugin_a_foo', publishable: false)}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
${_environmentSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['pubspec-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Major sections should follow standard repository ordering:'),
          contains('Missing "implements: plugin_a" in "plugin" section.'),
        ]),
      );
    });

    test('ignores some checks for unpublished packages', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, examples: <String>[]);

      // Missing metadata that is only useful for published packages, such as
      // repository and issue tracker.
      plugin.pubspecFile.writeAsStringSync('''
${_headerSection(
        'plugin',
        publishable: false,
        includeRepository: false,
        includeIssueTracker: false,
      )}
${_environmentSection()}
${_flutterSection(isPlugin: true)}
${_dependenciesSection()}
${_devDependenciesSection()}
''');

      final List<String> output =
          await runCapturingPrint(runner, <String>['pubspec-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin...'),
          contains('No issues found!'),
        ]),
      );
    });

    test('fails when a Flutter package has a too-low minimum Flutter version',
        () async {
      final RepositoryPackage package = createFakePackage(
          'a_package', packagesDir,
          isFlutter: true, examples: <String>[]);

      package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection(flutterConstraint: '>=2.10.0')}
${_dependenciesSection()}
${_topicsSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'pubspec-check',
        '--min-min-flutter-version',
        '3.0.0'
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Minimum allowed Flutter version 2.10.0 is less than 3.0.0'),
        ]),
      );
    });

    test(
        'passes when a Flutter package requires exactly the minimum Flutter version',
        () async {
      final RepositoryPackage package = createFakePackage(
          'a_package', packagesDir,
          isFlutter: true, examples: <String>[]);

      package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection(flutterConstraint: '>=3.3.0', dartConstraint: '>=2.18.0 <4.0.0')}
${_dependenciesSection()}
${_topicsSection()}
''');

      final List<String> output = await runCapturingPrint(runner,
          <String>['pubspec-check', '--min-min-flutter-version', '3.3.0']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for a_package...'),
          contains('No issues found!'),
        ]),
      );
    });

    test(
        'passes when a Flutter package requires a higher minimum Flutter version',
        () async {
      final RepositoryPackage package = createFakePackage(
          'a_package', packagesDir,
          isFlutter: true, examples: <String>[]);

      package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection(flutterConstraint: '>=3.7.0', dartConstraint: '>=2.19.0 <4.0.0')}
${_dependenciesSection()}
${_topicsSection()}
''');

      final List<String> output = await runCapturingPrint(runner,
          <String>['pubspec-check', '--min-min-flutter-version', '3.3.0']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for a_package...'),
          contains('No issues found!'),
        ]),
      );
    });

    test('fails when a non-Flutter package has a too-low minimum Dart version',
        () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, examples: <String>[]);

      package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection(dartConstraint: '>=2.14.0 <4.0.0', flutterConstraint: null)}
${_dependenciesSection()}
${_topicsSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'pubspec-check',
        '--min-min-flutter-version',
        '3.0.0'
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Minimum allowed Dart version 2.14.0 is less than 2.17.0'),
        ]),
      );
    });

    test(
        'passes when a non-Flutter package requires exactly the minimum Dart version',
        () async {
      final RepositoryPackage package = createFakePackage(
          'a_package', packagesDir,
          isFlutter: true, examples: <String>[]);

      package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection(dartConstraint: '>=2.18.0 <4.0.0', flutterConstraint: null)}
${_dependenciesSection()}
${_topicsSection()}
''');

      final List<String> output = await runCapturingPrint(runner,
          <String>['pubspec-check', '--min-min-flutter-version', '3.3.0']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for a_package...'),
          contains('No issues found!'),
        ]),
      );
    });

    test(
        'passes when a non-Flutter package requires a higher minimum Dart version',
        () async {
      final RepositoryPackage package = createFakePackage(
          'a_package', packagesDir,
          isFlutter: true, examples: <String>[]);

      package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection(dartConstraint: '>=2.18.0 <4.0.0', flutterConstraint: null)}
${_dependenciesSection()}
${_topicsSection()}
''');

      final List<String> output = await runCapturingPrint(runner,
          <String>['pubspec-check', '--min-min-flutter-version', '3.0.0']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for a_package...'),
          contains('No issues found!'),
        ]),
      );
    });

    test('fails when a Flutter->Dart SDK version mapping is missing', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, examples: <String>[]);

      package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection()}
${_dependenciesSection()}
${_topicsSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'pubspec-check',
        '--min-min-flutter-version',
        '2.0.0'
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Dart SDK version for Flutter SDK version 2.0.0 is unknown'),
        ]),
      );
    });

    test(
        'fails when a Flutter package has a too-low minimum Dart version for '
        'the corresponding minimum Flutter version', () async {
      final RepositoryPackage package = createFakePackage(
          'a_package', packagesDir,
          isFlutter: true, examples: <String>[]);

      package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection(flutterConstraint: '>=3.3.0', dartConstraint: '>=2.16.0 <4.0.0')}
${_dependenciesSection()}
${_topicsSection()}
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'pubspec-check',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('The minimum Dart version is 2.16.0, but the '
              'minimum Flutter version of 3.3.0 shipped with '
              'Dart 2.18.0. Please use consistent lower SDK '
              'bounds'),
        ]),
      );
    });

    group('dependency check', () {
      test('passes for local dependencies', () async {
        final RepositoryPackage package =
            createFakePackage('a_package', packagesDir);
        final RepositoryPackage dependencyPackage =
            createFakePackage('local_dependency', packagesDir);

        package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection()}
${_dependenciesSection(<String>['local_dependency: ^1.0.0'])}
${_topicsSection()}
''');
        dependencyPackage.pubspecFile.writeAsStringSync('''
${_headerSection('local_dependency')}
${_environmentSection()}
${_dependenciesSection()}
${_topicsSection()}
''');

        final List<String> output =
            await runCapturingPrint(runner, <String>['pubspec-check']);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for a_package...'),
            contains('No issues found!'),
          ]),
        );
      });

      test('fails when an unexpected dependency is found', () async {
        final RepositoryPackage package =
            createFakePackage('a_package', packagesDir, examples: <String>[]);

        package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection()}
${_dependenciesSection(<String>['bad_dependency: ^1.0.0'])}
${_topicsSection()}
''');

        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'pubspec-check',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                '  The following unexpected non-local dependencies were found:\n'
                '    bad_dependency\n'
                '  Please see https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#Dependencies\n'
                '  for more information and next steps.'),
          ]),
        );
      });

      test('fails when an unexpected dev dependency is found', () async {
        final RepositoryPackage package =
            createFakePackage('a_package', packagesDir, examples: <String>[]);

        package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection()}
${_dependenciesSection()}
${_devDependenciesSection(<String>['bad_dependency: ^1.0.0'])}
${_topicsSection()}
''');

        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'pubspec-check',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                '  The following unexpected non-local dependencies were found:\n'
                '    bad_dependency\n'
                '  Please see https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#Dependencies\n'
                '  for more information and next steps.'),
          ]),
        );
      });

      test('passes when a dependency is on the allow list', () async {
        final RepositoryPackage package =
            createFakePackage('a_package', packagesDir);

        package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection()}
${_dependenciesSection(<String>['allowed: ^1.0.0'])}
${_topicsSection()}
''');

        final List<String> output = await runCapturingPrint(runner,
            <String>['pubspec-check', '--allow-dependencies', 'allowed']);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for a_package...'),
            contains('No issues found!'),
          ]),
        );
      });

      test(
          'passes when an exactly-pinned dependency is on the pinned allow list',
          () async {
        final RepositoryPackage package =
            createFakePackage('a_package', packagesDir);

        package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection()}
${_dependenciesSection(<String>['allow_pinned: 1.0.0'])}
${_topicsSection()}
''');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'pubspec-check',
          '--allow-pinned-dependencies',
          'allow_pinned'
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for a_package...'),
            contains('No issues found!'),
          ]),
        );
      });

      test(
          'passes when an explicit-range-pinned dependency is on the pinned allow list',
          () async {
        final RepositoryPackage package =
            createFakePackage('a_package', packagesDir);

        package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection()}
${_dependenciesSection(<String>['allow_pinned: ">=1.0.0 <=1.3.1"'])}
${_topicsSection()}
''');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'pubspec-check',
          '--allow-pinned-dependencies',
          'allow_pinned'
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for a_package...'),
            contains('No issues found!'),
          ]),
        );
      });

      test('fails when an allowed-when-pinned dependency is unpinned',
          () async {
        final RepositoryPackage package =
            createFakePackage('a_package', packagesDir);

        package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection()}
${_dependenciesSection(<String>['allow_pinned: ^1.0.0'])}
${_topicsSection()}
''');

        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'pubspec-check',
          '--allow-pinned-dependencies',
          'allow_pinned'
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                '  The following unexpected non-local dependencies were found:\n'
                '    allow_pinned\n'
                '  Please see https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#Dependencies\n'
                '  for more information and next steps.'),
          ]),
        );
      });

      group('dev dependencies', () {
        const List<String> packages = <String>[
          'build_runner',
          'integration_test',
          'flutter_test',
          'mockito',
          'pigeon',
          'test',
        ];
        for (final String dependency in packages) {
          test('fails when $dependency is used in non dev dependency',
              () async {
            final RepositoryPackage package = createFakePackage(
                'a_package', packagesDir,
                examples: <String>[]);

            final String version =
                dependency == 'integration_test' || dependency == 'flutter_test'
                    ? '{ sdk: flutter }'
                    : '1.0.0';
            package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package')}
${_environmentSection()}
${_dependenciesSection(<String>[
                  '$dependency: $version',
                ])}
${_devDependenciesSection()}
${_topicsSection()}
''');

            Error? commandError;
            final List<String> output =
                await runCapturingPrint(runner, <String>[
              'pubspec-check',
            ], errorHandler: (Error e) {
              commandError = e;
            });

            expect(commandError, isA<ToolExit>());
            expect(
              output,
              containsAllInOrder(<Matcher>[
                contains(
                    '  The following dev dependencies were found in the dependencies section:\n'
                    '    $dependency\n'
                    '  Please move them to dev_dependencies.'),
              ]),
            );
          });
        }
      });

      test(
          'passes when integration_test or flutter_test are used in non published package',
          () async {
        final RepositoryPackage package =
            createFakePackage('a_package', packagesDir, examples: <String>[]);

        package.pubspecFile.writeAsStringSync('''
${_headerSection('a_package', publishable: false)}
${_environmentSection()}
${_dependenciesSection(<String>[
              'integration_test: \n    sdk: flutter',
              'flutter_test: \n    sdk: flutter'
            ])}
${_devDependenciesSection()}
${_topicsSection()}
''');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'pubspec-check',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for a_package...'),
            contains('Ran for'),
          ]),
        );
      });
    });
  });

  group('test pubspec_check_command on Windows', () {
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;
    late FileSystem fileSystem;
    late MockPlatform mockPlatform;
    late Directory packagesDir;

    setUp(() {
      fileSystem = MemoryFileSystem(style: FileSystemStyle.windows);
      mockPlatform = MockPlatform(isWindows: true);
      packagesDir = fileSystem.currentDirectory.childDirectory('packages');
      createPackagesDirectory(parentDir: packagesDir.parent);
      processRunner = RecordingProcessRunner();
      final PubspecCheckCommand command = PubspecCheckCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
      );

      runner = CommandRunner<void>(
          'pubspec_check_command', 'Test for pubspec_check_command');
      runner.addCommand(command);
    });

    test('repository check works', () async {
      final RepositoryPackage package =
          createFakePackage('package', packagesDir, examples: <String>[]);

      package.pubspecFile.writeAsStringSync('''
${_headerSection('package')}
${_environmentSection()}
${_dependenciesSection()}
${_topicsSection()}
''');

      final List<String> output =
          await runCapturingPrint(runner, <String>['pubspec-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for package...'),
          contains('No issues found!'),
        ]),
      );
    });
  });
}
