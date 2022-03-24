import 'dart:io';
import 'dart:typed_data';

import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

Future<void> main(List<String> args) async {
  if (args.length != 2) {
    print('Usage: vector_graphics_compiler input.svg output.bin');
    exit(1);
  }
  final String xml = File(args[0]).readAsStringSync();
  final File outputFile = File(args[1]);
  final Uint8List bytes = await encodeSvg(xml, args[0]);

  outputFile.writeAsBytesSync(bytes);
}
