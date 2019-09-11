// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fuchsia_ctl/fuchsia_ctl.dart';
import 'package:process/process.dart';

/// A wrapper around the Fuchsia SDK `pm` tool.
class PackageServer {
  /// Creates a new package server.
  PackageServer(
    this.pmPath, {
    this.processManager = const LocalProcessManager(),
  })  : assert(pmPath != null),
        assert(processManager != null);

  /// The path on the file system to the `pm` executable.
  final String pmPath;

  /// The process manager to use for launching `pm`.
  final ProcessManager processManager;

  Process _pmServerProcess;

  /// The port the server is listening on, if the server is running.
  ///
  /// Throws a [StateError] if accessed when the server is not running.
  int get serverPort {
    if (_pmServerProcess == null) {
      throw StateError('Attempted to get port before starting server.');
    }
    return _serverPort;
  }

  int _serverPort;

  /// Creates a new local repository and associated key material.
  ///
  /// Corresponds to `pm newrepo`.
  Future<OperationResult> newRepo(String repo) async {
    return OperationResult.fromProcessResult(
      await processManager.run(
        <String>[
          pmPath,
          'newrepo',
          '-repo', repo, //
        ],
      ),
    );
  }

  /// Publishes an archive package for use on a device with the specified
  /// .far files.
  Future<OperationResult> publishRepo(String repo, String farFile) async {
    return OperationResult.fromProcessResult(
      await processManager.run(
        <String>[
          pmPath,
          'publish',
          '-a',
          '-repo', repo, //
          '-f', farFile,
        ],
      ),
    );
  }

  /// Starts a server for the specified repo path and port.
  ///
  /// Use port 0 to have the server choose a port. The acutal port used
  /// will be avialalbe in the [serverPort] property after this method
  /// returns. The stdout and stderr of the server will be printed to [stdout]
  /// and [stderr], respectively.
  Future<void> serveRepo(
    String repo, {
    String address = '',
    int port = 0,
  }) async {
    assert(repo != null);
    assert(port != null);
    _pmServerProcess = await processManager.start(<String>[
      pmPath,
      'serve',
      '-repo', repo, //
      '-l', '$address:$port',
    ]);
    final Completer<void> serverPortCompleter = Completer<void>();
    _pmServerProcess.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((String line) {
      if (line.contains('serving $repo at http://')) {
        _serverPort = int.parse(line.substring(line.lastIndexOf(':') + 1));
        serverPortCompleter.complete();
      }
      stdout.writeln(line);
    });
    _pmServerProcess.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(stderr.writeln);
    await serverPortCompleter.future;
  }

  /// Closes a running server.
  ///
  /// Calling this before calling [serveRepo] will result in a [StateError].
  Future<OperationResult> close() async {
    if (_pmServerProcess == null) {
      throw StateError('Must call serveRepo before calling close.');
    }
    _pmServerProcess.kill();
    final int exitCode = await _pmServerProcess.exitCode;
    if (exitCode == 0) {
      return OperationResult.success();
    }
    return OperationResult.error('The "pm" executable exited with non-zero exit code.');
  }
}
