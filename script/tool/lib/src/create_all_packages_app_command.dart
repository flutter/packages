// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

import 'common/core.dart';
import 'common/package_command.dart';
import 'common/process_runner.dart';
import 'common/repository_package.dart';

@visibleForTesting

/// The name of the build-all-packages project.
const String allPackagesProjectName = 'all_packages';

const int _exitFlutterCreateFailed = 3;
const int _exitGenNativeBuildFilesFailed = 4;
const int _exitMissingFile = 5;

/// A command to create an application that builds all in a single application.
class CreateAllPackagesAppCommand extends PackageCommand {
  /// Creates an instance of the builder command.
  CreateAllPackagesAppCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
  }) : super(packagesDir, processRunner: processRunner, platform: platform) {
    argParser.addOption(_outputDirectoryFlag,
        defaultsTo: packagesDir.parent.path,
        help: 'The path the directory to create the "$allPackagesProjectName" '
            'project in.\n'
            'Defaults to the repository root.');
    argParser.addOption(_agpVersionFlag,
        help: 'The AGP version to use in the created app, instead of the '
            'default `flutter create`d version. Will generally need to be used '
            ' with $_gradleVersionFlag due to compatibility limits.');
    argParser.addOption(_androidLanguageFlag,
        defaultsTo: 'kotlin',
        allowed: <String>['java', 'kotlin'],
        help: 'The AGP version to use in the created app, instead of the '
            'default `flutter create`d version. Will generally need to be used '
            ' with $_gradleVersionFlag due to compatibility limits.');
    argParser.addOption(_gradleVersionFlag,
        help: 'The Gradle version to use in the created app, instead of the '
            'default `flutter create`d version. Will generally need to be used '
            ' with $_agpVersionFlag due to compatibility limits.');
    argParser.addMultiOption(_platformsFlag,
        help: 'A platforms list to pass to `flutter create`');
  }

  static const String _androidLanguageFlag = 'android-language';
  static const String _agpVersionFlag = 'agp-version';
  static const String _gradleVersionFlag = 'gradle-version';
  static const String _outputDirectoryFlag = 'output-dir';
  static const String _platformsFlag = 'platforms';

  /// The location to create the synthesized app project.
  Directory get _appDirectory => packagesDir.fileSystem
      .directory(getStringArg(_outputDirectoryFlag))
      .childDirectory(allPackagesProjectName);

  /// The synthesized app project.
  RepositoryPackage get app => RepositoryPackage(_appDirectory);

  @override
  String get description =>
      'Generate Flutter app that includes all target packagas.';

  @override
  String get name => 'create-all-packages-app';

  @override
  Future<void> run() async {
    final int exitCode = await _createApp();
    if (exitCode != 0) {
      printError('Failed to `flutter create`: $exitCode');
      throw ToolExit(_exitFlutterCreateFailed);
    }

    final Set<String> excluded = getExcludedPackageNames();
    if (excluded.isNotEmpty) {
      print('Exluding the following plugins from the combined build:');
      for (final String plugin in excluded) {
        print('  $plugin');
      }
      print('');
    }

    await _genPubspecWithAllPlugins();

    // Run `flutter pub get` to generate all native build files.
    // TODO(stuartmorgan): This hangs on Windows for some reason. Since it's
    // currently not needed on Windows, skip it there, but we should investigate
    // further and/or implement https://github.com/flutter/flutter/issues/93407,
    // and remove the need for this conditional.
    if (!platform.isWindows) {
      if (!await _genNativeBuildFiles()) {
        printError(
            "Failed to generate native build files via 'flutter pub get'");
        throw ToolExit(_exitGenNativeBuildFilesFailed);
      }
    }

    await Future.wait(<Future<void>>[
      if (_targetPlatformIncludes(platformAndroid)) ...<Future<void>>[
        _updateTopLevelGradle(
            agpVersion: getNullableStringArg(_agpVersionFlag)),
        _updateGradleWrapper(
            gradleVersion: getNullableStringArg(_gradleVersionFlag)),
        _updateAppGradle(),
      ],
      if (_targetPlatformIncludes(platformMacOS)) ...<Future<void>>[
        _updateMacosPbxproj(),
        // This step requires the native file generation triggered by
        // flutter pub get above, so can't currently be run on Windows.
        if (!platform.isWindows) _updateMacosPodfile(),
      ],
    ]);
  }

  /// True if the created app includes [platform].
  bool _targetPlatformIncludes(String platform) {
    final List<String> platforms = getStringListArg(_platformsFlag);
    // An empty platform list means the app targets all platforms, since that's
    // how `flutter create` works.
    return platforms.contains(platform) || platforms.isEmpty;
  }

  Future<int> _createApp() async {
    final List<String> platforms = getStringListArg(_platformsFlag);
    return processRunner.runAndStream(
      flutterCommand,
      <String>[
        'create',
        if (platforms.isNotEmpty) '--platforms=${platforms.join(',')}',
        '--template=app',
        '--project-name=$allPackagesProjectName',
        '--android-language=${getStringArg(_androidLanguageFlag)}',
        _appDirectory.path,
      ],
    );
  }

  /// Rewrites [file], replacing any lines contain a key in [replacements] with
  /// the lines in the corresponding value, and adding any lines in [additions]'
  /// values after lines containing the key.
  void _adjustFile(
    File file, {
    Map<String, List<String>> replacements = const <String, List<String>>{},
    Map<String, List<String>> additions = const <String, List<String>>{},
  }) {
    if (replacements.isEmpty && additions.isEmpty) {
      return;
    }
    if (!file.existsSync()) {
      printError('Unable to find ${file.path} for updating.');
      throw ToolExit(_exitMissingFile);
    }

    final StringBuffer output = StringBuffer();
    for (final String line in file.readAsLinesSync()) {
      List<String> lines = <String>[line];
      for (final String targetString in replacements.keys) {
        if (line.contains(targetString)) {
          lines = replacements[targetString]!;
          break;
        }
      }
      lines.forEach(output.writeln);

      for (final String targetString in additions.keys) {
        if (line.contains(targetString)) {
          additions[targetString]!.forEach(output.writeln);
        }
      }
    }
    file.writeAsStringSync(output.toString());
  }

  Future<void> _updateTopLevelGradle({String? agpVersion}) async {
    final File gradleFile = app
        .platformDirectory(FlutterPlatform.android)
        .childFile('build.gradle');
    _adjustFile(
      gradleFile,
      replacements: <String, List<String>>{
        if (agpVersion != null)
          'com.android.tools.build:': <String>[
            "        classpath 'com.android.tools.build:gradle:$agpVersion'"
          ],
      },
    );
  }

  Future<void> _updateGradleWrapper({String? gradleVersion}) async {
    final File gradleFile = app
        .platformDirectory(FlutterPlatform.android)
        .childDirectory('gradle')
        .childDirectory('wrapper')
        .childFile('gradle-wrapper.properties');
    _adjustFile(
      gradleFile,
      replacements: <String, List<String>>{
        if (gradleVersion != null)
          'distributionUrl': <String>[
            'distributionUrl=https\\://services.gradle.org/distributions/gradle-$gradleVersion-bin.zip'
          ],
      },
    );
  }

  Future<void> _updateAppGradle() async {
    final File gradleFile = app
        .platformDirectory(FlutterPlatform.android)
        .childDirectory('app')
        .childFile('build.gradle');
    _adjustFile(
      gradleFile,
      replacements: <String, List<String>>{
        // minSdkVersion 21 is required by camera_android.
        'minSdkVersion': <String>['minSdkVersion 21'],
        // compileSdkVersion 33 is required by local_auth.
        'compileSdkVersion': <String>['compileSdkVersion 33'],
      },
      additions: <String, List<String>>{
        'defaultConfig {': <String>['        multiDexEnabled true'],
        // Tests for https://github.com/flutter/flutter/issues/43383
        'dependencies {': <String>[
          "    implementation 'androidx.lifecycle:lifecycle-runtime:2.2.0-rc01'\n"
        ],
      },
    );
  }

  Future<void> _genPubspecWithAllPlugins() async {
    // Read the old pubspec file's Dart SDK version, in order to preserve it
    // in the new file. The template sometimes relies on having opted in to
    // specific language features via SDK version, so using a different one
    // can cause compilation failures.
    final Pubspec originalPubspec = app.parsePubspec();
    const String dartSdkKey = 'sdk';
    final VersionConstraint dartSdkConstraint =
        originalPubspec.environment?[dartSdkKey] ??
            VersionConstraint.compatibleWith(
              Version.parse('2.12.0'),
            );

    final Map<String, PathDependency> pluginDeps =
        await _getValidPathDependencies();
    final Pubspec pubspec = Pubspec(
      allPackagesProjectName,
      description: 'Flutter app containing all 1st party plugins.',
      version: Version.parse('1.0.0+1'),
      environment: <String, VersionConstraint>{
        dartSdkKey: dartSdkConstraint,
      },
      dependencies: <String, Dependency>{
        'flutter': SdkDependency('flutter'),
      }..addAll(pluginDeps),
      devDependencies: <String, Dependency>{
        'flutter_test': SdkDependency('flutter'),
      },
      dependencyOverrides: pluginDeps,
    );
    app.pubspecFile.writeAsStringSync(_pubspecToString(pubspec));
  }

  Future<Map<String, PathDependency>> _getValidPathDependencies() async {
    final Map<String, PathDependency> pathDependencies =
        <String, PathDependency>{};

    await for (final PackageEnumerationEntry entry in getTargetPackages()) {
      final RepositoryPackage package = entry.package;
      final Directory pluginDirectory = package.directory;
      final String pluginName = pluginDirectory.basename;
      final Pubspec pubspec = package.parsePubspec();

      if (pubspec.publishTo != 'none') {
        pathDependencies[pluginName] = PathDependency(pluginDirectory.path);
      }
    }
    return pathDependencies;
  }

  String _pubspecToString(Pubspec pubspec) {
    return '''
### Generated file. Do not edit. Run `dart pub global run flutter_plugin_tools gen-pubspec` to update.
name: ${pubspec.name}
description: ${pubspec.description}
publish_to: none

version: ${pubspec.version}

environment:${_pubspecMapString(pubspec.environment!)}

dependencies:${_pubspecMapString(pubspec.dependencies)}

dependency_overrides:${_pubspecMapString(pubspec.dependencyOverrides)}

dev_dependencies:${_pubspecMapString(pubspec.devDependencies)}
###''';
  }

  String _pubspecMapString(Map<String, Object?> values) {
    final StringBuffer buffer = StringBuffer();

    for (final MapEntry<String, Object?> entry in values.entries) {
      buffer.writeln();
      final Object? entryValue = entry.value;
      if (entryValue is VersionConstraint) {
        String value = entryValue.toString();
        // Range constraints require quoting.
        if (value.startsWith('>') || value.startsWith('<')) {
          value = "'$value'";
        }
        buffer.write('  ${entry.key}: $value');
      } else if (entryValue is SdkDependency) {
        buffer.write('  ${entry.key}: \n    sdk: ${entryValue.sdk}');
      } else if (entryValue is PathDependency) {
        String depPath = entryValue.path;
        if (path.style == p.Style.windows) {
          // Posix-style path separators are preferred in pubspec.yaml (and
          // using a consistent format makes unit testing simpler), so convert.
          final List<String> components = path.split(depPath);
          final String firstComponent = components.first;
          // path.split leaves a \ on drive components that isn't necessary,
          // and confuses pub, so remove it.
          if (firstComponent.endsWith(r':\')) {
            components[0] =
                firstComponent.substring(0, firstComponent.length - 1);
          }
          depPath = p.posix.joinAll(components);
        }
        buffer.write('  ${entry.key}: \n    path: $depPath');
      } else {
        throw UnimplementedError(
          'Not available for type: ${entryValue.runtimeType}',
        );
      }
    }

    return buffer.toString();
  }

  Future<bool> _genNativeBuildFiles() async {
    final int exitCode = await processRunner.runAndStream(
      flutterCommand,
      <String>['pub', 'get'],
      workingDir: _appDirectory,
    );
    return exitCode == 0;
  }

  Future<void> _updateMacosPodfile() async {
    /// Only change the macOS deployment target if the host platform is macOS.
    /// The Podfile is not generated on other platforms.
    if (!platform.isMacOS) {
      return;
    }

    final File podfile =
        app.platformDirectory(FlutterPlatform.macos).childFile('Podfile');
    _adjustFile(
      podfile,
      replacements: <String, List<String>>{
        // macOS 10.15 is required by in_app_purchase.
        'platform :osx': <String>["platform :osx, '10.15'"],
      },
    );
  }

  Future<void> _updateMacosPbxproj() async {
    final File pbxprojFile = app
        .platformDirectory(FlutterPlatform.macos)
        .childDirectory('Runner.xcodeproj')
        .childFile('project.pbxproj');
    _adjustFile(
      pbxprojFile,
      replacements: <String, List<String>>{
        // macOS 10.15 is required by in_app_purchase.
        'MACOSX_DEPLOYMENT_TARGET': <String>[
          '				MACOSX_DEPLOYMENT_TARGET = 10.15;'
        ],
      },
    );
  }
}
