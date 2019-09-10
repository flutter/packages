import 'dart:convert';
import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:meta/meta.dart';
import 'package:process/process.dart';
import 'package:uuid/uuid.dart';

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
  })  : assert(processManager != null),
        assert(fs != null);

  /// The [ProcessManager] used to launch the boot server, `tar`,
  /// and `ssh-keygen`.
  final ProcessManager processManager;

  /// The [FileSystem] implementation used to
  final FileSystem fs;

  /// Create SSH key material suitable for accessing the image once paved.
  Future<ProcessResult> createSshKeys({bool force = false}) async {
    final Directory sshDir = fs.directory('.ssh');
    final File authorizedKeys = sshDir.childFile('authorized_keys');
    if (authorizedKeys.existsSync() && !force) {
      return null;
    }

    if (sshDir.existsSync()) {
      await sshDir.delete(recursive: true);
    }

    await sshDir.create();
    final File pkey = sshDir.childFile('pkey');
    final File pkeyPub = sshDir.childFile('pkey.pub');
    final ProcessResult result = await processManager.run(
      <String>[
        'ssh-keygen',
        '-t', 'ed25519', //
        '-f', pkey.path,
        '-q',
        '-N', '',
      ],
    );
    if (result.exitCode != 0) {
      return result;
    }

    final List<String> pkeyPubParts = pkeyPub.readAsStringSync().split(' ');
    await authorizedKeys
        .writeAsString('${pkeyPubParts[0]} ${pkeyPubParts[1]}\n');
    return result;
  }

  Future<ProcessResult> _untar(
      String imageTgzPath, Directory destination) async {
    // The archive package is very slow and memory intensive. Use
    // system tar.
    return await processManager.run(<String>[
      'tar',
      '-xvf', imageTgzPath, //
      '-C', destination.path,
    ]);
  }

  /// Paves an image (in .tgz format) to the specified device.
  ///
  /// The `imageTgzPath` must not be null. If `deviceName` is null, the
  /// first discoverable device will be used.
  Future<ProcessResult> pave(String imageTgzPath, String deviceName) async {
    assert(imageTgzPath != null);
    if (deviceName == null) {
      stderr.writeln('Warning: No device name specified. '
          'If multiple devices are attached, this may result in paving '
          'an unexpected device.');
    }
    final String uuid = Uuid().v4();
    final Directory imageDirectory = fs.directory('image_$uuid');
    stdout.writeln('Using ${imageDirectory.path} as temp path.');
    await imageDirectory.create();
    final ProcessResult untarResult = await _untar(imageTgzPath, imageDirectory);

    if (untarResult.exitCode != 0) {
      stderr.writeln('Unpacking image $imageTgzPath failed.');
      imageDirectory.deleteSync(recursive: true);
      return untarResult;
    }

    final ProcessResult sshResult = await createSshKeys();
    if (sshResult != null && sshResult.exitCode != 0) {
      stderr.writeln('Creating SSH Keys failed.');
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
    );
    final StringBuffer paveStdout = StringBuffer();
    final StringBuffer paveStderr = StringBuffer();
    paveProcess.stdout.transform(utf8.decoder).forEach((String s) {
      stdout.write(s);
      paveStdout.write(s);
    });
    paveProcess.stderr.transform(utf8.decoder).forEach((String s) {
      stderr.write(s);
      paveStderr.write(s);
    });
    final int exitCode = await paveProcess.exitCode;
    await stdout.flush();
    await stderr.flush();
    imageDirectory.deleteSync(recursive: true);
    return ProcessResult(paveProcess.pid, exitCode, paveStdout.toString(),
        paveStderr.toString());
  }
}
