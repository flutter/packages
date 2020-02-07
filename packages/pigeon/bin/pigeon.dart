// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'package:pigeon/pigeon_lib.dart';

Future<void> main(List<String> args) async {
  final PigeonOptions opts = Pigeon.parseArgs(args);
  assert(opts.input != null);
  final String importLine =
      (opts.input != null) ? 'import \'${opts.input}\';\n' : '';
  final String code = """$importLine
import 'dart:io';
import 'package:pigeon/pigeon_lib.dart';

void main(List<String> args) async {
  exit(await Pigeon.run(args));
}
""";
  // TODO(aaclarke): Start using a system temp file.
  const String tempFilename = '_pigeon_temp_.dart';
  final File tempFile = await File(tempFilename).writeAsString(code);
  final Process process =
      await Process.start('dart', <String>[tempFilename] + args);
  process.stdout.transform(utf8.decoder).listen((String data) => print(data));
  process.stderr.transform(utf8.decoder).listen((String data) => print(data));
  final int exitCode = await process.exitCode;
  tempFile.deleteSync();
  exit(exitCode);
}
