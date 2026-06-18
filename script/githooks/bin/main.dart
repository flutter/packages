import 'dart:io';
import 'package:args/command_runner.dart';
import '../lib/src/pre_commit_command.dart';

void main(List<String> args) async {
  final runner = CommandRunner('githooks', 'Git hooks for flutter/packages')
    ..addCommand(PreCommitCommand());

  try {
    await runner.run(args);
  } catch (e) {
    print(e);
    exit(1);
  }
}
