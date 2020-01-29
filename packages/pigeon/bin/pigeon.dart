import 'dart:convert';
import 'dart:io';
import 'package:pigeon/pigeon_lib.dart';

Future<void> main(List<String> args) async {
  final DartleOptions opts = Dartle.parseArgs(args);
  assert(opts.input != null);
  String code = '';
  if (opts.input != null) {
    code = 'import \'${opts.input}\';\n';
  }
  code += """
import 'dart:io';
import 'package:pigeon/pigeon_lib.dart';

void main(List<String> args) async {
  exit(await Dartle.run(args));
}
""";
  const String tempFilename = '_pigeon_temp_.dart';
  final File tempFile = await File(tempFilename).writeAsString(code);
  final Process process = await Process.start('dart', [tempFilename] + args);
  process.stdout.transform(utf8.decoder).listen((data) {
    print(data);
  });
  process.stderr.transform(utf8.decoder).listen((data) {
    print(data);
  });
  final int exitCode = await process.exitCode;
  tempFile.deleteSync();
  exit(exitCode);
}
