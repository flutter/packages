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
  final Directory tempDir = Directory.systemTemp.createTempSync();

  String importLine = '';
  if (opts.input != null) {
    final String rawInputPath = opts.input;
    final String absInputPath = File(rawInputPath).absolute.path;
    final String relInputPath = path.relative(absInputPath, from: tempDir.path);
    importLine = 'import \'$relInputPath\';\n';
  }
  final String code = """$importLine
import 'dart:io';
import 'dart:isolate';
import 'package:pigeon/pigeon_lib.dart';

void main(List<String> args, SendPort sendPort) async {
  sendPort.send(await Pigeon.run(args));
}
""";

  final File tempFile = File(path.join(tempDir.path, '_pigeon_temp_.dart'));
  await tempFile.writeAsString(code);
  final ReceivePort receivePort = ReceivePort();
  Isolate.spawnUri(
    // Using Uri.file instead of Uri.parse in order to parse backslashes as
    // path segment separator with Windows semantics.
    Uri.file(tempFile.path),
    args,
    receivePort.sendPort,
  );

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
