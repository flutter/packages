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
  setUpAll(() {
    expect(initializePathOpsFromFlutterCache(), isTrue);
  });

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
 <g marker-mid="url(#a)"><path d="M0 0L10 10L20 0" fill="none" style="marker:url(#b)"/></g>
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

  group('marker vertices and orientation', () {
    const defs = '''
<defs><marker id="a" overflow="visible" markerUnits="userSpaceOnUse" orient="auto"><path d="M0 0h2"/></marker></defs>''';

    LineToCommand tip(Path path) => path.commands.elementAt(1) as LineToCommand;

    test('the ends of a closed subpath bisect the closing and first segments', () {
      final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">$defs
 <path d="M0 0 L10 0 L10 10 L0 10 Z" fill="none" marker-start="url(#a)" marker-end="url(#a)"/>
</svg>''');
      // Both markers have the same geometry, which is stored only once.
      expect(
        result.commands.where((command) => command.type == DrawCommandType.path),
        hasLength(2),
      );
      expect(tip(result.paths.single).x, closeTo(1.41421356, 0.000001));
      expect(tip(result.paths.single).y, closeTo(-1.41421356, 0.000001));
    });

    test('an open subpath ending on its start point is not treated as closed', () {
      final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">$defs
 <path d="M0 0 L10 0 L10 10 L0 10 L0 0" fill="none" marker-start="url(#a)"/>
</svg>''');
      expect(tip(result.paths.single).x, closeTo(2, 0.000001));
      expect(tip(result.paths.single).y, closeTo(0, 0.000001));
    });

    test('closed subpaths draw every marker on their shared vertices', () {
      final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs>
  <marker id="s" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0h1v1z"/></marker>
  <marker id="m" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0h2v2z"/></marker>
  <marker id="e" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0h3v3z"/></marker>
 </defs>
 <path d="M10,10 h10 v10 z m20,0 h10 v10 z m20,0 h10 v10 z" fill="none"
   marker-start="url(#s)" marker-mid="url(#m)" marker-end="url(#e)"/>
</svg>''');
      expect(
        result.commands.where((command) => command.type == DrawCommandType.path),
        hasLength(12),
      );
      expect(result.paths, contains(parseSvgPathData('M10 10 h1 v1 z')));
      expect(result.paths, contains(parseSvgPathData('M10 10 h2 v2 z')));
      expect(result.paths, contains(parseSvgPathData('M50 10 h3 v3 z')));
    });

    test('a single vertex draws both the start and end markers', () {
      final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs>
  <marker id="s" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0h1v1z"/></marker>
  <marker id="e" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0h3v3z"/></marker>
 </defs>
 <path d="M10 10" fill="none" marker-start="url(#s)" marker-end="url(#e)"/>
</svg>''');
      expect(result.paths, <Path>[
        parseSvgPathData('M10 10 h1 v1 z'),
        parseSvgPathData('M10 10 h3 v3 z'),
      ]);
    });

    test('a trailing moveto is a vertex', () {
      final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="a" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0h1v1z"/></marker></defs>
 <path d="M0 0 L10 0 M20 20" fill="none" marker-end="url(#a)"/>
</svg>''');
      expect(result.paths.last, parseSvgPathData('M20 20 h1 v1 z'));
    });

    test('a coincident first control point uses the next control point', () {
      final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">$defs
 <path d="M0 0 C0 0 0 10 10 10" fill="none" marker-start="url(#a)"/>
</svg>''');
      expect(tip(result.paths.single).x, closeTo(0, 0.000001));
      expect(tip(result.paths.single).y, closeTo(2, 0.000001));
    });

    test('line, polyline and polygon are markable', () {
      for (final shape in <String>[
        '<line x1="0" y1="0" x2="10" y2="0" marker-end="url(#d)"/>',
        '<polyline points="5,0 10,0" fill="none" marker-end="url(#d)"/>',
        '<polygon points="10,0 20,0 20,20" fill="none" marker-start="url(#d)"/>',
      ]) {
        final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="d" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0h1v1z"/></marker></defs>
 $shape
</svg>''');
        expect(result.paths, contains(parseSvgPathData('M10 0 h1 v1 z')), reason: shape);
      }
    });

    test('rect, circle and ellipse are not markable', () {
      final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100" style="marker:url(#d)">
 <defs><marker id="d" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0h1v1z"/></marker></defs>
 <rect width="10" height="10"/>
 <circle cx="20" cy="20" r="5"/>
 <ellipse cx="40" cy="40" rx="5" ry="2"/>
</svg>''');
      expect(result.paths, hasLength(3));
      expect(result.paths, isNot(contains(parseSvgPathData('M0 0 h1 v1 z'))));
    });

    test('the marker shorthand is not a presentation attribute', () {
      final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="d" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0h1v1z"/></marker></defs>
 <path d="M0 0 L10 10" fill="none" marker="url(#d)"/>
</svg>''');
      expect(result.paths, isEmpty);
    });

    test('quoted marker references and none are understood', () {
      final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="d" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0h1v1z"/></marker></defs>
 <path d="M0 0 L10 10 L20 0" fill="none" style="marker-start: url('#d'); marker-mid: none; marker-end: url( &quot;#d&quot; )"/>
</svg>''');
      expect(result.paths, <Path>[
        parseSvgPathData('M0 0 h1 v1 z'),
        parseSvgPathData('M20 0 h1 v1 z'),
      ]);
    });

    test('markers only referencing none do not parse a layer', () {
      final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <path d="M0 0 L10 10" stroke="black" opacity="0.5" style="marker:none"/>
</svg>''');
      expect(
        result.commands.map((command) => command.type),
        isNot(contains(DrawCommandType.saveLayer)),
      );
    });
  });

  group('marker attributes', () {
    VectorInstructions parse(String attributes, {String content = '<path d="M0 0h1v1z"/>'}) {
      return parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="a" $attributes>$content</marker></defs>
 <path d="M0 0 L20 30 L40 0" fill="none" marker-mid="url(#a)"/>
</svg>''');
    }

    int clipCount(VectorInstructions result) =>
        result.commands.where((command) => command.type == DrawCommandType.clip).length;

    test('overflow auto does not clip, and scroll does', () {
      expect(clipCount(parse('overflow="auto"')), 0);
      expect(clipCount(parse('overflow="visible"')), 0);
      expect(clipCount(parse('overflow="hidden"')), 1);
      expect(clipCount(parse('overflow="scroll"')), 1);
    });

    test('zero and negative marker sizes render nothing', () {
      expect(parse('markerWidth="0"').paths, isEmpty);
      expect(parse('markerHeight="0"').paths, isEmpty);
      expect(parse('markerWidth="-1"').paths, isEmpty);
      expect(parse('viewBox="0 0 0 10"').paths, isEmpty);
    });

    test('an invalid viewBox is ignored entirely', () {
      const common = 'overflow="visible" markerUnits="userSpaceOnUse" markerWidth="10"';
      final Path expected = parse(common).paths.single;
      expect(parse('$common viewBox="0 0 oops 10"').paths.single, expected);
      expect(parse('$common viewBox="0 0 10"').paths.single, expected);
      expect(
        parse('$common viewBox="0 0 oops 10" refX="right"').paths.single,
        parseSvgPathData('M10 30 h1 v1 z'),
      );
    });

    test('invalid numeric attributes fall back to their defaults', () {
      final VectorInstructions result = parse(
        'overflow="visible" markerUnits="userSpaceOnUse" markerWidth="oops" refX="oops" orient="oops"',
      );
      expect(result.paths.single, parseSvgPathData('M20 30 h1 v1 z'));
    });

    test('invalid preserveAspectRatio and markerUnits fall back to their defaults', () {
      const viewBox = 'overflow="visible" markerWidth="10" markerHeight="20" viewBox="0 0 10 10"';
      expect(
        parse('$viewBox markerUnits="userSpaceOnUse" preserveAspectRatio="oops"').paths.single,
        parse('$viewBox markerUnits="userSpaceOnUse"').paths.single,
      );
      expect(parse('$viewBox markerUnits="oops"').paths.single, parse(viewBox).paths.single);
    });

    test('preserveAspectRatio aligns the viewport around the reference point', () {
      const common =
          'markerUnits="userSpaceOnUse" markerWidth="10" markerHeight="20" viewBox="0 0 10 10"';
      Iterable<Rect> bounds(String aspectRatio) =>
          parse('$common preserveAspectRatio="$aspectRatio"').paths.map((path) => path.bounds());

      expect(bounds('xMinYMin'), contains(const Rect.fromLTWH(20, 30, 10, 20)));
      expect(bounds('xMaxYMax'), contains(const Rect.fromLTWH(20, 20, 10, 20)));
      expect(bounds('defer xMaxYMax'), contains(const Rect.fromLTWH(20, 25, 10, 20)));
    });

    test('preserveAspectRatio slice scales to cover the viewport', () {
      const common =
          'overflow="visible" markerUnits="userSpaceOnUse" markerWidth="10" markerHeight="20" viewBox="0 0 10 10"';
      expect(
        parse('$common preserveAspectRatio="xMinYMin slice"').paths.single,
        parseSvgPathData('M20 30 h2 v2 z'),
      );
    });

    test('display none on the marker does not prevent it being referenced', () {
      expect(
        parse('overflow="visible" markerUnits="userSpaceOnUse" display="none"').paths,
        hasLength(1),
      );
    });

    test('transform on the marker is ignored', () {
      expect(
        parse(
          'overflow="visible" markerUnits="userSpaceOnUse" transform="translate(5 5)"',
        ).paths.single,
        parseSvgPathData('M20 30 h1 v1 z'),
      );
    });

    test('opacity on the marker composites its contents', () {
      final VectorInstructions result = parse(
        'overflow="visible" markerUnits="userSpaceOnUse" opacity="0.5"',
      );
      expect(result.commands.map((command) => command.type), contains(DrawCommandType.saveLayer));
    });

    test('properties do not inherit from the referencing element', () {
      final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="a" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0h1v1z"/></marker></defs>
 <path d="M0 0 L20 30 L40 0" fill="red" stroke="blue" marker-mid="url(#a)"/>
</svg>''');
      expect(result.paints, contains(const Paint(fill: Fill(color: Color.opaqueBlack))));
    });

    test('clipPath children do not draw markers', () {
      final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs>
  <marker id="a" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0h1v1z"/></marker>
  <clipPath id="c"><path d="M0 0 L20 30 L40 0" marker-mid="url(#a)"/></clipPath>
 </defs>
 <rect width="10" height="10" clip-path="url(#c)"/>
</svg>''');
      expect(result.paths, isNot(contains(parseSvgPathData('M20 30 h1 v1 z'))));
    });
  });

  group('contextual paint', () {
    const red = Color(0xffff0000);
    const blue = Color(0xff0000ff);

    VectorInstructions parse(String content, String shape, {String defs = ''}) {
      return parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs>$defs<marker id="a" overflow="visible" markerUnits="userSpaceOnUse">$content</marker></defs>
 $shape
</svg>''');
    }

    /// The paint of the only drawn marker, which is the last path drawn.
    Paint markerPaint(VectorInstructions result) {
      final DrawCommand command = result.commands.lastWhere(
        (command) => command.type == DrawCommandType.path,
      );
      return result.paints[command.paintId!];
    }

    const path = 'd="M0 0 L20 30 L40 0" marker-mid="url(#a)"';

    test('context-stroke and context-fill use the referencing element paint', () {
      final Paint paint = markerPaint(
        parse(
          '<path d="M0 0h1v1z" fill="context-stroke" stroke="context-fill"/>',
          '<path $path fill="red" stroke="blue"/>',
        ),
      );
      expect(paint.fill!.color, blue);
      expect(paint.stroke!.color, red);
    });

    test('each referencing element provides its own paint', () {
      final VectorInstructions result = parse(
        '<path d="M0 0h1v1z" fill="context-stroke"/>',
        '<path $path fill="none" stroke="red"/><path $path fill="none" stroke="blue"/>',
      );
      final Iterable<Color?> fills = result.paints.map((paint) => paint.fill?.color);
      expect(fills, containsAll(<Color>[red, blue]));
    });

    test('contextual paint inherits from the marker and can be overridden', () {
      final VectorInstructions inherited = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="a" fill="context-stroke" overflow="visible" markerUnits="userSpaceOnUse"><g><path d="M0 0h1v1z"/></g></marker></defs>
 <path $path fill="none" stroke="red"/>
</svg>''');
      expect(markerPaint(inherited).fill!.color, red);

      final VectorInstructions overridden = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs><marker id="a" fill="context-stroke" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0h1v1z" fill="blue"/></marker></defs>
 <path $path fill="none" stroke="red"/>
</svg>''');
      expect(markerPaint(overridden).fill!.color, blue);
    });

    test('the marker element keeps its own fill opacity', () {
      final Paint paint = markerPaint(
        parse(
          '<path d="M0 0h1v1z" fill="context-stroke" fill-opacity="0.5"/>',
          '<path $path fill="none" stroke="red" stroke-opacity="0.25"/>',
        ),
      );
      expect(paint.fill!.color, red.withOpacity(0.5));
    });

    test('an unset context paint uses the initial value', () {
      final Paint filled = markerPaint(
        parse('<path d="M0 0h1v1z" fill="context-fill"/>', '<path $path stroke="red"/>'),
      );
      expect(filled.fill!.color, Color.opaqueBlack);

      final VectorInstructions result = parse(
        '<path d="M0 0h1v1z" fill="context-stroke"/>',
        '<path $path fill="none"/>',
      );
      expect(result.paths, isEmpty);
    });

    test('a context paint of none paints nothing', () {
      final VectorInstructions result = parse(
        '<path d="M0 0h1v1z" fill="context-fill"/>',
        '<path $path fill="none" stroke="red"/>',
      );
      expect(result.paths, hasLength(1));
    });

    test('gradients are continuous with the referencing element', () {
      final VectorInstructions result = parse(
        '<path d="M0 0h1v1z" fill="context-stroke"/>',
        '<path $path fill="none" stroke="url(#g)"/>',
        defs:
            '<linearGradient id="g"><stop offset="0" stop-color="red"/><stop offset="1" stop-color="blue"/></linearGradient>',
      );
      final Paint main = result.paints.firstWhere((paint) => paint.stroke != null);
      final Paint marker = result.paints.firstWhere((paint) => paint.fill != null);
      expect(main.stroke!.shader, isNotNull);
      expect(marker.fill!.shader, main.stroke!.shader);
    });

    test('nested markers resolve the context recursively', () {
      final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <defs>
  <marker id="inner" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0h1v1z" fill="context-stroke"/></marker>
  <marker id="a" overflow="visible" markerUnits="userSpaceOnUse"><path d="M0 0 L1 1 L2 0" fill="none" stroke="context-stroke" marker-mid="url(#inner)"/></marker>
 </defs>
 <path $path fill="none" stroke="red"/>
</svg>''');
      expect(markerPaint(result).fill!.color, red);
    });

    test('there is no paint outside of a context element', () {
      final VectorInstructions result = parseWithoutOptimizers('''
<svg viewBox="0 0 100 100">
 <path d="M0 0 L20 30" fill="context-fill" stroke="context-stroke"/>
</svg>''');
      expect(result.paths, isEmpty);
    });

    test('encodes with the normal optimizer pipeline', () {
      final Uint8List bytes = encodeSvg(
        xml: '''
<svg viewBox="0 0 100 100">
 <defs><marker id="a" fill="context-stroke" opacity="0.5" markerUnits="userSpaceOnUse"><path d="M0 0h1v1z"/></marker></defs>
 <path d="M0 0 L20 30 L40 0" fill="none" stroke="red" marker-mid="url(#a)"/>
</svg>''',
        debugName: 'marker.svg',
        warningsAsErrors: true,
      );
      expect(bytes, isNotEmpty);
    });
  });
}
