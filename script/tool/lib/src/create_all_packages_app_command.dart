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
import 'common/file_utils.dart';
import 'common/output_utils.dart';
import 'common/package_command.dart';
import 'common/process_runner.dart';
import 'common/pub_utils.dart';
import 'common/repository_package.dart';

/// The name of the build-all-packages project, as passed to `flutter create`.
@visibleForTesting
const String allPackagesProjectName = 'all_packages';

const int _exitFlutterCreateFailed = 3;
const int _exitGenNativeBuildFilesFailed = 4;
const int _exitMissingFile = 5;
const int _exitMissingLegacySource = 6;

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
    argParser.addOption(_legacySourceFlag,
        help: 'A partial project directory to use as a source for replacing '
            'portions of the created app. All top-level directories in the '
            'source will replace the corresponding directories in the output '
            'directory post-create.\n\n'
            'The replacement will be done before any tool-driven '
            'modifications.');
  }

  static const String _legacySourceFlag = 'legacy-source';
  static const String _outputDirectoryFlag = 'output-dir';

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

    final String? legacySource = getNullableStringArg(_legacySourceFlag);
    if (legacySource != null) {
      final Directory legacyDir =
          packagesDir.fileSystem.directory(legacySource);
      await _replaceWithLegacy(target: _appDirectory, source: legacyDir);
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
      if (!await runPubGet(app, processRunner, platform)) {
        printError(
            "Failed to generate native build files via 'flutter pub get'");
        throw ToolExit(_exitGenNativeBuildFilesFailed);
      }
    }

    await Future.wait(<Future<void>>[
      _updateAppGradle(),
      _updateIOSPbxproj(),
      _updateMacOSPbxproj(),
      // This step requires the native file generation triggered by
      // flutter pub get above, so can't currently be run on Windows.
      if (!platform.isWindows) _updateMacosPodfile(),
    ]);
  }

  Future<int> _createApp() async {
    return processRunner.runAndStream(
      flutterCommand,
      <String>[
        'create',
        '--template=app',
        '--project-name=$allPackagesProjectName',
        _appDirectory.path,
      ],
    );
  }

  Future<void> _replaceWithLegacy(
      {required Directory target, required Directory source}) async {
    if (!source.existsSync()) {
      printError('No such legacy source directory: ${source.path}');
      throw ToolExit(_exitMissingLegacySource);
    }
    for (final FileSystemEntity entity in source.listSync()) {
      final String basename = entity.basename;
      print('Replacing $basename with legacy version...');
      if (entity is Directory) {
        target.childDirectory(basename).deleteSync(recursive: true);
      } else {
        target.childFile(basename).deleteSync();
      }
      _copyDirectory(source: source, target: target);
    }
  }

  void _copyDirectory({required Directory target, required Directory source}) {
    target.createSync(recursive: true);
    for (final FileSystemEntity entity in source.listSync(recursive: true)) {
      final List<String> subcomponents =
          p.split(p.relative(entity.path, from: source.path));
      if (entity is Directory) {
        childDirectoryWithSubcomponents(target, subcomponents)
            .createSync(recursive: true);
      } else if (entity is File) {
        final File targetFile =
            childFileWithSubcomponents(target, subcomponents);
        targetFile.parent.createSync(recursive: true);
        entity.copySync(targetFile.path);
      } else {
        throw UnimplementedError('Unsupported entity: $entity');
      }
    }
  }

  /// Rewrites [file], replacing any lines contain a key in [replacements] with
  /// the lines in the corresponding value, and adding any lines in [additions]'
  /// values after lines containing the key.
  void _adjustFile(
    File file, {
    Map<String, List<String>> replacements = const <String, List<String>>{},
    Map<String, List<String>> additions = const <String, List<String>>{},
    Map<RegExp, List<String>> regexReplacements =
        const <RegExp, List<String>>{},
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
      List<String>? replacementLines;
      for (final MapEntry<String, List<String>> replacement
          in replacements.entries) {
        if (line.contains(replacement.key)) {
          replacementLines = replacement.value;
          break;
        }
      }
      if (replacementLines == null) {
        for (final MapEntry<RegExp, List<String>> replacement
            in regexReplacements.entries) {
          final RegExpMatch? match = replacement.key.firstMatch(line);
          if (match != null) {
            replacementLines = replacement.value;
            break;
          }
        }
      }
      (replacementLines ?? <String>[line]).forEach(output.writeln);

      for (final String targetString in additions.keys) {
        if (line.contains(targetString)) {
          additions[targetString]!.forEach(output.writeln);
        }
      }
    }
    file.writeAsStringSync(output.toString());
  }

  Future<void> _updateAppGradle() async {
    final File gradleFile = app
        .platformDirectory(FlutterPlatform.android)
        .childDirectory('app')
        .listSync()
        .whereType<File>()
        .firstWhere(
          (File file) => file.basename.startsWith('build.gradle'),
        );

    final bool gradleFileIsKotlin = gradleFile.basename.endsWith('kts');

    // Ensure that there is a dependencies section, so the dependencies addition
    // below will work.
    final String content = gradleFile.readAsStringSync();
    if (!content.contains('\ndependencies {')) {
      gradleFile.writeAsStringSync('''
$content
dependencies {}
''');
    }

    final String lifecycleDependency = gradleFileIsKotlin
        ? '    implementation("androidx.lifecycle:lifecycle-runtime:2.2.0-rc01")'
        : "    implementation 'androidx.lifecycle:lifecycle-runtime:2.2.0-rc01'";

    _adjustFile(
      gradleFile,
      replacements: <String, List<String>>{
        if (gradleFileIsKotlin)
          'compileSdk': <String>['compileSdk = 36']
        else ...<String, List<String>>{
          'compileSdkVersion': <String>['compileSdk 36'],
        }
      },
      regexReplacements: <RegExp, List<String>>{
        // Tests for https://github.com/flutter/flutter/issues/43383
        // Handling of 'dependencies' is more complex since it hasn't been very
        // stable across template versions.
        // - Handle an empty, collapsed dependencies section.
        RegExp(r'^dependencies\s+{\s*}$'): <String>[
          'dependencies {',
          lifecycleDependency,
          '}',
        ],
        // - Handle a normal dependencies section.
        RegExp(r'^dependencies\s+{$'): <String>[
          'dependencies {',
          lifecycleDependency,
        ],
        // - See below for handling of the case where there is no dependencies
        // section.
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
        originalPubspec.environment[dartSdkKey] ??
            VersionConstraint.compatibleWith(
              Version.parse('3.0.0'),
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

    // An application cannot depend directly on multiple federated
    // implementations of the same plugin for the same platform, which means the
    // app cannot directly depend on both camera_android and
    // camera_android_androidx. Since camera_android_androidx is endorsed, it
    // will be included transitively already, so exclude it from the direct
    // dependency list to allow including camera_android to ensure that they
    // don't conflict at build time (if they did, it would be impossible to use
    // camera_android while camera_android_androidx is endorsed).
    // This is special-cased here, rather than being done via the normal
    // exclusion config file mechanism, because it still needs to be in the
    // depenedency overrides list to ensure that the version from path is used.
    pubspec.dependencies.remove('camera_android_camerax');

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

environment:${_pubspecMapString(pubspec.environment)}

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

  Future<void> _updateMacOSPbxproj() async {
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

  Future<void> _updateIOSPbxproj() async {
    final File pbxprojFile = app
        .platformDirectory(FlutterPlatform.ios)
        .childDirectory('Runner.xcodeproj')
        .childFile('project.pbxproj');
    _adjustFile(
      pbxprojFile,
      replacements: <String, List<String>>{
        // iOS 14 is required by google_maps_flutter.
        'IPHONEOS_DEPLOYMENT_TARGET': <String>[
          '				IPHONEOS_DEPLOYMENT_TARGET = 14.0;'
        ],
      },
    );
  }
}
