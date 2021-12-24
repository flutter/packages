// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:meta/meta.dart';
import 'package:process/process.dart';
import 'package:uuid/uuid.dart';

import 'operation_result.dart';
import 'ssh_key_manager.dart';
import 'tar.dart';

/// Paves a prebuilt system image to a Fuchsia device.
///
/// The Fuchsia device must be in zedboot mode.
@immutable
class ImagePaver {
  /// Creates a new image paver.
  ///
  /// All properties must not be null.
  const ImagePaver({
    this.processManager = const LocalProcessManager(),
    this.fs = const LocalFileSystem(),
    this.tar = const SystemTar(processManager: LocalProcessManager()),
    this.sshKeyManagerProvider = SystemSshKeyManager.defaultProvider,
  })  : assert(processManager != null),
        assert(fs != null),
        assert(tar != null);

  /// The [ProcessManager] used to launch the boot server, `tar`,
  /// and `ssh-keygen`.
  final ProcessManager processManager;

  /// The default pave timeout as [Duration] in milliseconds.
  static const Duration defaultPaveTimeoutMs =
      Duration(milliseconds: 5 * 60 * 1000);

  /// The [FileSystem] implementation used to
  final FileSystem fs;

  /// The implementation to use for untarring system images.
  final Tar tar;

  /// The implementation to use for creating SSH keys.
  final SshKeyManagerProvider sshKeyManagerProvider;

  /// Paves an image (in .tgz format) to the specified device.
  ///
  /// The `imageTgzPath` must not be null. If `deviceName` is null, the
  /// first discoverable device will be used.
  Future<OperationResult> pave(
    String imageTgzPath,
    String deviceName, {
    String publicKeyPath,
    bool verbose = true,
    Duration timeoutMs = defaultPaveTimeoutMs,
  }) async {
    assert(imageTgzPath != null);
    if (deviceName == null) {
      stderr.writeln('Warning: No device name specified. '
          'If multiple devices are attached, this may result in paving '
          'an unexpected device.');
    }
    final SshKeyManager sshKeyManager = sshKeyManagerProvider(
      processManager: processManager,
      publicKeyPath: publicKeyPath,
      fs: fs,
    );
    final String uuid = const Uuid().v4();
    final Directory imageDirectory = fs.directory('image_$uuid');
    if (verbose) {
      stdout.writeln('Using ${imageDirectory.path} as temp path.');
    }
    await imageDirectory.create();
    final OperationResult untarResult = await tar.untar(
      imageTgzPath,
      imageDirectory.path,
    );

    if (!untarResult.success) {
      if (verbose) {
        stderr.writeln('Unpacking image $imageTgzPath failed.');
      }
      imageDirectory.deleteSync(recursive: true);
      return untarResult;
    }

    final OperationResult sshResult = await sshKeyManager.createKeys();
    if (!sshResult.success) {
      if (verbose) {
        stderr.writeln('Creating SSH Keys failed.');
      }
      imageDirectory.deleteSync(recursive: true);
      return sshResult;
    }
    final Process paveProcess = await processManager.start(
      <String>[
        '${imageDirectory.path}/pave.sh',
        '--fail-fast',
        '-1', // pave once and exit
        '--allow-zedboot-version-mismatch',
        if (deviceName != null) ...<String>['-n', deviceName],
        '--authorized-keys', '.ssh/authorized_keys',
      ],
    ).timeout(timeoutMs);
    final StringBuffer paveStdout = StringBuffer();
    final StringBuffer paveStderr = StringBuffer();
    paveProcess.stdout.transform(utf8.decoder).forEach((String s) {
      if (verbose) {
        stdout.write(s);
      }
      paveStdout.write(s);
    });
    paveProcess.stderr.transform(utf8.decoder).forEach((String s) {
      if (verbose) {
        stderr.write(s);
      }
      paveStderr.write(s);
    });
    final int exitCode = await paveProcess.exitCode;
    await stdout.flush();
    await stderr.flush();
    imageDirectory.deleteSync(recursive: true);

    return OperationResult.fromProcessResult(
      ProcessResult(
        paveProcess.pid,
        exitCode,
        paveStdout.toString(),
        paveStderr.toString(),
      ),
    );
  }
}
