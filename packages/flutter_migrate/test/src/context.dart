// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_migrate/src/base/context.dart';
import 'package:flutter_migrate/src/base/file_system.dart';
import 'package:flutter_migrate/src/base/logger.dart';
import 'package:flutter_migrate/src/base/terminal.dart';
import 'package:meta/meta.dart';
import 'package:process/process.dart';

import 'common.dart';
import 'fakes.dart';

/// Return the test logger. This assumes that the current Logger is a BufferLogger.
BufferLogger get testLogger => context.get<Logger>()! as BufferLogger;

@isTest
void testUsingContext(
  String description,
  dynamic Function() testMethod, {
  Map<Type, Generator> overrides = const <Type, Generator>{},
  bool initializeFlutterRoot = true,
  String? testOn,
  Timeout? timeout,
  bool?
      skip, // should default to `false`, but https://github.com/dart-lang/test/issues/545 doesn't allow this
}) {
  if (overrides[FileSystem] != null && overrides[ProcessManager] == null) {
    throw StateError(
        'If you override the FileSystem context you must also provide a ProcessManager, '
        'otherwise the processes you launch will not be dealing with the same file system '
        'that you are dealing with in your test.');
  }

  // Ensure we don't rely on the default [Config] constructor which will
  // leak a sticky $HOME/.flutter_settings behind!
  Directory? configDir;
  tearDown(() {
    if (configDir != null) {
      tryToDelete(configDir!);
      configDir = null;
    }
  });

  test(description, () async {
    await runInContext<dynamic>(() {
      return context.run<dynamic>(
        name: 'mocks',
        overrides: <Type, Generator>{
          AnsiTerminal: () => AnsiTerminal(stdio: FakeStdio()),
          OutputPreferences: () => OutputPreferences.test(),
          Logger: () => BufferLogger.test(),
          ProcessManager: () => const LocalProcessManager(),
        },
        body: () {
          return runZonedGuarded<Future<dynamic>>(() {
            try {
              return context.run<dynamic>(
                // Apply the overrides to the test context in the zone since their
                // instantiation may reference items already stored on the context.
                overrides: overrides,
                name: 'test-specific overrides',
                body: () async {
                  if (initializeFlutterRoot) {
                    // Provide a sane default for the flutterRoot directory. Individual
                    // tests can override this either in the test or during setup.
                    // Cache.flutterRoot ??= flutterRoot;
                  }
                  return await testMethod();
                },
              );
              // This catch rethrows, so doesn't need to catch only Exception.
            } catch (error) {
              // ignore: avoid_catches_without_on_clauses
              _printBufferedErrors(context);
              rethrow;
            }
          }, (Object error, StackTrace stackTrace) {
            // When things fail, it's ok to print to the console!
            print(error); // ignore: avoid_print
            print(stackTrace); // ignore: avoid_print
            _printBufferedErrors(context);
            throw error; //ignore: only_throw_errors
          });
        },
      );
    }, overrides: <Type, Generator>{});
  }, testOn: testOn, skip: skip, timeout: timeout);
}

void _printBufferedErrors(AppContext testContext) {
  if (testContext.get<Logger>() is BufferLogger) {
    final BufferLogger bufferLogger =
        testContext.get<Logger>()! as BufferLogger;
    if (bufferLogger.errorText.isNotEmpty) {
      // This is where the logger outputting errors is implemented, so it has
      // to use `print`.
      print(bufferLogger.errorText); // ignore: avoid_print
    }
    bufferLogger.clear();
  }
}

Future<T> runInContext<T>(
  FutureOr<T> Function() runner, {
  Map<Type, Generator>? overrides,
}) async {
  // Wrap runner with any asynchronous initialization that should run with the
  // overrides and callbacks.
  // late bool runningOnBot;
  FutureOr<T> runnerWrapper() async {
    return runner();
  }

  return context.run<T>(
      name: 'global fallbacks',
      body: runnerWrapper,
      overrides: overrides,
      fallbacks: <Type, Generator>{});
}
