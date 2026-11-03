// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

class _BytesLoader extends BytesLoader {
  const _BytesLoader(this.bytes);
  final Uint8List bytes;

  @override
  Future<ByteData> loadBytes(BuildContext? context) async => bytes.buffer.asByteData();
}

void main() {
  test('marker-mid draws the marker at every interior path vertex', () {
    final VectorInstructions instructions = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
  <defs><marker overflow="visible" id="dot" markerUnits="userSpaceOnUse" markerWidth="10" markerHeight="10">
    <path d="M0 0 L2 0 L0 2 Z" fill="white"/>
  </marker></defs>
  <path d="M0 0 L10 10 L20 10 L30 10" fill="none" marker-mid="url(#dot)"/>
</svg>''');
    expect(instructions.paths, <Path>[
      parseSvgPathData('M10 10 L12 10 L10 12 Z'),
      parseSvgPathData('M20 10 L22 10 L20 12 Z'),
    ]);
  });

  test('marker-end supports forward definitions and auto orientation', () {
    final VectorInstructions instructions = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
  <line x1="20" y1="10" x2="20" y2="30" stroke="black" marker-end="url(#arrow)"/>
  <defs><marker overflow="visible" id="arrow" markerUnits="userSpaceOnUse" markerWidth="10" markerHeight="10" orient="auto">
    <path d="M0 0 L2 0 L0 2 Z"/>
  </marker></defs>
</svg>''');
    expect(instructions.paths.length, 2);
    expect(instructions.paths.last, parseSvgPathData('M20 30 L20 32 L18 30 Z'));
  });

  test('markers inherit on groups and follow the shape transform', () {
    final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker overflow="visible" id="dot" markerUnits="userSpaceOnUse"><path d="M0 0h1v1z"/></marker></defs>
 <g marker-mid="url(#dot)" transform="translate(10 20)">
   <path d="M0 0 L5 5 L10 0" fill="none"/>
 </g>
</svg>''');
    expect(result.paths, <Path>[parseSvgPathData('M15 25 h1 v1 z')]);
  });

  test('arc segments create markers only at original SVG vertices', () {
    final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker overflow="visible" id="dot" markerUnits="userSpaceOnUse"><path d="M0 0h1v1z"/></marker></defs>
 <path d="M10 50 A40 40 0 1 1 90 50 L95 50" fill="none" marker-mid="url(#dot)"/>
</svg>''');
    expect(result.paths, hasLength(1));
    final vertex = result.paths.single.commands.first as MoveToCommand;
    expect(vertex.x, closeTo(90, 0.00001));
    expect(vertex.y, closeTo(50, 0.00001));
  });

  test('start and end apply only to the first and last vertex across subpaths', () {
    final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker overflow="visible" id="dot" markerUnits="userSpaceOnUse"><path d="M0 0h1v1z"/></marker></defs>
 <path d="M1 1 L2 2 M3 3 L4 4" fill="none" marker-mid="url(#dot)"/>
</svg>''');
    expect(result.paths, <Path>[
      parseSvgPathData('M2 2 h1 v1 z'),
      parseSvgPathData('M3 3 h1 v1 z'),
    ]);
  });

  test('markerUnits strokeWidth scales marker geometry', () {
    final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker overflow="visible" id="dot"><path d="M0 0h1v1z"/></marker></defs>
 <path d="M0 0 L10 10 L20 0" fill="none" stroke="black" stroke-width="2" marker-mid="url(#dot)"/>
</svg>''');
    expect(result.paths.last, parseSvgPathData('M10 10 h2 v2 z'));
  });

  test('self-closing and missing marker references do not draw', () {
    final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker overflow="visible" id="empty"/></defs>
 <path d="M0 0 L10 10 L20 0" fill="none" marker-start="url(#missing)" marker-mid="url(#empty)"/>
</svg>''');
    expect(result.paths, isEmpty);
  });

  test('marker viewport clips by default and visible overflow disables it', () {
    VectorInstructions parse(String overflow) => parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="a" markerWidth="2" markerHeight="2" $overflow><path d="M0 0 h5 v5 z"/></marker></defs>
 <path d="M10 10 L20 20 L30 10" fill="none" marker-mid="url(#a)"/>
</svg>''');
    expect(
      parse('').commands.where((command) => command.type == DrawCommandType.clip),
      hasLength(1),
    );
    expect(
      parse('overflow="visible"').commands.where((command) => command.type == DrawCommandType.clip),
      isEmpty,
    );
  });

  test('viewBox, reference point and preserveAspectRatio align marker content', () {
    final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="a" overflow="visible" markerUnits="userSpaceOnUse" markerWidth="10" markerHeight="20" viewBox="0 0 10 10" refX="5" refY="5"><path d="M0 0 h1 v1 z"/></marker></defs>
 <path d="M0 0 L20 30 L40 0" fill="none" marker-mid="url(#a)"/>
</svg>''');
    expect(result.paths.single, parseSvgPathData('M15 25 h1 v1 z'));
  });

  test('recursive markers terminate and retain the non-recursive geometry', () {
    final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="a" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0 L1 0 L1 1" marker-mid="url(#a)"/></marker></defs>
 <path d="M0 0 L20 20 L40 0" fill="none" marker-mid="url(#a)"/>
</svg>''');
    expect(result.paths, hasLength(1));
  });

  test('auto orientation uses the next direction after a zero-length segment', () {
    final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="a" overflow="visible" markerUnits="userSpaceOnUse" orient="auto"><path d="M0 0h2v1z"/></marker></defs>
 <path d="M0 0 L0 0 L0 10" fill="none" marker-start="url(#a)"/>
</svg>''');
    final point = result.paths.single.commands.elementAt(1) as LineToCommand;
    expect(point.x, closeTo(0, 0.000001));
    expect(point.y, closeTo(2, 0.000001));
  });

  test('marker shorthand overrides inherited marker properties', () {
    final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs>
  <marker id="a" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0h1v1z"/></marker>
  <marker id="b" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0h2v2z"/></marker>
 </defs>
 <g marker-mid="url(#a)"><path d="M0 0L10 10L20 0" fill="none" marker="url(#b)"/></g>
</svg>''');
    expect(result.paths, <Path>[
      parseSvgPathData('M0 0 h2 v2 z'),
      parseSvgPathData('M10 10 h2 v2 z'),
      parseSvgPathData('M20 0 h2 v2 z'),
    ]);
  });

  test('marker at each of fifty vertices is emitted without warnings', () {
    final String vertices = List<String>.generate(51, (index) => 'L${index + 1} 10').join(' ');
    final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <marker id="star" markerWidth="5" markerHeight="5" overflow="visible"><path d="M0 0h1v1z"/></marker>
 <path d="M0 10 $vertices" fill="none" marker-mid="url(#star)"/>
</svg>''', warningsAsErrors: true);
    expect(result.commands.where((command) => command.type == DrawCommandType.path), hasLength(50));
  });

  test('marker inherits paint from the definition tree', () {
    final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100" fill="red">
 <defs><marker id="a" markerUnits="userSpaceOnUse" overflow="visible"><path d="M0 0h1v1z"/></marker></defs>
 <path d="M0 0L10 10L20 0" fill="none" marker-mid="url(#a)"/>
</svg>''');
    expect(result.paints, contains(const Paint(fill: Fill(color: Color(0xffff0000)))));
  });

  test('marker viewport can use unequal scales with preserveAspectRatio none', () {
    final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="a" overflow="visible" markerUnits="userSpaceOnUse" markerWidth="10" markerHeight="20" viewBox="0 0 10 10" preserveAspectRatio="none"><path d="M0 0 h1 v1 z"/></marker></defs>
 <path d="M0 0 L20 30 L40 0" fill="none" marker-mid="url(#a)"/>
</svg>''');
    expect(result.paths.single, parseSvgPathData('M20 30 h1 v2 z'));
  });

  test('element opacity composites the shape and its markers together', () {
    final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="a" markerUnits="userSpaceOnUse" overflow="visible"><path d="M0 0h1v1z"/></marker></defs>
 <path d="M0 0L10 10L20 0" fill="none" stroke="black" stroke-opacity="0.25" opacity="0.5" marker-mid="url(#a)"/>
</svg>''');
    expect(result.commands.first.type, DrawCommandType.saveLayer);
    expect(result.commands.last.type, DrawCommandType.restore);
    expect(result.paints.first.fill!.color, const Color(0x7f000000));
    expect(
      result.paints.singleWhere((paint) => paint.stroke != null).stroke!.color,
      const Color(0x3f000000),
    );
  });

  test('marker reference coordinates accept SVG 2 keywords and percentages', () {
    VectorInstructions parse(String rx, String ry) => parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="a" overflow="visible" markerUnits="userSpaceOnUse" markerWidth="10" markerHeight="10" viewBox="-5 -5 10 10" refX="$rx" refY="$ry"><path d="M0 0 h1 v1 z"/></marker></defs>
 <path d="M0 0L20 30L40 0" fill="none" marker-mid="url(#a)"/>
</svg>''');
    expect(parse('center', '50%').paths.single, parseSvgPathData('M20 30 h1 v1 z'));
    expect(parse('left', 'bottom').paths.single, parseSvgPathData('M25 25 h1 v1 z'));
  });

  test('compiler encodes markers with the normal optimizer pipeline', () {
    expect(initializePathOpsFromFlutterCache(), isTrue);
    final Uint8List bytes = encodeSvg(
      xml: '''
<svg viewBox="0 0 100 100">
 <defs><marker id="a" markerWidth="3" markerHeight="3"><path d="M0 0h1v1z"/></marker></defs>
 <path d="M0 0L10 10L20 0" fill="none" marker-mid="url(#a)"/>
</svg>''',
      debugName: 'marker.svg',
      warningsAsErrors: true,
    );
    expect(bytes, isNotEmpty);
  });

  testWidgets('encoded marker renders and clips in the vector graphics runtime', (
    WidgetTester tester,
  ) async {
    final Uint8List bytes = encodeSvg(
      xml: '''
<svg viewBox="0 0 100 100">
 <marker id="a" markerUnits="userSpaceOnUse" markerWidth="3" markerHeight="3"><rect width="10" height="10" fill="red"/></marker>
 <path d="M0 0 L20 30 L40 0" fill="none" marker-mid="url(#a)"/>
</svg>''',
      debugName: 'marker.svg',
      enableClippingOptimizer: false,
      enableMaskingOptimizer: false,
      enableOverdrawOptimizer: false,
    );
    const capture = Key('capture');
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: RepaintBoundary(
              key: capture,
              child: VectorGraphic(loader: _BytesLoader(bytes)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final RenderRepaintBoundary boundary = tester.renderObject(find.byKey(capture));
    await tester.runAsync(() async {
      final ui.Image image = await boundary.toImage();
      final ByteData pixels = (await image.toByteData())!;
      int channel(int x, int y, int channel) => pixels.getUint8((y * 100 + x) * 4 + channel);
      expect(channel(21, 31, 0), 255);
      expect(channel(21, 31, 3), 255);
      expect(channel(25, 35, 3), 0);
      image.dispose();
    });
  });

  test('marker angle units are interpreted consistently', () {
    for (final angle in <String>['90', '90deg', '100grad', '0.25turn', '1.5707963267948966rad']) {
      final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="a" overflow="visible" markerUnits="userSpaceOnUse" orient="$angle"><path d="M0 0 h2 v1 z"/></marker></defs>
 <path d="M0 0 L20 30 L40 0" fill="none" marker-mid="url(#a)"/>
</svg>''');
      final point = result.paths.single.commands.elementAt(1) as LineToCommand;
      expect(point.x, closeTo(20, 0.000001), reason: angle);
      expect(point.y, closeTo(32, 0.000001), reason: angle);
    }
  });

  test('auto-start-reverse changes the start marker orientation', () {
    final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="a" overflow="visible" markerUnits="userSpaceOnUse" orient="auto-start-reverse"><path d="M0 0h2v1z"/></marker></defs>
 <path d="M10 10 L20 10" fill="none" marker-start="url(#a)" marker-end="url(#a)"/>
</svg>''');
    final start = result.paths.first.commands.elementAt(1) as LineToCommand;
    final end = result.paths.last.commands.elementAt(1) as LineToCommand;
    expect(start.x, closeTo(8, 0.000001));
    expect(end.x, closeTo(22, 0.000001));
  });
}
