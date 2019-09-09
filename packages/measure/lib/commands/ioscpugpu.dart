// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:measure/commands/ioscpugpu/new.dart';
import 'package:measure/commands/ioscpugpu/parse.dart';

class IosCpuGpu extends Command<void> {
  IosCpuGpu() {
    addSubcommand(IosCpuGpuNew());
    addSubcommand(IosCpuGpuParse());
  }

  @override
  String get name => 'ioscpugpu';
  @override
  String get description => 'Measure the iOS CPU/GPU percentage.';
}
