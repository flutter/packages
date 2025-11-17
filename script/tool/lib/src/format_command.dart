// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';

import 'common/core.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/pub_utils.dart';
import 'common/repository_package.dart';

/// In theory this should be 8191, but in practice that was still resulting in
/// "The input line is too long" errors. This was chosen as a value that worked
/// in practice via trial and error, but may need to be adjusted based on
/// further experience.
@visibleForTesting
const int windowsCommandLineMax = 8000;

/// This value is picked somewhat arbitrarily based on checking `ARG_MAX` on a
/// macOS and Linux machine. If anyone encounters a lower limit in pratice, it
/// can be lowered accordingly.
@visibleForTesting
const int nonWindowsCommandLineMax = 1000000;

const int _exitClangFormatFailed = 3;
const int _exitFlutterFormatFailed = 4;
const int _exitJavaFormatFailed = 5;
const int _exitGitFailed = 6;
const int _exitDependencyMissing = 7;
const int _exitSwiftFormatFailed = 8;
const int _exitKotlinFormatFailed = 9;
const int _exitSwiftLintFoundIssues = 10;
const int _exitDartLanguageVersionIssue = 11;

final Uri _javaFormatterUrl = Uri.https('github.com',
    '/google/google-java-format/releases/download/google-java-format-1.3/google-java-format-1.3-all-deps.jar');
final Uri _kotlinFormatterUrl = Uri.https('maven.org',
    '/maven2/com/facebook/ktfmt/0.46/ktfmt-0.46-jar-with-dependencies.jar');

/// A command to format all package code.
class FormatCommand extends PackageLoopingCommand {
  /// Creates an instance of the format command.
  FormatCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
    super.gitDir,
  }) {
    argParser.addFlag(_failonChangeArg, hide: true);
    argParser.addFlag(_dartArg, help: 'Format Dart files', defaultsTo: true);
    argParser.addFlag(_clangFormatArg,
        help: 'Format with "clang-format"', defaultsTo: true);
    argParser.addFlag(_kotlinArg,
        help: 'Format Kotlin files', defaultsTo: true);
    argParser.addFlag(_javaArg, help: 'Format Java files', defaultsTo: true);
    // Currently swift-format is run via xcrun, so only works on macOS. If that
    // ever becomes an issue, the ability to find it in the path and/or allow
    // providing a path could be restored, to allow developers on Linux or
    // Windows to build swift-format from source and use that. See
    // https://github.com/flutter/packages/pull/9460.
    argParser.addFlag(_swiftArg,
        help: 'Format and lint Swift files', defaultsTo: platform.isMacOS);
    argParser.addOption(_clangFormatPathArg,
        defaultsTo: 'clang-format', help: 'Path to "clang-format" executable.');
    argParser.addOption(_javaPathArg,
        defaultsTo: 'java', help: 'Path to "java" executable.');
  }

  static const String _dartArg = 'dart';
  static const String _clangFormatArg = 'clang-format';
  static const String _failonChangeArg = 'fail-on-change';
  static const String _kotlinArg = 'kotlin';
  static const String _javaArg = 'java';
  static const String _swiftArg = 'swift';
  static const String _clangFormatPathArg = 'clang-format-path';
  static const String _javaPathArg = 'java-path';

  @override
  final String name = 'format';

  @override
  final String description =
      'Formats the code of all packages (C++, Dart, Java, Kotlin, Objective-C, '
      'and optionally Swift).\n\n'
      'This command requires "git", "flutter", "java", and "clang-format" v5 '
      'to be in your path.';

  @override
  Future<void> initializeRun() async {
    final String javaFormatterPath = await _getJavaFormatterPath();
    final String kotlinFormatterPath = await _getKotlinFormatterPath();

    // All but Dart is formatted here rather than in runForPackage because
    // running the formatters separately for each package is an order of
    // magnitude slower, due to the startup overhead of the formatters.
    //
    // Dart has to be run per-package because the formatter can have different
    // behavior based on the package's SDK, which can't be determined if the
    // formatter isn't running in the context of the package.
    final Iterable<String> files =
        await _getFilteredFilePaths(getFiles(), relativeTo: packagesDir);
    if (getBoolArg(_javaArg)) {
      await _formatJava(files, javaFormatterPath);
    }
    if (getBoolArg(_kotlinArg)) {
      await _formatKotlin(files, kotlinFormatterPath);
    }
    if (getBoolArg(_clangFormatArg)) {
      await _formatCppAndObjectiveC(files);
    }
    if (getBoolArg(_swiftArg)) {
      await _formatAndLintSwift(files);
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final Iterable<String> files = await _getFilteredFilePaths(
      getFilesForPackage(package),
      relativeTo: package.directory,
    );
    if (getBoolArg(_dartArg)) {
      if (!await _formatDart(package, files, workingDir: package.directory)) {
        return PackageResult.fail(<String>['unable to fetch dependencies']);
      }
    }
    // Success or failure is determined overall in completeRun, since most code
    // isn't being validated per-package, so just always return success at the
    // package level if fetching dependencies worked.
    // TODO(stuartmorgan): Consider doing _didModifyAnything checks per-package
    //  instead, since the other languages are already formatted by the time
    //  this code is being run.
    return PackageResult.success();
  }

  @override
  Future<void> completeRun() async {
    if (getBoolArg(_failonChangeArg)) {
      final bool modified = await _didModifyAnything();
      if (modified) {
        throw ToolExit(exitCommandFoundErrors);
      }
    }
  }

  Future<bool> _didModifyAnything() async {
    final io.ProcessResult modifiedFiles = await processRunner.run(
      'git',
      <String>[
        'ls-files',
        '--modified',
        packagesDir.path,
        thirdPartyPackagesDir.path
      ],
      workingDir: packagesDir.parent,
      logOnError: true,
    );
    if (modifiedFiles.exitCode != 0) {
      printError('Unable to determine changed files.');
      throw ToolExit(_exitGitFailed);
    }

    print('\n\n');

    final String stdout = modifiedFiles.stdout as String;
    if (stdout.isEmpty) {
      print('All files formatted correctly.');
      return false;
    }

    print('These files are not formatted correctly (see diff below):');
    LineSplitter.split(stdout).map((String line) => '  $line').forEach(print);

    print('\nTo fix run the repository tooling `format` command: '
        'https://github.com/flutter/packages/blob/main/script/tool/README.md#format-code\n'
        'or copy-paste this command into your terminal:');

    final io.ProcessResult diff = await processRunner.run(
      'git',
      <String>['diff', packagesDir.path, thirdPartyPackagesDir.path],
      workingDir: packagesDir.parent,
      logOnError: true,
    );
    if (diff.exitCode != 0) {
      printError('Unable to determine diff.');
      throw ToolExit(_exitGitFailed);
    }
    print('patch -p1 <<DONE');
    print(diff.stdout);
    print('DONE');
    return true;
  }

  Future<void> _formatCppAndObjectiveC(Iterable<String> files) async {
    final Iterable<String> clangFiles = _getPathsWithExtensions(
        files, <String>{'.h', '.m', '.mm', '.cc', '.cpp'});
    if (clangFiles.isNotEmpty) {
      final String clangFormat = await _findValidClangFormat();

      print('Formatting .cc, .cpp, .h, .m, and .mm files...');
      final int exitCode = await _runBatched(
          clangFormat, <String>['-i', '--style=file'],
          files: clangFiles);
      if (exitCode != 0) {
        printError(
            'Failed to format C, C++, and Objective-C files: exit code $exitCode.');
        throw ToolExit(_exitClangFormatFailed);
      }
    }
  }

  Future<void> _formatAndLintSwift(Iterable<String> files) async {
    final Iterable<String> swiftFiles =
        _getPathsWithExtensions(files, <String>{'.swift'});
    if (swiftFiles.isNotEmpty) {
      print('Formatting .swift files...');
      final int formatExitCode = await _runBatched(
          'xcrun', <String>['swift-format', '-i'],
          files: swiftFiles);
      if (formatExitCode != 0) {
        printError('Failed to format Swift files: exit code $formatExitCode.');
        throw ToolExit(_exitSwiftFormatFailed);
      }

      print('Linting .swift files...');
      final int lintExitCode = await _runBatched(
          'xcrun',
          <String>[
            'swift-format',
            'lint',
            '--parallel',
            '--strict',
          ],
          files: swiftFiles);
      if (lintExitCode == 1) {
        printError('Swift linter found issues. See above for linter output.');
        throw ToolExit(_exitSwiftLintFoundIssues);
      } else if (lintExitCode != 0) {
        printError('Failed to lint Swift files: exit code $lintExitCode.');
        throw ToolExit(_exitSwiftFormatFailed);
      }
    }
  }

  Future<String> _findValidClangFormat() async {
    final String clangFormat = getStringArg(_clangFormatPathArg);
    if (await _hasDependency(clangFormat)) {
      return clangFormat;
    }

    // There is a known issue where "chromium/depot_tools/clang-format"
    // fails with "Problem while looking for clang-format in Chromium source tree".
    // Loop through all "clang-format"s in PATH until a working one is found,
    // for example "/usr/local/bin/clang-format" or a "brew" installed version.
    for (final String clangFormatPath in await _whichAll('clang-format')) {
      if (await _hasDependency(clangFormatPath)) {
        return clangFormatPath;
      }
    }
    printError('Unable to run "clang-format". Make sure that it is in your '
        'path, or provide a full path with --$_clangFormatPathArg.');
    throw ToolExit(_exitDependencyMissing);
  }

  Future<void> _formatJava(Iterable<String> files, String formatterPath) async {
    final Iterable<String> javaFiles =
        _getPathsWithExtensions(files, <String>{'.java'});
    if (javaFiles.isNotEmpty) {
      final String java = getStringArg(_javaPathArg);
      if (!await _hasDependency(java)) {
        printError(
            'Unable to run "java". Make sure that it is in your path, or '
            'provide a full path with --$_javaPathArg.');
        throw ToolExit(_exitDependencyMissing);
      }

      print('Formatting .java files...');
      final int exitCode = await _runBatched(
          java, <String>['-jar', formatterPath, '--replace'],
          files: javaFiles);
      if (exitCode != 0) {
        printError('Failed to format Java files: exit code $exitCode.');
        throw ToolExit(_exitJavaFormatFailed);
      }
    }
  }

  Future<void> _formatKotlin(
      Iterable<String> files, String formatterPath) async {
    final Iterable<String> kotlinFiles =
        _getPathsWithExtensions(files, <String>{'.kt'});
    if (kotlinFiles.isNotEmpty) {
      final String java = getStringArg(_javaPathArg);
      if (!await _hasDependency(java)) {
        printError(
            'Unable to run "java". Make sure that it is in your path, or '
            'provide a full path with --$_javaPathArg.');
        throw ToolExit(_exitDependencyMissing);
      }

      print('Formatting .kt files...');
      final int exitCode = await _runBatched(
          java, <String>['-jar', formatterPath],
          files: kotlinFiles);
      if (exitCode != 0) {
        printError('Failed to format Kotlin files: exit code $exitCode.');
        throw ToolExit(_exitKotlinFormatFailed);
      }
    }
  }

  /// Formats any Dart files in the given [files] in [package].
  ///
  /// Returns false if the package couldn't be formatted due to failure to
  /// fetch dependencies.
  Future<bool> _formatDart(
    RepositoryPackage package,
    Iterable<String> files, {
    Directory? workingDir,
  }) async {
    final Iterable<String> dartFiles =
        _getPathsWithExtensions(files, <String>{'.dart'});
    if (dartFiles.isNotEmpty) {
      final List<RepositoryPackage> packagesToGet = <RepositoryPackage>[
        package,
        ...package.getSubpackages(includeExamples: false)
      ];
      // Ensure that the package language version has been correctly resolved,
      // since it can change the behavior of the Dart formatter. This must be
      // done for every sub-package to avoid inconsistent results if
      // sub-packages have different language versions than the main package.
      for (final RepositoryPackage p in packagesToGet) {
        if (!_resolvedLanguageVersionIsUpToDate(p)) {
          if (!await runPubGet(p, processRunner, platform)) {
            printError('Unable to fetch dependencies.');
            return false;
          }
        }
      }

      print('Formatting .dart files...');
      final int exitCode = await _runBatched('dart', <String>['format'],
          files: dartFiles, workingDir: workingDir);
      if (exitCode != 0) {
        printError('Failed to format Dart files: exit code $exitCode.');
        throw ToolExit(_exitFlutterFormatFailed);
      }
    }
    return true;
  }

  /// Given a stream of [files], returns the paths of any that are not in known
  /// locations to ignore, relative to [relativeTo].
  Future<Iterable<String>> _getFilteredFilePaths(
    Stream<File> files, {
    required Directory relativeTo,
  }) async {
    // Returns a pattern to check for [directories] as a subset of a file path.
    RegExp pathFragmentForDirectories(List<String> directories) {
      String s = path.separator;
      // Escape the separator for use in the regex.
      if (s == r'\') {
        s = r'\\';
      }
      return RegExp('(?:^|$s)${path.joinAll(directories)}$s');
    }

    final String fromPath = relativeTo.path;

    // Dart files are allowed to have a pragma to disable auto-formatting. This
    // was added because Hixie hurts when dealing with what dartfmt does to
    // artisanally-formatted Dart, while Stuart gets really frustrated when
    // dealing with PRs from newer contributors who don't know how to make Dart
    // readable. After much discussion, it was decided that files in the plugins
    // and packages repos that really benefit from hand-formatting (e.g. files
    // with large blobs of hex literals) could be opted-out of the requirement
    // that they be autoformatted, so long as the code's owner was willing to
    // bear the cost of this during code reviews.
    // In the event that code ownership moves to someone who does not hold the
    // same views as the original owner, the pragma can be removed and the file
    // auto-formatted.
    const String handFormattedExtension = '.dart';
    const String handFormattedPragma = '// This file is hand-formatted.';

    return files
        .where((File file) {
          // See comment above near [handFormattedPragma].
          return path.extension(file.path) != handFormattedExtension ||
              !file.readAsLinesSync().contains(handFormattedPragma);
        })
        .map((File file) => path.relative(file.path, from: fromPath))
        .where((String path) =>
            // Ignore files in build/ directories (e.g., headers of frameworks)
            // to avoid useless extra work in local repositories.
            !path.contains(
                pathFragmentForDirectories(<String>['example', 'build'])) &&
            // Ignore files in Pods, which are not part of the repository.
            !path.contains(pathFragmentForDirectories(<String>['Pods'])) &&
            // See https://github.com/flutter/flutter/issues/144039
            !path.endsWith('GeneratedPluginRegistrant.swift') &&
            // Ignore .dart_tool/, which can have various intermediate files.
            !path.contains(pathFragmentForDirectories(<String>['.dart_tool'])))
        .toList();
  }

  Iterable<String> _getPathsWithExtensions(
      Iterable<String> files, Set<String> extensions) {
    return files.where(
        (String filePath) => extensions.contains(path.extension(filePath)));
  }

  Future<String> _getJavaFormatterPath() async {
    final String javaFormatterPath = path.join(
        path.dirname(path.fromUri(platform.script)),
        'google-java-format-1.3-all-deps.jar');
    final File javaFormatterFile =
        packagesDir.fileSystem.file(javaFormatterPath);

    if (!javaFormatterFile.existsSync()) {
      print('Downloading Google Java Format...');
      final http.Response response = await http.get(_javaFormatterUrl);
      javaFormatterFile.writeAsBytesSync(response.bodyBytes);
    }

    return javaFormatterPath;
  }

  Future<String> _getKotlinFormatterPath() async {
    final String kotlinFormatterPath = path.join(
        path.dirname(path.fromUri(platform.script)),
        'ktfmt-0.46-jar-with-dependencies.jar');
    final File kotlinFormatterFile =
        packagesDir.fileSystem.file(kotlinFormatterPath);

    if (!kotlinFormatterFile.existsSync()) {
      print('Downloading ktfmt...');
      final http.Response response = await http.get(_kotlinFormatterUrl);
      kotlinFormatterFile.writeAsBytesSync(response.bodyBytes);
    }

    return kotlinFormatterPath;
  }

  /// Returns true if [command] can be run successfully.
  Future<bool> _hasDependency(String command) async {
    // Some versions of Java accept both -version and --version, but some only
    // accept -version.
    final String versionFlag = command == 'java' ? '-version' : '--version';
    try {
      final io.ProcessResult result =
          await processRunner.run(command, <String>[versionFlag]);
      if (result.exitCode != 0) {
        return false;
      }
    } on io.ProcessException {
      // Thrown when the binary is missing entirely.
      return false;
    }
    return true;
  }

  /// Returns all instances of [command] executable found on user path.
  Future<List<String>> _whichAll(String command) async {
    try {
      final io.ProcessResult result =
          await processRunner.run('which', <String>['-a', command]);

      if (result.exitCode != 0) {
        return <String>[];
      }

      final String stdout = (result.stdout as String).trim();
      if (stdout.isEmpty) {
        return <String>[];
      }
      return LineSplitter.split(stdout).toList();
    } on io.ProcessException {
      return <String>[];
    }
  }

  /// Runs [command] on [arguments] on all of the files in [files], batched as
  /// necessary to avoid OS command-line length limits.
  ///
  /// Returns the exit code of the first failure, which stops the run, or 0
  /// on success.
  Future<int> _runBatched(String command, List<String> arguments,
      {required Iterable<String> files, Directory? workingDir}) async {
    final int commandLineMax =
        platform.isWindows ? windowsCommandLineMax : nonWindowsCommandLineMax;

    // Compute the max length of the file argument portion of a batch.
    // Add one to each argument's length for the space before it.
    final int argumentTotalLength =
        arguments.fold(0, (int sum, String arg) => sum + arg.length + 1);
    final int batchMaxTotalLength =
        commandLineMax - command.length - argumentTotalLength;

    // Run the command in batches.
    final List<List<String>> batches =
        _partitionFileList(files, maxStringLength: batchMaxTotalLength);
    for (final List<String> batch in batches) {
      batch.sort(); // For ease of testing.
      final int exitCode = await processRunner.runAndStream(
          command, <String>[...arguments, ...batch],
          workingDir: workingDir ?? packagesDir);
      if (exitCode != 0) {
        return exitCode;
      }
    }
    return 0;
  }

  /// Partitions [files] into batches whose max string length as parameters to
  /// a command (including the spaces between them, and between the list and
  /// the command itself) is no longer than [maxStringLength].
  List<List<String>> _partitionFileList(Iterable<String> files,
      {required int maxStringLength}) {
    final List<List<String>> batches = <List<String>>[<String>[]];
    int currentBatchTotalLength = 0;
    for (final String file in files) {
      final int length = file.length + 1 /* for the space */;
      if (currentBatchTotalLength + length > maxStringLength) {
        // Start a new batch.
        batches.add(<String>[]);
        currentBatchTotalLength = 0;
      }
      batches.last.add(file);
      currentBatchTotalLength += length;
    }
    return batches;
  }

  bool _resolvedLanguageVersionIsUpToDate(RepositoryPackage package) {
    final File configFile = package.directory
        .childDirectory('.dart_tool')
        .childFile('package_config.json');
    // If the file isn't present, there is no resolved language version.
    if (!configFile.existsSync()) {
      return false;
    }
    // Otherwise, check that it's up to date, since 'dart format' uses the
    // resolved version even if pubspec.yaml has been changed.
    final Pubspec pubspec = package.parsePubspec();
    final VersionConstraint? dartSdkConstraint = pubspec.environment['sdk'];
    if (dartSdkConstraint == null) {
      printError(
          '${package.pubspecFile.absolute.path} is missing a Dart SDK constraint');
      throw ToolExit(_exitDartLanguageVersionIssue);
    }
    final String minDartSdkVersion = switch (dartSdkConstraint) {
      final VersionRange r => r.min.toString(),
      // A Dart SDK constraint should always be a range.
      _ => throw ToolExit(_exitDartLanguageVersionIssue),
    };
    final String packageName = pubspec.name;

    final Map<Object, Object?> configJson =
        jsonDecode(configFile.readAsStringSync()) as Map<Object, Object?>;
    final Map<Object, Object?>? packageInfo =
        (configJson['packages'] as List<Object?>?)
            ?.cast<Map<Object, Object?>>()
            .where((Map<Object, Object?> p) => p['name'] == packageName)
            .firstOrNull;
    final String? resolvedLanguageVersion =
        packageInfo == null ? null : packageInfo['languageVersion'] as String?;
    if (resolvedLanguageVersion == null) {
      // This shouldn't ever happen, so log for potential investigation.
      printWarning(
          'No language version found for $packageName in ${configFile.absolute.path}');
      return false;
    }
    // Check for startsWith rather than equality since the JSON languageVerison
    // currently only uses major.minor, rather than the full three-part version.
    if (!minDartSdkVersion.startsWith(resolvedLanguageVersion)) {
      print('Resolved language version for $packageName is stale '
          '($resolvedLanguageVersion vs $minDartSdkVersion)');
      return false;
    }
    return true;
  }
}
