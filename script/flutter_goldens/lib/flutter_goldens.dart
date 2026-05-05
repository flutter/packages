// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'dart:io';
library;

import 'dart:async' show FutureOr;

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

/// Main method that can be used in a `flutter_test_config.dart` file to set
/// [goldenFileComparator] to an instance of [FlutterGoldenFileComparator] that
/// works for the current test. _Which_ [FlutterGoldenFileComparator] is
/// instantiated is based on the current testing environment.
///
/// When set, the `namePrefix` is prepended to the names of all gold images.
///
/// This function assumes the [goldenFileComparator] has been set to a
/// [LocalFileComparator], which happens in the bootstrap code used when running
/// tests using `flutter test`. This should not be called when running a test
/// using `flutter run`, as in that environment, the [goldenFileComparator] is a
/// [TrivialComparator].
///
/// An [HttpClient] is created when this method is called. That client is used
/// to communicate with the Skia Gold servers. Any [HttpOverrides] set in this
/// will affect whether this is effective or not. For example, if the current
/// override provides a mock client that always fails, then all calls to gold
/// comparison functions will fail.
Future<void> testExecutable(
  FutureOr<void> Function() testMain, {
  String? namePrefix,
}) async {
  assert(
    goldenFileComparator is LocalFileComparator,
    'The flutter_goldens package should be used from a flutter_test_config.dart '
    'file, which is only invoked when using "flutter test". The "flutter test" '
    'bootstrap logic sets "goldenFileComparator" to a LocalFileComparator. It '
    'appears in this instance however that the "goldenFileComparator" is a '
    '${goldenFileComparator.runtimeType}.\n'
    'See also: https://flutter.dev/to/flutter-test-docs',
  );
  const FileSystem fs = LocalFileSystem();

  namePrefix ??= FlutterGoldenFileComparator.getPackageName(fs);

  goldenFileComparator = FlutterSkippingFileComparator.fromLocalFileComparator(
    localFileComparator: goldenFileComparator as LocalFileComparator,
    'Golden file testing is currently skipped.',
    namePrefix: namePrefix,
    fs: fs,
  );
  await testMain();
}

/// Abstract base class golden file comparator specific to the `flutter/packages`
/// repository.
///
///  The [FlutterSkippingFileComparator] is utilized to skip tests outside
///  of the appropriate environments. Currently, some packages or environments
///  do not execute golden file testing, and as such do not require a
/// comparator. This comparator is also used when an internet connection is unavailable.
abstract class FlutterGoldenFileComparator extends GoldenFileComparator {
  /// Creates a [FlutterGoldenFileComparator] that will resolve golden file
  /// URIs relative to the specified [basedir]. When testing locally, the
  /// [basedir] will also contain any diffs from failed tests, or goldens
  /// generated from newly introduced tests.
  @visibleForTesting
  FlutterGoldenFileComparator(
    this.basedir, {
    required this.fs,
    this.namePrefix,
  });

  /// The directory to which golden file URIs will be resolved in [compare] and
  /// [update].
  final Uri basedir;

  /// The file system used to perform file access.
  final FileSystem fs;

  /// The prefix that is added to all golden names.
  final String? namePrefix;

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) async {
    final File goldenFile = getGoldenFile(golden);
    await goldenFile.parent.create(recursive: true);
    await goldenFile.writeAsBytes(imageBytes, flush: true);
  }

  @override
  Uri getTestUri(Uri key, int? version) => key;

  /// Calculate the appropriate basedir for the current test context.
  ///
  /// The optional [suffix] argument is used by the
  /// [FlutterPostSubmitFileComparator] and the [FlutterPreSubmitFileComparator].
  /// These [FlutterGoldenFileComparator]s randomize their base directories to
  /// maintain thread safety while using the `goldctl` tool.
  @protected
  @visibleForTesting
  static Directory getBaseDirectory(
    LocalFileComparator defaultComparator, {
    String? suffix,
    required FileSystem fs,
  }) {
    final Directory comparisonRoot = switch (suffix) {
      null =>
        fs.directory(defaultComparator.basedir).childDirectory('skia_goldens'),
      _ => fs.systemTempDirectory.createTempSync(suffix),
    };
    return comparisonRoot;
  }

  /// Returns the golden [File] identified by the given [Uri].
  @protected
  File getGoldenFile(Uri uri) {
    final File goldenFile = fs.directory(basedir).childFile(fs.file(uri).path);

    return goldenFile;
  }

  /// Extracts the package name from the nearest `pubspec.yaml` file.
  @visibleForTesting
  static String? getPackageName(FileSystem fs) {
    Directory current = fs.currentDirectory;
    while (current.path != current.parent.path) {
      final File pubspec = current.childFile('pubspec.yaml');
      if (pubspec.existsSync()) {
        try {
          final yaml = loadYaml(pubspec.readAsStringSync()) as YamlMap;
          return yaml['name'] as String?;
        } catch (e) {
          // Ignore parsing errors and keep looking
        }
      }
      current = current.parent;
    }
    return null;
  }
}

/// A [FlutterGoldenFileComparator] for testing conditions that do not execute
/// golden file tests.
///
/// Currently, this comparator is used on Luci environments when executing tests
/// outside of the flutter/flutter repository.
///
/// See also:
///
///  * [FlutterPostSubmitFileComparator], another [FlutterGoldenFileComparator]
///    that tests golden images through Skia Gold.
///  * [FlutterPreSubmitFileComparator], another
///    [FlutterGoldenFileComparator] that tests golden images before changes are
///    merged into the master branch.
///  * [FlutterLocalFileComparator], another
///    [FlutterGoldenFileComparator] that tests golden images locally on your
///    current machine.
class FlutterSkippingFileComparator extends FlutterGoldenFileComparator {
  /// Creates a [FlutterSkippingFileComparator] that will skip tests that
  /// are not in the right environment for golden file testing.
  FlutterSkippingFileComparator(
    super.basedir,
    this.reason, {
    super.namePrefix,
    required super.fs,
  });

  /// Describes the reason for using the [FlutterSkippingFileComparator].
  final String reason;

  /// Creates a new [FlutterSkippingFileComparator] that mirrors the
  /// relative path resolution of the given [localFileComparator].
  static FlutterSkippingFileComparator fromLocalFileComparator(
    String reason, {
    required LocalFileComparator localFileComparator,
    String? namePrefix,
    required FileSystem fs,
  }) {
    final Uri basedir = localFileComparator.basedir;
    return FlutterSkippingFileComparator(
      basedir,
      reason,
      namePrefix: namePrefix,
      fs: fs,
    );
  }

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async => true;

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) async {}
}
