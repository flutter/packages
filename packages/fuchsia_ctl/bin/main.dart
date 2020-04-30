// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:retry/retry.dart';
import 'package:uuid/uuid.dart';

import 'package:fuchsia_ctl/fuchsia_ctl.dart';

typedef AsyncResult = Future<OperationResult> Function(
    String, DevFinder, ArgResults);

const Map<String, AsyncResult> commands = <String, AsyncResult>{
  'emu': emulator,
  'pave': pave,
  'pm': pm,
  'ssh': ssh,
  'test': test,
  'push-packages': pushPackages,
};

Future<void> main(List<String> args) async {
  if (!Platform.isLinux) {
    throw UnsupportedError('This tool only supports Linux.');
  }

  final ArgParser parser = ArgParser();
  parser
    ..addOption('device-name',
        abbr: 'd',
        help: 'The device node name to use. '
            'If not specified, the first discoverable device will be used.')
    ..addOption('dev-finder-path',
        defaultsTo: './dev_finder',
        help: 'The path to the dev_finder executable.')
    ..addFlag('help', defaultsTo: false, help: 'Prints help.');

  parser.addCommand('emu')
    ..addOption('image', help: 'Fuchsia image to run')
    ..addOption('zbi', help: 'Bootloader image to sign and run')
    ..addOption('qemu-kernel', help: 'QEMU kernel to run')
    ..addOption('window-size', help: 'Emulator window size formatted "WxH"')
    ..addOption('aemu', help: 'AEMU executable path')
    ..addOption('sdk',
        help: 'Location to Fuchsia SDK containing tools and images')
    ..addOption('ssh-path', defaultsTo: '.fuchsia', help: 'Path to ssh keys')
    ..addFlag('headless', help: 'Run FEMU without graphical window');

  parser.addCommand('ssh')
    ..addFlag('interactive',
        abbr: 'i',
        help: 'Whether to ssh in interactive mode. '
            'If --comand is specified, this is ignored.')
    ..addOption('command',
        abbr: 'c',
        help: 'The command to run on the device. '
            'If specified, --interactive is ignored.')
    ..addOption('identity-file',
        defaultsTo: '.ssh/pkey', help: 'The key to use when SSHing.')
    ..addOption('timeout-seconds',
        defaultsTo: '120', help: 'Ssh command timeout in seconds.');
  parser.addCommand('pave')
    ..addOption('public-key',
        abbr: 'p', help: 'The public key to add to authorized_keys.')
    ..addOption('image',
        abbr: 'i', help: 'The system image tgz to unpack and pave.');

  final ArgParser pmSubCommand = parser.addCommand('pm')
    ..addOption('pm-path',
        defaultsTo: './pm', help: 'The path to the pm executable.')
    ..addOption('repo',
        abbr: 'r',
        help: 'The location of the repository folder to create, '
            'publish, or serve.')
    ..addCommand('serve')
    ..addCommand('newRepo');
  pmSubCommand
      .addCommand('publishRepo')
      .addMultiOption('far', abbr: 'f', help: 'The .far files to publish.');

  parser.addCommand('push-packages')
    ..addOption('pm-path',
        defaultsTo: './pm', help: 'The path to the pm executable.')
    ..addOption('repoArchive', help: 'The path to the repo tar.gz archive.')
    ..addOption('identity-file',
        defaultsTo: '.ssh/pkey', help: 'The key to use when SSHing.')
    ..addMultiOption('packages',
        abbr: 'p',
        help: 'Packages from the repo that need to be pushed to the device.');

  parser.addCommand('test')
    ..addOption('pm-path',
        defaultsTo: './pm', help: 'The path to the pm executable.')
    ..addOption('identity-file',
        defaultsTo: '.ssh/pkey', help: 'The key to use when SSHing.')
    ..addOption('target',
        abbr: 't', help: 'The name of the target to pass to runtests.')
    ..addOption('arguments',
        abbr: 'a',
        help: 'Command line arguments to pass when invoking the tests')
    ..addMultiOption('far',
        abbr: 'f', help: 'The .far files to include for the test.')
    ..addOption('timeout-seconds',
        defaultsTo: '120', help: 'Test timeout in seconds.')
    ..addOption('packages-directory', help: 'amber files directory.');

  final ArgResults results = parser.parse(args);

  if (results.command == null) {
    stderr.writeln('Unknown command, expected one of: ${parser.commands.keys}');
    stderr.writeln(parser.usage);
    exit(-1);
  }

  if (results['help']) {
    stderr.writeln(parser.commands[results.command.name].usage);
    exit(0);
  }

  final AsyncResult command = commands[results.command.name];
  if (command == null) {
    stderr.writeln('Unkown command ${results.command.name}.');
    stderr.writeln(parser.usage);
    exit(-1);
  }
  final OperationResult result = await command(
    results['device-name'],
    DevFinder(results['dev-finder-path']),
    results.command,
  );
  if (!result.success) {
    exit(-1);
  }
}

@visibleForTesting
Future<OperationResult> emulator(
  String deviceName,
  DevFinder devFinder,
  ArgResults args,
) async {
  final Emulator emulator = Emulator(
    aemuPath: args['aemu'],
    fuchsiaImagePath: args['image'],
    fuchsiaSdkPath: args['sdk'],
    qemuKernelPath: args['qemu-kernel'],
    sshPath: args['ssh-path'],
    zbiPath: args['zbi'],
  );
  await emulator.prepareEnvironment();

  return emulator.start(
    headless: args['headless'],
    windowSize: args['window-size'],
  );
}

@visibleForTesting
Future<OperationResult> ssh(
  String deviceName,
  DevFinder devFinder,
  ArgResults args,
) async {
  const SshClient sshClient = SshClient();
  final String targetIp = await devFinder.getTargetAddress(deviceName);
  final String identityFile = args['identity-file'];
  if (args['interactive']) {
    return await sshClient.interactive(
      targetIp,
      identityFilePath: identityFile,
    );
  }
  final OperationResult result = await sshClient.runCommand(targetIp,
      identityFilePath: identityFile,
      command: args['command'].split(' '),
      timeoutMs:
          Duration(milliseconds: int.parse(args['timeout-seconds']) * 1000));
  stdout.writeln(
      '==================================== STDOUT ====================================');
  stdout.writeln(result.info);
  stderr.writeln(
      '==================================== STDERR ====================================');
  stderr.writeln(result.error);
  return result;
}

@visibleForTesting
Future<OperationResult> pave(
  String deviceName,
  DevFinder devFinder,
  ArgResults args,
) async {
  const ImagePaver paver = ImagePaver();
  const RetryOptions r = RetryOptions(
    maxDelay: Duration(seconds: 30),
    maxAttempts: 3,
  );
  return await r.retry(() async {
    final OperationResult result = await paver.pave(
      args['image'],
      deviceName,
      publicKeyPath: args['public-key'],
    );
    if (!result.success) {
      throw RetryException('Exit code different from 0', result);
    }
    return result;
  }, retryIf: (Exception e) => e is RetryException);
}

@visibleForTesting
Future<OperationResult> pm(
  String deviceName,
  DevFinder devFinder,
  ArgResults args,
) async {
  final PackageServer server = PackageServer(args['pm-path']);
  switch (args.command.name) {
    case 'serve':
      await server.serveRepo(args['repo']);
      await Future<void>.delayed(const Duration(seconds: 15));
      return await server.close();
    case 'newRepo':
      return await server.newRepo(args['repo']);
    case 'publishRepo':
      return await server.publishRepo(args['repo'], args['far']);
    default:
      throw ArgumentError('Command ${args.command.name} unknown.');
  }
}

@visibleForTesting
Future<OperationResult> pushPackages(
  String deviceName,
  DevFinder devFinder,
  ArgResults args,
) async {
  final PackageServer server = PackageServer(args['pm-path']);
  final String repoArchive = args['repoArchive'];
  final List<String> packages = args['packages'];
  final String identityFile = args['identity-file'];

  const FileSystem fs = LocalFileSystem();
  final String uuid = Uuid().v4();
  final Directory repo = fs.systemTempDirectory.childDirectory('repo_$uuid');
  const Tar tar = SystemTar();
  try {
    final String targetIp = await devFinder.getTargetAddress(deviceName);
    final AmberCtl amberCtl = AmberCtl(targetIp, identityFile);

    stdout.writeln('Untaring $repoArchive to ${repo.path}');
    repo.createSync(recursive: true);
    await tar.untar(repoArchive, repo.path);

    final String repositoryBase = path.join(repo.path, 'amber-files');
    stdout.writeln('Serving $repositoryBase to $targetIp');
    await server.serveRepo(repositoryBase, port: 0);
    await amberCtl.addSrc(server.serverPort);

    stdout.writeln('Pushing packages $packages to $targetIp');
    for (String packageName in packages) {
      stdout.writeln('Attempting to add package $packageName.');
      await amberCtl.addPackage(packageName);
    }

    return OperationResult.success(
        info: 'Successfully pushed $packages to $targetIp.');
  } finally {
    // We may not have created the repo if dev finder errored first.
    if (repo.existsSync()) {
      repo.deleteSync(recursive: true);
    }
    if (server.serving) {
      await server.close();
    }
  }
}

@visibleForTesting
Future<OperationResult> test(
  String deviceName,
  DevFinder devFinder,
  ArgResults args,
) async {
  const FileSystem fs = LocalFileSystem();
  final String identityFile = args['identity-file'];

  //final PackageServer server = PackageServer(args['pm-path']);
  PackageServer server;
  const SshClient ssh = SshClient();
  final List<String> farFiles = args['far'];
  final String target = args['target'];
  final String arguments = args['arguments'];
  Directory repo;
  if (args['packages-directory'] == null) {
    final String uuid = Uuid().v4();
    repo = fs.systemTempDirectory.childDirectory('repo_$uuid');
    server = PackageServer(args['pm-path']);
  } else {
    final String amberFilesPath = path.join(
      args['packages-directory'],
      'amber-files',
    );
    final String pmPath = path.join(
      args['packages-directory'],
      'pm',
    );
    repo = fs.directory(amberFilesPath);
    server = PackageServer(pmPath);
  }

  try {
    final String targetIp = await devFinder.getTargetAddress(deviceName);
    final AmberCtl amberCtl = AmberCtl(targetIp, identityFile);
    OperationResult result;
    stdout.writeln('Using ${repo.path} as repo to serve to $targetIp...');
    if (!repo.existsSync()) {
      repo.createSync(recursive: true);
      result = await server.newRepo(repo.path);
      if (!result.success) {
        stderr.writeln('Failed to create repo at $repo.');
        return result;
      }
    }
    await server.serveRepo(repo.path, port: 0);
    await amberCtl.addSrc(server.serverPort);

    for (String farFile in farFiles) {
      result = await server.publishRepo(repo.path, farFile);
      if (!result.success) {
        stderr.writeln('Failed to publish repo at $repo with $farFiles.');
        stderr.writeln(result.error);
        return result;
      }
      final RegExp r = RegExp(r'\-0.far|.far');
      final String packageName = fs.file(farFile).basename.replaceFirst(r, '');
      await amberCtl.addPackage(packageName);
    }

    final OperationResult testResult = await ssh.runCommand(
      targetIp,
      identityFilePath: identityFile,
      command: <String>[
        'run',
        'fuchsia-pkg://fuchsia.com/$target#meta/$target.cmx',
        arguments
      ],
      timeoutMs:
          Duration(milliseconds: int.parse(args['timeout-seconds']) * 1000),
    );
    stdout.writeln('Test results (passed: ${testResult.success}):');
    if (result.info != null) {
      stdout.writeln(testResult.info);
    }
    if (result.error != null) {
      stderr.writeln(testResult.error);
    }
    return testResult;
  } finally {
    // We may not have created the repo if dev finder errored first.
    if (repo.existsSync() && args['packages-directory'] != null) {
      repo.deleteSync(recursive: true);
    }
    if (server.serving) {
      await server.close();
    }
  }
}

/// The exception thrown when an operation needs a retry.
class RetryException implements Exception {
  /// Creates a new [RetryException] using the specified [cause] and [result]
  /// to force a retry.
  const RetryException(this.cause, this.result);

  /// The user-facing message to display.
  final String cause;

  /// Contains the result of the executed target command.
  final OperationResult result;

  @override
  String toString() =>
      '$runtimeType, cause: "$cause", underlying exception: $result.';
}
