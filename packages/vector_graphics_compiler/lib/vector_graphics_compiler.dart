import 'dart:typed_data';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'src/geometry/vertices.dart';
import 'src/geometry/path.dart';
import 'src/optimizers.dart';
import 'src/paint.dart';
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

/// Parses an SVG string into a [VectorInstructions] object.
Future<VectorInstructions> parse(
  String xml, {
  String key = '',
  bool warningsAsErrors = false,
  SvgTheme theme = const SvgTheme(),
}) async {
  final SvgParser parser = SvgParser(xml, theme, key, warningsAsErrors);
  return const PaintDeduplicator().optimize(await parser.parse());
}

/// Encode an SVG [input] string into a vector_graphics binary format.
Future<Uint8List> encodeSVG(String input, String filename) async {
  const VectorGraphicsCodec codec = VectorGraphicsCodec();
  final VectorInstructions instructions = await parse(input, key: filename);
  final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();

  final Map<int, int> fillIds = <int, int>{};
  final Map<int, int> strokeIds = <int, int>{};

  int nextPaintId = 0;
  for (final Paint paint in instructions.paints) {
    final Fill? fill = paint.fill;
    final Stroke? stroke = paint.stroke;

    if (fill != null) {
      final int fillId = codec.writeFill(
        buffer,
        fill.color?.value ?? 0,
        paint.blendMode?.index ?? 0,
      );
      fillIds[nextPaintId] = fillId;
    }
    if (stroke != null) {
      final int strokeId = codec.writeStroke(
        buffer,
        stroke.color?.value ?? 0,
        stroke.cap?.index ?? 0,
        stroke.join?.index ?? 0,
        paint.blendMode?.index ?? 0,
        stroke.miterLimit ?? 4,
        stroke.width ?? 1,
      );
      strokeIds[nextPaintId] = strokeId;
    }
    nextPaintId += 1;
  }

  final Map<int, int> pathIds = <int, int>{};
  int nextPathId = 0;
  for (final Path path in instructions.paths) {
    final int id = codec.writeStartPath(buffer, path.fillType.index);
    for (final PathCommand command in path.commands) {
      switch (command.type) {
        case PathCommandType.move:
          final MoveToCommand move = command as MoveToCommand;
          codec.writeMoveTo(buffer, move.x, move.y);
          break;
        case PathCommandType.line:
          final LineToCommand line = command as LineToCommand;
          codec.writeLineTo(buffer, line.x, line.y);
          break;
        case PathCommandType.cubic:
          final CubicToCommand cubic = command as CubicToCommand;
          codec.writeCubicTo(buffer, cubic.x1, cubic.y1, cubic.x2, cubic.y2,
              cubic.x3, cubic.y3);
          break;
        case PathCommandType.close:
          codec.writeClose(buffer);
          break;
      }
    }
    codec.writeFinishPath(buffer);
    pathIds[nextPathId] = id;
    nextPathId += 1;
  }

  for (final DrawCommand command in instructions.commands) {
    switch (command.type) {
      case DrawCommandType.path:
        if (fillIds.containsKey(command.paintId)) {
          codec.writeDrawPath(
            buffer,
            pathIds[command.objectId]!,
            fillIds[command.paintId]!,
          );
        }
        if (strokeIds.containsKey(command.paintId)) {
          codec.writeDrawPath(
            buffer,
            pathIds[command.objectId]!,
            strokeIds[command.paintId]!,
          );
        }
        break;
      case DrawCommandType.vertices:
        final IndexedVertices vertices =
            instructions.vertices[command.objectId];
        final int fillId = fillIds[command.paintId]!;
        assert(!strokeIds.containsKey(command.paintId));
        codec.writeDrawVertices(
            buffer, vertices.vertices, vertices.indices, fillId);
        break;
    }
  }
  return buffer.done().buffer.asUint8List();
}
