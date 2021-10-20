// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:process/process.dart';

/// A wrapper for the Fuchsia SDK `ffx` tool.
@immutable
class FFX {
  /// Creates a new wrapper for the `ffx` tool.
  ///
  /// All parameters must not be null.
  const FFX(
    this.ffxPath, {
    this.processManager = const LocalProcessManager(),
  })  : assert(ffxPath != null),
        assert(processManager != null);

  /// The path to the Fuchsia SDK `ffx`tool on disk.
  final String ffxPath;

  /// The [ProcessManager] to use for launching the `ffx`tool.
  final ProcessManager processManager;

  Future<String> _runFFXWithRetries(
    String deviceName,
    int numTries,
    int sleepDelay, {
    @required bool nullOk,
  }) async {
    assert(numTries != null);
    assert(sleepDelay != null);
    assert(nullOk != null);

    if (deviceName == null) {
      stderr.writeln('Warning: device name not specified; if '
          'multiple devices are attached you may not get the right one.');
    }
    final List<String> command = <String>[
      ffxPath,
      'target',
      'list',
      '--format',
      'a',
      if (deviceName != null) deviceName,
    ];

    for (int i = 0; i < numTries; i++) {
      final ProcessResult result = await processManager.run(command);
      if (result.exitCode == 0) {
        final List<String> addresses = result.stdout.toString().split('\n');
        if (addresses.isNotEmpty) {
          return addresses[0].trim();
        }
      }
      await Future<void>.delayed(Duration(seconds: sleepDelay));
    }
    if (!nullOk) {
      throw FFXException('Failed to get target IP for $deviceName');
    }
    return null;
  }

  /// Gets the target address for the specified `deviceName`.
  ///
  /// If `deviceName` is null, will attempt to get the target address of the
  /// first discoverable device.
  ///
  /// The `numTries` parameter must not be null, and specifies how many
  /// times to retry finding the device. This is useful e.g. after paving a
  /// device and waiting for it to become available. The `sleepDelay` also
  /// must not be null, and specifies the number of seconds to wait between
  /// retries.
  ///
  /// The `nullOk` parameter must not be null. If true, this method will
  /// return null if it cannot find a device; otherwise, it will throw. The
  /// default value is false.
  Future<String> getTargetAddress(
    String deviceName, {
    int numTries = 75,
    int sleepDelay = 4,
    bool nullOk = false,
  }) {
    return _runFFXWithRetries(
      deviceName,
      numTries,
      sleepDelay,
      nullOk: nullOk,
    );
  }
}

/// The exception thrown when a [FFX] lookup fails.
class FFXException implements Exception {
  /// Creates a new [FFXException], such as when ffx fails to find
  /// a device.
  const FFXException(this.message);

  /// The user-facing message to display.
  final String message;

  @override
  String toString() => message;
}
