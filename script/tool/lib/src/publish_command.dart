// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import 'common/core.dart';
import 'common/file_utils.dart';
import 'common/git_version_finder.dart';
import 'common/output_utils.dart';
import 'common/package_command.dart';
import 'common/package_looping_command.dart';
import 'common/pub_utils.dart';
import 'common/pub_version_finder.dart';
import 'common/repository_package.dart';

@immutable
class _RemoteInfo {
  const _RemoteInfo({required this.name, required this.url});

  /// The git name for the remote.
  final String name;

  /// The remote's URL.
  final String url;
}

/// Wraps pub publish with a few niceties used by the flutter/plugin team.
///
/// 1. Checks for any modified files in git and refuses to publish if there's an
///    issue.
/// 2. Tags the release with the format <package-name>-v<package-version>.
/// 3. Pushes the release to a remote.
///
/// Both 2 and 3 are optional, see `plugin_tools help publish` for full
/// usage information.
///
/// [processRunner], [print], and [stdin] can be overriden for easier testing.
class PublishCommand extends PackageLoopingCommand {
  /// Creates an instance of the publish command.
  PublishCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
    io.Stdin? stdinput,
    super.gitDir,
    http.Client? httpClient,
  })  : _pubVersionFinder =
            PubVersionFinder(httpClient: httpClient ?? http.Client()),
        _stdin = stdinput ?? io.stdin {
    argParser.addFlag(_alreadyTaggedFlag,
        help:
            'Instead of tagging, validates that the current checkout is already tagged with the expected version.\n'
            'This is primarily intended for use in CI publish steps triggered by tagging.',
        negatable: false);
    argParser.addMultiOption(_pubFlagsOption,
        help:
            'A list of options that will be forwarded on to pub. Separate multiple flags with commas.');
    argParser.addOption(
      _remoteOption,
      help: 'The name of the remote to push the tags to.',
      // Flutter convention is to use "upstream" for the single source of truth, and "origin" for personal forks.
      defaultsTo: 'upstream',
    );
    argParser.addFlag(
      _allChangedFlag,
      help:
          'Release all packages that contains pubspec changes at the current commit compares to the base-sha.\n'
          'The --packages option is ignored if this is on.',
    );
    argParser.addFlag(
      _dryRunFlag,
      help:
          'Skips the real `pub publish` and `git tag` commands and assumes both commands are successful.\n'
          'This does not run `pub publish --dry-run`.\n'
          'If you want to run the command with `pub publish --dry-run`, use `pub-publish-flags=--dry-run`',
    );
    argParser.addFlag(_skipConfirmationFlag,
        help: 'Run the command without asking for Y/N inputs.\n'
            'This command will add a `--force` flag to the `pub publish` command if it is not added with $_pubFlagsOption\n');
    argParser.addFlag(_tagForAutoPublishFlag,
        help:
            'Runs the dry-run publish, and tags if it succeeds, but does not actually publish.\n'
            'This is intended for use with a separate publish step that is based on tag push events.',
        negatable: false);
  }

  static const String _alreadyTaggedFlag = 'already-tagged';
  static const String _pubFlagsOption = 'pub-publish-flags';
  static const String _remoteOption = 'remote';
  static const String _allChangedFlag = 'all-changed';
  static const String _dryRunFlag = 'dry-run';
  static const String _skipConfirmationFlag = 'skip-confirmation';
  static const String _tagForAutoPublishFlag = 'tag-for-auto-publish';

  static const String _pubCredentialName = 'PUB_CREDENTIALS';

  // Version tags should follow <package-name>-v<semantic-version>. For example,
  // `flutter_plugin_tools-v0.0.24`.
  static const String _tagFormat = '%PACKAGE%-v%VERSION%';

  /// Returns the correct path where the pub credential is stored.
  @visibleForTesting
  late final String credentialsPath =
      _getCredentialsPath(platform: platform, path: path);

  @override
  final String name = 'publish';

  @override
  final String description =
      'Attempts to publish the given packages and tag the release(s) on GitHub.\n'
      'If running this on CI, an environment variable named $_pubCredentialName must be set to a String that represents the pub credential JSON.\n'
      'WARNING: Do not check in the content of pub credential JSON, it should only come from secure sources.';

  final io.Stdin _stdin;
  StreamSubscription<String>? _stdinSubscription;
  final PubVersionFinder _pubVersionFinder;

  // Tags that already exist in the repository.
  List<String> _existingGitTags = <String>[];
  // The remote to push tags to.
  late _RemoteInfo _remote;
  // Flags to pass to `pub publish`.
  late List<String> _publishFlags;

  @override
  String get successSummaryMessage => 'published';

  @override
  String get failureListHeader =>
      'The following packages had failures during publishing:';

  @override
  Future<void> initializeRun() async {
    print('Checking local repo...');

    // Ensure that the requested remote is present.
    final String remoteName = getStringArg(_remoteOption);
    final String? remoteUrl = await _verifyRemote(remoteName);
    if (remoteUrl == null) {
      printError('Unable to find URL for remote $remoteName; cannot push tags');
      throw ToolExit(1);
    }
    _remote = _RemoteInfo(name: remoteName, url: remoteUrl);

    // Pre-fetch all the repository's tags, to check against when publishing.
    final GitDir repository = await gitDir;
    final io.ProcessResult existingTagsResult =
        await repository.runCommand(<String>['tag', '--sort=-committerdate']);
    _existingGitTags = (existingTagsResult.stdout as String).split('\n')
      ..removeWhere((String element) => element.isEmpty);

    _publishFlags = <String>[
      ...getStringListArg(_pubFlagsOption),
      if (getBoolArg(_skipConfirmationFlag)) '--force',
    ];

    if (getBoolArg(_dryRunFlag)) {
      print('=============== DRY RUN ===============');
    }
  }

  @override
  Stream<PackageEnumerationEntry> getPackagesToProcess() async* {
    if (getBoolArg(_allChangedFlag)) {
      final GitVersionFinder gitVersionFinder = await retrieveVersionFinder();
      final String baseSha = await gitVersionFinder.getBaseSha();
      print(
          'Publishing all packages that have changed relative to "$baseSha"\n');
      final List<String> changedPubspecs =
          await gitVersionFinder.getChangedPubSpecs();

      for (final String pubspecPath in changedPubspecs) {
        // git outputs a relativa, Posix-style path.
        final File pubspecFile = childFileWithSubcomponents(
            packagesDir.fileSystem.directory((await gitDir).path),
            p.posix.split(pubspecPath));
        yield PackageEnumerationEntry(RepositoryPackage(pubspecFile.parent),
            excluded: false);
      }
    } else {
      yield* getTargetPackages(filterExcluded: false);
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final PackageResult? checkResult = await _checkNeedsRelease(package);
    if (checkResult != null) {
      return checkResult;
    }

    if (!await _runPrePublishScript(package)) {
      return PackageResult.fail(<String>['pre-publish failed']);
    }

    if (!await _checkGitStatus(package)) {
      return PackageResult.fail(<String>['uncommitted changes']);
    }

    final bool tagOnly = getBoolArg(_tagForAutoPublishFlag);
    if (!tagOnly) {
      if (!await _publish(package)) {
        return PackageResult.fail(<String>['publish failed']);
      }
    }

    final String tag = _getTag(package);
    if (getBoolArg(_alreadyTaggedFlag)) {
      if (!(await _getCurrentTags()).contains(tag)) {
        printError('The current checkout is not already tagged "$tag"');
        return PackageResult.fail(<String>['missing tag']);
      }
    } else {
      if (!await _tagRelease(package, tag)) {
        return PackageResult.fail(<String>['tagging failed']);
      }
    }

    final String action = tagOnly ? 'Tagged' : 'Published';
    print('\n$action ${package.directory.basename} successfully!');
    return PackageResult.success();
  }

  @override
  Future<void> completeRun() async {
    _pubVersionFinder.httpClient.close();
    await _stdinSubscription?.cancel();
    _stdinSubscription = null;
  }

  /// Checks whether [package] needs to be released, printing check status and
  /// returning one of:
  /// - PackageResult.fail if the check could not be completed
  /// - PackageResult.skip if no release is necessary
  /// - null if releasing should proceed
  ///
  /// In cases where a non-null result is returned, that should be returned
  /// as the final result for the package, without further processing.
  Future<PackageResult?> _checkNeedsRelease(RepositoryPackage package) async {
    if (!package.pubspecFile.existsSync()) {
      logWarning('''
The pubspec file for ${package.displayName} does not exist, so no publishing will happen.
Safe to ignore if the package is deleted in this commit.
''');
      return PackageResult.skip('package deleted');
    }

    final Pubspec pubspec = package.parsePubspec();

    if (pubspec.name == 'flutter_plugin_tools') {
      // Ignore flutter_plugin_tools package when running publishing through flutter_plugin_tools.
      // TODO(cyanglaz): Make the tool also auto publish flutter_plugin_tools package.
      // https://github.com/flutter/flutter/issues/85430
      return PackageResult.skip(
          'publishing flutter_plugin_tools via the tool is not supported');
    }

    if (pubspec.publishTo == 'none') {
      return PackageResult.skip('publish_to: none');
    }

    if (pubspec.version == null) {
      printError(
          'No version found. A package that intentionally has no version should be marked "publish_to: none"');
      return PackageResult.fail(<String>['no version']);
    }

    // Check if the package named `packageName` with `version` has already
    // been published.
    final Version version = pubspec.version!;
    final PubVersionFinderResponse pubVersionFinderResponse =
        await _pubVersionFinder.getPackageVersion(packageName: pubspec.name);
    if (pubVersionFinderResponse.versions.contains(version)) {
      final String tagsForPackageWithSameVersion = _existingGitTags.firstWhere(
          (String tag) =>
              tag.split('-v').first == pubspec.name &&
              tag.split('-v').last == version.toString(),
          orElse: () => '');
      if (tagsForPackageWithSameVersion.isEmpty) {
        printError(
            '${pubspec.name} $version has already been published, however '
            'the git release tag (${pubspec.name}-v$version) was not found. '
            'Please manually fix the tag then run the command again.');
        return PackageResult.fail(<String>['published but untagged']);
      } else {
        print('${pubspec.name} $version has already been published.');
        return PackageResult.skip('already published');
      }
    }
    return null;
  }

  // Tag the release with <package-name>-v<version>, and push it to the remote.
  //
  // Return `true` if successful, `false` otherwise.
  Future<bool> _tagRelease(RepositoryPackage package, String tag) async {
    print('Tagging release $tag...');
    if (!getBoolArg(_dryRunFlag)) {
      final io.ProcessResult result = await (await gitDir).runCommand(
        <String>['tag', tag],
        throwOnError: false,
      );
      if (result.exitCode != 0) {
        return false;
      }
    }

    print('Pushing tag to ${_remote.name}...');
    final bool success = await _pushTagToRemote(
      tag: tag,
      remote: _remote,
    );
    if (success) {
      print('Release tagged!');
    }
    return success;
  }

  Future<Iterable<String>> _getCurrentTags() async {
    // git tag --points-at HEAD
    final io.ProcessResult tagsResult = await (await gitDir).runCommand(
      <String>['tag', '--points-at', 'HEAD'],
      throwOnError: false,
    );
    if (tagsResult.exitCode != 0) {
      return <String>[];
    }

    return (tagsResult.stdout as String)
        .split('\n')
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty);
  }

  Future<bool> _checkGitStatus(RepositoryPackage package) async {
    final io.ProcessResult statusResult = await (await gitDir).runCommand(
      <String>[
        'status',
        '--porcelain',
        '--ignored',
        package.directory.absolute.path
      ],
      throwOnError: false,
    );
    if (statusResult.exitCode != 0) {
      return false;
    }

    final String statusOutput = statusResult.stdout as String;
    if (statusOutput.isNotEmpty) {
      printError(
          "There are files in the package directory that haven't been saved in git. Refusing to publish these files:\n\n"
          '$statusOutput\n'
          'If the directory should be clean, you can run `git clean -xdf && git reset --hard HEAD` to wipe all local changes.');
    }
    return statusOutput.isEmpty;
  }

  Future<String?> _verifyRemote(String remote) async {
    final io.ProcessResult getRemoteUrlResult = await (await gitDir).runCommand(
      <String>['remote', 'get-url', remote],
      throwOnError: false,
    );
    if (getRemoteUrlResult.exitCode != 0) {
      return null;
    }
    return getRemoteUrlResult.stdout as String?;
  }

  Future<bool> _runPrePublishScript(RepositoryPackage package) async {
    final File script = package.prePublishScript;
    if (!script.existsSync()) {
      return true;
    }
    final String relativeScriptPath =
        getRelativePosixPath(script, from: package.directory);
    print('Running pre-publish hook $relativeScriptPath...');

    // Ensure that dependencies are available.
    if (!await runPubGet(package, processRunner, platform)) {
      printError('Failed to get depenedencies');
      return false;
    }

    final int exitCode = await processRunner.runAndStream(
        'dart', <String>['run', relativeScriptPath],
        workingDir: package.directory);
    if (exitCode != 0) {
      printError('Pre-publish script failed.');
      return false;
    }
    return true;
  }

  Future<bool> _publish(RepositoryPackage package) async {
    print('Publishing...');
    print('Running `pub publish ${_publishFlags.join(' ')}` in '
        '${package.directory.absolute.path}...\n');
    if (getBoolArg(_dryRunFlag)) {
      return true;
    }

    if (_publishFlags.contains('--force')) {
      _ensureValidPubCredential();
    }

    final io.Process publish = await processRunner.start(
        flutterCommand, <String>['pub', 'publish', ..._publishFlags],
        workingDirectory: package.directory);
    publish.stdout.transform(utf8.decoder).listen((String data) => print(data));
    publish.stderr.transform(utf8.decoder).listen((String data) => print(data));
    _stdinSubscription ??= _stdin
        .transform(utf8.decoder)
        .listen((String data) => publish.stdin.writeln(data));
    final int result = await publish.exitCode;
    if (result != 0) {
      printError('Publishing ${package.directory.basename} failed.');
      return false;
    }

    print('Package published!');
    return true;
  }

  String _getTag(RepositoryPackage package) {
    final File pubspecFile = package.pubspecFile;
    final YamlMap pubspecYaml =
        loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
    final String name = pubspecYaml['name'] as String;
    final String version = pubspecYaml['version'] as String;
    // We should have failed to publish if these were unset.
    assert(name.isNotEmpty && version.isNotEmpty);
    return _tagFormat
        .replaceAll('%PACKAGE%', name)
        .replaceAll('%VERSION%', version);
  }

  // Pushes the `tag` to `remote`
  //
  // Return `true` if successful, `false` otherwise.
  Future<bool> _pushTagToRemote({
    required String tag,
    required _RemoteInfo remote,
  }) async {
    if (!getBoolArg(_dryRunFlag)) {
      final io.ProcessResult result = await (await gitDir).runCommand(
        <String>['push', remote.name, tag],
        throwOnError: false,
      );
      if (result.exitCode != 0) {
        return false;
      }
    }
    return true;
  }

  void _ensureValidPubCredential() {
    final File credentialFile = packagesDir.fileSystem.file(credentialsPath);
    if (credentialFile.existsSync() &&
        credentialFile.readAsStringSync().isNotEmpty) {
      return;
    }
    final String? credential = platform.environment[_pubCredentialName];
    if (credential == null) {
      printError('''
No pub credential available. Please check if `$credentialsPath` is valid.
If running this command on CI, you can set the pub credential content in the $_pubCredentialName environment variable.
''');
      throw ToolExit(1);
    }
    credentialFile.createSync(recursive: true);
    credentialFile.openSync(mode: FileMode.writeOnlyAppend)
      ..writeStringSync(credential)
      ..closeSync();
  }
}

/// The path in which pub expects to find its credentials file.
String _getCredentialsPath(
    {required Platform platform, required p.Context path}) {
  // See https://github.com/dart-lang/pub/blob/master/doc/cache_layout.md#layout
  String? configDir;
  if (platform.isLinux) {
    String? configHome = platform.environment['XDG_CONFIG_HOME'];
    if (configHome == null) {
      final String? home = platform.environment['HOME'];
      if (home == null) {
        printError('"HOME" environment variable is not set.');
      } else {
        configHome = path.join(home, '.config');
      }
    }
    if (configHome != null) {
      configDir = path.join(configHome, 'dart');
    }
  } else if (platform.isWindows) {
    final String? appData = platform.environment['APPDATA'];
    if (appData == null) {
      printError('"APPDATA" environment variable is not set.');
    } else {
      configDir = path.join(appData, 'dart');
    }
  } else if (platform.isMacOS) {
    final String? home = platform.environment['HOME'];
    if (home == null) {
      printError('"HOME" environment variable is not set.');
    } else {
      configDir = path.join(home, 'Library', 'Application Support', 'dart');
    }
  }

  if (configDir == null) {
    printError('Unable to determine pub con location');
    throw ToolExit(1);
  }

  return path.join(configDir, 'pub-credentials.json');
}
