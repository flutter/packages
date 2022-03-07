import 'dart:io';

import 'package:vector_graphics_compiler/src/optimizers.dart';

import 'src/svg/theme.dart';
import 'src/svg/parser.dart';
import 'src/vector_instructions.dart';

export 'src/geometry/basic_types.dart';
export 'src/geometry/matrix.dart';
export 'src/geometry/path.dart';
export 'src/geometry/vertices.dart';
export 'src/optimizers.dart';
export 'src/paint.dart';
export 'src/svg/theme.dart';
export 'src/vector_instructions.dart';

Future<VectorInstructions> parse(
  String xml, {
  String key = '',
  bool warningsAsErrors = false,
  SvgTheme theme = const SvgTheme(),
}) async {
  final SvgParser parser = SvgParser(xml, theme, key, warningsAsErrors);
  return const PaintDeduplicator().optimize(await parser.parse());
}

void main(List<String> args) async {
  final String xml = File(args.first).readAsStringSync();
  final VectorInstructions instructions = await parse(xml, key: args.first);
  // TODO: serialize instructions
  print(instructions.commands.length);
}
