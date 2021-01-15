// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.2

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;
import 'package:pigeon/pigeon_lib.dart';

/// This creates a relative path from `from` to `input`, the output being a
/// posix path on all platforms.
String _posixRelative(String input, {String from}) {
  final path.Context context = path.Context(style: path.Style.posix);
  final String rawInputPath = input;
  final String absInputPath = File(rawInputPath).absolute.path;
  // By going through URI's we can make sure paths can go between drives in
  // Windows.
  final Uri inputUri = path.toUri(absInputPath);
  final String posixAbsInputPath = context.fromUri(inputUri);
  final Uri tempUri = path.toUri(from);
  final String posixTempPath = context.fromUri(tempUri);
  return context.relative(posixAbsInputPath, from: posixTempPath);
}

/// aa_bb_cc -> AaBbCc
String _underLineToHump(String str) {
  return str
      .split('_')
      .map((String e) => e.replaceRange(0, 1, e[0].toUpperCase()))
      .join();
}

/// AaBbCc -> aa_bb_cc
String _humpToUnderLine(String str) {
  return str.replaceAllMapped(RegExp(r'(^[A-Z])|([A-Z])'), (match) {
    if (match[2] != null) {
      return '_${match[2]?.toLowerCase()}';
    } else {
      return match[1]?.toLowerCase() ?? '';
    }
  });
}

Future<void> main(List<String> args) async {
  final PigeonOptions opts = Pigeon.parseArgs(args);
  final Directory tempDir = Directory.systemTemp.createTempSync(
    'flutter_pigeon.',
  );
  if (opts.isDir) {
    final Directory inputDir = Directory(opts.inputDir);
    if (!inputDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
      exit(exitCode);
    }

    final List<FileSystemEntity> list = inputDir.listSync(recursive: true);
    final List<String> inputDirs = path.split(opts.inputDir);
    for (int i = 0; i < list.length; i++) {
      final FileSystemEntity element = list[i];
      if (element is File) {
        final String input = element.path;
        final List<String> fileParents = path.split(input);
        final String fileName = path.basenameWithoutExtension(input);
        final String outName = '${fileName}_${opts.suffit}';
        final String humpName = _underLineToHump(outName);
        opts.input = input;

        final List<String> middle =
            fileParents.sublist(inputDirs.length, fileParents.length - 1);
        final List<String> javaPackage = middle.isNotEmpty
            ? [
                '--java_package',
                '${opts.javaOptions.package}.${middle.join('.')}',
              ]
            : [
                '--java_package',
                opts.javaOptions.package,
              ];

        final List<String> objcPrefix = opts.objcOptions.prefix != null
            ? [
                '--objc_prefix',
                opts.objcOptions.prefix,
              ]
            : List<String>.empty();

        final List<String> fileArgs = [
          '--input',
          input,
          '--dart_out',
          path.join(
            opts.dartOutDir.replaceAll('/', path.separator),
            middle.join(path.separator),
            '$outName.dart',
          ),
          '--java_out',
          path.join(
            opts.javaOutDir.replaceAll('/', path.separator),
            opts.javaOptions.package?.replaceAll('.', path.separator) ?? '',
            middle.join(path.separator),
            '$humpName.java',
          ),
          '--objc_header_out',
          path.join(
            opts.objcOutDir.replaceAll('/', path.separator),
            middle.join(path.separator),
            '$humpName.h',
          ),
          '--objc_source_out',
          path.join(
            opts.objcOutDir.replaceAll('/', path.separator),
            middle.join(path.separator),
            '$humpName.m',
          ),
        ]
          ..addAll(javaPackage)
          ..addAll(objcPrefix);

        print('generate file $input');
        print('generate args $fileArgs');
        final int code = await _genFile(fileArgs, opts, tempDir);
        print('generate resule $code $input');
        print('============================');
      }
    }
  } else {
    await _genFile(args, opts, tempDir);
  }
  tempDir.deleteSync(recursive: true);
  exit(exitCode);
}

Future<int> _genFile(
    List<String> args, PigeonOptions opts, Directory tempDir) async {
  String importLine = '';
  if (opts.input != null) {
    final String relInputPath = _posixRelative(opts.input, from: tempDir.path);
    importLine = 'import \'$relInputPath\';\n';
  }
  final String code = """// @dart = 2.2
$importLine
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
  return exitCode;
}
