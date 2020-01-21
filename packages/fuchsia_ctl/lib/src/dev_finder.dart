// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:process/process.dart';

/// A wrapper for the Fuchsia SDK `dev_finder` tool.
@immutable
class DevFinder {
  /// Creates a new wrapper for the `dev_finder` tool.
  ///
  /// All parameters must not be null.
  const DevFinder(
    this.devFinderPath, {
    this.processManager = const LocalProcessManager(),
  })  : assert(devFinderPath != null),
        assert(processManager != null);

  /// The path to the Fuchsia SDK `dev_finder` tool on disk.
  final String devFinderPath;

  /// The [ProcessManager] to use for launching the `dev_finder` tool.
  final ProcessManager processManager;

  Future<String> _runDevFinderWithRetries(
    String deviceName,
    int numTries,
    int sleepDelay, {
    bool local = false,
    @required bool nullOk,
  }) async {
    assert(numTries != null);
    assert(sleepDelay != null);
    assert(local != null);
    assert(nullOk != null);

    if (deviceName == null) {
      stderr.writeln('Warning: device name not specified; if '
          'multiple devices are attached you may not get the right one.');
    }
    final List<String> command = <String>[
      devFinderPath,
      if (deviceName != null)
        'resolve'
      else
        'list',
      '-device-limit', '1', //
      if (local)
        '-local',
      if (deviceName != null)
        deviceName,
    ];

    for (int i = 0; i < numTries; i++) {
      final ProcessResult result = await processManager.run(command);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
      await Future<void>.delayed(Duration(seconds: sleepDelay));
    }
    if (!nullOk) {
      throw DevFinderException(
          'Failed to get ${local ? 'local' : 'target'} IP for $deviceName');
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
    int numTries = 60,
    int sleepDelay = 2,
    bool nullOk = false,
  }) {
    return _runDevFinderWithRetries(
      deviceName,
      numTries,
      sleepDelay,
      nullOk: nullOk,
      local: false,
    );
  }

  /// Gets the local interface address for the specified `deviceName`.
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
  Future<String> getLocalAddress(
    String deviceName, {
    int numTries = 30,
    int sleepDelay = 2,
    bool nullOk = false,
  }) {
    return _runDevFinderWithRetries(
      deviceName,
      numTries,
      sleepDelay,
      nullOk: nullOk,
      local: true,
    );
  }
}

/// The exception thrown when a [DevFinder] lookup fails.
class DevFinderException implements Exception {
  /// Creates a new [DevFinderException], such as when dev_finder fails to find
  /// a device.
  const DevFinderException(this.message);

  /// The user-facing message to display.
  final String message;

  @override
  String toString() => message;
}
