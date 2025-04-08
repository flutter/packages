// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show exit;

import 'package:pigeon/src/pigeon_cl.dart';

Future<void> main(List<String> args) async {
  exit(await runCommandLine(args));
}
