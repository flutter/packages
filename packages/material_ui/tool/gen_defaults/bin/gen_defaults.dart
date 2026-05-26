// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// ## Usage
//
// Run from the root of flutter/packages:
//
// ```
// dart packages/material_ui/tool/gen_defaults/bin/gen_defaults.dart [-v]
// ```

import 'package:args/args.dart';

// TODO(elliette): Import template files.
// import '../templates/x_template.dart';

Future<void> main(List<String> args) async {
  // Parse arguments
  final parser = ArgParser();
  parser.addFlag('verbose', abbr: 'v', help: 'Enable verbose output', negatable: false);
  final ArgResults argResults = parser.parse(args);
  // TODO(elliette): Add token logger when verbose flag is used.
  // ignore: unused_local_variable
  final verbose = argResults['verbose'] as bool;
  // TODO(elliette): Invoke template generators.
  // const XTemplate().generateFile(verbose: verbose);
}
