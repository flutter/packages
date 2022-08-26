// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as path;
import 'package:process/process.dart';
import 'package:uuid/uuid.dart';

import '../fuchsia_ctl.dart';

/// A wrapper around the Fuchsia SDK `pm` tool.
class PackageServer {
  /// Creates a new package server.
  PackageServer(
    this.pmPath, {
    this.processManager = const LocalProcessManager(),
    this.fileSystem = const LocalFileSystem(),
  })  : assert(pmPath != null),
        assert(processManager != null),
        assert(fileSystem != null);

  /// The path on the file system to the `pm` executable.
  final String pmPath;

  /// The process manager to use for launching `pm`.
  final ProcessManager processManager;

  /// The file sytem for the package server.
  final FileSystem fileSystem;

  Process? _pmServerProcess;

  /// Path to the port file generated by `pm`.
  String? portPath;

  /// The port the server is listening on, if the server is running.
  ///
  /// Throws a [StateError] if accessed when the server is not running.
  int? get serverPort {
    if (_pmServerProcess == null) {
      throw StateError('Attempted to get port before starting server.');
    }
    return _serverPort;
  }

  int? _serverPort;

  /// Is the server up?
  bool get serving {
    return _pmServerProcess != null;
  }

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
    String? portFilePath,
  }) async {
    assert(repo != null);
    assert(port != null);

    final String uuid = const Uuid().v4();
    portPath = portFilePath ??
        path.join(fileSystem.systemTempDirectory.path, '${uuid}_port.txt');
    final List<String> pmCommand = <String>[
      pmPath,
      'serve',
      '-repo',
      repo,
      '-l',
      '$address:$port',
      '-f',
      portPath!,
    ];
    stdout.writeln('Running ${pmCommand.join(' ')}');
    _pmServerProcess = await processManager.start(pmCommand);
    await Future<void>.delayed(const Duration(seconds: 5), () async {
      final String portString = await fileSystem.file(portPath).readAsString();
      _serverPort = int.parse(portString);
    });
    _pmServerProcess!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(stdout.writeln);
    _pmServerProcess!.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(stderr.writeln);
  }

  /// Closes a running server.
  ///
  /// Calling this before calling [serveRepo] will result in a [StateError].
  Future<OperationResult> close() async {
    if (_pmServerProcess == null) {
      throw StateError('Must call serveRepo before calling close.');
    }
    await fileSystem.file(portPath).delete();
    _pmServerProcess!.kill();
    final int exitCode = await _pmServerProcess!.exitCode;
    _pmServerProcess = null;
    if (exitCode == 0) {
      return OperationResult.success();
    }
    return OperationResult.error(
        'The "pm" executable exited with non-zero exit code.');
  }
}
