// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:fuchsia_ctl/fuchsia_ctl.dart';
import 'package:fuchsia_ctl/src/operation_result.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

typedef AsyncResult = Future<OperationResult> Function(String, DevFinder, ArgResults);

const Map<String, AsyncResult> commands = <String, AsyncResult>{
  'pave': pave,
  'pm': pm,
  'ssh': ssh,
  'test': test,
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
        defaultsTo: './dev_finder', help: 'The path to the dev_finder executable.');
  parser.addCommand('ssh')
    ..addFlag('interactive',
        abbr: 'i',
        help: 'Whether to ssh in interactive mode. '
            'If --comand is specified, this is ignored.')
    ..addOption('command',
        abbr: 'c',
        help: 'The command to run on the device. '
            'If specified, --interactive is ignored.')
    ..addOption('identity-file', defaultsTo: '.ssh/pkey', help: 'The key to use when SSHing.');
  parser.addCommand('pave')
    ..addOption('image', abbr: 'i', help: 'The system image tgz to unpack and pave.');

  final ArgParser pmSubCommand = parser.addCommand('pm')
    ..addOption('pm-path', defaultsTo: './pm', help: 'The path to the pm executable.')
    ..addOption('repo',
        abbr: 'r',
        help: 'The location of the repository folder to create, '
            'publish, or serve.')
    ..addCommand('serve')
    ..addCommand('newRepo');
  pmSubCommand
      .addCommand('publishRepo')
      .addMultiOption('far', abbr: 'f', help: 'The .far files to publish.');

  parser.addCommand('test')
    ..addOption('pm-path', defaultsTo: './pm', help: 'The path to the pm executable.')
    ..addOption('identity-file', defaultsTo: '.ssh/pkey', help: 'The key to use when SSHing.')
    ..addOption('target', abbr: 't', help: 'The name of the target to pass to runtests.')
    ..addMultiOption('far', abbr: 'f', help: 'The .far files to include for the test.');

  final ArgResults results = parser.parse(args);

  if (results.command == null) {
    stderr.writeln('Unknown command, expeced one of: ${parser.commands.keys}');
    stderr.writeln(parser.usage);
    return;
  }
  final AsyncResult command = commands[results.command.name];
  if (command == null) {
    stderr.writeln('Unkown command ${results.command.name}.');
    stderr.writeln(parser.usage);
    return;
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
  final OperationResult result = await sshClient.runCommand(
    targetIp,
    identityFilePath: identityFile,
    command: args['command'].split(' '),
  );
  stdout
      .writeln('==================================== STDOUT ====================================');
  stdout.writeln(result.info);
  stderr
      .writeln('==================================== STDERR ====================================');
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
  return await paver.pave(args['image'], deviceName);
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
      await Future<void>.delayed(Duration(seconds: 15));
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
Future<OperationResult> test(
  String deviceName,
  DevFinder devFinder,
  ArgResults args,
) async {
  const FileSystem fs = LocalFileSystem();
  final String uuid = Uuid().v4();
  final String identityFile = args['identity-file'];
  final Directory repo = fs.systemTempDirectory.childDirectory('repo_$uuid');
  final PackageServer server = PackageServer(args['pm-path']);
  const SshClient ssh = SshClient();
  final List<String> farFiles = args['far'];
  final String target = args['target'];
  try {
    final String localIp = await devFinder.getLocalAddress(deviceName);
    final String targetIp = await devFinder.getTargetAddress(deviceName);
    stdout.writeln('Using ${repo.path} as repo to serve to $targetIp...');
    repo.createSync(recursive: true);
    OperationResult result = await server.newRepo(repo.path);

    if (!result.success) {
      stderr.writeln('Failed to create repo at $repo.');
      return result;
    }

    await server.serveRepo(repo.path, port: 54321);

    result = await ssh.runCommand(
      targetIp,
      identityFilePath: identityFile,
      command: <String>[
        'amberctl',
        'add_src',
        '-f', 'http://$localIp:${server.serverPort}/config.json', //
        '-n', uuid,
      ],
    );
    if (!result.success) {
      stderr.writeln('amberctl add_src failed, aborting.');
      return result;
    }

    for (String farFile in farFiles) {
      result = await server.publishRepo(repo.path, farFile);
      if (!result.success) {
        stderr.writeln('Failed to publish repo at $repo with $farFiles.');
        return result;
      }
      final String packageName = fs.file(farFile).basename.replaceFirst('-0.far', '');
      stdout.writeln('Adding $packageName...');
      result = await ssh.runCommand(
        targetIp,
        identityFilePath: identityFile,
        command: <String>[
          'amberctl',
          'get_up',
          '-n', packageName, //
        ],
      );
      if (!result.success) {
        stderr.writeln('amberctl get_up failed, aborting.');
        return result;
      }
    }

    stdout.writeln('Test results:');
    return await ssh.runCommand(
      targetIp,
      identityFilePath: identityFile,
      command: <String>['pkgfs/packages/$target/0/bin/app'],
    );
  } finally {
    repo.deleteSync(recursive: true);
    await server.close();
  }
}
