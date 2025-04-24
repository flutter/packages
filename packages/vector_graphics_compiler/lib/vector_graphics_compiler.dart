// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'src/geometry/image.dart';
import 'src/geometry/matrix.dart';
import 'src/geometry/path.dart';
import 'src/geometry/pattern.dart';
import 'src/geometry/vertices.dart';
import 'src/paint.dart';
import 'src/svg/color_mapper.dart';
import 'src/svg/parser.dart';
import 'src/svg/theme.dart';
import 'src/vector_instructions.dart';

export 'src/_initialize_path_ops_io.dart'
    if (dart.library.js_interop) 'src/_initialize_path_ops_web.dart';
export 'src/_initialize_tessellator_io.dart'
    if (dart.library.js_interop) 'src/_initialize_tessellator_web.dart';
export 'src/geometry/basic_types.dart';
export 'src/geometry/matrix.dart';
export 'src/geometry/path.dart';
export 'src/geometry/vertices.dart';
export 'src/paint.dart';
export 'src/svg/color_mapper.dart';
export 'src/svg/path_ops.dart' show initializeLibPathOps;
export 'src/svg/resolver.dart';
export 'src/svg/tessellator.dart' show initializeLibTesselator;
export 'src/svg/theme.dart';
export 'src/vector_instructions.dart';

/// Parses an SVG string into a [VectorInstructions] object, with all optional
/// optimizers disabled.
VectorInstructions parseWithoutOptimizers(
  String xml, {
  String key = '',
  bool warningsAsErrors = false,
  SvgTheme theme = const SvgTheme(),
  ColorMapper? colorMapper,
}) {
  return parse(
    xml,
    key: key,
    warningsAsErrors: warningsAsErrors,
    theme: theme,
    enableClippingOptimizer: false,
    enableMaskingOptimizer: false,
    enableOverdrawOptimizer: false,
    colorMapper: colorMapper,
  );
}

/// Parses an SVG string into a [VectorInstructions] object.
VectorInstructions parse(
  String xml, {
  String key = '',
  bool warningsAsErrors = false,
  SvgTheme theme = const SvgTheme(),
  bool enableMaskingOptimizer = true,
  bool enableClippingOptimizer = true,
  bool enableOverdrawOptimizer = true,
  ColorMapper? colorMapper,
}) {
  final SvgParser parser = SvgParser(
    xml,
    theme,
    key,
    warningsAsErrors,
    colorMapper,
  );
  parser.enableMaskingOptimizer = enableMaskingOptimizer;
  parser.enableClippingOptimizer = enableClippingOptimizer;
  parser.enableOverdrawOptimizer = enableOverdrawOptimizer;
  return parser.parse();
}

Float64List? _encodeMatrix(AffineMatrix? matrix) {
  if (matrix == null || matrix == AffineMatrix.identity) {
    return null;
  }
  return matrix.toMatrix4();
}

void _encodeShader(
  Gradient? shader,
  Map<Gradient, int> shaderIds,
  VectorGraphicsCodec codec,
  VectorGraphicsBuffer buffer,
) {
  if (shader == null) {
    return;
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
          <int>[for (final Color color in shader.colors!) color.value]),
      offsets: Float32List.fromList(shader.offsets!),
      tileMode: shader.tileMode!.index,
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
          <int>[for (final Color color in shader.colors!) color.value]),
      offsets: Float32List.fromList(shader.offsets!),
      tileMode: shader.tileMode!.index,
      transform: _encodeMatrix(shader.transform),
    );
  } else {
    assert(false);
    throw StateError('illegal shader type: $shader');
  }
  shaderIds[shader] = shaderId;
}

/// String input, String filename
/// Encode an SVG [input] string into a vector_graphics binary format.
Uint8List encodeSvg({
  required String xml,
  required String debugName,
  SvgTheme theme = const SvgTheme(),
  bool enableMaskingOptimizer = true,
  bool enableClippingOptimizer = true,
  bool enableOverdrawOptimizer = true,
  bool warningsAsErrors = false,
  bool useHalfPrecisionControlPoints = false,
  ColorMapper? colorMapper,
}) {
  return _encodeInstructions(
    parse(
      xml,
      key: debugName,
      theme: theme,
      enableMaskingOptimizer: enableMaskingOptimizer,
      enableClippingOptimizer: enableClippingOptimizer,
      enableOverdrawOptimizer: enableOverdrawOptimizer,
      warningsAsErrors: warningsAsErrors,
      colorMapper: colorMapper,
    ),
    useHalfPrecisionControlPoints,
  );
}

Uint8List _encodeInstructions(
  VectorInstructions instructions,
  bool useHalfPrecisionControlPoints,
) {
  const VectorGraphicsCodec codec = VectorGraphicsCodec();
  final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();

  codec.writeSize(buffer, instructions.width, instructions.height);

  final Map<int, int> fillIds = <int, int>{};
  final Map<int, int> strokeIds = <int, int>{};
  final Map<Gradient, int> shaderIds = <Gradient, int>{};

  for (final ImageData data in instructions.images) {
    codec.writeImage(buffer, data.format, data.data);
  }

  for (final Paint paint in instructions.paints) {
    _encodeShader(paint.fill?.shader, shaderIds, codec, buffer);
    _encodeShader(paint.stroke?.shader, shaderIds, codec, buffer);
  }

  int nextPaintId = 0;
  for (final Paint paint in instructions.paints) {
    final Fill? fill = paint.fill;
    final Stroke? stroke = paint.stroke;

    if (fill != null) {
      final int? shaderId = shaderIds[fill.shader];
      final int fillId = codec.writeFill(
        buffer,
        fill.color.value,
        paint.blendMode.index,
        shaderId,
      );
      fillIds[nextPaintId] = fillId;
    }
    if (stroke != null) {
      final int? shaderId = shaderIds[stroke.shader];
      final int strokeId = codec.writeStroke(
        buffer,
        stroke.color.value,
        stroke.cap?.index ?? 0,
        stroke.join?.index ?? 0,
        paint.blendMode.index,
        stroke.miterLimit ?? 4,
        stroke.width ?? 1,
        shaderId,
      );
      strokeIds[nextPaintId] = strokeId;
    }
    nextPaintId += 1;
  }

  final Map<int, int> pathIds = <int, int>{};
  int nextPathId = 0;
  for (final Path path in instructions.paths) {
    final List<int> controlPointTypes = <int>[];
    final List<double> controlPoints = <double>[];

    for (final PathCommand command in path.commands) {
      switch (command.type) {
        case PathCommandType.move:
          final MoveToCommand move = command as MoveToCommand;
          controlPointTypes.add(ControlPointTypes.moveTo);
          controlPoints.addAll(<double>[move.x, move.y]);
        case PathCommandType.line:
          final LineToCommand line = command as LineToCommand;
          controlPointTypes.add(ControlPointTypes.lineTo);
          controlPoints.addAll(<double>[line.x, line.y]);
        case PathCommandType.cubic:
          final CubicToCommand cubic = command as CubicToCommand;
          controlPointTypes.add(ControlPointTypes.cubicTo);
          controlPoints.addAll(<double>[
            cubic.x1,
            cubic.y1,
            cubic.x2,
            cubic.y2,
            cubic.x3,
            cubic.y3,
          ]);
        case PathCommandType.close:
          controlPointTypes.add(ControlPointTypes.close);
      }
    }
    final int id = codec.writePath(
      buffer,
      Uint8List.fromList(controlPointTypes),
      Float32List.fromList(controlPoints),
      path.fillType.index,
      half: useHalfPrecisionControlPoints,
    );
    pathIds[nextPathId] = id;
    nextPathId += 1;
  }

  for (final TextPosition position in instructions.textPositions) {
    codec.writeTextPosition(
      buffer,
      position.x,
      position.y,
      position.dx,
      position.dy,
      position.reset,
      position.transform?.toMatrix4(),
    );
  }

  for (final TextConfig textConfig in instructions.text) {
    codec.writeTextConfig(
      buffer: buffer,
      text: textConfig.text,
      fontFamily: textConfig.fontFamily,
      xAnchorMultiplier: textConfig.xAnchorMultiplier,
      fontWeight: textConfig.fontWeight.index,
      fontSize: textConfig.fontSize,
      decoration: textConfig.decoration.mask,
      decorationStyle: textConfig.decorationStyle.index,
      decorationColor: textConfig.decorationColor.value,
    );
  }

  for (final DrawCommand command in instructions.commands) {
    switch (command.type) {
      case DrawCommandType.path:
        if (fillIds.containsKey(command.paintId)) {
          codec.writeDrawPath(
            buffer,
            pathIds[command.objectId]!,
            fillIds[command.paintId]!,
            command.patternId,
          );
        }
        if (strokeIds.containsKey(command.paintId)) {
          codec.writeDrawPath(
            buffer,
            pathIds[command.objectId]!,
            strokeIds[command.paintId]!,
            command.patternId,
          );
        }
      case DrawCommandType.vertices:
        final IndexedVertices vertices =
            instructions.vertices[command.objectId!];
        final int fillId = fillIds[command.paintId]!;
        codec.writeDrawVertices(
            buffer, vertices.vertices, vertices.indices, fillId);
      case DrawCommandType.saveLayer:
        codec.writeSaveLayer(buffer, fillIds[command.paintId]!);
      case DrawCommandType.restore:
        codec.writeRestoreLayer(buffer);
      case DrawCommandType.clip:
        codec.writeClipPath(buffer, pathIds[command.objectId]!);
      case DrawCommandType.mask:
        codec.writeMask(buffer);

      case DrawCommandType.pattern:
        final PatternData patternData =
            instructions.patternData[command.patternDataId!];
        codec.writePattern(
          buffer,
          patternData.x,
          patternData.y,
          patternData.width,
          patternData.height,
          patternData.transform.toMatrix4(),
        );

      case DrawCommandType.textPosition:
        codec.writeUpdateTextPosition(buffer, command.objectId!);

      case DrawCommandType.text:
        codec.writeDrawText(
          buffer,
          command.objectId!,
          fillIds[command.paintId],
          strokeIds[command.paintId],
          command.patternId,
        );

      case DrawCommandType.image:
        final DrawImageData drawImageData =
            instructions.drawImages[command.objectId!];
        codec.writeDrawImage(
          buffer,
          drawImageData.id,
          drawImageData.rect.left,
          drawImageData.rect.top,
          drawImageData.rect.width,
          drawImageData.rect.height,
          drawImageData.transform?.toMatrix4(),
        );
    }
  }
  return buffer.done().buffer.asUint8List();
}
