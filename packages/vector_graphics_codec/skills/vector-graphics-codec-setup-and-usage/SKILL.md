---
name: vector-graphics-codec-setup-and-usage
description: Set up and use vector_graphics_codec to encode and decode the binary format shared between vector_graphics and vector_graphics_compiler.
---

# Setting Up and Using vector_graphics_codec

The `vector_graphics_codec` package provides the low-level binary encoding and decoding implementation (`VectorGraphicsCodec`, `VectorGraphicsBuffer`, and `VectorGraphicsCodecListener`) shared by `package:vector_graphics_compiler` and `package:vector_graphics`.

> **Note**: This binary format is tightly coupled between compiler and runtime versions and does not guarantee cross-version stability. Most Flutter app developers should use `vector_graphics` and `vector_graphics_compiler` directly rather than calling the low-level codec.

## 1. Installation

Add `vector_graphics_codec` to your Dart project's `pubspec.yaml`:

```bash
dart pub add vector_graphics_codec
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  vector_graphics_codec: ^1.1.13
```

## 2. Usage and API Examples

Import the package in your Dart code:

```dart
import 'package:vector_graphics_codec/vector_graphics_codec.dart';
```

### Encoding Vector Graphics Commands into a Binary Buffer

Use `VectorGraphicsCodec` and `VectorGraphicsBuffer` to programmatically serialize size, paints, paths, and draw commands into a binary `ByteData` payload:

```dart
import 'dart:typed_data';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

Uint8List encodeSimpleTriangle() {
  const VectorGraphicsCodec codec = VectorGraphicsCodec();
  final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();

  // 1. Write viewbox dimensions
  codec.writeSize(buffer, 100.0, 100.0);

  // 2. Write a solid blue fill paint (ARGB: 0xFF0000FF, BlendMode.srcOver = 3)
  final int fillPaintId = codec.writeFill(buffer, 0xFF0000FF, 3);

  // 3. Write triangle path geometry
  final Uint8List controlTypes = Uint8List.fromList(<int>[
    ControlPointTypes.moveTo,
    ControlPointTypes.lineTo,
    ControlPointTypes.lineTo,
    ControlPointTypes.close,
  ]);
  final Float32List controlPoints = Float32List.fromList(<double>[
    50.0, 10.0, // moveTo(50, 10)
    90.0, 90.0, // lineTo(90, 90)
    10.0, 90.0, // lineTo(10, 90)
  ]);
  final int pathId = codec.writePath(
    buffer,
    controlTypes,
    controlPoints,
    0, // Fill type: nonZero
  );

  // 4. Write draw command
  codec.writeDrawPath(buffer, pathId, fillPaintId, null);

  // 5. Finalize buffer to bytes
  final ByteData byteData = buffer.done();
  return byteData.buffer.asUint8List();
}
```

### Decoding Binary Assets with `VectorGraphicsCodecListener`

Implement `VectorGraphicsCodecListener` to inspect or render instructions decoded from a `ByteData` buffer:

```dart
import 'dart:typed_data';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

class LoggingCodecListener extends VectorGraphicsCodecListener {
  @override
  void onSize(double width, double height) {
    print('Canvas size: ${width}x$height');
  }

  @override
  void onPaintObject({
    required int color,
    required int? strokeCap,
    required int? strokeJoin,
    required int blendMode,
    required double? strokeMiterLimit,
    required double? strokeWidth,
    required int paintStyle,
    required int id,
    required int? shaderId,
  }) {
    print('Paint #$id: color=0x${color.toRadixString(16)} style=$paintStyle');
  }

  @override
  void onDrawPath(int pathId, int paintId, int? patternId) {
    print('DrawPath: pathId=$pathId paintId=$paintId');
  }

  // Implement remaining listener callbacks as needed...
  @override
  void onPathStart(int id, int fillType) {}
  @override
  void onPathMoveTo(double x, double y) {}
  @override
  void onPathLineTo(double x, double y) {}
  @override
  void onPathCubicTo(double x1, double y1, double x2, double y2, double x3, double y3) {}
  @override
  void onPathClose() {}
  @override
  void onPathFinished() {}
  @override
  void onClipPath(int pathId) {}
  @override
  void onMask() {}
  @override
  void onSaveLayer(int paintId) {}
  @override
  void onRestoreLayer() {}
  @override
  void onLinearGradient(double fromX, double fromY, double toX, double toY, Int32List colors, Float32List? offsets, int tileMode, int id) {}
  @override
  void onRadialGradient(double centerX, double centerY, double radius, double? focalX, double? focalY, Int32List colors, Float32List? offsets, Float64List? transform, int tileMode, int id) {}
  @override
  void onDrawVertices(Float32List vertices, Uint16List? indices, int paintId) {}
  @override
  void onTextConfig(String text, String? fontFamily, double xAnchorMultiplier, int fontWeight, double fontSize, int decoration, int decorationStyle, int decorationColor, int id) {}
  @override
  void onTextPosition(double? x, double? y, double? dx, double? dy, bool reset, Float64List? transform, int id) {}
  @override
  void onUpdateTextPosition(int textPositionId) {}
  @override
  void onDrawText(int textId, int? fillId, int? strokeId, int? patternId) {}
  @override
  void onImage(int imageId, int format, Uint8List data, {VectorGraphicsErrorListener? onError}) {}
  @override
  void onDrawImage(int imageId, double x, double y, double width, double height, Float64List? transform) {}
  @override
  void onPatternStart(int patternId, double x, double y, double width, double height, Float64List transform) {}
}

void inspectEncodedBytes(Uint8List bytes) {
  const VectorGraphicsCodec codec = VectorGraphicsCodec();
  codec.decode(
    bytes.buffer.asByteData(),
    LoggingCodecListener(),
  );
}
```
