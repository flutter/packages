// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Future<Uint8List> render(String svg) async {
  final ui.Image image = await renderSvg(svg);
  try {
    return await pixels(image);
  } finally {
    image.dispose();
  }
}

List<int> pixel(Uint8List image, int x, int y) =>
    image.sublist((y * 128 + x) * 4, (y * 128 + x) * 4 + 4);

const String curveBounds = '''
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="128" height="128">
<defs>
<filter id="f" x="0" y="0" width="1" height="1">
<feFlood flood-color="blue"/>
</filter>
</defs>
<path d="M16 112 C16 -16 112 -16 112 112 Z" filter="url(#f)"/>
</svg>
''';
const String nestedBounds = '''
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="128" height="128">
<defs>
<filter id="f">
<feFlood flood-color="blue"/>
</filter>
<filter id="identity">
<feOffset/>
</filter>
</defs>
<g filter="url(#f)">
<path filter="url(#identity)" transform="translate(64 32) rotate(45)" d="M0 0 L32 0 L0 32 Z"/>
</g>
</svg>
''';
const String directBounds = '''
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="128" height="128">
<defs>
<filter id="f">
<feFlood flood-color="blue"/>
</filter>
</defs>
<g filter="url(#f)">
<path transform="translate(64 32) rotate(45)" d="M0 0 L32 0 L0 32 Z"/>
</g>
</svg>
''';
const String shapeBlend = '''
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="128" height="128">
<defs>
<filter id="f">
<feFlood flood-color="red"/>
</filter>
</defs>
<rect width="128" height="128" fill="blue"/>
<rect x="24" y="24" width="64" height="64" fill="red" style="mix-blend-mode:screen" filter="url(#f)"/>
</svg>
''';
const String groupBlend = '''
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="128" height="128">
<defs>
<filter id="f">
<feFlood flood-color="red"/>
</filter>
</defs>
<rect width="128" height="128" fill="blue"/>
<g style="mix-blend-mode:screen" filter="url(#f)">
<rect x="24" y="24" width="64" height="64" fill="red"/>
</g>
</svg>
''';
const String animate = '''
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="128" height="128">
<defs>
<filter id="f">
<feFlood flood-color="blue"/>
<animate attributeName="x" from="-10%" to="-20%" dur="1s" begin="indefinite"/>
</filter>
</defs>
<rect x="24" y="24" width="64" height="64" fill="red" filter="url(#f)"/>
</svg>
''';
const String mergeScript = '''
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="128" height="128">
<defs>
<filter id="f">
<feMerge>
<feMergeNode in="SourceGraphic"/>
<script type="application/ecmascript"/>
</feMerge>
</filter>
</defs>
<rect x="24" y="24" width="64" height="64" fill="red" filter="url(#f)"/>
</svg>
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('cubic object bounds exclude control points', () async {
    final Uint8List image = await render(curveBounds);
    expect(pixel(image, 24, 8), <int>[0, 0, 0, 0]);
    expect(pixel(image, 24, 16), <int>[0, 0, 255, 255]);
    expect(
      image,
      await render(
        curveBounds.replaceFirst('M16 112 C16 -16 112 -16 112 112 Z', 'M16 16 H112 V112 H16 Z'),
      ),
    );
  });
  for (final transform in <String>[
    'translate(64 32) rotate(45)',
    'translate(32 32) skewX(30)',
    'translate(64 80) rotate(-30) scale(1 -1)',
  ]) {
    test('nested identity filters preserve ancestor geometry: $transform', () async {
      final String nested = nestedBounds.replaceAll('translate(64 32) rotate(45)', transform);
      final String direct = directBounds.replaceAll('translate(64 32) rotate(45)', transform);
      expect(await render(nested), await render(direct));
    });
  }
  for (final svg in <String>[shapeBlend, groupBlend]) {
    test(
      'filtered element blends generated pixels (${svg == shapeBlend ? 'shape' : 'group'})',
      () async {
        expect(pixel(await render(svg), 56, 56), <int>[255, 0, 255, 255]);
        expect(
          pixel(
            await render(
              svg.replaceFirst('mix-blend-mode:screen', 'mix-blend-mode:screen;opacity:.5'),
            ),
            56,
            56,
          ),
          <int>[128, 0, 255, 255],
        );
      },
    );
  }

  for (final shape in <String>[
    '<use href="#r" style="mix-blend-mode:screen" filter="url(#f)"/>',
    '<text x="24" y="56" font-size="32" style="mix-blend-mode:screen" filter="url(#f)">TEST</text>',
  ]) {
    test('generated filter pixels blend for $shape', () async {
      final Uint8List image = await render('''
        <svg width="128" height="128"><defs>
          <filter id="f"><feFlood flood-color="red"/></filter>
          <rect id="r" x="24" y="24" width="64" height="64"/>
        </defs><rect width="128" height="128" fill="blue"/>$shape</svg>
      ''');
      expect(pixel(image, 30, 40), <int>[255, 0, 255, 255]);
    });
  }
  for (final constraint in <String>['clip-path="url(#c)"', 'mask="url(#m)"']) {
    test('filtered blending survives $constraint', () async {
      final Uint8List image = await render('''
        <svg width="128" height="128"><defs>
          <filter id="f"><feFlood flood-color="red"/></filter>
          <clipPath id="c"><rect width="64" height="64"/></clipPath>
          <mask id="m"><rect width="64" height="64" fill="white"/></mask>
        </defs><rect width="128" height="128" fill="blue"/>
        <rect x="24" y="24" width="64" height="64" style="mix-blend-mode:screen"
          filter="url(#f)" $constraint/></svg>
      ''');
      expect(pixel(image, 40, 40), <int>[255, 0, 255, 255]);
      expect(pixel(image, 72, 72), <int>[0, 0, 255, 255]);
    });
  }
  test('descendant blending is retained inside the filtered source', () async {
    final Uint8List image = await render('''
<svg width="128" height="128">
      <defs><filter id="f"><feOffset/></filter></defs>
      <rect width="128" height="128" fill="blue"/>
      <g style="mix-blend-mode:screen" filter="url(#f)">
        <rect x="24" y="24" width="64" height="64" fill="lime"/>
        <rect x="24" y="24" width="32" height="32" fill="red" style="mix-blend-mode:screen"/>
      </g>
    </svg>''');
    expect(pixel(image, 40, 40), <int>[255, 255, 255, 255]);
    expect(pixel(image, 72, 72), <int>[0, 255, 255, 255]);
  });

  test('primitive object units use tight curve bounds for offsets', () async {
    final Uint8List image = await render('''
<svg width="128" height="128">
      <defs><filter id="f" filterUnits="userSpaceOnUse" primitiveUnits="objectBoundingBox"
        x="0" y="0" width="128" height="128"><feOffset dy=".5"/></filter></defs>
      <g filter="url(#f)"><path d="M16 112 C16 -16 112 -16 112 112 Z" fill="none"/>
        <rect x="24" y="24" width="16" height="16" fill="red"/></g>
    </svg>''');
    expect(
      image,
      await render(
        '<svg width="128" height="128"><rect x="24" y="72" width="16" height="16" fill="red"/></svg>',
      ),
    );
  });
  test('inactive animation is not a filter primitive', () async {
    expect(pixel(await render(animate), 56, 56), <int>[0, 0, 255, 255]);
  });
  test('script is not a merge node', () async {
    expect(pixel(await render(mergeScript), 56, 56), <int>[255, 0, 0, 255]);
  });
  test('SVG 1.1 filter templates inherit attributes and children', () async {
    const svg =
        '<svg width="128" height="128" xmlns:xlink="http://www.w3.org/1999/xlink">'
        ' <defs><filter id="f" xlink:href="#middle"/><filter id="middle" href="#base"/>'
        ' <filter id="base" x="0" y="0" width="1" height="1"><feFlood flood-color="blue"/></filter></defs>'
        ' <rect x="16" y="24" width="64" height="48" filter="url(#f)"/></svg>';
    expect(
      await render(svg),
      await render(
        '<svg width="128" height="128"><rect x="16" y="24" width="64" height="48" fill="blue"/></svg>',
      ),
    );
  });
  for (final axis in <String>['width', 'height']) {
    for (final size in <String>['0', '-1']) {
      for (final primitive in <String>['feFlood', 'feOffset']) {
        test('$primitive with $axis=$size produces transparent output', () async {
          final Uint8List data = await render(filterSvg('<$primitive $axis="$size"/>'));
          expect(data.every((int value) => value == 0), isTrue);
        });
      }
    }
  }
}
