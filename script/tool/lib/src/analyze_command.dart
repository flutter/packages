// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:file/file.dart';

import 'common/core.dart';
import 'common/file_filters.dart';
import 'common/flutter_command_utils.dart';
import 'common/gradle.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/repository_package.dart';
import 'common/xcode.dart';

/// A command to run Dart analysis on packages.
class AnalyzeCommand extends PackageLoopingCommand {
  /// Creates a analysis command instance.
  AnalyzeCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
    super.gitDir,
  }) {
    // Platform options.
    // By default, only Dart analysis is run.
    argParser.addFlag(_dartFlag, help: "Runs 'dart analyze'", defaultsTo: true);
    argParser.addFlag(
      platformAndroid,
      help: "Runs 'gradle lint' on Android code",
    );
    argParser.addFlag(
      platformIOS,
      help: "Runs 'xcodebuild analyze' on iOS code",
    );
    argParser.addFlag(
      platformMacOS,
      help: "Runs 'xcodebuild analyze' on macOS code",
    );

    // Dart options.
    argParser.addMultiOption(
      _customAnalysisFlag,
      help:
          'Directories (comma separated) that are allowed to have their own '
          'analysis options.\n\n'
          'Alternately, a list of one or more YAML files that contain a list '
          'of allowed directories.',
      defaultsTo: <String>[],
    );
    argParser.addOption(
      _analysisSdk,
      valueHelp: 'dart-sdk',
      help:
          'An optional path to a Dart SDK; this is used to override the '
          'SDK used to provide analysis.',
    );
    argParser.addFlag(
      _downgradeFlag,
      help:
          'Runs "flutter pub downgrade" before analysis to verify that '
          'the minimum constraints are sufficiently new for APIs used.',
    );
    argParser.addFlag(
      _libOnlyFlag,
      help:
          'Only analyze the lib/ directory of the main package, not the '
          'entire package.',
    );
    argParser.addFlag(
      _skipIfResolvingFailsFlag,
      help:
          'If resolution fails, skip the package. This is only '
          'intended to be used with pathified analysis, where a resolver '
          'failure indicates that no out-of-band failure can result anyway.',
      hide: true,
    );

    // Xcode options.
    argParser.addOption(
      _minIOSVersionArg,
      help:
          'Sets the minimum iOS deployment version to use when compiling, '
          'overriding the default minimum version. This can be used to find '
          'deprecation warnings that will affect the plugin in the future.',
    );
    argParser.addOption(
      _minMacOSVersionArg,
      help:
          'Sets the minimum macOS deployment version to use when compiling, '
          'overriding the default minimum version. This can be used to find '
          'deprecation warnings that will affect the plugin in the future.',
    );
  }

  static const String _dartFlag = 'dart';
  static const String _customAnalysisFlag = 'custom-analysis';
  static const String _downgradeFlag = 'downgrade';
  static const String _libOnlyFlag = 'lib-only';
  static const String _analysisSdk = 'analysis-sdk';
  static const String _skipIfResolvingFailsFlag = 'skip-if-resolving-fails';
  static const String _minIOSVersionArg = 'ios-min-version';
  static const String _minMacOSVersionArg = 'macos-min-version';

  late String _dartBinaryPath;

  Set<String> _allowedCustomAnalysisDirectories = const <String>{};

  @override
  final String name = 'analyze';

  @override
  final String description =
      'Analyzes all packages using dart analyze.\n\n'
      'This command requires "dart" and "flutter" to be in your path.';

  /// Checks that there are no unexpected analysis_options.yaml files.
  bool _hasUnexpectedAnalysisOptions(RepositoryPackage package) {
    final List<FileSystemEntity> files = package.directory.listSync(
      recursive: true,
      followLinks: false,
    );
    for (final file in files) {
      if (file.basename != 'analysis_options.yaml' &&
          file.basename != '.analysis_options') {
        continue;
      }

      // Skip anything checked out inside of .dart_tool/.
      if (file.path.contains('/.dart_tool/')) {
        continue;
      }

      final bool allowed = _allowedCustomAnalysisDirectories.any(
        (String directory) =>
            directory.isNotEmpty &&
            path.isWithin(
              packagesDir.childDirectory(directory).path,
              file.path,
            ),
      );
      if (allowed) {
        continue;
      }

      printError(
        'Found an extra analysis_options.yaml at ${file.absolute.path}.',
      );
      printError(
        'If this was deliberate, pass the package to the analyze command '
        'with the --$_customAnalysisFlag flag and try again.',
      );
      return true;
    }
    return false;
  }

  @override
  bool shouldIgnoreFile(String path) {
    // Support files don't affect any analysis.
    if (isRepoLevelNonCodeImpactingFile(path) || isPackageSupportFile(path)) {
      return true;
    }

    // For native code, it depends on the flags.
    if (path.endsWith('.dart')) {
      return !getBoolArg(_dartFlag);
    }
    if (path.endsWith('.java') || path.endsWith('.kt')) {
      return !getBoolArg(platformAndroid);
    }
    if (path.endsWith('.c') ||
        path.endsWith('.cc') ||
        path.endsWith('.cpp') ||
        path.endsWith('.h')) {
      // If C/C++ linting is added, Windows and Linux should be added here.
      return !(getBoolArg(platformIOS) || getBoolArg(platformMacOS));
    }
    if (path.endsWith('.m') ||
        path.endsWith('.mm') ||
        path.endsWith('.swift')) {
      return !(getBoolArg(platformIOS) || getBoolArg(platformMacOS));
    }

    return false;
  }

  @override
  Future<void> initializeRun() async {
    _allowedCustomAnalysisDirectories = getYamlListArg(_customAnalysisFlag);

    // Use the Dart SDK override if one was passed in.
    final dartSdk = argResults![_analysisSdk] as String?;
    _dartBinaryPath = dartSdk == null
        ? 'dart'
        : path.join(dartSdk, 'bin', 'dart');
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final subResults = <String, PackageResult>{};
    if (getBoolArg(_dartFlag)) {
      _printSectionHeading('Running dart analyze.');
      subResults['Dart'] = await _runDartAnalysisForPackage(package);
    }
    if (getBoolArg(platformAndroid)) {
      _printSectionHeading('Running gradle lint.');
      subResults['Android'] = await _runGradleLintForPackage(package);
    }
    if (getBoolArg(platformIOS)) {
      _printSectionHeading('Running iOS xcodebuild analyze.');
      final String minIOSVersion = getStringArg(_minIOSVersionArg);
      subResults['iOS'] = await _runXcodeAnalysisForPackage(
        package,
        FlutterPlatform.ios,
        extraFlags: <String>[
          '-destination',
          'generic/platform=iOS Simulator',
          if (minIOSVersion.isNotEmpty)
            'IPHONEOS_DEPLOYMENT_TARGET=$minIOSVersion',
        ],
      );
    }
    if (getBoolArg(platformMacOS)) {
      _printSectionHeading('Running macOS xcodebuild analyze.');
      final String minMacOSVersion = getStringArg(_minMacOSVersionArg);
      subResults['macOS'] = await _runXcodeAnalysisForPackage(
        package,
        FlutterPlatform.macos,
        extraFlags: <String>[
          if (minMacOSVersion.isNotEmpty)
            'MACOSX_DEPLOYMENT_TARGET=$minMacOSVersion',
        ],
      );
    }

    // Make sure at least one analysis option was requested.
    if (subResults.isEmpty) {
      printError('At least one analysis option flag must be provided.');
      throw ToolExit(exitInvalidArguments);
    }
    // If only one analysis was requested, just return its result.
    if (subResults.length == 1) {
      return subResults.values.first;
    }
    // Otherwise, aggregate the messages, with the least positive status.
    final failedResults = Map<String, PackageResult>.of(subResults)
      ..removeWhere(
        (String key, PackageResult value) => value.state != RunState.failed,
      );
    final skippedResults = Map<String, PackageResult>.of(subResults)
      ..removeWhere(
        (String key, PackageResult value) => value.state != RunState.skipped,
      );
    // If anything failed, collect all the failure messages, prefixed by type.
    if (failedResults.isNotEmpty) {
      return PackageResult.fail(<String>[
        for (final MapEntry<String, PackageResult> entry
            in failedResults.entries)
          '${entry.key}${entry.value.details.isEmpty ? '' : ': ${entry.value.details.join(', ')}'}',
      ]);
    }
    // If everything was skipped, mark as skipped with all of the explanations.
    if (skippedResults.length == subResults.length) {
      return PackageResult.skip(
        skippedResults.entries
            .map(
              (MapEntry<String, PackageResult> entry) =>
                  '${entry.key}: ${entry.value.details.first}',
            )
            .join(', '),
      );
    }
    // For all succes, or a mix of success and skip, log any skips but mark as
    // success.
    for (final MapEntry<String, PackageResult> skip in skippedResults.entries) {
      printSkip('Skipped ${skip.key}: ${skip.value.details.first}');
    }
    return PackageResult.success();
  }

  void _printSectionHeading(String heading) {
    print('\n$heading');
    print('--------------------');
  }

  /// Runs Dart analysis for the given package, and returns the result that
  /// applies to that analysis.
  Future<PackageResult> _runDartAnalysisForPackage(
    RepositoryPackage package,
  ) async {
    final bool libOnly = getBoolArg(_libOnlyFlag);

    if (libOnly && !package.libDirectory.existsSync()) {
      return PackageResult.skip('No lib/ directory.');
    }

    if (getBoolArg(_downgradeFlag)) {
      if (!await _runPubCommand(package, 'downgrade')) {
        return PackageResult.fail(<String>['Unable to downgrade dependencies']);
      }
    }

    // Analysis runs over the package and all subpackages (unless only lib/ is
    // being analyzed), so all of them need `flutter pub get` run before
    // analyzing. `example` packages can be skipped since 'flutter pub get'
    // automatically runs `pub get` in examples as part of handling the parent
    // directory.
    final packagesToGet = <RepositoryPackage>[
      package,
      if (!libOnly) ...package.getSubpackages(),
    ];
    for (final packageToGet in packagesToGet) {
      if (packageToGet.directory.basename != 'example' ||
          !RepositoryPackage(
            packageToGet.directory.parent,
          ).pubspecFile.existsSync()) {
        if (!await _runPubCommand(packageToGet, 'get')) {
          if (getBoolArg(_skipIfResolvingFailsFlag)) {
            // Re-run, capturing output, to see if the failure was a resolver
            // failure. (This is slightly inefficient, but this should be a
            // very rare case.)
            const resolverFailureMessage = 'version solving failed';
            final io.ProcessResult result = await processRunner.run(
              flutterCommand,
              <String>['pub', 'get'],
              workingDir: packageToGet.directory,
            );
            if ((result.stderr as String).contains(resolverFailureMessage) ||
                (result.stdout as String).contains(resolverFailureMessage)) {
              logWarning('Skipping package due to pub resolution failure.');
              return PackageResult.skip('Resolution failed.');
            }
          }
          return PackageResult.fail(<String>['Unable to get dependencies']);
        }
      }
    }

    if (_hasUnexpectedAnalysisOptions(package)) {
      return PackageResult.fail(<String>['Unexpected local analysis options']);
    }
    final int exitCode = await processRunner.runAndStream(
      _dartBinaryPath,
      <String>['analyze', '--fatal-infos', if (libOnly) 'lib'],
      workingDir: package.directory,
    );
    if (exitCode != 0) {
      return PackageResult.fail();
    }
    return PackageResult.success();
  }

  Future<bool> _runPubCommand(RepositoryPackage package, String command) async {
    final int exitCode = await processRunner.runAndStream(
      flutterCommand,
      <String>['pub', command],
      workingDir: package.directory,
    );
    return exitCode == 0;
  }

  /// Runs Gradle lint analysis for the given package, and returns the result
  /// that applies to that analysis.
  Future<PackageResult> _runGradleLintForPackage(
    RepositoryPackage package,
  ) async {
    if (!pluginSupportsPlatform(
      platformAndroid,
      package,
      requiredMode: PlatformSupport.inline,
    )) {
      return PackageResult.skip(
        'Package does not contain native Android plugin code',
      );
    }

    for (final RepositoryPackage example in package.getExamples()) {
      final project = GradleProject(
        example,
        processRunner: processRunner,
        platform: platform,
      );

      if (!project.isConfigured()) {
        final bool buildSuccess = await runConfigOnlyBuild(
          example,
          processRunner,
          platform,
          FlutterPlatform.android,
        );
        if (!buildSuccess) {
          printError('Unable to configure Gradle project.');
          return PackageResult.fail(<String>['Unable to configure Gradle.']);
        }
      }

      final String packageName = package.directory.basename;

      // Only lint one build mode to avoid extra work.
      // Only lint the plugin project itself, to avoid failing due to errors in
      // dependencies.
      //
      // TODO(stuartmorgan): Consider adding an XML parser to read and summarize
      //  all results. Currently, only the first three errors will be shown
      //  inline, and the rest have to be checked via the CI-uploaded artifact.
      final int exitCode = await project.runCommand('$packageName:lintDebug');
      if (exitCode != 0) {
        return PackageResult.fail();
      }
    }

    return PackageResult.success();
  }

  /// Analyzes [plugin] for [targetPlatform].
  Future<PackageResult> _runXcodeAnalysisForPackage(
    RepositoryPackage package,
    FlutterPlatform targetPlatform, {
    List<String> extraFlags = const <String>[],
  }) async {
    final platformString = targetPlatform == FlutterPlatform.ios
        ? 'iOS'
        : 'macOS';
    if (!pluginSupportsPlatform(
      targetPlatform.name,
      package,
      requiredMode: PlatformSupport.inline,
    )) {
      return PackageResult.skip(
        'Package does not contain native $platformString plugin code',
      );
    }

    final xcode = Xcode(processRunner: processRunner, log: true);
    final errors = <String>[];
    for (final RepositoryPackage example in package.getExamples()) {
      // See https://github.com/flutter/flutter/issues/172427 for discussion of
      // why this is currently necessary.
      print('Disabling Swift Package Manager...');
      setSwiftPackageManagerState(example, enabled: false);

      // Unconditionally re-run build with --debug --config-only, to ensure that
      // the project is in a debug state even if it was previously configured,
      // and that SwiftPM is disabled.
      print('Running flutter build --config-only...');
      final bool buildSuccess = await runConfigOnlyBuild(
        example,
        processRunner,
        platform,
        targetPlatform,
        buildDebug: true,
      );
      if (!buildSuccess) {
        printError('Unable to prepare native project files.');
        errors.add(
          'Unable to build ${getRelativePosixPath(example.directory, from: package.directory)}.',
        );
        continue;
      }

      // Running tests and static analyzer.
      final String examplePath = getRelativePosixPath(
        example.directory,
        from: package.directory.parent,
      );
      print('Running $platformString tests and analyzer for $examplePath...');
      final int exitCode = await xcode.runXcodeBuild(
        example.directory,
        platformString,
        // Clean before analyzing to remove cached swiftmodules from previous
        // runs, which can cause conflicts.
        actions: <String>['clean', 'analyze'],
        workspace: '${platformString.toLowerCase()}/Runner.xcworkspace',
        scheme: 'Runner',
        configuration: 'Debug',
        hostPlatform: platform,
        extraFlags: <String>[...extraFlags, 'GCC_TREAT_WARNINGS_AS_ERRORS=YES'],
      );
      if (exitCode == 0) {
        printSuccess('$examplePath ($platformString) passed analysis.');
      } else {
        printError('$examplePath ($platformString) failed analysis.');
        errors.add(
          '${getRelativePosixPath(example.directory, from: package.directory)} failed analysis.',
        );
      }

      print('Removing Swift Package Manager override...');
      setSwiftPackageManagerState(example, enabled: null);
    }
    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }
}
