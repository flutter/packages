// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'test_svg_strings.dart';

class TestBytesLoader extends BytesLoader {
  const TestBytesLoader(this.data);

  final ByteData data;

  @override
  Future<ByteData> loadBytes(BuildContext context) async {
    return data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) {
    return other is TestBytesLoader && other.data == data;
  }
}

void main() {
  setUpAll(() {
    if (!initializePathOpsFromFlutterCache()) {
      fail('error in setup');
    }
  });

  testWidgets('Can endcode and decode simple SVGs with no errors',
      (WidgetTester tester) async {
    for (final String svg in allSvgTestStrings) {
      final Uint8List bytes = await encodeSvg(
        xml: svg,
        debugName: 'test.svg',
        warningsAsErrors: true,
      );

      await tester.pumpWidget(Center(
          child: VectorGraphic(
              loader: TestBytesLoader(bytes.buffer.asByteData()))));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Errors on unsupported image mime type',
      (WidgetTester tester) async {
    const String svgInlineImage = r'''
<svg width="248" height="100" viewBox="0 0 248 100">
<image id="image0" width="50" height="50" xlink:href="data:image/foobar;base64,iVBORw0I5IAAM1SvoAAAAASUVORK5CYII=">
</svg>
''';

    expect(
        () => encodeSvg(
            xml: svgInlineImage, debugName: 'test.svg', warningsAsErrors: true),
        throwsA(isA<UnimplementedError>()));
  });

  test('encodeSvg encodes stroke shaders', () async {
    const String svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120">
  <defs>
    <linearGradient id="j" x1="69" y1="59" x2="36" y2="84" gradientUnits="userSpaceOnUse">
      <stop offset="0" stop-color="#ffffff" />
      <stop offset="1" stop-color="#000000" />
    </linearGradient>
  </defs>
  <g>
    <path d="M34 76h23" fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="8" stroke="url(#j)" />
  </g>
</svg>
''';

    final Uint8List bytes = await encodeSvg(xml: svg, debugName: 'test');
    const VectorGraphicsCodec codec = VectorGraphicsCodec();
    final TestListener listener = TestListener();
    codec.decode(bytes.buffer.asByteData(), listener);
    expect(listener.commands, <Object>[
      const OnSize(120, 120),
      OnLinearGradient(
        id: 0,
        fromX: 69,
        fromY: 59,
        toX: 36,
        toY: 84,
        colors: Int32List.fromList(<int>[0xffffffff, 0xff000000]),
        offsets: Float32List.fromList(<double>[0, 1]),
        tileMode: 0,
      ),
      OnPaintObject(
        color: 0xffffffff,
        strokeCap: 1,
        strokeJoin: 1,
        blendMode: BlendMode.srcOver.index,
        strokeMiterLimit: 4.0,
        strokeWidth: 8,
        paintStyle: 1,
        id: 0,
        shaderId: 0,
      ),
      const OnPathStart(0, 0),
      const OnPathMoveTo(34, 76),
      const OnPathLineTo(57, 76),
      const OnPathFinished(),
      const OnDrawPath(0, 0),
    ]);
  });

  test('Encodes nested tspan for text', () async {
    const String svg = '''
<svg viewBox="0 0 1000 300" xmlns="http://www.w3.org/2000/svg" version="1.1">

  <text x="100" y="50"
      font-family="Roboto" font-size="55" font-weight="normal" fill="blue" >
    Plain text Roboto</text>
  <text x="100" y="100"
      font-family="Verdana" font-size="55" font-weight="normal" fill="blue" >
    Plain text Verdana</text>

  <text x="100" y="150"
      font-family="Verdana" font-size="55" font-weight="bold" fill="blue" >
    Bold text Verdana</text>

  <text x="150" y="215"
      font-family="Roboto" font-size="55" fill="green" >
    <tspan stroke="red" font-weight="900" >Stroked bold line</tspan>
    <tspan y="50">Line 3</tspan>
  </text>
</svg>
''';

    final Uint8List bytes = await encodeSvg(xml: svg, debugName: 'test');
    const VectorGraphicsCodec codec = VectorGraphicsCodec();
    final TestListener listener = TestListener();
    codec.decode(bytes.buffer.asByteData(), listener);
    expect(listener.commands, <Object>[
      const OnSize(1000, 300),
      OnPaintObject(
        color: 4278190335,
        strokeCap: null,
        strokeJoin: null,
        blendMode: BlendMode.srcOver.index,
        strokeMiterLimit: null,
        strokeWidth: null,
        paintStyle: 0,
        id: 0,
        shaderId: null,
      ),
      OnPaintObject(
        color: 4278222848,
        strokeCap: null,
        strokeJoin: null,
        blendMode: BlendMode.srcOver.index,
        strokeMiterLimit: null,
        strokeWidth: null,
        paintStyle: 0,
        id: 1,
        shaderId: null,
      ),
      OnPaintObject(
        color: 4294901760,
        strokeCap: 0,
        strokeJoin: 0,
        blendMode: BlendMode.srcOver.index,
        strokeMiterLimit: 4.0,
        strokeWidth: 1.0,
        paintStyle: 1,
        id: 2,
        shaderId: null,
      ),
      OnPaintObject(
        color: 4278222848,
        strokeCap: null,
        strokeJoin: null,
        blendMode: BlendMode.srcOver.index,
        strokeMiterLimit: null,
        strokeWidth: null,
        paintStyle: 0,
        id: 3,
        shaderId: null,
      ),
      const OnTextConfig(
          'Plain text Roboto', 100, 50, 55, 'Roboto', 3, null, 0),
      const OnTextConfig(
          'Plain text Verdana', 100, 100, 55, 'Verdana', 3, null, 1),
      const OnTextConfig(
          'Bold text Verdana', 100, 150, 55, 'Verdana', 6, null, 2),
      const OnTextConfig(
          'Stroked bold line', 150, 215, 55, 'Roboto', 8, null, 3),
      const OnTextConfig('Line 3', 150, 50, 55, 'Roboto', 3, null, 4),
      const OnDrawText(0, 0),
      const OnDrawText(1, 0),
      const OnDrawText(2, 0),
      const OnDrawText(3, 1),
      const OnDrawText(3, 2),
      const OnDrawText(4, 3),
    ]);
  });
}

class TestListener extends VectorGraphicsCodecListener {
  final List<Object> commands = <Object>[];

  @override
  void onDrawPath(int pathId, int? paintId) {
    commands.add(OnDrawPath(pathId, paintId));
  }

  @override
  void onDrawVertices(Float32List vertices, Uint16List? indices, int? paintId) {
    commands.add(OnDrawVertices(vertices, indices, paintId));
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
    commands.add(
      OnPaintObject(
        color: color,
        strokeCap: strokeCap,
        strokeJoin: strokeJoin,
        blendMode: blendMode,
        strokeMiterLimit: strokeMiterLimit,
        strokeWidth: strokeWidth,
        paintStyle: paintStyle,
        id: id,
        shaderId: shaderId,
      ),
    );
  }

  @override
  void onPathClose() {
    commands.add(const OnPathClose());
  }

  @override
  void onPathCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    commands.add(OnPathCubicTo(x1, y1, x2, y2, x3, y3));
  }

  @override
  void onPathFinished() {
    commands.add(const OnPathFinished());
  }

  @override
  void onPathLineTo(double x, double y) {
    commands.add(OnPathLineTo(x, y));
  }

  @override
  void onPathMoveTo(double x, double y) {
    commands.add(OnPathMoveTo(x, y));
  }

  @override
  void onPathStart(int id, int fillType) {
    commands.add(OnPathStart(id, fillType));
  }

  @override
  void onRestoreLayer() {
    commands.add(const OnRestoreLayer());
  }

  @override
  void onMask() {
    commands.add(const OnMask());
  }

  @override
  void onSaveLayer(int id) {
    commands.add(OnSaveLayer(id));
  }

  @override
  void onClipPath(int pathId) {
    commands.add(OnClipPath(pathId));
  }

  @override
  void onRadialGradient(
    double centerX,
    double centerY,
    double radius,
    double? focalX,
    double? focalY,
    Int32List colors,
    Float32List? offsets,
    Float64List? transform,
    int tileMode,
    int id,
  ) {
    commands.add(
      OnRadialGradient(
        centerX: centerX,
        centerY: centerY,
        radius: radius,
        focalX: focalX,
        focalY: focalY,
        colors: colors,
        offsets: offsets,
        transform: transform,
        tileMode: tileMode,
        id: id,
      ),
    );
  }

  @override
  void onLinearGradient(
    double fromX,
    double fromY,
    double toX,
    double toY,
    Int32List colors,
    Float32List? offsets,
    int tileMode,
    int id,
  ) {
    commands.add(OnLinearGradient(
      fromX: fromX,
      fromY: fromY,
      toX: toX,
      toY: toY,
      colors: colors,
      offsets: offsets,
      tileMode: tileMode,
      id: id,
    ));
  }

  @override
  void onSize(double width, double height) {
    commands.add(OnSize(width, height));
  }

  @override
  void onTextConfig(
    String text,
    String? fontFamily,
    double dx,
    double dy,
    int fontWeight,
    double fontSize,
    Float64List? transform,
    int id,
  ) {
    commands.add(OnTextConfig(
      text,
      dx,
      dy,
      fontSize,
      fontFamily,
      fontWeight,
      transform,
      id,
    ));
  }

  @override
  void onDrawText(int textId, int paintId) {
    commands.add(OnDrawText(textId, paintId));
  }

  @override
  void onDrawImage(
      int imageId, double x, double y, double width, double height) {
    commands.add(OnDrawImage(imageId, x, y, width, height));
  }

  @override
  void onImage(int imageId, int format, Uint8List data) {
    commands.add(OnImage(imageId, format, data));
  }
}

class OnMask {
  const OnMask();
}

class OnLinearGradient {
  const OnLinearGradient({
    required this.fromX,
    required this.fromY,
    required this.toX,
    required this.toY,
    required this.colors,
    required this.offsets,
    required this.tileMode,
    required this.id,
  });

  final double fromX;
  final double fromY;
  final double toX;
  final double toY;
  final Int32List colors;
  final Float32List? offsets;
  final int tileMode;
  final int id;

  @override
  int get hashCode => Object.hash(
        fromX,
        fromY,
        toX,
        toY,
        Object.hashAll(colors),
        Object.hashAll(offsets ?? <double>[]),
        tileMode,
        id,
      );

  @override
  bool operator ==(Object other) {
    return other is OnLinearGradient &&
        other.fromX == fromX &&
        other.fromY == fromY &&
        other.toX == toX &&
        other.toY == toY &&
        _listEquals(other.colors, colors) &&
        _listEquals(other.offsets, offsets) &&
        other.tileMode == tileMode &&
        other.id == id;
  }

  @override
  String toString() {
    return 'OnLinearGradient('
        'fromX: $fromX, '
        'toX: $toX, '
        'fromY: $fromY, '
        'toY: $toY, '
        'colors: Int32List.fromList($colors), '
        'offsets: Float32List.fromList($offsets), '
        'tileMode: $tileMode, '
        'id: $id)';
  }
}

class OnRadialGradient {
  const OnRadialGradient({
    required this.centerX,
    required this.centerY,
    required this.radius,
    required this.focalX,
    required this.focalY,
    required this.colors,
    required this.offsets,
    required this.transform,
    required this.tileMode,
    required this.id,
  });

  final double centerX;
  final double centerY;
  final double radius;
  final double? focalX;
  final double? focalY;
  final Int32List colors;
  final Float32List? offsets;
  final Float64List? transform;
  final int tileMode;
  final int id;

  @override
  int get hashCode => Object.hash(
        centerX,
        centerY,
        radius,
        focalX,
        focalY,
        Object.hashAll(colors),
        Object.hashAll(offsets ?? <double>[]),
        Object.hashAll(transform ?? <double>[]),
        tileMode,
        id,
      );

  @override
  bool operator ==(Object other) {
    return other is OnRadialGradient &&
        other.centerX == centerX &&
        other.centerY == centerY &&
        other.radius == radius &&
        other.focalX == focalX &&
        other.focalX == focalY &&
        _listEquals(other.colors, colors) &&
        _listEquals(other.offsets, offsets) &&
        _listEquals(other.transform, transform) &&
        other.tileMode == tileMode &&
        other.id == id;
  }
}

class OnSaveLayer {
  const OnSaveLayer(this.id);

  final int id;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is OnSaveLayer && other.id == id;
}

class OnClipPath {
  const OnClipPath(this.id);

  final int id;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is OnClipPath && other.id == id;
}

class OnRestoreLayer {
  const OnRestoreLayer();
}

class OnDrawPath {
  const OnDrawPath(this.pathId, this.paintId);

  final int pathId;
  final int? paintId;

  @override
  int get hashCode => Object.hash(pathId, paintId);

  @override
  bool operator ==(Object other) =>
      other is OnDrawPath && other.pathId == pathId && other.paintId == paintId;

  @override
  String toString() => 'OnDrawPath($pathId, $paintId)';
}

class OnDrawVertices {
  const OnDrawVertices(this.vertices, this.indices, this.paintId);

  final List<double> vertices;
  final List<int>? indices;
  final int? paintId;

  @override
  int get hashCode => Object.hash(
      Object.hashAll(vertices), Object.hashAll(indices ?? <int>[]), paintId);

  @override
  bool operator ==(Object other) =>
      other is OnDrawVertices &&
      _listEquals(vertices, other.vertices) &&
      _listEquals(indices, other.indices) &&
      other.paintId == paintId;

  @override
  String toString() => 'OnDrawVertices($vertices, $indices, $paintId)';
}

class OnPaintObject {
  const OnPaintObject({
    required this.color,
    required this.strokeCap,
    required this.strokeJoin,
    required this.blendMode,
    required this.strokeMiterLimit,
    required this.strokeWidth,
    required this.paintStyle,
    required this.id,
    required this.shaderId,
  });

  final int color;
  final int? strokeCap;
  final int? strokeJoin;
  final int blendMode;
  final double? strokeMiterLimit;
  final double? strokeWidth;
  final int paintStyle;
  final int id;
  final int? shaderId;

  @override
  int get hashCode => Object.hash(color, strokeCap, strokeJoin, blendMode,
      strokeMiterLimit, strokeWidth, paintStyle, id, shaderId);

  @override
  bool operator ==(Object other) =>
      other is OnPaintObject &&
      other.color == color &&
      other.strokeCap == strokeCap &&
      other.strokeJoin == strokeJoin &&
      other.blendMode == blendMode &&
      other.strokeMiterLimit == strokeMiterLimit &&
      other.strokeWidth == strokeWidth &&
      other.paintStyle == paintStyle &&
      other.id == id &&
      other.shaderId == shaderId;

  @override
  String toString() =>
      'OnPaintObject(color: $color, strokeCap: $strokeCap, strokeJoin: $strokeJoin, '
      'blendMode: $blendMode, strokeMiterLimit: $strokeMiterLimit, strokeWidth: $strokeWidth, '
      'paintStyle: $paintStyle, id: $id, shaderId: $shaderId)';
}

class OnPathClose {
  const OnPathClose();

  @override
  int get hashCode => 44221;

  @override
  bool operator ==(Object other) => other is OnPathClose;

  @override
  String toString() => 'OnPathClose';
}

class OnPathCubicTo {
  const OnPathCubicTo(this.x1, this.y1, this.x2, this.y2, this.x3, this.y3);

  final double x1;
  final double x2;
  final double x3;
  final double y1;
  final double y2;
  final double y3;

  @override
  int get hashCode => Object.hash(x1, y1, x2, y2, x3, y3);

  @override
  bool operator ==(Object other) =>
      other is OnPathCubicTo &&
      other.x1 == x1 &&
      other.y1 == y1 &&
      other.x2 == x2 &&
      other.y2 == y2 &&
      other.x3 == x3 &&
      other.y3 == y3;

  @override
  String toString() => 'OnPathCubicTo($x1, $y1, $x2, $y2, $x3, $y3)';
}

class OnPathFinished {
  const OnPathFinished();

  @override
  int get hashCode => 1223;

  @override
  bool operator ==(Object other) => other is OnPathFinished;

  @override
  String toString() => 'OnPathFinished';
}

class OnPathLineTo {
  const OnPathLineTo(this.x, this.y);

  final double x;
  final double y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  bool operator ==(Object other) =>
      other is OnPathLineTo && other.x == x && other.y == y;

  @override
  String toString() => 'OnPathLineTo($x, $y)';
}

class OnPathMoveTo {
  const OnPathMoveTo(this.x, this.y);

  final double x;
  final double y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  bool operator ==(Object other) =>
      other is OnPathMoveTo && other.x == x && other.y == y;

  @override
  String toString() => 'OnPathMoveTo($x, $y)';
}

class OnPathStart {
  const OnPathStart(this.id, this.fillType);

  final int id;
  final int fillType;

  @override
  int get hashCode => Object.hash(id, fillType);

  @override
  bool operator ==(Object other) =>
      other is OnPathStart && other.id == id && other.fillType == fillType;

  @override
  String toString() => 'OnPathStart($id, $fillType)';
}

class OnSize {
  const OnSize(this.width, this.height);

  final double width;
  final double height;

  @override
  int get hashCode => Object.hash(width, height);

  @override
  bool operator ==(Object other) =>
      other is OnSize && other.width == width && other.height == height;

  @override
  String toString() => 'OnSize($width, $height)';
}

class OnTextConfig {
  const OnTextConfig(
    this.text,
    this.x,
    this.y,
    this.fontSize,
    this.fontFamily,
    this.fontWeight,
    this.transform,
    this.id,
  );

  final String text;
  final double x;
  final double y;
  final double fontSize;
  final String? fontFamily;
  final int fontWeight;
  final int id;
  final Float64List? transform;

  @override
  int get hashCode => Object.hash(text, x, y, fontSize, fontFamily, fontWeight,
      Object.hashAll(transform ?? <double>[]), id);

  @override
  bool operator ==(Object other) =>
      other is OnTextConfig &&
      other.text == text &&
      other.x == x &&
      other.y == y &&
      other.fontSize == fontSize &&
      other.fontFamily == fontFamily &&
      other.fontWeight == fontWeight &&
      _listEquals(other.transform, transform) &&
      other.id == id;

  @override
  String toString() =>
      'OnTextConfig($text, $x, $y, $fontSize, $fontFamily, $fontWeight, $transform, $id)';
}

class OnDrawText {
  const OnDrawText(this.textId, this.paintId);

  final int textId;
  final int paintId;

  @override
  int get hashCode => Object.hash(textId, paintId);

  @override
  bool operator ==(Object other) =>
      other is OnDrawText && other.textId == textId && other.paintId == paintId;

  @override
  String toString() => 'OnDrawText($textId, $paintId)';
}

class OnImage {
  const OnImage(this.id, this.format, this.data);

  final int id;
  final int format;
  final List<int> data;

  @override
  int get hashCode => Object.hash(id, format, data);

  @override
  bool operator ==(Object other) =>
      other is OnImage &&
      other.id == id &&
      other.format == format &&
      _listEquals(other.data, data);

  @override
  String toString() => 'OnImage($id, $format, data:${data.length} bytes)';
}

class OnDrawImage {
  const OnDrawImage(this.id, this.x, this.y, this.width, this.height);

  final int id;
  final double x;
  final double y;
  final double width;
  final double height;

  @override
  int get hashCode => Object.hash(id, x, y, width, height);

  @override
  bool operator ==(Object other) {
    return other is OnDrawImage &&
        other.id == id &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height;
  }

  @override
  String toString() => 'OnDrawImage($id, $x, $y, $width, $height)';
}

bool _listEquals<E>(List<E>? left, List<E>? right) {
  if (left == null && right == null) {
    return true;
  }
  if (left == null || right == null) {
    return false;
  }
  if (left.length != right.length) {
    return false;
  }
  for (int i = 0; i < left.length; i++) {
    if (left[i] != right[i]) {
      return false;
    }
  }
  return true;
}
