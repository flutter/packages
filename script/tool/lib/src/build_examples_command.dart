// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:yaml/yaml.dart';

import 'common/core.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/repository_package.dart';

/// Key for APK.
const String _platformFlagApk = 'apk';

const String _pluginToolsConfigFileName = '.pluginToolsConfig.yaml';
const String _pluginToolsConfigBuildFlagsKey = 'buildFlags';
const String _pluginToolsConfigGlobalKey = 'global';

const String _pluginToolsConfigExample = '''
$_pluginToolsConfigBuildFlagsKey:
  $_pluginToolsConfigGlobalKey:
    - "--no-tree-shake-icons"
    - "--dart-define=buildmode=testing"
''';

const int _exitNoPlatformFlags = 3;
const int _exitInvalidPluginToolsConfig = 4;

// Flutter build types. These are the values passed to `flutter build <foo>`.
const String _flutterBuildTypeAndroid = 'apk';
const String _flutterBuildTypeIOS = 'ios';
const String _flutterBuildTypeLinux = 'linux';
const String _flutterBuildTypeMacOS = 'macos';
const String _flutterBuildTypeWeb = 'web';
const String _flutterBuildTypeWindows = 'windows';

const String _flutterBuildTypeAndroidAlias = 'android';

/// Key for Swift Package Manager.
const String _swiftPackageManagerFlag = 'swift-package-manager';

/// A command to build the example applications for packages.
class BuildExamplesCommand extends PackageLoopingCommand {
  /// Creates an instance of the build command.
  BuildExamplesCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
  }) {
    argParser.addFlag(platformLinux);
    argParser.addFlag(platformMacOS);
    argParser.addFlag(platformWeb);
    argParser.addFlag(platformWindows);
    argParser.addFlag(platformIOS);
    argParser.addFlag(_platformFlagApk,
        aliases: const <String>[_flutterBuildTypeAndroidAlias]);
    argParser.addOption(
      kEnableExperiment,
      defaultsTo: '',
      help: 'Enables the given Dart SDK experiments.',
    );
    argParser.addFlag(_swiftPackageManagerFlag, defaultsTo: null);
  }

  // Maps the switch this command uses to identify a platform to information
  // about it.
  static final Map<String, _PlatformDetails> _platforms =
      <String, _PlatformDetails>{
    _platformFlagApk: const _PlatformDetails(
      'Android',
      pluginPlatform: platformAndroid,
      flutterBuildType: _flutterBuildTypeAndroid,
    ),
    platformIOS: const _PlatformDetails(
      'iOS',
      pluginPlatform: platformIOS,
      flutterBuildType: _flutterBuildTypeIOS,
      extraBuildFlags: <String>['--no-codesign'],
    ),
    platformLinux: const _PlatformDetails(
      'Linux',
      pluginPlatform: platformLinux,
      flutterBuildType: _flutterBuildTypeLinux,
    ),
    platformMacOS: const _PlatformDetails(
      'macOS',
      pluginPlatform: platformMacOS,
      flutterBuildType: _flutterBuildTypeMacOS,
    ),
    platformWeb: const _PlatformDetails(
      'web',
      pluginPlatform: platformWeb,
      flutterBuildType: _flutterBuildTypeWeb,
    ),
    platformWindows: const _PlatformDetails(
      'Windows',
      pluginPlatform: platformWindows,
      flutterBuildType: _flutterBuildTypeWindows,
    ),
  };

  @override
  final String name = 'build-examples';

  @override
  final String description =
      'Builds all example apps (IPA for iOS and APK for Android).\n\n'
      'This command requires "flutter" to be in your path.\n\n'
      'A $_pluginToolsConfigFileName file can be placed in an example app '
      'directory to specify additional build arguments. It should be a YAML '
      'file with a top-level map containing a single key '
      '"$_pluginToolsConfigBuildFlagsKey" containing a map containing a '
      'single key "$_pluginToolsConfigGlobalKey" containing a list of build '
      'arguments.';

  /// Returns whether the Swift Package Manager feature should be enabled,
  /// disabled, or left to the release channel's default value.
  bool? get _swiftPackageManagerFeatureConfig {
    final List<String> platformFlags = _platforms.keys.toList();
    if (!platformFlags.contains(platformIOS) &&
        !platformFlags.contains(platformMacOS)) {
      return null;
    }

    // TODO(loic-sharma): Allow enabling on stable once Swift Package Manager
    // feature is available on stable.
    if (platform.environment['CHANNEL'] != 'master') {
      return null;
    }

    return getNullableBoolArg(_swiftPackageManagerFlag);
  }

  @override
  Future<void> initializeRun() async {
    final List<String> platformFlags = _platforms.keys.toList();
    platformFlags.sort();
    if (!platformFlags.any((String platform) => getBoolArg(platform))) {
      printError(
          'None of ${platformFlags.map((String platform) => '--$platform').join(', ')} '
          'were specified. At least one platform must be provided.');
      throw ToolExit(_exitNoPlatformFlags);
    }

    switch (_swiftPackageManagerFeatureConfig) {
      case true:
        await processRunner.runAndStream(
          flutterCommand,
          <String>['config', '--enable-swift-package-manager'],
          exitOnError: true,
        );
      case false:
        await processRunner.runAndStream(
          flutterCommand,
          <String>['config', '--no-enable-swift-package-manager'],
          exitOnError: true,
        );
      case null:
        break;
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final List<String> errors = <String>[];

    final bool isPlugin = isFlutterPlugin(package);
    final Iterable<_PlatformDetails> requestedPlatforms = _platforms.entries
        .where(
            (MapEntry<String, _PlatformDetails> entry) => getBoolArg(entry.key))
        .map((MapEntry<String, _PlatformDetails> entry) => entry.value);

    // Platform support is checked at the package level for plugins; there is
    // no package-level platform information for non-plugin packages.
    final Set<_PlatformDetails> buildPlatforms = isPlugin
        ? requestedPlatforms
            .where((_PlatformDetails platform) =>
                pluginSupportsPlatform(platform.pluginPlatform, package))
            .toSet()
        : requestedPlatforms.toSet();

    String platformDisplayList(Iterable<_PlatformDetails> platforms) {
      return platforms.map((_PlatformDetails p) => p.label).join(', ');
    }

    if (buildPlatforms.isEmpty) {
      final String unsupported = requestedPlatforms.length == 1
          ? '${requestedPlatforms.first.label} is not supported'
          : 'None of [${platformDisplayList(requestedPlatforms)}] are supported';
      return PackageResult.skip('$unsupported by this plugin');
    }
    print('Building for: ${platformDisplayList(buildPlatforms)}');

    final Set<_PlatformDetails> unsupportedPlatforms =
        requestedPlatforms.toSet().difference(buildPlatforms);
    if (unsupportedPlatforms.isNotEmpty) {
      final List<String> skippedPlatforms = unsupportedPlatforms
          .map((_PlatformDetails platform) => platform.label)
          .toList();
      skippedPlatforms.sort();
      print('Skipping unsupported platform(s): '
          '${skippedPlatforms.join(', ')}');
    }
    print('');

    bool builtSomething = false;
    for (final RepositoryPackage example in package.getExamples()) {
      final String packageName =
          getRelativePosixPath(example.directory, from: packagesDir);

      for (final _PlatformDetails platform in buildPlatforms) {
        // Repo policy is that a plugin must have examples configured for all
        // supported platforms. For packages, just log and skip any requested
        // platform that a package doesn't have set up.
        if (!isPlugin &&
            !example.appSupportsPlatform(
                getPlatformByName(platform.pluginPlatform))) {
          print('Skipping ${platform.label} for $packageName; not supported.');
          continue;
        }

        builtSomething = true;

        String buildPlatform = platform.label;
        if (platform.label.toLowerCase() != platform.flutterBuildType) {
          buildPlatform += ' (${platform.flutterBuildType})';
        }
        print('\nBUILDING $packageName for $buildPlatform');
        if (!await _buildExample(example, platform.flutterBuildType,
            extraBuildFlags: platform.extraBuildFlags)) {
          errors.add('$packageName (${platform.label})');
        }
      }
    }

    if (!builtSomething) {
      if (isPlugin) {
        errors.add('No examples found');
      } else {
        return PackageResult.skip(
            'No examples found supporting requested platform(s).');
      }
    }

    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }

  Iterable<String> _readExtraBuildFlagsConfiguration(
      Directory directory) sync* {
    final File pluginToolsConfig =
        directory.childFile(_pluginToolsConfigFileName);
    if (pluginToolsConfig.existsSync()) {
      final Object? configuration =
          loadYaml(pluginToolsConfig.readAsStringSync());
      if (configuration is! YamlMap) {
        printError('The $_pluginToolsConfigFileName file must be a YAML map.');
        printError(
            'Currently, the key "$_pluginToolsConfigBuildFlagsKey" is the only one that has an effect.');
        printError(
            'It must itself be a map. Currently, in that map only the key "$_pluginToolsConfigGlobalKey"');
        printError(
            'has any effect; it must contain a list of arguments to pass to the');
        printError('flutter tool.');
        printError(_pluginToolsConfigExample);
        throw ToolExit(_exitInvalidPluginToolsConfig);
      }
      if (configuration.containsKey(_pluginToolsConfigBuildFlagsKey)) {
        final Object? buildFlagsConfiguration =
            configuration[_pluginToolsConfigBuildFlagsKey];
        if (buildFlagsConfiguration is! YamlMap) {
          printError(
              'The $_pluginToolsConfigFileName file\'s "$_pluginToolsConfigBuildFlagsKey" key must be a map.');
          printError(
              'Currently, in that map only the key "$_pluginToolsConfigGlobalKey" has any effect; it must ');
          printError(
              'contain a list of arguments to pass to the flutter tool.');
          printError(_pluginToolsConfigExample);
          throw ToolExit(_exitInvalidPluginToolsConfig);
        }
        if (buildFlagsConfiguration.containsKey(_pluginToolsConfigGlobalKey)) {
          final Object? globalBuildFlagsConfiguration =
              buildFlagsConfiguration[_pluginToolsConfigGlobalKey];
          if (globalBuildFlagsConfiguration is! YamlList) {
            printError(
                'The $_pluginToolsConfigFileName file\'s "$_pluginToolsConfigBuildFlagsKey" key must be a map');
            printError('whose "$_pluginToolsConfigGlobalKey" key is a list.');
            printError(
                'That list must contain a list of arguments to pass to the flutter tool.');
            printError(
                'For example, the $_pluginToolsConfigFileName file could look like:');
            printError(_pluginToolsConfigExample);
            throw ToolExit(_exitInvalidPluginToolsConfig);
          }
          yield* globalBuildFlagsConfiguration.cast<String>();
        }
      }
    }
  }

  Future<bool> _buildExample(
    RepositoryPackage example,
    String flutterBuildType, {
    List<String> extraBuildFlags = const <String>[],
  }) async {
    final String enableExperiment = getStringArg(kEnableExperiment);

    final int exitCode = await processRunner.runAndStream(
      flutterCommand,
      <String>[
        'build',
        flutterBuildType,
        ...extraBuildFlags,
        ..._readExtraBuildFlagsConfiguration(example.directory),
        if (enableExperiment.isNotEmpty)
          '--enable-experiment=$enableExperiment',
      ],
      workingDir: example.directory,
    );
    return exitCode == 0;
  }
}

/// A collection of information related to a specific platform.
class _PlatformDetails {
  const _PlatformDetails(
    this.label, {
    required this.pluginPlatform,
    required this.flutterBuildType,
    this.extraBuildFlags = const <String>[],
  });

  /// The name to use in output.
  final String label;

  /// The key in a pubspec's platform: entry.
  final String pluginPlatform;

  /// The `flutter build` build type.
  final String flutterBuildType;

  /// Any extra flags to pass to `flutter build`.
  final List<String> extraBuildFlags;
}
