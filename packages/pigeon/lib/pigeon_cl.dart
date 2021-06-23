// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:pigeon/pigeon_lib.dart';

/// This is the main entrypoint for the command-line tool.  [args] are the
/// commmand line arguments and there is an optional [packageConfig] to
/// accomodate users that want to integrate pigeon with other build systems.
Future<int> runCommandLine(List<String> args, {Uri? packageConfig}) async {
  return Pigeon.run(args);
}
