import 'dart:typed_data';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'src/geometry/vertices.dart';
import 'src/geometry/path.dart';
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
  return await parser.parse();
}

/// Encode an SVG [input] string into a vector_graphics binary format.
Future<Uint8List> encodeSVG(String input, String filename) async {
  const VectorGraphicsCodec codec = VectorGraphicsCodec();
  final VectorInstructions instructions = await parse(input, key: filename);
  final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();

  codec.writeSize(buffer, instructions.width, instructions.height);

  final Map<int, int> fillIds = <int, int>{};
  final Map<int, int> strokeIds = <int, int>{};
  final Map<Shader, int> shaderIds = <Shader, int>{};

  for (final Paint paint in instructions.paints) {
    final Shader? shader = paint.fill?.shader;
    if (shader == null) {
      continue;
    }
    int shaderId;
    if (shader is LinearGradient) {
      shaderId = codec.writeLinearGradient(
        buffer,
        fromX: shader.from.x,
        fromY: shader.from.y,
        toX: shader.to.x,
        toY: shader.to.y,
        colors: Int32List.fromList(
            <int>[for (Color color in shader.colors) color.value]),
        offsets: shader.offsets != null
            ? Float32List.fromList(shader.offsets!)
            : null,
        tileMode: shader.tileMode.index,
      );
    } else if (shader is RadialGradient) {
      shaderId = codec.writeRadialGradient(
        buffer,
        centerX: shader.center.x,
        centerY: shader.center.y,
        radius: shader.radius,
        focalX: shader.focalPoint?.x,
        focalY: shader.focalPoint?.y,
        colors: Int32List.fromList(
            <int>[for (Color color in shader.colors) color.value]),
        offsets: shader.offsets != null
            ? Float32List.fromList(shader.offsets!)
            : null,
        tileMode: shader.tileMode.index,
      );
    } else {
      assert(false);
      throw StateError('illegal shader type: $shader');
    }
    shaderIds[shader] = shaderId;
  }

  int nextPaintId = 0;
  for (final Paint paint in instructions.paints) {
    final Fill? fill = paint.fill;
    final Stroke? stroke = paint.stroke;

    if (fill != null) {
      final int? shaderId = shaderIds[fill.shader];
      final int fillId = codec.writeFill(
        buffer,
        fill.color?.value ?? 0,
        paint.blendMode?.index ?? 0,
        shaderId,
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
        codec.writeDrawVertices(
            buffer, vertices.vertices, vertices.indices, fillId);
        break;
      case DrawCommandType.saveLayer:
        codec.writeSaveLayer(buffer, fillIds[command.paintId]!);
        break;
      case DrawCommandType.restore:
        codec.writeRestoreLayer(buffer);
        break;
      case DrawCommandType.clip:
        codec.writeClipPath(buffer, pathIds[command.objectId]!);
        break;
    }
  }
  return buffer.done().buffer.asUint8List();
}
