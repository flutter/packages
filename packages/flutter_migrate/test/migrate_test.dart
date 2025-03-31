// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_migrate/src/base/common.dart';
import 'package:flutter_migrate/src/base/file_system.dart';
import 'package:flutter_migrate/src/base/io.dart';
import 'package:flutter_migrate/src/base/logger.dart';
import 'package:flutter_migrate/src/base/signals.dart';
import 'package:flutter_migrate/src/base/terminal.dart';
import 'package:process/process.dart';

import 'src/common.dart';
import 'src/context.dart';
import 'test_data/migrate_project.dart';

// This file contains E2E test that execute the core migrate commands
// and simulates manual conflict resolution and other manipulations of
// the project files.
void main() {
  late Directory tempDir;
  late BufferLogger logger;
  late ProcessManager processManager;
  late FileSystem fileSystem;

  setUp(() async {
    logger = BufferLogger.test();
    processManager = const LocalProcessManager();
    fileSystem = LocalFileSystem.test(signals: LocalSignals.instance);
    tempDir = fileSystem.systemTempDirectory.createTempSync('flutter_run_test');
  });

  tearDown(() async {
    tryToDelete(tempDir);
  });

  Future<bool> hasFlutterEnvironment() async {
    final String flutterRoot = getFlutterRoot();
    final String flutterExecutable = fileSystem.path
        .join(flutterRoot, 'bin', 'flutter${isWindows ? '.bat' : ''}');
    final ProcessResult result = await Process.run(
        flutterExecutable, <String>['analyze', '--suggestions', '--machine']);
    if (result.exitCode != 0) {
      return false;
    }
    return true;
  }

  // Migrates a clean untouched app generated with flutter create
  testUsingContext('vanilla migrate process succeeds', () async {
    // This tool does not support old versions of flutter that dont include
    // `flutter analyze --suggestions --machine` command
    if (!await hasFlutterEnvironment()) {
      return;
    }
    // Flutter Stable 1.22.6 hash: 9b2d32b605630f28625709ebd9d78ab3016b2bf6
    await MigrateProject.installProject('version:1.22.6_stable', tempDir);

    ProcessResult result = await runMigrateCommand(<String>[
      'start',
      '--verbose',
    ], workingDirectory: tempDir.path);
    expect(result.stdout.toString(), contains('Staging directory created at'));
    const String linesToMatch = '''
Added files:
  - android/app/src/main/res/values-night/styles.xml
  - android/app/src/main/res/drawable-v21/launch_background.xml
  - analysis_options.yaml
Modified files:
  - .metadata
  - ios/Runner/Info.plist
  - ios/Runner.xcodeproj/project.xcworkspace/contents.xcworkspacedata
  - ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme
  - ios/Flutter/AppFrameworkInfo.plist
  - ios/.gitignore
  - pubspec.yaml
  - .gitignore
  - android/app/build.gradle
  - android/app/src/profile/AndroidManifest.xml
  - android/app/src/main/res/values/styles.xml
  - android/app/src/main/AndroidManifest.xml
  - android/app/src/debug/AndroidManifest.xml
  - android/gradle/wrapper/gradle-wrapper.properties
  - android/.gitignore
  - android/build.gradle''';
    for (final String line in linesToMatch.split('\n')) {
      expect(result.stdout.toString(), contains(line));
    }

    result = await runMigrateCommand(<String>[
      'apply',
      '--verbose',
    ], workingDirectory: tempDir.path);
    logger.printStatus('${result.exitCode}', color: TerminalColor.blue);
    logger.printStatus(result.stdout as String, color: TerminalColor.green);
    logger.printStatus(result.stderr as String, color: TerminalColor.red);
    expect(result.exitCode, 0);
    expect(result.stdout.toString(), contains('Migration complete'));

    expect(tempDir.childFile('.metadata').readAsStringSync(),
        contains('migration:\n  platforms:\n    - platform: root\n'));

    expect(
        tempDir
            .childFile('android/app/src/main/res/values-night/styles.xml')
            .existsSync(),
        true);
    expect(tempDir.childFile('analysis_options.yaml').existsSync(), true);
  },
      timeout: const Timeout(Duration(seconds: 500)),
      // TODO(stuartmorgan): These should not be unit tests, see
      // https://github.com/flutter/flutter/issues/121257.
      skip: true);

  // Migrates a clean untouched app generated with flutter create
  testUsingContext('vanilla migrate builds', () async {
    // This tool does not support old versions of flutter that dont include
    // `flutter analyze --suggestions --machine` command
    if (!await hasFlutterEnvironment()) {
      return;
    }
    // Flutter Stable 2.0.0 hash: 60bd88df915880d23877bfc1602e8ddcf4c4dd2a
    await MigrateProject.installProject('version:2.0.0_stable', tempDir,
        main: '''
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Container(),
    );
  }
}
''');
    ProcessResult result = await runMigrateCommand(<String>[
      'start',
      '--verbose',
    ], workingDirectory: tempDir.path);
    expect(result.stdout.toString(), contains('Staging directory created at'));

    result = await runMigrateCommand(<String>[
      'apply',
      '--verbose',
    ], workingDirectory: tempDir.path);
    logger.printStatus('${result.exitCode}', color: TerminalColor.blue);
    logger.printStatus(result.stdout as String, color: TerminalColor.green);
    logger.printStatus(result.stderr as String, color: TerminalColor.red);
    expect(result.exitCode, 0);
    expect(result.stdout.toString(), contains('Migration complete'));

    result = await processManager.run(<String>[
      'flutter',
      'build',
      'apk',
      '--debug',
    ], workingDirectory: tempDir.path);
    expect(result.exitCode, 0);
    expect(result.stdout.toString(), contains('app-debug.apk'));
    // Skipped due to being flaky, the build completes successfully, but sometimes
    // Gradle crashes due to resources on the bot. We should fine tune this to
    // make it stable.
  },
      timeout: const Timeout(Duration(seconds: 900)),
      // TODO(stuartmorgan): These should not be unit tests, see
      // https://github.com/flutter/flutter/issues/121257.
      skip: true);

  testUsingContext('migrate abandon', () async {
    // Abandon in an empty dir fails.
    ProcessResult result = await runMigrateCommand(<String>[
      'abandon',
      '--verbose',
    ], workingDirectory: tempDir.path);
    expect(result.exitCode, 0);
    expect(result.stderr.toString(),
        contains('Error: No pubspec.yaml file found'));
    expect(
        result.stderr.toString(),
        contains(
            'This command should be run from the root of your Flutter project'));

    final File manifestFile =
        tempDir.childFile('migrate_staging_dir/.migrate_manifest');
    expect(manifestFile.existsSync(), false);

    // Flutter Stable 1.22.6 hash: 9b2d32b605630f28625709ebd9d78ab3016b2bf6
    await MigrateProject.installProject('version:1.22.6_stable', tempDir);

    // Initialized repo fails.
    result = await runMigrateCommand(<String>[
      'abandon',
      '--verbose',
    ], workingDirectory: tempDir.path);
    expect(result.exitCode, 0);
    expect(result.stdout.toString(), contains('No migration in progress'));

    // Create migration.
    manifestFile.createSync(recursive: true);

    // Directory with manifest_staging_dir succeeds.
    result = await runMigrateCommand(<String>[
      'abandon',
      '--verbose',
      '--force',
    ], workingDirectory: tempDir.path);
    expect(result.exitCode, 0);
    expect(result.stdout.toString(), contains('Abandon complete'));
  },
      timeout: const Timeout(Duration(seconds: 300)),
      // TODO(stuartmorgan): These should not be unit tests, see
      // https://github.com/flutter/flutter/issues/121257.
      skip: true);

  // Migrates a user-modified app
  testUsingContext('modified migrate process succeeds', () async {
    // This tool does not support old versions of flutter that dont include
    // `flutter analyze --suggestions --machine` command
    if (!await hasFlutterEnvironment()) {
      return;
    }
    // Flutter Stable 1.22.6 hash: 9b2d32b605630f28625709ebd9d78ab3016b2bf6
    await MigrateProject.installProject('version:1.22.6_stable', tempDir,
        vanilla: false);

    ProcessResult result = await runMigrateCommand(<String>[
      'apply',
      '--verbose',
    ], workingDirectory: tempDir.path);
    expect(result.exitCode, 0);
    expect(result.stdout.toString(), contains('No migration'));

    result = await runMigrateCommand(<String>[
      'status',
      '--verbose',
    ], workingDirectory: tempDir.path);
    expect(result.exitCode, 0);
    expect(result.stdout.toString(), contains('No migration'));

    result = await runMigrateCommand(<String>[
      'start',
      '--verbose',
    ], workingDirectory: tempDir.path);
    expect(result.exitCode, 0);
    expect(result.stdout.toString(), contains('Staging directory created at'));
    const String linesToMatch = '''
Modified files:
  - .metadata
  - ios/Runner/Info.plist
  - ios/Runner.xcodeproj/project.xcworkspace/contents.xcworkspacedata
  - ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme
  - ios/Flutter/AppFrameworkInfo.plist
  - ios/.gitignore
  - .gitignore
  - android/app/build.gradle
  - android/app/src/profile/AndroidManifest.xml
  - android/app/src/main/res/values/styles.xml
  - android/app/src/main/AndroidManifest.xml
  - android/app/src/debug/AndroidManifest.xml
  - android/gradle/wrapper/gradle-wrapper.properties
  - android/.gitignore
  - android/build.gradle
Merge conflicted files:
  - pubspec.yaml''';
    for (final String line in linesToMatch.split('\n')) {
      expect(result.stdout.toString(), contains(line));
    }

    // Call apply with conflicts remaining. Should fail.
    result = await runMigrateCommand(<String>[
      'apply',
      '--verbose',
    ], workingDirectory: tempDir.path);
    expect(result.exitCode, 0);
    expect(
        result.stdout.toString(),
        contains(
            'Conflicting files found. Resolve these conflicts and try again.'));
    expect(result.stdout.toString(), contains('- pubspec.yaml'));

    result = await runMigrateCommand(<String>[
      'status',
      '--verbose',
    ], workingDirectory: tempDir.path);
    expect(result.exitCode, 0);
    expect(result.stdout.toString(), contains('Modified files'));
    expect(result.stdout.toString(), contains('Merge conflicted files'));

    // Manually resolve conflics. The correct contents for resolution may change over time,
    // but it shouldnt matter for this test.
    final File metadataFile =
        tempDir.childFile('migrate_staging_dir/.metadata');
    metadataFile.writeAsStringSync('''
# This file tracks properties of this Flutter project.
# Used by Flutter tool to assess capabilities and perform upgrades etc.
#
# This file should be version controlled and should not be manually edited.

version:
  revision: e96a72392696df66755ca246ff291dfc6ca6c4ad
  channel: unknown

project_type: app

''', flush: true);
    final File pubspecYamlFile =
        tempDir.childFile('migrate_staging_dir/pubspec.yaml');
    pubspecYamlFile.writeAsStringSync('''
name: vanilla_app_1_22_6_stable
description: This is a modified description from the default.

# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
version: 1.0.0+1

environment:
  sdk: ">=2.17.0-79.0.dev <3.0.0"

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter


  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^1.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  assets:
    - images/a_dot_burr.jpeg
    - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images.

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package

''', flush: true);

    result = await runMigrateCommand(<String>[
      'status',
      '--verbose',
    ], workingDirectory: tempDir.path);
    expect(result.exitCode, 0);
    expect(result.stdout.toString(), contains('Modified files'));
    expect(result.stdout.toString(), contains('diff --git'));
    expect(result.stdout.toString(), contains('@@'));
    expect(result.stdout.toString(), isNot(contains('Merge conflicted files')));

    result = await runMigrateCommand(<String>[
      'apply',
      '--verbose',
    ], workingDirectory: tempDir.path);
    expect(result.exitCode, 0);
    expect(result.stdout.toString(), contains('Migration complete'));

    expect(tempDir.childFile('.metadata').readAsStringSync(),
        contains('e96a72392696df66755ca246ff291dfc6ca6c4ad'));
    expect(tempDir.childFile('pubspec.yaml').readAsStringSync(),
        isNot(contains('">=2.6.0 <3.0.0"')));
    expect(tempDir.childFile('pubspec.yaml').readAsStringSync(),
        contains('">=2.17.0-79.0.dev <3.0.0"'));
    expect(
        tempDir.childFile('pubspec.yaml').readAsStringSync(),
        contains(
            'description: This is a modified description from the default.'));
    expect(tempDir.childFile('lib/main.dart').readAsStringSync(),
        contains('OtherWidget()'));
    expect(tempDir.childFile('lib/other.dart').existsSync(), true);
    expect(tempDir.childFile('lib/other.dart').readAsStringSync(),
        contains('class OtherWidget'));

    expect(
        tempDir
            .childFile('android/app/src/main/res/values-night/styles.xml')
            .existsSync(),
        true);
    expect(tempDir.childFile('analysis_options.yaml').existsSync(), true);
  },
      timeout: const Timeout(Duration(seconds: 500)),
      // TODO(stuartmorgan): These should not be unit tests, see
      // https://github.com/flutter/flutter/issues/121257.
      skip: true);
}
