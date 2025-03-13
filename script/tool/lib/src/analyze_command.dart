// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:file/file.dart';

import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';

/// A command to run Dart analysis on packages.
class AnalyzeCommand extends PackageLoopingCommand {
  /// Creates a analysis command instance.
  AnalyzeCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
  }) {
    argParser.addMultiOption(_customAnalysisFlag,
        help:
            'Directories (comma separated) that are allowed to have their own '
            'analysis options.\n\n'
            'Alternately, a list of one or more YAML files that contain a list '
            'of allowed directories.',
        defaultsTo: <String>[]);
    argParser.addOption(_analysisSdk,
        valueHelp: 'dart-sdk',
        help: 'An optional path to a Dart SDK; this is used to override the '
            'SDK used to provide analysis.');
    argParser.addFlag(_downgradeFlag,
        help: 'Runs "flutter pub downgrade" before analysis to verify that '
            'the minimum constraints are sufficiently new for APIs used.');
    argParser.addFlag(_libOnlyFlag,
        help: 'Only analyze the lib/ directory of the main package, not the '
            'entire package.');
    argParser.addFlag(_skipIfResolvingFailsFlag,
        help: 'If resolution fails, skip the package. This is only '
            'intended to be used with pathified analysis, where a resolver '
            'failure indicates that no out-of-band failure can result anyway.',
        hide: true);
  }

  static const String _customAnalysisFlag = 'custom-analysis';
  static const String _downgradeFlag = 'downgrade';
  static const String _libOnlyFlag = 'lib-only';
  static const String _analysisSdk = 'analysis-sdk';
  static const String _skipIfResolvingFailsFlag = 'skip-if-resolving-fails';

  late String _dartBinaryPath;

  Set<String> _allowedCustomAnalysisDirectories = const <String>{};

  @override
  final String name = 'analyze';

  @override
  final String description = 'Analyzes all packages using dart analyze.\n\n'
      'This command requires "dart" and "flutter" to be in your path.';

  @override
  final bool hasLongOutput = false;

  /// Checks that there are no unexpected analysis_options.yaml files.
  bool _hasUnexpectedAnalysisOptions(RepositoryPackage package) {
    final List<FileSystemEntity> files =
        package.directory.listSync(recursive: true, followLinks: false);
    for (final FileSystemEntity file in files) {
      if (file.basename != 'analysis_options.yaml' &&
          file.basename != '.analysis_options') {
        continue;
      }

      final bool allowed = _allowedCustomAnalysisDirectories.any(
          (String directory) =>
              directory.isNotEmpty &&
              path.isWithin(
                  packagesDir.childDirectory(directory).path, file.path));
      if (allowed) {
        continue;
      }

      printError(
          'Found an extra analysis_options.yaml at ${file.absolute.path}.');
      printError(
          'If this was deliberate, pass the package to the analyze command '
          'with the --$_customAnalysisFlag flag and try again.');
      return true;
    }
    return false;
  }

  @override
  Future<void> initializeRun() async {
    _allowedCustomAnalysisDirectories = getYamlListArg(_customAnalysisFlag);

    // Use the Dart SDK override if one was passed in.
    final String? dartSdk = argResults![_analysisSdk] as String?;
    _dartBinaryPath =
        dartSdk == null ? 'dart' : path.join(dartSdk, 'bin', 'dart');
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
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
    // analyzing. `example` packages can be skipped since 'flutter packages get'
    // automatically runs `pub get` in examples as part of handling the parent
    // directory.
    final List<RepositoryPackage> packagesToGet = <RepositoryPackage>[
      package,
      if (!libOnly) ...await getSubpackages(package).toList(),
    ];
    for (final RepositoryPackage packageToGet in packagesToGet) {
      if (packageToGet.directory.basename != 'example' ||
          !RepositoryPackage(packageToGet.directory.parent)
              .pubspecFile
              .existsSync()) {
        if (!await _runPubCommand(packageToGet, 'get')) {
          if (getBoolArg(_skipIfResolvingFailsFlag)) {
            // Re-run, capturing output, to see if the failure was a resolver
            // failure. (This is slightly inefficient, but this should be a
            // very rare case.)
            const String resolverFailureMessage = 'version solving failed';
            final io.ProcessResult result = await processRunner.run(
                flutterCommand, <String>['pub', 'get'],
                workingDir: packageToGet.directory);
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
    final int exitCode = await processRunner.runAndStream(_dartBinaryPath,
        <String>['analyze', '--fatal-infos', if (libOnly) 'lib'],
        workingDir: package.directory);
    if (exitCode != 0) {
      return PackageResult.fail();
    }
    return PackageResult.success();
  }

  Future<bool> _runPubCommand(RepositoryPackage package, String command) async {
    final int exitCode = await processRunner.runAndStream(
        flutterCommand, <String>['pub', command],
        workingDir: package.directory);
    return exitCode == 0;
  }
}
