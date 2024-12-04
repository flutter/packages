// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'file_system.dart';

/// Throw a specialized exception for expected situations
/// where the tool should exit with a clear message to the user
/// and no stack trace unless the --verbose option is specified.
/// For example: network errors.
Never throwToolExit(String? message, {int? exitCode}) {
  throw ToolExit(message, exitCode: exitCode);
}

/// Specialized exception for expected situations
/// where the tool should exit with a clear message to the user
/// and no stack trace unless the --verbose option is specified.
/// For example: network errors.
class ToolExit implements Exception {
  ToolExit(this.message, {this.exitCode});

  final String? message;
  final int? exitCode;

  @override
  String toString() => 'Error: $message';
}

/// Return the name of an enum item.
String getEnumName(dynamic enumItem) {
  final String name = '$enumItem';
  final int index = name.indexOf('.');
  return index == -1 ? name : name.substring(index + 1);
}

/// Runs [fn] with special handling of asynchronous errors.
///
/// If the execution of [fn] does not throw a synchronous exception, and if the
/// [Future] returned by [fn] is completed with a value, then the [Future]
/// returned by [asyncGuard] is completed with that value if it has not already
/// been completed with an error.
///
/// If the execution of [fn] throws a synchronous exception, and no [onError]
/// callback is provided, then the [Future] returned by [asyncGuard] is
/// completed with an error whose object and stack trace are given by the
/// synchronous exception. If an [onError] callback is provided, then the
/// [Future] returned by [asyncGuard] is completed with its result when passed
/// the error object and stack trace.
///
/// If the execution of [fn] results in an asynchronous exception that would
/// otherwise be unhandled, and no [onError] callback is provided, then the
/// [Future] returned by [asyncGuard] is completed with an error whose object
/// and stack trace are given by the asynchronous exception. If an [onError]
/// callback is provided, then the [Future] returned by [asyncGuard] is
/// completed with its result when passed the error object and stack trace.
///
/// After the returned [Future] is completed, whether it be with a value or an
/// error, all further errors resulting from the execution of [fn] are ignored.
///
/// Rationale:
///
/// Consider the following snippet:
/// ```dart
/// try {
///   await foo();
///   ...
/// } catch (e) {
///   ...
/// }
/// ```
/// If the [Future] returned by `foo` is completed with an error, that error is
/// handled by the catch block. However, if `foo` spawns an asynchronous
/// operation whose errors are unhandled, those errors will not be caught by
/// the catch block, and will instead propagate to the containing [Zone]. This
/// behavior is non-intuitive to programmers expecting the `catch` to catch all
/// the errors resulting from the code under the `try`.
///
/// As such, it would be convenient if the `try {} catch {}` here could handle
/// not only errors completing the awaited [Future]s it contains, but also
/// any otherwise unhandled asynchronous errors occurring as a result of awaited
/// expressions. This is how `await` is often assumed to work, which leads to
/// unexpected unhandled exceptions.
///
/// [asyncGuard] is intended to wrap awaited expressions occurring in a `try`
/// block. The behavior described above gives the behavior that users
/// intuitively expect from `await`. Consider the snippet:
/// ```dart
/// try {
///   await asyncGuard(() async {
///     var c = Completer();
///     c.completeError('Error');
///   });
/// } catch (e) {
///   // e is 'Error';
/// }
/// ```
/// Without the [asyncGuard] the error 'Error' would be propagated to the
/// error handler of the containing [Zone]. With the [asyncGuard], the error
/// 'Error' is instead caught by the `catch`.
///
/// [asyncGuard] also accepts an [onError] callback for situations in which
/// completing the returned [Future] with an error is not appropriate.
/// For example, it is not always possible to immediately await the returned
/// [Future]. In these cases, an [onError] callback is needed to prevent an
/// error from propagating to the containing [Zone].
///
/// [onError] must have type `FutureOr<T> Function(Object error)` or
/// `FutureOr<T> Function(Object error, StackTrace stackTrace)` otherwise an
/// [ArgumentError] will be thrown synchronously.
Future<T> asyncGuard<T>(
  Future<T> Function() fn, {
  Function? onError,
}) {
  if (onError != null &&
      onError is! _UnaryOnError<T> &&
      onError is! _BinaryOnError<T>) {
    throw ArgumentError('onError must be a unary function accepting an Object, '
        'or a binary function accepting an Object and '
        'StackTrace. onError must return a T');
  }
  final Completer<T> completer = Completer<T>();

  void handleError(Object e, StackTrace s) {
    if (completer.isCompleted) {
      return;
    }
    if (onError == null) {
      completer.completeError(e, s);
      return;
    }
    if (onError is _BinaryOnError<T>) {
      completer.complete(onError(e, s));
    } else if (onError is _UnaryOnError<T>) {
      completer.complete(onError(e));
    }
  }

  runZonedGuarded<void>(() async {
    try {
      final T result = await fn();
      if (!completer.isCompleted) {
        completer.complete(result);
      }
      // This catches all exceptions so that they can be propagated to the
      // caller-supplied error handling or the completer.
    } catch (e, s) {
      // ignore: avoid_catches_without_on_clauses, forwards to Future
      handleError(e, s);
    }
  }, (Object e, StackTrace s) {
    handleError(e, s);
  });

  return completer.future;
}

typedef _UnaryOnError<T> = FutureOr<T> Function(Object error);
typedef _BinaryOnError<T> = FutureOr<T> Function(
    Object error, StackTrace stackTrace);

/// Whether the test is running in a web browser compiled to JavaScript.
///
/// See also:
///
///  * [kIsWeb], the equivalent constant in the `foundation` library.
const bool isBrowser = identical(0, 0.0);

/// Whether the test is running on the Windows operating system.
///
/// This does not include tests compiled to JavaScript running in a browser on
/// the Windows operating system.
///
/// See also:
///
///  * [isBrowser], which reports true for tests running in browsers.
bool get isWindows {
  if (isBrowser) {
    return false;
  }
  return Platform.isWindows;
}

/// Whether the test is running on the macOS operating system.
///
/// This does not include tests compiled to JavaScript running in a browser on
/// the macOS operating system.
///
/// See also:
///
///  * [isBrowser], which reports true for tests running in browsers.
bool get isMacOS {
  if (isBrowser) {
    return false;
  }
  return Platform.isMacOS;
}

/// Whether the test is running on the Linux operating system.
///
/// This does not include tests compiled to JavaScript running in a browser on
/// the Linux operating system.
///
/// See also:
///
///  * [isBrowser], which reports true for tests running in browsers.
bool get isLinux {
  if (isBrowser) {
    return false;
  }
  return Platform.isLinux;
}

String? flutterRoot;

/// Determine the absolute and normalized path for the root of the current
/// Flutter checkout.
///
/// This method has a series of fallbacks for determining the repo location. The
/// first success will immediately return the root without further checks.
///
/// The order of these tests is:
///   1. FLUTTER_ROOT environment variable contains the path.
///   2. Platform script is a data URI scheme, returning `../..` to support
///      tests run from `packages/flutter_tools`.
///   3. Platform script is package URI scheme, returning the grandparent directory
///      of the package config file location from `packages/flutter_tools/.packages`.
///   4. Platform script file path is the snapshot path generated by `bin/flutter`,
///      returning the grandparent directory from `bin/cache`.
///   5. Platform script file name is the entrypoint in `packages/flutter_tools/bin/flutter_tools.dart`,
///      returning the 4th parent directory.
///   6. The current directory
///
/// If an exception is thrown during any of these checks, an error message is
/// printed and `.` is returned by default (6).
String defaultFlutterRoot({
  required FileSystem fileSystem,
}) {
  const String kFlutterRootEnvironmentVariableName =
      'FLUTTER_ROOT'; // should point to //flutter/ (root of flutter/flutter repo)
  const String kSnapshotFileName =
      'flutter_tools.snapshot'; // in //flutter/bin/cache/
  const String kFlutterToolsScriptFileName =
      'flutter_tools.dart'; // in //flutter/packages/flutter_tools/bin/
  String normalize(String path) {
    return fileSystem.path.normalize(fileSystem.path.absolute(path));
  }

  if (Platform.environment.containsKey(kFlutterRootEnvironmentVariableName)) {
    return normalize(
        Platform.environment[kFlutterRootEnvironmentVariableName]!);
  }
  try {
    if (Platform.script.scheme == 'data') {
      return normalize('../..'); // The tool is running as a test.
    }
    final String Function(String) dirname = fileSystem.path.dirname;

    if (Platform.script.scheme == 'package') {
      final String packageConfigPath =
          Uri.parse(Platform.packageConfig!).toFilePath(
        windows: isWindows,
      );
      return normalize(dirname(dirname(dirname(packageConfigPath))));
    }

    if (Platform.script.scheme == 'file') {
      final String script = Platform.script.toFilePath(
        windows: isWindows,
      );
      if (fileSystem.path.basename(script) == kSnapshotFileName) {
        return normalize(dirname(dirname(fileSystem.path.dirname(script))));
      }
      if (fileSystem.path.basename(script) == kFlutterToolsScriptFileName) {
        return normalize(dirname(dirname(dirname(dirname(script)))));
      }
    }
  } on Exception catch (error) {
    // There is currently no logger attached since this is computed at startup.
    // ignore: avoid_print
    print('$error');
  }
  return normalize('.');
}
