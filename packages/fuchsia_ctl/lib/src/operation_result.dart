// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:meta/meta.dart';

/// The result of running a command or operation.
///
/// This loosely corresponds to a [ProcessResult], but is not necessarily the
/// result of running a process.
@immutable
class OperationResult {
  const OperationResult._(
    this.success, {
    this.info = '',
    this.error = '',
  });

  /// A successful operation result with a non-null but potentially empty info
  /// message, and an empty error message.
  factory OperationResult.success({
    String info = '',
  }) {
    assert(info != null);
    return OperationResult._(true, info: info, error: '');
  }

  /// A failing operation result with a non-null but potentially empty error,
  /// and a non-null but potentially empty info.
  factory OperationResult.error(
    String error, {
    String info = '',
  }) {
    assert(error != null);
    assert(info != null);
    return OperationResult._(false, info: info, error: error);
  }

  factory OperationResult.fromProcessResult(
    ProcessResult result, {
    int expectedExitCode = 0,
  }) {
    assert(expectedExitCode != null);
    return OperationResult._(
      result.exitCode == expectedExitCode,
      info: result.stdout.toString(),
      error: result.stderr.toString(),
    );
  }

  /// Whether the result was successful or not. Not null.
  final bool success;

  /// Information from the result, e.g. the stdout of a process.
  final String info;

  /// Error information from the result, e.g. the stderr of a process.
  final String error;

  @override
  String toString() =>
      '$runtimeType{${success ? 'success' : 'failure'}, info: "$info", error: "$error"}';
}
