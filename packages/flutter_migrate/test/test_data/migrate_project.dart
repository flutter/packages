// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@Timeout(Duration(seconds: 600))
library;

import 'dart:io';
import 'package:file/file.dart';
import 'package:flutter_migrate/src/base/file_system.dart';

import '../src/common.dart';
import '../src/test_utils.dart';
import 'project.dart';

class MigrateProject extends Project {
  MigrateProject(this.version, {this.vanilla = true, this.main});

  final String version;

  /// Manually set main.dart
  @override
  final String? main;

  /// Non-vanilla is a set of changed files that guarantee a merge conflict.
  final bool vanilla;

  late String _appPath;

  static Future<void> installProject(String verison, Directory dir,
      {bool vanilla = true, String? main}) async {
    final MigrateProject project =
        MigrateProject(verison, vanilla: vanilla, main: main);
    await project.setUpIn(dir);

    // Init a git repo to test uncommitted changes checks
    await processManager.run(<String>[
      'git',
      'init',
    ], workingDirectory: dir.path);
    await processManager.run(<String>[
      'git',
      'checkout',
      '-b',
      'master',
    ], workingDirectory: dir.path);
    await commitChanges(dir);
  }

  static Future<void> commitChanges(Directory dir) async {
    await processManager.run(<String>[
      'git',
      'add',
      '.',
    ], workingDirectory: dir.path);
    await processManager.run(<String>[
      'git',
      'commit',
      '-m',
      '"All changes"',
    ], workingDirectory: dir.path);
  }

  @override
  Future<void> setUpIn(
    Directory dir, {
    bool useSyntheticPackage = false,
  }) async {
    this.dir = dir;
    _appPath = dir.path;
    writeFile(fileSystem.path.join(dir.path, 'android', 'local.properties'),
        androidLocalProperties);
    final Directory tempDir = createResolvedTempDirectorySync('cipd_dest.');
    final Directory depotToolsDir =
        createResolvedTempDirectorySync('depot_tools.');

    await processManager.run(<String>[
      'git',
      'clone',
      'https://chromium.googlesource.com/chromium/tools/depot_tools',
      depotToolsDir.path,
    ], workingDirectory: dir.path);

    final File cipdFile =
        depotToolsDir.childFile(Platform.isWindows ? 'cipd.bat' : 'cipd');
    await processManager.run(<String>[
      cipdFile.path,
      'init',
      tempDir.path,
      '-force',
    ], workingDirectory: dir.path);

    await processManager.run(<String>[
      cipdFile.path,
      'install',
      'flutter/test/full_app_fixtures/vanilla',
      version,
      '-root',
      tempDir.path,
    ], workingDirectory: dir.path);

    if (Platform.isWindows) {
      ProcessResult res = await processManager.run(<String>[
        'robocopy',
        tempDir.path,
        dir.path,
        '*',
        '/E',
        '/V',
        '/mov',
      ]);
      // Robocopy exit code 1 means some files were copied. 0 means no files were copied.
      assert(res.exitCode == 1);
      res = await processManager.run(<String>[
        'takeown',
        '/f',
        dir.path,
        '/r',
      ]);
      res = await processManager.run(<String>[
        'takeown',
        '/f',
        '${dir.path}\\lib\\main.dart',
        '/r',
      ]);
      res = await processManager.run(<String>[
        'icacls',
        dir.path,
      ], workingDirectory: dir.path);
      // Add full access permissions to Users
      res = await processManager.run(<String>[
        'icacls',
        dir.path,
        '/q',
        '/c',
        '/t',
        '/grant',
        'Users:F',
      ]);
    } else {
      // This cp command changes the symlinks to real files so the tool can edit them.
      await processManager.run(<String>[
        'cp',
        '-R',
        '-L',
        '-f',
        '${tempDir.path}/.',
        dir.path,
      ]);

      await processManager.run(<String>[
        'rm',
        '-rf',
        '.cipd',
      ], workingDirectory: dir.path);

      await processManager.run(<String>[
        'chmod',
        '-R',
        '+w',
        dir.path,
      ], workingDirectory: dir.path);

      await processManager.run(<String>[
        'chmod',
        '-R',
        '+r',
        dir.path,
      ], workingDirectory: dir.path);
    }

    if (!vanilla) {
      writeFile(fileSystem.path.join(dir.path, 'lib', 'main.dart'), libMain);
      writeFile(fileSystem.path.join(dir.path, 'lib', 'other.dart'), libOther);
      writeFile(fileSystem.path.join(dir.path, 'pubspec.yaml'), pubspecCustom);
    }
    if (main != null) {
      writeFile(fileSystem.path.join(dir.path, 'lib', 'main.dart'), main!);
    }
    tryToDelete(tempDir);
    tryToDelete(depotToolsDir);
  }

  // Maintain the same pubspec as the configured app.
  @override
  String get pubspec => fileSystem
      .file(fileSystem.path.join(_appPath, 'pubspec.yaml'))
      .readAsStringSync();

  String get androidLocalProperties => '''
  flutter.sdk=${getFlutterRoot()}
  ''';

  String get libMain => '''
import 'package:flutter/material.dart';
import 'other.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: OtherWidget(),
    );
  }
}

''';

  String get libOther => '''
class OtherWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 100, height: 100);
  }
}

''';

  String get pubspecCustom => '''
name: vanilla_app_1_22_6_stable
description: This is a modified description from the default.

# The following line prevents the package from being accidentally published to
# pub.dev using `pub publish`. This is preferred for private packages.
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
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter


  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter.
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

''';
}
