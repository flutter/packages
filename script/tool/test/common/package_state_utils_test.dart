// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/git_version_finder.dart';
import 'package:flutter_plugin_tools/src/common/package_state_utils.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

import '../util.dart';

void main() {
  late Directory packagesDir;

  setUp(() {
    (:packagesDir, processRunner: _, gitProcessRunner: _, gitDir: _) =
        configureBaseCommandMocks();
  });

  group('checkPackageChangeState', () {
    test('reports version change needed for code changes', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_package/lib/plugin.dart',
      ];

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_package');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
      expect(state.needsChangelogChange, true);
    });

    test('handles trailing slash on package path', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_package/lib/plugin.dart',
      ];

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_package/');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
      expect(state.needsChangelogChange, true);
      expect(state.hasChangelogChange, false);
    });

    test('does not flag version- and changelog-change-exempt changes',
        () async {
      final RepositoryPackage package =
          createFakePlugin('a_plugin', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/CHANGELOG.md',
        // Dev-facing docs.
        'packages/a_plugin/CONTRIBUTING.md',
        // Analysis.
        'packages/a_plugin/example/android/lint-baseline.xml',
        // Tests.
        'packages/a_plugin/example/android/src/androidTest/foo/bar/FooTest.java',
        'packages/a_plugin/example/ios/RunnerTests/Foo.m',
        'packages/a_plugin/example/ios/RunnerUITests/info.plist',
        // Pigeon input.
        'packages/a_plugin/pigeons/messages.dart',
        // Test scripts.
        'packages/a_plugin/run_tests.sh',
        'packages/a_plugin/dart_test.yaml',
        // Tools.
        'packages/a_plugin/tool/a_development_tool.dart',
        // Example build files.
        'packages/a_plugin/example/android/build.gradle',
        'packages/a_plugin/example/android/gradle/wrapper/gradle-wrapper.properties',
        'packages/a_plugin/example/ios/Runner.xcodeproj/project.pbxproj',
        'packages/a_plugin/example/ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme',
        'packages/a_plugin/example/linux/flutter/CMakeLists.txt',
        'packages/a_plugin/example/macos/Podfile',
        'packages/a_plugin/example/macos/Runner.xcodeproj/project.pbxproj',
        'packages/a_plugin/example/macos/Runner.xcworkspace/contents.xcworkspacedata',
        'packages/a_plugin/example/windows/CMakeLists.txt',
        'packages/a_plugin/example/pubspec.yaml',
        // Pigeon platform tests, which have an unusual structure.
        'packages/a_plugin/platform_tests/shared_test_plugin_code/lib/integration_tests.dart',
        'packages/a_plugin/platform_tests/test_plugin/windows/test_plugin.cpp',
      ];

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, false);
      expect(state.needsChangelogChange, false);
      expect(state.hasChangelogChange, true);
    });

    test('only considers a root "tool" folder to be special', () async {
      final RepositoryPackage package =
          createFakePlugin('a_plugin', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/lib/foo/tool/tool_thing.dart',
      ];

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
      expect(state.needsChangelogChange, true);
    });

    test('requires a version change for example/lib/main.dart', () async {
      final RepositoryPackage package = createFakePlugin(
          'a_plugin', packagesDir,
          extraFiles: <String>['example/lib/main.dart']);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/example/lib/main.dart',
      ];

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
      expect(state.needsChangelogChange, true);
    });

    test('requires a version change for example/main.dart', () async {
      final RepositoryPackage package = createFakePlugin(
          'a_plugin', packagesDir,
          extraFiles: <String>['example/main.dart']);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/example/main.dart',
      ];

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
      expect(state.needsChangelogChange, true);
    });

    test('requires a version change for example readme.md', () async {
      final RepositoryPackage package =
          createFakePlugin('a_plugin', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/example/README.md',
      ];

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
      expect(state.needsChangelogChange, true);
    });

    test('requires a version change for example/example.md', () async {
      final RepositoryPackage package = createFakePlugin(
          'a_plugin', packagesDir,
          extraFiles: <String>['example/example.md']);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/example/example.md',
      ];

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
      expect(state.needsChangelogChange, true);
    });

    test(
        'requires a changelog change but no version change for '
        'lower-priority examples when example.md is present', () async {
      final RepositoryPackage package = createFakePlugin(
          'a_plugin', packagesDir,
          extraFiles: <String>['example/example.md']);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/example/lib/main.dart',
        'packages/a_plugin/example/main.dart',
        'packages/a_plugin/example/README.md',
      ];

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, false);
      expect(state.needsChangelogChange, true);
    });

    test(
        'requires a changelog change but no version change for README.md when '
        'code example is present', () async {
      final RepositoryPackage package = createFakePlugin(
          'a_plugin', packagesDir,
          extraFiles: <String>['example/lib/main.dart']);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/example/README.md',
      ];

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, false);
      expect(state.needsChangelogChange, true);
    });

    test(
        'requires neither a changelog nor version change for README.md when '
        'code example is present in a federated plugin implementation',
        () async {
      final RepositoryPackage package = createFakePlugin(
          'a_plugin_android', packagesDir.childDirectory('a_plugin'),
          extraFiles: <String>['example/lib/main.dart']);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/a_plugin_android/example/README.md',
      ];

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/a_plugin_android');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, false);
      expect(state.needsChangelogChange, false);
    });

    test(
        'does not requires changelog or version change for build.gradle '
        'test-dependency-only changes', () async {
      final RepositoryPackage package =
          createFakePlugin('a_plugin', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/android/build.gradle',
      ];

      final GitVersionFinder git = FakeGitVersionFinder(<String, List<String>>{
        'packages/a_plugin/android/build.gradle': <String>[
          "-  androidTestImplementation 'androidx.test.espresso:espresso-core:3.2.0'",
          "-  testImplementation 'junit:junit:4.10.0'",
          "+  androidTestImplementation 'androidx.test.espresso:espresso-core:3.4.0'",
          "+  testImplementation 'junit:junit:4.13.2'",
        ]
      });

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/',
          git: git);

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, false);
      expect(state.needsChangelogChange, false);
    });

    test('requires changelog or version change for other build.gradle changes',
        () async {
      final RepositoryPackage package =
          createFakePlugin('a_plugin', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/android/build.gradle',
      ];

      final GitVersionFinder git = FakeGitVersionFinder(<String, List<String>>{
        'packages/a_plugin/android/build.gradle': <String>[
          "-  androidTestImplementation 'androidx.test.espresso:espresso-core:3.2.0'",
          "-  testImplementation 'junit:junit:4.10.0'",
          "+  androidTestImplementation 'androidx.test.espresso:espresso-core:3.4.0'",
          "+  testImplementation 'junit:junit:4.13.2'",
          "-  implementation 'com.google.android.gms:play-services-maps:18.0.0'",
          "+  implementation 'com.google.android.gms:play-services-maps:18.0.2'",
        ]
      });

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/',
          git: git);

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
      expect(state.needsChangelogChange, true);
    });

    test(
        'does not requires changelog or version change for '
        'non-doc-comment-only changes', () async {
      final RepositoryPackage package =
          createFakePlugin('a_plugin', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/lib/a_plugin.dart',
      ];

      final GitVersionFinder git = FakeGitVersionFinder(<String, List<String>>{
        'packages/a_plugin/lib/a_plugin.dart': <String>[
          '-  // Old comment.',
          '+  // New comment.',
          '+ ', // Allow whitespace line changes as part of comment changes.
        ]
      });

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/',
          git: git);

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, false);
      expect(state.needsChangelogChange, false);
    });

    test('requires changelog or version change for doc comment changes',
        () async {
      final RepositoryPackage package =
          createFakePlugin('a_plugin', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/lib/a_plugin.dart',
      ];

      final GitVersionFinder git = FakeGitVersionFinder(<String, List<String>>{
        'packages/a_plugin/lib/a_plugin.dart': <String>[
          '-  /// Old doc comment.',
          '+  /// New doc comment.',
        ]
      });

      final PackageChangeState state = await checkPackageChangeState(
        package,
        changedPaths: changedFiles,
        relativePackagePath: 'packages/a_plugin/',
        git: git,
      );

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
      expect(state.needsChangelogChange, true);
    });

    test('requires changelog or version change for Dart code change', () async {
      final RepositoryPackage package =
          createFakePlugin('a_plugin', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/lib/a_plugin.dart',
      ];

      final GitVersionFinder git = FakeGitVersionFinder(<String, List<String>>{
        'packages/a_plugin/lib/a_plugin.dart': <String>[
          // Include inline comments to ensure the comment check doesn't have
          // false positives for lines that include comment changes but aren't
          // only comment changes.
          '-  callOldMethod(); // inline comment',
          '+  callNewMethod(); // inline comment',
        ]
      });

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/',
          git: git);

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
      expect(state.needsChangelogChange, true);
    });

    test(
        'requires changelog or version change if build.gradle diffs cannot '
        'be checked', () async {
      final RepositoryPackage package =
          createFakePlugin('a_plugin', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/android/build.gradle',
      ];

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/');

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
      expect(state.needsChangelogChange, true);
    });

    test(
        'requires changelog or version change if build.gradle diffs cannot '
        'be determined', () async {
      final RepositoryPackage package =
          createFakePlugin('a_plugin', packagesDir);

      const List<String> changedFiles = <String>[
        'packages/a_plugin/android/build.gradle',
      ];

      final GitVersionFinder git = FakeGitVersionFinder(<String, List<String>>{
        'packages/a_plugin/android/build.gradle': <String>[]
      });

      final PackageChangeState state = await checkPackageChangeState(package,
          changedPaths: changedFiles,
          relativePackagePath: 'packages/a_plugin/',
          git: git);

      expect(state.hasChanges, true);
      expect(state.needsVersionChange, true);
      expect(state.needsChangelogChange, true);
    });
  });
}

class FakeGitVersionFinder extends Fake implements GitVersionFinder {
  FakeGitVersionFinder(this.fileDiffs);

  final Map<String, List<String>> fileDiffs;

  @override
  Future<List<String>> getDiffContents({
    String? targetPath,
    bool includeUncommitted = false,
  }) async {
    return fileDiffs[targetPath]!;
  }
}
