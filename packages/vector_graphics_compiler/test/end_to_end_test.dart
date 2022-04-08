import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'test_svg_strings.dart';
import '../../vector_graphics_codec/test/vector_graphics_codec_test.dart'
    show
        TestListener,
        OnSize,
        OnLinearGradient,
        OnPaintObject,
        OnPathStart,
        OnPathMoveTo,
        OnPathLineTo,
        OnPathFinished,
        OnDrawPath,
        OnTextConfig,
        OnDrawText;

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
  testWidgets('Can endcode and decode simple SVGs with no errors',
      (WidgetTester tester) async {
    for (final String svg in allSvgTestStrings) {
      final Uint8List bytes = await encodeSvg(svg, 'test.svg');

      await tester.pumpWidget(Center(
          child: VectorGraphic(
              loader: TestBytesLoader(bytes.buffer.asByteData()))));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    }
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

    final Uint8List bytes = await encodeSvg(svg, 'test');
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

    final Uint8List bytes = await encodeSvg(svg, 'test');
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
