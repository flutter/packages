import 'dart:io';

import 'package:args/args.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:fuchsia_ctl/fuchsia_ctl.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

typedef AsyncInt = Future<int> Function(String, DevFinder, ArgResults);

const Map<String, AsyncInt> commands = <String, AsyncInt>{
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
        defaultsTo: './dev_finder',
        help: 'The path to the dev_finder executable.');
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
        defaultsTo: '.ssh/pkey', help: 'The key to use when SSHing.');
  parser.addCommand('pave')
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

  parser.addCommand('test')
    ..addOption('pm-path',
        defaultsTo: './pm', help: 'The path to the pm executable.')
    ..addOption('identity-file',
        defaultsTo: '.ssh/pkey', help: 'The key to use when SSHing.')
    ..addOption('target',
        abbr: 't', help: 'The name of the target to pass to runtests.')
    ..addMultiOption('far',
        abbr: 'f', help: 'The .far files to include for the test.');

  final ArgResults results = parser.parse(args);

  if (results.command == null) {
    stderr.writeln('Unknown command, expeced one of: ${parser.commands.keys}');
    stderr.writeln(parser.usage);
    return;
  }
  final AsyncInt command = commands[results.command.name];
  if (command == null) {
    stderr.writeln('Unkown command ${results.command.name}.');
    stderr.writeln(parser.usage);
    return;
  }
  final int returnCode = await command(
    results['device-name'],
    DevFinder(results['dev-finder-path']),
    results.command,
  );
  exit(returnCode);
}

@visibleForTesting
Future<int> ssh(
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
  final ProcessResult result = await sshClient.runCommand(
    targetIp,
    identityFilePath: identityFile,
    command: args['command'].split(' '),
  );
  stdout.writeln(
      '==================================== STDOUT ====================================');
  stdout.writeln(result.stdout);
  stderr.writeln(
      '==================================== STDERR ====================================');
  stderr.writeln(result.stderr);
  stdout.writeln(
      '==================================== EXCODE ====================================');
  stdout.writeln(result.exitCode);
  return result.exitCode;
}

@visibleForTesting
Future<int> pave(
  String deviceName,
  DevFinder devFinder,
  ArgResults args,
) async {
  const ImagePaver paver = ImagePaver();
  final ProcessResult result = await paver.pave(args['image'], deviceName);
  return result.exitCode;
}

@visibleForTesting
Future<int> pm(
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
      final ProcessResult result = await server.newRepo(args['repo']);
      return result.exitCode;
    case 'publishRepo':
      final ProcessResult result =
          await server.publishRepo(args['repo'], args['far']);
      return result.exitCode;
    default:
      throw ArgumentError('Command ${args.command.name} unknown.');
  }
}

@visibleForTesting
Future<int> test(
  String deviceName,
  DevFinder devFinder,
  ArgResults args,
) async {
  int checkProcessResult(ProcessResult result, String failureMessage) {
    stdout.writeln(result.stdout);
    stderr.writeln(result.stderr);
    if (result.exitCode != 0) {
      stderr.writeln(failureMessage);
    }
    return result.exitCode;
  }

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
    int result = checkProcessResult(
      await server.newRepo(repo.path),
      'Failed to create repo at $repo.',
    );
    if (result != 0) {
      return result;
    }

    await server.serveRepo(repo.path, port: 54321);

    result = checkProcessResult(
      await ssh.runCommand(
        targetIp,
        identityFilePath: identityFile,
        command: <String>[
          'amberctl',
          'add_src',
          '-f', 'http://$localIp:${server.serverPort}/config.json', //
          '-n', uuid,
        ],
      ),
      'amberctl add_src failed, aborting.',
    );
    if (result != 0) {
      return result;
    }

    for (String farFile in farFiles) {
      result = checkProcessResult(
        await server.publishRepo(repo.path, farFile),
        'Failed to publish repo at $repo with $farFiles.',
      );
      if (result != 0) {
        return result;
      }
      final String packageName =
          fs.file(farFile).basename.replaceFirst('-0.far', '');
      stdout.writeln('Adding $packageName...');
      result = checkProcessResult(
        await ssh.runCommand(
          targetIp,
          identityFilePath: identityFile,
          command: <String>[
            'amberctl',
            'get_up',
            '-n', packageName, //
          ],
        ),
        'amberctl get_up failed, aborting.',
      );
      if (result != 0) {
        return result;
      }
    }

    stdout.writeln('Test results:');
    return checkProcessResult(
      await ssh.runCommand(
        targetIp,
        identityFilePath: identityFile,
        command: <String>['pkgfs/packages/$target/0/bin/app'],
      ),
      'Test failed, aborting.',
    );
  } finally {
    repo.deleteSync(recursive: true);
    await server.close();
  }
}
