// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file/file.dart';
import 'package:file/local.dart' as local_fs;
import 'package:meta/meta.dart';

import 'common.dart';
import 'io.dart';
import 'logger.dart';
import 'signals.dart';

// package:file/local.dart must not be exported. This exposes LocalFileSystem,
// which we override to ensure that temporary directories are cleaned up when
// the tool is killed by a signal.
export 'package:file/file.dart';

/// Exception indicating that a file that was expected to exist was not found.
class FileNotFoundException implements IOException {
  const FileNotFoundException(this.path);

  final String path;

  @override
  String toString() => 'File not found: $path';
}

/// Return a relative path if [fullPath] is contained by the cwd, else return an
/// absolute path.
String getDisplayPath(String fullPath, FileSystem fileSystem) {
  final String cwd =
      fileSystem.currentDirectory.path + fileSystem.path.separator;
  return fullPath.startsWith(cwd) ? fullPath.substring(cwd.length) : fullPath;
}

/// This class extends [local_fs.LocalFileSystem] in order to clean up
/// directories and files that the tool creates under the system temporary
/// directory when the tool exits either normally or when killed by a signal.
class LocalFileSystem extends local_fs.LocalFileSystem {
  LocalFileSystem(this._signals, this._fatalSignals, this.shutdownHooks);

  @visibleForTesting
  LocalFileSystem.test({
    required Signals signals,
    List<ProcessSignal> fatalSignals = Signals.defaultExitSignals,
  }) : this(signals, fatalSignals, ShutdownHooks());

  Directory? _systemTemp;
  final Map<ProcessSignal, Object> _signalTokens = <ProcessSignal, Object>{};

  final ShutdownHooks shutdownHooks;

  Future<void> dispose() async {
    _tryToDeleteTemp();
    for (final MapEntry<ProcessSignal, Object> signalToken
        in _signalTokens.entries) {
      await _signals.removeHandler(signalToken.key, signalToken.value);
    }
    _signalTokens.clear();
  }

  final Signals _signals;
  final List<ProcessSignal> _fatalSignals;

  void _tryToDeleteTemp() {
    try {
      if (_systemTemp?.existsSync() ?? false) {
        _systemTemp?.deleteSync(recursive: true);
      }
    } on FileSystemException {
      // ignore
    }
    _systemTemp = null;
  }

  // This getter returns a fresh entry under /tmp, like
  // /tmp/flutter_tools.abcxyz, then the rest of the tool creates /tmp entries
  // under that, like /tmp/flutter_tools.abcxyz/flutter_build_stuff.123456.
  // Right before exiting because of a signal or otherwise, we delete
  // /tmp/flutter_tools.abcxyz, not the whole of /tmp.
  @override
  Directory get systemTempDirectory {
    if (_systemTemp == null) {
      if (!superSystemTempDirectory.existsSync()) {
        throwToolExit(
            'Your system temp directory (${superSystemTempDirectory.path}) does not exist. '
            'Did you set an invalid override in your environment? See issue https://github.com/flutter/flutter/issues/74042 for more context.');
      }
      _systemTemp = superSystemTempDirectory.createTempSync('flutter_tools.')
        ..createSync(recursive: true);
      // Make sure that the temporary directory is cleaned up if the tool is
      // killed by a signal.
      for (final ProcessSignal signal in _fatalSignals) {
        final Object token = _signals.addHandler(
          signal,
          (ProcessSignal _) {
            _tryToDeleteTemp();
          },
        );
        _signalTokens[signal] = token;
      }
      // Make sure that the temporary directory is cleaned up when the tool
      // exits normally.
      shutdownHooks.addShutdownHook(
        _tryToDeleteTemp,
      );
    }
    return _systemTemp!;
  }

  // This only exist because the memory file system does not support a systemTemp that does not exists #74042
  @visibleForTesting
  Directory get superSystemTempDirectory => super.systemTempDirectory;
}

/// A function that will be run before the VM exits.
typedef ShutdownHook = FutureOr<void> Function();

abstract class ShutdownHooks {
  factory ShutdownHooks() => _DefaultShutdownHooks();

  /// Registers a [ShutdownHook] to be executed before the VM exits.
  void addShutdownHook(ShutdownHook shutdownHook);

  @visibleForTesting
  List<ShutdownHook> get registeredHooks;

  /// Runs all registered shutdown hooks and returns a future that completes when
  /// all such hooks have finished.
  ///
  /// Shutdown hooks will be run in groups by their [ShutdownStage]. All shutdown
  /// hooks within a given stage will be started in parallel and will be
  /// guaranteed to run to completion before shutdown hooks in the next stage are
  /// started.
  ///
  /// This class is constructed before the [Logger], so it cannot be direct
  /// injected in the constructor.
  Future<void> runShutdownHooks(Logger logger);
}

class _DefaultShutdownHooks implements ShutdownHooks {
  _DefaultShutdownHooks();

  @override
  final List<ShutdownHook> registeredHooks = <ShutdownHook>[];

  bool _shutdownHooksRunning = false;

  @override
  void addShutdownHook(ShutdownHook shutdownHook) {
    assert(!_shutdownHooksRunning);
    registeredHooks.add(shutdownHook);
  }

  @override
  Future<void> runShutdownHooks(Logger logger) async {
    logger.printTrace(
      'Running ${registeredHooks.length} shutdown hook${registeredHooks.length == 1 ? '' : 's'}',
    );
    _shutdownHooksRunning = true;
    try {
      final List<Future<dynamic>> futures = <Future<dynamic>>[];
      for (final ShutdownHook shutdownHook in registeredHooks) {
        final FutureOr<dynamic> result = shutdownHook();
        if (result is Future<dynamic>) {
          futures.add(result);
        }
      }
      await Future.wait<dynamic>(futures);
    } finally {
      _shutdownHooksRunning = false;
    }
    logger.printTrace('Shutdown hooks complete');
  }
}
