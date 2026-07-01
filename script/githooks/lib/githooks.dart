// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';

import 'src/pre_commit_command.dart';

/// Runs the githooks command line utility.
Future<int> run(List<String> args) async {
  final runner = CommandRunner<bool>('githooks', 'Git hooks for flutter/packages')
    ..addCommand(PreCommitCommand());

  final bool success = await runner.run(args) ?? false;
  return success ? 0 : 1;
}
