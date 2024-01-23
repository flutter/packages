// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:flutter_migrate/src/base/context.dart';
import 'package:flutter_migrate/src/base/file_system.dart';
import 'package:flutter_migrate/src/base/io.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path; // flutter_ignore: package_path_import
import 'package:test_api/test_api.dart' // ignore: deprecated_member_use
    as test_package show test;
import 'package:test_api/test_api.dart' // ignore: deprecated_member_use
    hide
        test;

import 'test_utils.dart';

export 'package:test_api/test_api.dart' // ignore: deprecated_member_use
    hide
        isInstanceOf,
        test;

bool tryToDelete(FileSystemEntity fileEntity) {
  // This should not be necessary, but it turns out that
  // on Windows it's common for deletions to fail due to
  // bogus (we think) "access denied" errors.
  try {
    if (fileEntity.existsSync()) {
      fileEntity.deleteSync(recursive: true);
      return true;
    }
  } on FileSystemException catch (error) {
    // We print this so that it's visible in the logs, to get an idea of how
    // common this problem is, and if any patterns are ever noticed by anyone.
    // ignore: avoid_print
    print('Failed to delete ${fileEntity.path}: $error');
  }
  return false;
}

/// Gets the path to the root of the Flutter repository.
///
/// This will first look for a `FLUTTER_ROOT` environment variable. If the
/// environment variable is set, it will be returned. Otherwise, this will
/// deduce the path from `platform.script`.
String getFlutterRoot() {
  if (io.Platform.environment.containsKey('FLUTTER_ROOT')) {
    return io.Platform.environment['FLUTTER_ROOT']!;
  }

  Error invalidScript() => StateError(
      'Could not determine flutter_tools/ path from script URL (${io.Platform.script}); consider setting FLUTTER_ROOT explicitly.');

  Uri scriptUri;
  switch (io.Platform.script.scheme) {
    case 'file':
      scriptUri = io.Platform.script;
    case 'data':
      final RegExp flutterTools = RegExp(
          r'(file://[^"]*[/\\]flutter_tools[/\\][^"]+\.dart)',
          multiLine: true);
      final Match? match =
          flutterTools.firstMatch(Uri.decodeFull(io.Platform.script.path));
      if (match == null) {
        throw invalidScript();
      }
      scriptUri = Uri.parse(match.group(1)!);
    default:
      throw invalidScript();
  }

  final List<String> parts = path.split(fileSystem.path.fromUri(scriptUri));
  final int toolsIndex = parts.indexOf('flutter_tools');
  if (toolsIndex == -1) {
    throw invalidScript();
  }
  final String toolsPath = path.joinAll(parts.sublist(0, toolsIndex + 1));
  return path.normalize(path.join(toolsPath, '..', '..'));
}

String getMigratePackageRoot() {
  return io.Directory.current.path;
}

String getMigrateMain() {
  return fileSystem.path
      .join(getMigratePackageRoot(), 'bin', 'flutter_migrate.dart');
}

Future<ProcessResult> runMigrateCommand(List<String> args,
    {String? workingDirectory}) {
  final List<String> commandArgs = <String>['dart', 'run', getMigrateMain()];
  commandArgs.addAll(args);
  return processManager.run(commandArgs, workingDirectory: workingDirectory);
}

/// The tool overrides `test` to ensure that files created under the
/// system temporary directory are deleted after each test by calling
/// `LocalFileSystem.dispose()`.
@isTest
void test(
  String description,
  FutureOr<void> Function() body, {
  String? testOn,
  dynamic skip,
  List<String>? tags,
  Map<String, dynamic>? onPlatform,
  int? retry,
  Timeout? timeout,
}) {
  test_package.test(
    description,
    () async {
      addTearDown(() async {
        await fileSystem.dispose();
      });

      return body();
    },
    skip: skip,
    tags: tags,
    onPlatform: onPlatform,
    retry: retry,
    testOn: testOn,
    timeout: timeout,
    // We don't support "timeout"; see ../../dart_test.yaml which
    // configures all tests to have a 15 minute timeout which should
    // definitely be enough.
  );
}

/// Executes a test body in zone that does not allow context-based injection.
///
/// For classes which have been refactored to exclude context-based injection
/// or globals like [fs] or [platform], prefer using this test method as it
/// will prevent accidentally including these context getters in future code
/// changes.
///
/// For more information, see https://github.com/flutter/flutter/issues/47161
@isTest
void testWithoutContext(
  String description,
  FutureOr<void> Function() body, {
  String? testOn,
  dynamic skip,
  List<String>? tags,
  Map<String, dynamic>? onPlatform,
  int? retry,
  Timeout? timeout,
}) {
  return test(
    description,
    () async {
      return runZoned(body, zoneValues: <Object, Object>{
        contextKey: const _NoContext(),
      });
    },
    skip: skip,
    tags: tags,
    onPlatform: onPlatform,
    retry: retry,
    testOn: testOn,
    timeout: timeout,
    // We support timeout here due to the packages repo not setting default
    // timeout to 15min.
  );
}

/// An implementation of [AppContext] that throws if context.get is called in the test.
///
/// The intention of the class is to ensure we do not accidentally regress when
/// moving towards more explicit dependency injection by accidentally using
/// a Zone value in place of a constructor parameter.
class _NoContext implements AppContext {
  const _NoContext();

  @override
  T get<T>() {
    throw UnsupportedError('context.get<$T> is not supported in test methods. '
        'Use Testbed or testUsingContext if accessing Zone injected '
        'values.');
  }

  @override
  String get name => 'No Context';

  @override
  Future<V> run<V>({
    required FutureOr<V> Function() body,
    String? name,
    Map<Type, Generator>? overrides,
    Map<Type, Generator>? fallbacks,
    ZoneSpecification? zoneSpecification,
  }) async {
    return body();
  }
}

/// Matcher for functions that throw [AssertionError].
final Matcher throwsAssertionError = throwsA(isA<AssertionError>());
