// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';

import 'package:gauge/commands/ioscpugpu.dart';

void main(List<String> args) {
  final CommandRunner<void> runner = CommandRunner<void>(
    'gauge',
    'Tools for gauging/measuring some performance metrics.',
  );
  runner.addCommand(IosCpuGpu());
  runner.run(args);
}
