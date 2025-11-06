// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';

import 'core.dart';

export 'package:pubspec_parse/pubspec_parse.dart' show Pubspec;
export 'core.dart' show FlutterPlatform;

/// A package in the repository.
//
// TODO(stuartmorgan): Add more package-related info here, such as an on-demand
// cache of the parsed pubspec.
class RepositoryPackage {
  /// Creates a representation of the package at [directory].
  RepositoryPackage(this.directory);

  /// The location of the package.
  final Directory directory;

  /// The path to the package.
  String get path => directory.path;

  /// Returns the string to use when referring to the package in user-targeted
  /// messages.
  ///
  /// Callers should not expect a specific format for this string, since
  /// it uses heuristics to try to be precise without being overly verbose. If
  /// an exact format (e.g., published name, or basename) is required, that
  /// should be used instead.
  String get displayName {
    List<String> components = directory.fileSystem.path.split(directory.path);
    // Remove everything up to the packages directory.
    final int packagesIndex = components.indexOf('packages');
    if (packagesIndex != -1) {
      components = components.sublist(packagesIndex + 1);
    }
    // For the common federated plugin pattern of `foo/foo_subpackage`, drop
    // the first part since it's not useful.
    if (components.length >= 2 &&
        components[1].startsWith('${components[0]}_')) {
      components = components.sublist(1);
    }
    return p.posix.joinAll(components);
  }

  /// The package's top-level pubspec.yaml.
  File get pubspecFile => directory.childFile('pubspec.yaml');

  /// The package's top-level README.
  File get readmeFile => directory.childFile('README.md');

  /// The package's top-level README.
  File get changelogFile => directory.childFile('CHANGELOG.md');

  /// The package's top-level README.
  File get authorsFile => directory.childFile('AUTHORS');

  /// The package's top-level ci_config.yaml.
  File get ciConfigFile => directory.childFile('ci_config.yaml');

  /// The lib directory containing the package's code.
  Directory get libDirectory => directory.childDirectory('lib');

  /// The test directory containing the package's Dart tests.
  Directory get testDirectory => directory.childDirectory('test');

  /// The path to the script that is run by the `custom-test` command.
  File get customTestScript =>
      directory.childDirectory('tool').childFile('run_tests.dart');

  /// The path to the script that is run before publishing.
  File get prePublishScript =>
      directory.childDirectory('tool').childFile('pre_publish.dart');

  /// Returns the directory containing support for [platform].
  Directory platformDirectory(FlutterPlatform platform) {
    late final String directoryName;
    switch (platform) {
      case FlutterPlatform.android:
        directoryName = 'android';
      case FlutterPlatform.ios:
        directoryName = 'ios';
      case FlutterPlatform.linux:
        directoryName = 'linux';
      case FlutterPlatform.macos:
        directoryName = 'macos';
      case FlutterPlatform.web:
        directoryName = 'web';
      case FlutterPlatform.windows:
        directoryName = 'windows';
    }
    return directory.childDirectory(directoryName);
  }

  /// Returns true if the package is an app that supports [platform].
  ///
  /// The "app" prefix on this method is because this currently only works
  /// for app packages (e.g., examples).
  // TODO(stuartmorgan): Add support for non-app packages, by parsing the
  // pubspec for `flutter:platform:` or `platform:` sections.
  bool appSupportsPlatform(FlutterPlatform platform) {
    return platformDirectory(platform).existsSync();
  }

  late final Pubspec _parsedPubspec =
      Pubspec.parse(pubspecFile.readAsStringSync());

  /// Returns the parsed [pubspecFile].
  ///
  /// Caches for future use.
  Pubspec parsePubspec() => _parsedPubspec;

  /// Returns true if the package depends on Flutter.
  bool requiresFlutter() {
    const String flutterDependency = 'flutter';
    final Pubspec pubspec = parsePubspec();
    return pubspec.dependencies.containsKey(flutterDependency) ||
        pubspec.devDependencies.containsKey(flutterDependency);
  }

  /// True if this appears to be a federated plugin package, according to
  /// repository conventions.
  bool get isFederated =>
      directory.parent.basename != 'packages' &&
      directory.basename.startsWith(directory.parent.basename);

  /// True if this appears to be the app-facing package of a federated plugin,
  /// according to repository conventions.
  bool get isAppFacing =>
      directory.parent.basename != 'packages' &&
      directory.basename == directory.parent.basename;

  /// True if this appears to be a platform interface package, according to
  /// repository conventions.
  bool get isPlatformInterface =>
      directory.basename.endsWith('_platform_interface');

  /// True if this appears to be a platform implementation package, according to
  /// repository conventions.
  bool get isPlatformImplementation =>
      // Any part of a federated plugin that isn't the platform interface and
      // isn't the app-facing package should be an implementation package.
      isFederated &&
      !isPlatformInterface &&
      directory.basename != directory.parent.basename;

  /// True if this appears to be an example package, according to package
  /// conventions.
  bool get isExample {
    final RepositoryPackage? enclosingPackage = getEnclosingPackage();
    if (enclosingPackage == null) {
      // An example package is enclosed in another package.
      return false;
    }
    // Check whether this is one of the enclosing package's examples.
    return enclosingPackage
        .getExamples()
        .any((RepositoryPackage p) => p.path == path);
  }

  /// Returns the Flutter example packages contained in the package, if any.
  Iterable<RepositoryPackage> getExamples() {
    final Directory exampleDirectory = directory.childDirectory('example');
    if (!exampleDirectory.existsSync()) {
      return <RepositoryPackage>[];
    }
    if (isPackage(exampleDirectory)) {
      return <RepositoryPackage>[RepositoryPackage(exampleDirectory)];
    }
    // Only look at the subdirectories of the example directory if the example
    // directory itself is not a Dart package, and only look one level below the
    // example directory for other Dart packages.
    return exampleDirectory
        .listSync()
        .where((FileSystemEntity entity) => isPackage(entity))
        // isPackage guarantees that the cast to Directory is safe.
        .map((FileSystemEntity entity) =>
            RepositoryPackage(entity as Directory));
  }

  /// Returns the package that this package is a part of, if any.
  ///
  /// Currently this is limited to checking up two directories, since that
  /// covers all the example structures currently used.
  RepositoryPackage? getEnclosingPackage() {
    final Directory parent = directory.parent;
    if (isPackage(parent)) {
      return RepositoryPackage(parent);
    }
    if (isPackage(parent.parent)) {
      return RepositoryPackage(parent.parent);
    }
    return null;
  }

  /// Returns all Dart package folders (e.g., examples) under this package.
  Iterable<RepositoryPackage> getSubpackages({bool includeExamples = true}) {
    return directory
        .listSync(recursive: true, followLinks: false)
        .where(isPackage)
        .map((FileSystemEntity directory) =>
            // isPackage guarantees that this cast is valid.
            RepositoryPackage(directory as Directory))
        .where((RepositoryPackage p) =>
            includeExamples || (p.directory.basename != 'example'));
  }

  /// Returns true if the package is not marked as "publish_to: none".
  bool isPublishable() {
    return parsePubspec().publishTo != 'none';
  }
}
