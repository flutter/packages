// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:process/process.dart';

import 'operation_result.dart';

/// A wrapper for untarring artifacts.
///
/// Implemented by [SystemTar].
abstract class Tar {
  /// A const constructor to allow subclasses to create const constructors.
  const Tar();

  /// Untars a tar file.
  Future<OperationResult> untar(
    String src,
    String destination, {
    Duration timeoutMs,
  });
}

/// The archive package is very slow and memory intensive. Use
/// system tar.
@immutable
class SystemTar implements Tar {
  /// Creates a new [SystemTar] using the specified [ProcessManager].
  ///
  /// The processManager parameter must not be null.
  const SystemTar({
    this.processManager = const LocalProcessManager(),
  }) : assert(processManager != null);

  /// The [ProcessManager] impleemntation to use when spawning the system tar
  /// program.
  final ProcessManager processManager;

  /// The default timeout for untar operations as [Duration] in milliseconds.
  static const Duration defaultTarTimeoutMs =
      Duration(milliseconds: 5 * 60 * 1000);

  @override
  Future<OperationResult> untar(
    String src,
    String destination, {
    Duration timeoutMs = defaultTarTimeoutMs,
  }) async {
    final ProcessResult result = await processManager.run(<String>[
      'tar',
      '-xf', src, //
      '-C', destination,
    ]).timeout(timeoutMs);

    return OperationResult.fromProcessResult(result);
  }
}
