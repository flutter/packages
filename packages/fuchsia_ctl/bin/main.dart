import 'dart:io';

import 'package:args/args.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:fuchsia_ctl/fuchsia_ctl.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

typedef AsyncVoid = Future<void> Function(String, DevFinder, ArgResults);

const Map<String, AsyncVoid> commands = <String, AsyncVoid>{
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
    ..addMultiOption('far',
        abbr: 'f', help: 'The .far files to include for the test.');

  final ArgResults results = parser.parse(args);

  if (results.command == null) {
    stderr.writeln('Unknown command, expeced one of: ${parser.commands.keys}');
    stderr.writeln(parser.usage);
    return;
  }
  final AsyncVoid command = commands[results.command.name];
  if (command == null) {
    stderr.writeln('Unkown command ${results.command.name}.');
    stderr.writeln(parser.usage);
    return;
  }
  await command(
    results['device-name'],
    DevFinder(results['dev-finder-path']),
    results.command,
  );
}

@visibleForTesting
Future<void> ssh(
  String deviceName,
  DevFinder devFinder,
  ArgResults args,
) async {
  const SshClient sshClient = SshClient();
  final String targetIp = await devFinder.getTargetAddress(deviceName);
  final String identityFile = args['identity-file'];
  if (args['interactive']) {
    final int exitCode = await sshClient.interactive(
      targetIp,
      identityFilePath: identityFile,
    );
    return exit(exitCode);
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
}

@visibleForTesting
Future<void> pave(
  String deviceName,
  DevFinder devFinder,
  ArgResults args,
) async {
  const ImagePaver paver = ImagePaver();
  await paver.pave(args['image'], deviceName);
}

@visibleForTesting
Future<void> pm(
  String deviceName,
  DevFinder devFinder,
  ArgResults args,
) async {
  final PackageServer server = PackageServer(args['pm-path']);
  switch (args.command.name) {
    case 'serve':
      await server.serveRepo(
        args['repo'],
        0,
      );
      await Future<void>.delayed(Duration(seconds: 15));
      await server.close();
      return;
    case 'newRepo':
      await server.newRepo(args['repo']);
      return;
    case 'publishRepo':
      await server.publishRepo(args['repo'], args['far']);
      return;
    default:
      throw ArgumentError('Command ${args.command.name} unknown.');
  }
}

@visibleForTesting
Future<void> test(
  String deviceName,
  DevFinder devFinder,
  ArgResults args,
) async {
  const FileSystem fs = LocalFileSystem();
  final String uuid = Uuid().v4();
  final String identityFile = args['identity-file-path'];
  final Directory repo = fs.systemTempDirectory.childDirectory('repo_$uuid');
  final PackageServer server = PackageServer(args['pm-path']);
  const SshClient ssh = SshClient();
  try {
    final String localIp = await devFinder.getTargetAddress(deviceName);
    final String targetIp = await devFinder.getTargetAddress(deviceName);
    stdout.writeln('Using ${repo.path} as repo to serve to $targetIp...');
    repo.createSync(recursive: true);
    await server.newRepo(repo.path);
    await server.publishRepo(repo.path, args['far']);
    await server.serveRepo(repo.path, port: 54321);
    await ssh.runCommand(
      targetIp,
      identityFilePath: identityFile,
      command: <String>[
        'amber_ctl',
        'add_src',
        '-x',
        '-f', 'http://$localIp:${server.serverPort}/config.json', //
        '-n', uuid,
      ],
    );
    await ssh
        .runCommand(targetIp, identityFilePath: identityFile, command: <String>[
      'amber_ctl',
      'get_up',
      '-n', 'fpac'
    ]);
  } finally {
    repo.deleteSync(recursive: true);
    await server.close();
  }
}
