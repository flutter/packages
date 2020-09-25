// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as path;
import 'package:pigeon/pigeon_lib.dart';

Future<void> main(List<String> args) async {
  final PigeonOptions opts = Pigeon.parseArgs(args);
  assert(opts.input != null);
  final String rawInputPath = opts.input;
  final Directory tempDir = Directory.systemTemp.createTempSync();
  final String absInputPath = File(rawInputPath).absolute.path;
  final String relInputPath = path.relative(absInputPath, from: tempDir.path);

  final String importLine =
      (opts.input != null) ? 'import \'$relInputPath\';\n' : '';
  final String code = """$importLine
import 'dart:io';
import 'dart:isolate';
import 'package:pigeon/pigeon_lib.dart';

void main(List<String> args, SendPort sendPort) async {
  sendPort.send(await Pigeon.run(args));
}
""";
  final String tempFilename = path.join(tempDir.path, '_pigeon_temp_.dart');
  await File(tempFilename).writeAsString(code);
  final ReceivePort receivePort = ReceivePort();
  Isolate.spawnUri(Uri.parse(tempFilename), args, receivePort.sendPort);
  final Completer<int> completer = Completer<int>();
  receivePort.listen((dynamic message) {
    try {
      // ignore: avoid_as
      completer.complete(message as int);
    } catch (exception) {
      completer.completeError(exception);
    }
  });
  final int exitCode = await completer.future;
  tempDir.deleteSync(recursive: true);
  exit(exitCode);
}
