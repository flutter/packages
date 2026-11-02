// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:yaml/yaml.dart';

import 'common/core.dart';
import 'common/file_filters.dart';
import 'common/file_utils.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/pub_utils.dart';
import 'common/repository_package.dart';

const int _exitUnknownTestPlatform = 3;
const int _exitNoTestsRan = 79;

enum _TestPlatform {
  // Must run in the command-line VM.
  vm,
  // Must run in a browser.
  browser,
}

/// A command to run Dart unit tests for packages.
class DartTestCommand extends PackageLoopingCommand {
  /// Creates an instance of the test command.
  DartTestCommand(super.packagesDir, {super.processRunner, super.platform, super.gitDir}) {
    argParser.addOption(
      kEnableExperiment,
      defaultsTo: '',
      help:
          'Runs Dart unit tests in Dart VM with the given experiments enabled. '
          'See https://github.com/dart-lang/sdk/blob/main/docs/process/experimental-flags.md '
          'for details.',
    );
    argParser.addOption(
      _platformFlag,
      help:
          'Runs tests on the given platform instead of the default platform '
          '("vm" in most cases, "chrome" for web plugin implementations).',
    );
    argParser.addFlag(kWebWasmFlag, help: 'Compile to WebAssembly rather than JavaScript');
    argParser.addOption(
      _packageTagsFlag,
      help:
          'Path to a YAML file that maps packages to tags to run for that '
          'package. Packages are identified by their path relative to the '
          'packages directory (e.g., "foo" or "foo/foo_android"). Only test '
          'files that contain the tag name are run, so the tag must appear '
          'literally in each test file that uses it, and must not appear in '
          'non-test Dart files. If the tag is a tag selector expression (e.g., '
          '"!slow"), or the package\'s dart_test.yaml could tag tests or select '
          'test files in other ways, all test files are run with the tag '
          'filter instead.',
    );
  }

  static const String _platformFlag = 'platform';
  static const String _packageTagsFlag = 'package-tags';

  /// Matches a single tag name, using the same identifier rules as
  /// `package:test` tag selectors. Anything else is a tag selector expression
  /// (e.g., `!slow` or `a || b`), which can't be found by searching test files.
  static final RegExp _tagNamePattern = RegExp(r'^[a-zA-Z_-][a-zA-Z0-9_-]*$');

  /// Keys in a package's `dart_test.yaml` that could cause tests to be tagged,
  /// or files to be treated as tests, in ways that searching test files for
  /// the tag can't detect.
  static const Set<String> _testConfigKeysPreventingFileSelection = <String>{
    // Allows one tag to imply another.
    'add_tags',
    // Change which files are run as tests.
    'paths',
    'filename',
    // Pulls in another configuration file, which could set any of the above.
    'include',
  };

  Map<String, String>? _packageTags;

  @override
  final String name = 'dart-test';

  // TODO(stuartmorgan): Eventually remove 'test', which is a legacy name from
  // before there were other test commands that made it ambiguous. For now it's
  // an alias to avoid breaking people's workflows.
  @override
  List<String> get aliases => <String>['test', 'test-dart'];

  @override
  final String description =
      'Runs the Dart tests for all packages.\n\n'
      'This command requires "flutter" to be in your path.';

  @override
  PackageLoopingType get packageLoopingType => PackageLoopingType.includeAllSubpackages;

  @override
  bool shouldIgnoreFile(String path) {
    return isRepoLevelNonCodeImpactingFile(path) ||
        isNativeCodeFile(path) ||
        isPackageSupportFile(path);
  }

  @override
  Future<void> initializeRun() async {
    _initializePackageTags();
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    if (!package.testDirectory.existsSync()) {
      return PackageResult.skip('No test/ directory.');
    }

    String? platform = getNullableStringArg(_platformFlag);

    // Skip running plugin tests for non-web-supporting plugins (or non-web
    // federated plugin implementations) on web, since there's no reason to
    // expect them to work.
    final bool webPlatform = platform != null && platform != 'vm';
    final explicitVMPlatform = platform == 'vm';
    final bool isWebOnlyPluginImplementation =
        pluginSupportsPlatform(platformWeb, package, requiredMode: PlatformSupport.inline) &&
        package.directory.basename.endsWith('_web');
    if (webPlatform) {
      if (isFlutterPlugin(package) && !pluginSupportsPlatform(platformWeb, package)) {
        return PackageResult.skip("Non-web plugin tests don't need web testing.");
      }
      if (_testOnTarget(package) == _TestPlatform.vm) {
        // This explict skip is necessary because trying to run tests in a mode
        // that the package has opted out of returns a non-zero exit code.
        return PackageResult.skip('Package has opted out of non-vm testing.');
      }
    } else if (explicitVMPlatform) {
      if (isWebOnlyPluginImplementation) {
        return PackageResult.skip("Web plugin tests don't need vm testing.");
      }
      final _TestPlatform? target = _testOnTarget(package);
      if (target != null && _testOnTarget(package) != _TestPlatform.vm) {
        // This explict skip is necessary because trying to run tests in a mode
        // that the package has opted out of returns a non-zero exit code.
        return PackageResult.skip('Package has opted out of vm testing.');
      }
    } else if (platform == null && isWebOnlyPluginImplementation) {
      // If no explicit mode is requested, run web plugin implementations in
      // Chrome since their tests are not expected to work in vm mode. This
      // allows easily running all unit tests locally, without having to run
      // both modes.
      platform = 'chrome';
    }

    // Whether to run web tests compiled to wasm.
    final bool wasm = platform != 'vm' && getBoolArg(kWebWasmFlag);

    final String? tag = _getTagForPackage(package);
    // Passing only the files that can contain tagged tests avoids compiling
    // and loading every other test file just to discover that it has no
    // matching tests, which is expensive on web.
    var testFiles = const <String>[];
    if (tag != null) {
      final String? fallbackReason = _reasonTestFilesCannotBeSelected(package, tag);
      if (fallbackReason != null) {
        print('Running all test files with --tags=$tag because $fallbackReason.');
      } else {
        final List<String> nonTestFilesWithTag = _nonTestFilesContainingTag(package, tag);
        if (nonTestFilesWithTag.isNotEmpty) {
          printError(
            'The tag "$tag" appears in the following files, which are not test '
            'files:\n'
            '${nonTestFilesWithTag.map((String file) => '  $file').join('\n')}\n'
            'Tests tagged via a constant or helper defined in these files will '
            'not be run with --$_packageTagsFlag. Use the tag directly in each '
            "test file that uses it (e.g., `tags: '$tag'`).",
          );
          return PackageResult.fail(nonTestFilesWithTag);
        }
        final List<String> taggedFiles = _testFilesForTag(package, tag);
        if (taggedFiles.isEmpty) {
          return PackageResult.skip('No test files contain the requested tag.');
        }
        testFiles = taggedFiles;
      }
    }
    final int exitCode;
    if (package.requiresFlutter()) {
      exitCode = await _runFlutterTests(
        package,
        platform: platform,
        wasm: wasm,
        tag: tag,
        testFiles: testFiles,
      );
    } else {
      exitCode = await _runDartTests(
        package,
        platform: platform,
        wasm: wasm,
        tag: tag,
        testFiles: testFiles,
      );
    }
    if (tag != null && exitCode == _exitNoTestsRan) {
      return PackageResult.skip('No tests match the requested tag.');
    }
    return exitCode == 0 ? PackageResult.success() : PackageResult.fail();
  }

  /// Runs the Dart tests for a Flutter package, returning the process exit code.
  ///
  /// If [testFiles] is non-empty, only those files are run.
  Future<int> _runFlutterTests(
    RepositoryPackage package, {
    String? platform,
    bool wasm = false,
    String? tag,
    List<String> testFiles = const <String>[],
  }) async {
    final String experiment = getStringArg(kEnableExperiment);

    return processRunner.runAndStream(flutterCommand, <String>[
      'test',
      '--color',
      if (experiment.isNotEmpty) '--enable-experiment=$experiment',
      // Flutter defaults to VM mode (under a different name) and explicitly
      // setting it is deprecated, so pass nothing in that case.
      if (platform != null && platform != 'vm') '--platform=$platform',
      if (wasm) '--wasm',
      if (tag != null) '--tags=$tag',
      ...testFiles,
    ], workingDir: package.directory);
  }

  /// Runs the Dart tests for a non-Flutter package, returning the process exit code.
  ///
  /// If [testFiles] is non-empty, only those files are run.
  Future<int> _runDartTests(
    RepositoryPackage package, {
    String? platform,
    bool wasm = false,
    String? tag,
    List<String> testFiles = const <String>[],
  }) async {
    // Unlike `flutter test`, `dart run test` does not automatically get
    // packages
    if (!await runPubGet(package, processRunner, super.platform)) {
      printError('Unable to fetch dependencies.');
      return 1;
    }

    final String experiment = getStringArg(kEnableExperiment);

    return processRunner.runAndStream('dart', <String>[
      'run',
      if (experiment.isNotEmpty) '--enable-experiment=$experiment',
      'test',
      if (platform != null) '--platform=$platform',
      if (wasm) '--compiler=dart2wasm',
      if (tag != null) '--tags=$tag',
      ...testFiles,
    ], workingDir: package.directory);
  }

  /// Returns why the test files in [package] that could contain tests tagged
  /// with [tag] can't be determined by searching them for [tag], or null if
  /// they can.
  ///
  /// If this returns non-null, all of the package's tests should be run with
  /// the tag filter instead.
  String? _reasonTestFilesCannotBeSelected(RepositoryPackage package, String tag) {
    if (!_tagNamePattern.hasMatch(tag)) {
      return '"$tag" is a tag selector expression rather than a single tag '
          'name, so test files using it cannot be found by searching for it';
    }
    final File testConfig = package.directory.childFile('dart_test.yaml');
    if (testConfig.existsSync()) {
      final String? key = _findYamlKey(
        loadYaml(testConfig.readAsStringSync()),
        _testConfigKeysPreventingFileSelection,
      );
      if (key != null) {
        return 'dart_test.yaml uses "$key", which could tag tests or select '
            'test files in ways that cannot be found by searching test files';
      }
    }
    return null;
  }

  /// Returns the test files in [package], relative to the package, that could
  /// contain tests tagged with [tag].
  ///
  /// A file is included if its contents mention [tag] anywhere, so this is a
  /// superset of the files that actually contain tagged tests; the `--tags`
  /// filter is still applied when running them. Tests that are tagged without
  /// the tag name appearing literally in their file (e.g., via a constant
  /// defined in another file) will not be found.
  ///
  /// This should only be used if [_reasonTestFilesCannotBeSelected] returns
  /// null.
  List<String> _testFilesForTag(RepositoryPackage package, String tag) {
    return package.testDirectory
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.basename.endsWith('_test.dart'))
        .where((File file) => file.readAsStringSync().contains(tag))
        .map((File file) => relativePosixPath(file, from: package.directory, platformContext: path))
        .toList()
      ..sort();
  }

  /// Returns the Dart files in [package]'s `lib/` and `test/` directories that
  /// contain [tag] but aren't test files, relative to the package.
  ///
  /// The tag appearing in such a file (e.g., in a shared constant, or in a
  /// helper that wraps `test`) means that tests may be tagged without the tag
  /// appearing in their own file, in which case [_testFilesForTag] wouldn't
  /// select them.
  List<String> _nonTestFilesContainingTag(RepositoryPackage package, String tag) {
    return <Directory>[package.libDirectory, package.testDirectory]
        .where((Directory dir) => dir.existsSync())
        .expand((Directory dir) => dir.listSync(recursive: true))
        .whereType<File>()
        .where((File file) => file.basename.endsWith('.dart'))
        .where(
          (File file) =>
              !(file.basename.endsWith('_test.dart') &&
                  path.isWithin(package.testDirectory.path, file.path)),
        )
        .where((File file) => file.readAsStringSync().contains(tag))
        .map((File file) => relativePosixPath(file, from: package.directory, platformContext: path))
        .toList()
      ..sort();
  }

  /// Returns the first of [keys] found in [node], or in any map nested within
  /// it, or null if there are none.
  String? _findYamlKey(Object? node, Set<String> keys) {
    if (node is YamlMap) {
      for (final Object? key in node.keys) {
        if (keys.contains(key)) {
          return key! as String;
        }
      }
      return _findYamlKeyInAny(node.values, keys);
    }
    if (node is YamlList) {
      return _findYamlKeyInAny(node, keys);
    }
    return null;
  }

  /// Returns the first result of [_findYamlKey] for [nodes] that isn't null,
  /// or null if there isn't one.
  String? _findYamlKeyInAny(Iterable<Object?> nodes, Set<String> keys) {
    for (final node in nodes) {
      final String? key = _findYamlKey(node, keys);
      if (key != null) {
        return key;
      }
    }
    return null;
  }

  /// Parses the `--package-tags` argument and populates the `_packageTags`
  /// map with the resulting package names to tags.
  void _initializePackageTags() {
    final packageTags = <String, String>{};
    final String? arg = getNullableStringArg(_packageTagsFlag);

    if (arg == null || arg.isEmpty) {
      _packageTags = packageTags;
      return;
    }

    final File file = packagesDir.fileSystem.file(arg);
    if (!file.existsSync()) {
      printError('The package tags file "$arg" does not exist.');
      throw ToolExit(exitInvalidArguments);
    }

    final Object? yaml = loadYaml(file.readAsStringSync());
    // Treat an empty or comment-only file as an empty map (no package tags).
    if (yaml == null) {
      _packageTags = packageTags;
      return;
    }
    if (yaml is YamlMap) {
      for (final MapEntry<dynamic, dynamic> entry in yaml.entries) {
        final pkg = entry.key.toString();
        final dynamic val = entry.value;
        if (val != null) {
          packageTags[pkg] = val.toString();
        }
      }
    } else {
      printError('The package tags file "$arg" is not a valid YAML map.');
      throw ToolExit(exitInvalidArguments);
    }
    _packageTags = packageTags;
    return;
  }

  /// Returns the tag to apply for [package] based on `--package-tags`, or null
  /// if none.
  ///
  /// This checks the package's [_packageTagKey], and falls back
  /// to checking the [_packageTagKey] of any enclosing packages
  /// up the directory tree. This allows tagging an entire plugin (including its
  /// nested examples) by simply tagging the enclosing package.
  String? _getTagForPackage(RepositoryPackage package) {
    final Map<String, String>? packageTags = _packageTags;
    if (packageTags != null && packageTags.isNotEmpty) {
      final candidates = <String>{};
      RepositoryPackage? current = package;
      while (current != null) {
        final String? key = _packageTagKey(current);
        if (key != null) {
          candidates.add(key);
        }
        current = current.getEnclosingPackage();
      }

      for (final candidate in candidates) {
        if (packageTags.containsKey(candidate)) {
          return packageTags[candidate];
        }
      }
    }

    return null;
  }

  /// Returns the key that a `--package-tags` entry uses to identify [package],
  /// or null if [package] is not in a packages directory.
  ///
  /// The key is the package's path relative to the packages directory that
  /// contains it, using POSIX separators (e.g., `foo`, `foo/example`, or
  /// `foo/foo_android`).
  String? _packageTagKey(RepositoryPackage package) {
    for (final root in <Directory>[packagesDir, thirdPartyPackagesDir]) {
      if (path.isWithin(root.absolute.path, package.directory.absolute.path)) {
        return relativePosixPath(package.directory, from: root, platformContext: path);
      }
    }
    return null;
  }

  /// Returns the required test environment, or null if none is specified.
  ///
  /// Throws if the target is not recognized.
  _TestPlatform? _testOnTarget(RepositoryPackage package) {
    final File testConfig = package.directory.childFile('dart_test.yaml');
    if (!testConfig.existsSync()) {
      return null;
    }
    final Object? root = loadYaml(testConfig.readAsStringSync());
    if (root is! YamlMap) {
      return null;
    }
    final Object? targetFilter = root['test_on'];
    if (targetFilter == null || targetFilter is! String) {
      return null;
    }
    // test_on lines can be very complex, but in pratice the packages in
    // this repo currently only need the ability to require vm or not, so a
    // simple one-target directive is all that's supported currently.
    // Making it deliberately strict avoids the possibility of accidentally
    // skipping vm coverage due to a complex expression that's not handled
    // correctly.
    switch (targetFilter) {
      case 'vm':
        return _TestPlatform.vm;
      case 'browser':
        return _TestPlatform.browser;
      default:
        printError(
          'Unknown "test_on" value: "$targetFilter"\n'
          "If this value needs to be supported for this package's tests, "
          'please update the repository tooling to support more test_on '
          'modes.',
        );
        throw ToolExit(_exitUnknownTestPlatform);
    }
  }
}
