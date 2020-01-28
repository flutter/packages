// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:fuchsia_ctl/fuchsia_ctl.dart';
import 'package:fuchsia_ctl/src/ssh_client.dart';
import 'package:uuid/uuid.dart';

import 'operation_result.dart';

const SshClient _kSsh = SshClient();

/// Wrapper for amberctl utility for commands executed on the target device.
@immutable
class AmberCtl {
  /// Creates a new [AmberCtl] with the specified [targetIp] and [identityFile].
  const AmberCtl(
    this._targetIp,
    this._identityFile,
  );

  final String _identityFile;
  final String _targetIp;

  /// Adds a new package update source for the target device.
  ///
  /// * [port] is what "pm serve" is bound to.
  /// * Returns the name of the package update source that is randomly generated.
  Future<String> addSrc(int port) async {
    final String uuid = Uuid().v4();
    final String localIp = await _getLocalIp(_targetIp);
    final OperationResult result = await _kSsh.runCommand(
      _targetIp,
      identityFilePath: _identityFile,
      command: <String>[
        'amberctl',
        'add_src',
        '-f',
        'http://[$localIp]:$port/config.json',
        '-n',
        uuid,
      ],
    );

    if (!result.success) {
      throw AmberCtlException('"add_src" failed, aborting.', result);
    } else {
      stdout.writeln('Successfully added an update'
          ' source on port $port with name $uuid.');
      return uuid;
    }
  }

  /// Adds a package with the given [packageName] to the device.
  Future<void> addPackage(String packageName) async {
    stdout.writeln('Adding $packageName...');
    final OperationResult result = await _kSsh.runCommand(
      _targetIp,
      identityFilePath: _identityFile,
      command: <String>[
        'amberctl',
        'get_up',
        '-n',
        packageName,
      ],
    );

    if (!result.success) {
      throw AmberCtlException('"get_up" failed, aborting.', result);
    }
  }

  Future<String> _getLocalIp(String targetIp) async {
    final OperationResult result = await _kSsh.runCommand(targetIp,
        identityFilePath: _identityFile,
        command: <String>['echo \$SSH_CONNECTION']);

    if (!result.success) {
      throw AmberCtlException('Failed to get local address, aborting.', result);
    } else {
      return result.info.split(' ')[0].replaceAll('%', '%25');
    }
  }
}

/// Wraps exceptions thrown by amberctl utility.
@immutable
class AmberCtlException implements Exception {
  /// Creates a new [AmberCtlException] using the specified [cause] and [result].
  const AmberCtlException(this.cause, this.result);

  /// Represents the human-readable cause for the amberctl error.
  final String cause;

  /// Contains the result of the executed target command.
  final OperationResult result;

  @override
  String toString() =>
      '$runtimeType, cause: "$cause", underlying exception: $result.';
}
