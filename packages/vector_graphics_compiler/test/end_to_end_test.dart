// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
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
  Future<ByteData> loadBytes(BuildContext? context) async {
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
  testWidgets('Can endcode and decode simple SVGs with no errors',
      (WidgetTester tester) async {
    for (final String svg in allSvgTestStrings) {
      final Uint8List bytes = encodeSvg(
        xml: svg,
        debugName: 'test.svg',
        warningsAsErrors: true,
        enableClippingOptimizer: false,
        enableMaskingOptimizer: false,
        enableOverdrawOptimizer: false,
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
              xml: svgInlineImage,
              debugName: 'test.svg',
              warningsAsErrors: true,
              enableClippingOptimizer: false,
              enableMaskingOptimizer: false,
              enableOverdrawOptimizer: false,
            ),
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

    final Uint8List bytes = encodeSvg(
      xml: svg,
      debugName: 'test',
      enableClippingOptimizer: false,
      enableMaskingOptimizer: false,
      enableOverdrawOptimizer: false,
    );
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
      const OnDrawPath(0, 0, null),
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

    final Uint8List bytes = encodeSvg(
      xml: svg,
      debugName: 'test',
      enableClippingOptimizer: false,
      enableMaskingOptimizer: false,
      enableOverdrawOptimizer: false,
    );
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
          'Plain text Roboto', 0, 55, 'Roboto', 3, 0, 0, 4278190080, 0),
      const OnTextConfig(
          'Plain text Verdana', 0, 55, 'Verdana', 3, 0, 0, 4278190080, 1),
      const OnTextConfig(
          'Bold text Verdana', 0, 55, 'Verdana', 6, 0, 0, 4278190080, 2),
      const OnTextConfig(
          'Stroked bold line', 0, 55, 'Roboto', 8, 0, 0, 4278190080, 3),
      const OnTextConfig(' Line 3', 0, 55, 'Roboto', 3, 0, 0, 4278190080, 4),
      const OnDrawText(0, 0, null, null),
      const OnDrawText(1, 0, null, null),
      const OnDrawText(2, 0, null, null),
      const OnDrawText(3, 1, 2, null),
      const OnDrawText(4, 3, null, null),
    ]);
  });

  test('Encodes image elids trivial translation transform', () async {
    const String svg = '''
<svg viewBox="0 0 1000 300" xmlns="http://www.w3.org/2000/svg" version="1.1">
  <g transform="translate(3, 3)">
    <image id="image0" width="50" height="50" xlink:href="data:image/png;base64,$kBase64ImageContents"/>
  </g>
</svg>
''';

    final Uint8List bytes = encodeSvg(
      xml: svg,
      debugName: 'test',
      enableClippingOptimizer: false,
      enableMaskingOptimizer: false,
      enableOverdrawOptimizer: false,
    );
    const VectorGraphicsCodec codec = VectorGraphicsCodec();
    final TestListener listener = TestListener();
    final ByteData data = bytes.buffer.asByteData();
    final DecodeResponse response = codec.decode(data, listener);
    codec.decode(data, listener, response: response);

    expect(listener.commands, <Object>[
      const OnSize(1000, 300),
      OnImage(0, 0, base64.decode(kBase64ImageContents)),
      const OnDrawImage(0, 3, 3, 50, 50, null),
    ]);
  });

  test('Encodes image elids trivial scale transform', () async {
    const String svg = '''
<svg viewBox="0 0 1000 300" xmlns="http://www.w3.org/2000/svg" version="1.1">
  <g transform="scale(2, 2)">
    <image id="image0" width="50" height="50" xlink:href="data:image/png;base64,$kBase64ImageContents"/>
  </g>
</svg>
''';

    final Uint8List bytes = encodeSvg(
      xml: svg,
      debugName: 'test',
      enableClippingOptimizer: false,
      enableMaskingOptimizer: false,
      enableOverdrawOptimizer: false,
    );
    const VectorGraphicsCodec codec = VectorGraphicsCodec();
    final TestListener listener = TestListener();
    final ByteData data = bytes.buffer.asByteData();
    final DecodeResponse response = codec.decode(data, listener);
    codec.decode(data, listener, response: response);

    expect(listener.commands, <Object>[
      const OnSize(1000, 300),
      OnImage(0, 0, base64.decode(kBase64ImageContents)),
      const OnDrawImage(0, 0, 0, 100, 100, null),
    ]);
  });

  test('Encodes image does not elide non-trivial transform', () async {
    const String svg = '''
<svg viewBox="0 0 1000 300" xmlns="http://www.w3.org/2000/svg" version="1.1">
  <g transform="matrix(3 1 -1 3 30 40)">
    <image id="image0" width="50" height="50" xlink:href="data:image/png;base64,$kBase64ImageContents"/>
  </g>
</svg>
''';

    final Uint8List bytes = encodeSvg(
      xml: svg,
      debugName: 'test',
      enableClippingOptimizer: false,
      enableMaskingOptimizer: false,
      enableOverdrawOptimizer: false,
    );
    const VectorGraphicsCodec codec = VectorGraphicsCodec();
    final TestListener listener = TestListener();
    final ByteData data = bytes.buffer.asByteData();
    final DecodeResponse response = codec.decode(data, listener);
    codec.decode(data, listener, response: response);

    expect(listener.commands, <Object>[
      const OnSize(1000, 300),
      OnImage(0, 0, base64.decode(kBase64ImageContents)),
      const OnDrawImage(0, 0, 0, 50, 50, <double>[
        3.0,
        1.0,
        0.0,
        0.0,
        -1.0,
        3.0,
        0.0,
        0.0,
        0.0,
        0.0,
        3.0,
        0.0,
        30.0,
        40.0,
        0.0,
        1.0,
      ]),
    ]);
  });
}

class TestListener extends VectorGraphicsCodecListener {
  final List<Object> commands = <Object>[];

  @override
  void onTextPosition(int textPositionId, double? x, double? y, double? dx,
      double? dy, bool reset, Float64List? transform) {}

  @override
  void onUpdateTextPosition(int textPositionId) {}

  @override
  void onDrawPath(int pathId, int? paintId, int? patternId) {
    commands.add(OnDrawPath(pathId, paintId, patternId));
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
    double xAnchorMultiplier,
    int fontWeight,
    double fontSize,
    int decoration,
    int decorationStyle,
    int decorationColor,
    int id,
  ) {
    commands.add(OnTextConfig(
      text,
      xAnchorMultiplier,
      fontSize,
      fontFamily,
      fontWeight,
      decoration,
      decorationStyle,
      decorationColor,
      id,
    ));
  }

  @override
  void onDrawText(int textId, int? fillId, int? strokeId, int? patternId) {
    commands.add(OnDrawText(textId, fillId, strokeId, patternId));
  }

  @override
  void onDrawImage(
    int imageId,
    double x,
    double y,
    double width,
    double height,
    Float64List? transform,
  ) {
    commands.add(OnDrawImage(imageId, x, y, width, height, transform));
  }

  @override
  void onImage(
    int imageId,
    int format,
    Uint8List data, {
    VectorGraphicsErrorListener? onError,
  }) {
    commands.add(OnImage(
      imageId,
      format,
      data,
      onError: onError,
    ));
  }

  @override
  void onPatternStart(int patternId, double x, double y, double width,
      double height, Float64List transform) {
    commands.add(OnPatternStart(patternId, x, y, width, height, transform));
  }
}

@immutable
class OnMask {
  const OnMask();
}

@immutable
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

@immutable
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

@immutable
class OnSaveLayer {
  const OnSaveLayer(this.id);

  final int id;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is OnSaveLayer && other.id == id;
}

@immutable
class OnClipPath {
  const OnClipPath(this.id);

  final int id;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is OnClipPath && other.id == id;
}

@immutable
class OnRestoreLayer {
  const OnRestoreLayer();
}

@immutable
class OnDrawPath {
  const OnDrawPath(this.pathId, this.paintId, this.patternId);

  final int pathId;
  final int? paintId;
  final int? patternId;

  @override
  int get hashCode => Object.hash(pathId, paintId, patternId);

  @override
  bool operator ==(Object other) =>
      other is OnDrawPath &&
      other.pathId == pathId &&
      other.paintId == paintId &&
      other.patternId == patternId;

  @override
  String toString() => 'OnDrawPath($pathId, $paintId, $patternId)';
}

@immutable
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

@immutable
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

@immutable
class OnPathClose {
  const OnPathClose();

  @override
  int get hashCode => 44221;

  @override
  bool operator ==(Object other) => other is OnPathClose;

  @override
  String toString() => 'OnPathClose';
}

@immutable
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

@immutable
class OnPathFinished {
  const OnPathFinished();

  @override
  int get hashCode => 1223;

  @override
  bool operator ==(Object other) => other is OnPathFinished;

  @override
  String toString() => 'OnPathFinished';
}

@immutable
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

@immutable
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

@immutable
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

@immutable
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

@immutable
class OnTextConfig {
  const OnTextConfig(
    this.text,
    this.xAnchorMultiplier,
    this.fontSize,
    this.fontFamily,
    this.fontWeight,
    this.decoration,
    this.decorationStyle,
    this.decorationColor,
    this.id,
  );

  final String text;
  final double xAnchorMultiplier;
  final double fontSize;
  final String? fontFamily;
  final int fontWeight;
  final int id;
  final int decoration;
  final int decorationStyle;
  final int decorationColor;

  @override
  int get hashCode => Object.hash(
        text,
        xAnchorMultiplier,
        fontSize,
        fontFamily,
        fontWeight,
        decoration,
        decorationStyle,
        decorationColor,
        id,
      );

  @override
  bool operator ==(Object other) =>
      other is OnTextConfig &&
      other.text == text &&
      other.xAnchorMultiplier == xAnchorMultiplier &&
      other.fontSize == fontSize &&
      other.fontFamily == fontFamily &&
      other.fontWeight == fontWeight &&
      other.decoration == decoration &&
      other.decorationStyle == decorationStyle &&
      other.decorationColor == decorationColor &&
      other.id == id;

  @override
  String toString() =>
      'OnTextConfig($text, (anchor: $xAnchorMultiplier), $fontSize, $fontFamily, $fontWeight, $decoration, $decorationStyle, $decorationColor, $id)';
}

@immutable
class OnDrawText {
  const OnDrawText(this.textId, this.fillId, this.strokeId, this.patternId);

  final int textId;
  final int? fillId;
  final int? strokeId;
  final int? patternId;

  @override
  int get hashCode => Object.hash(textId, fillId, strokeId, patternId);

  @override
  bool operator ==(Object other) =>
      other is OnDrawText &&
      other.textId == textId &&
      other.fillId == fillId &&
      other.strokeId == strokeId &&
      other.patternId == patternId;

  @override
  String toString() => 'OnDrawText($textId, $fillId, $strokeId, $patternId)';
}

@immutable
class OnImage {
  const OnImage(this.id, this.format, this.data, {this.onError});

  final int id;
  final int format;
  final List<int> data;
  final VectorGraphicsErrorListener? onError;

  @override
  int get hashCode => Object.hash(id, format, data, onError);

  @override
  bool operator ==(Object other) =>
      other is OnImage &&
      other.id == id &&
      other.format == format &&
      other.onError == onError &&
      _listEquals(other.data, data);

  @override
  String toString() => 'OnImage($id, $format, data:${data.length} bytes)';
}

@immutable
class OnDrawImage {
  const OnDrawImage(
    this.id,
    this.x,
    this.y,
    this.width,
    this.height,
    this.transform,
  );

  final int id;
  final double x;
  final double y;
  final double width;
  final double height;
  final List<double>? transform;

  @override
  int get hashCode => Object.hash(id, x, y, width, height);

  @override
  bool operator ==(Object other) {
    return other is OnDrawImage &&
        other.id == id &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height &&
        _listEquals(other.transform, transform);
  }

  @override
  String toString() => 'OnDrawImage($id, $x, $y, $width, $height, $transform)';
}

@immutable
class OnPatternStart {
  const OnPatternStart(
      this.patternId, this.x, this.y, this.width, this.height, this.transform);

  final int patternId;
  final double x;
  final double y;
  final double width;
  final double height;
  final Float64List transform;

  @override
  int get hashCode =>
      Object.hash(patternId, x, y, width, height, Object.hashAll(transform));

  @override
  bool operator ==(Object other) =>
      other is OnPatternStart &&
      other.patternId == patternId &&
      other.x == x &&
      other.y == y &&
      other.width == width &&
      other.height == height &&
      _listEquals(other.transform, transform);

  @override
  String toString() =>
      'OnPatternStart($patternId, $x, $y, $width, $height, $transform)';
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
