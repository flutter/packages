// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:flutter_migrate/src/base/command.dart';

export 'package:test/test.dart' hide isInstanceOf, test;

CommandRunner<void> createTestCommandRunner([MigrateCommand? command]) {
  final CommandRunner<void> runner = TestCommandRunner();
  if (command != null) {
    runner.addCommand(command);
  }
  return runner;
}

class TestCommandRunner extends CommandRunner<void> {
  TestCommandRunner()
      : super(
          'flutter',
          'Manage your Flutter app development.\n'
              '\n'
              'Common commands:\n'
              '\n'
              '  flutter create <output directory>\n'
              '    Create a new Flutter project in the specified directory.\n'
              '\n'
              '  flutter run [options]\n'
              '    Run your Flutter application on an attached device or in an emulator.',
        );
}
