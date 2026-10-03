// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/filters/filter_context.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final name in <String>['unfiltered', 'empty']) {
    test(referenceDescription(name), () => expectBrowserReference(name));
  }

  FilterContext context(Map<String, String> attributes) {
    final recorder = PictureRecorder();
    Canvas(recorder);
    return FilterContext(
      VectorFilter('filter', attributes),
      recorder.endRecording(),
      const Rect.fromLTWH(20, 30, 40, 50),
      const Size(128, 128),
    );
  }

  test('default filter region expands geometry bounds by ten percent', () {
    final FilterContext c = context(<String, String>{});
    addTearDown(c.dispose);
    expect(c.region, const Rect.fromLTWH(16, 25, 48, 60));
  });
  test('user-space percentages use the viewport', () {
    final FilterContext c = context(<String, String>{
      'filterUnits': 'userSpaceOnUse',
      'x': '25%',
      'y': '50%',
      'width': '50%',
      'height': '25%',
    });
    addTearDown(c.dispose);
    expect(c.region, const Rect.fromLTWH(32, 64, 64, 32));
  });
  for (final axis in <bool>[false, true]) {
    test('object primitive units resolve positions and distances: $axis', () {
      final FilterContext c = context(<String, String>{'primitiveUnits': 'objectBoundingBox'});
      addTearDown(c.dispose);
      expect(c.length('0.5', horizontal: axis), axis ? 20 : 25);
      expect(c.length('50%', horizontal: axis, position: true), axis ? 40 : 55);
    });
  }
  for (final value in <String>['NaN', 'Infinity', '-Infinity', 'bad', '', '1e999']) {
    test('reject nonfinite or malformed numbers: $value', () {
      expect(() => FilterContext.number(value), throwsFormatException);
    });
  }
  test('commas, exponent notation and signed values', () {
    expect(FilterContext.numbers(' 1e-2, -2 +3 '), <double>[0.01, -2, 3]);
  });
  test('named results are scoped and resolve before overwritten', () {
    final FilterContext c = context(<String, String>{});
    addTearDown(c.dispose);
    expect(c.input(null), same(c.sourceGraphic));
    expect(c.input('later'), same(c.previous));
    c.publish(VectorFilter('test', const <String, String>{'result': 'first'}), c.sourceGraphic);
    expect(c.input('first'), same(c.sourceGraphic));
    expect(c.input('SourceAlpha'), same(c.input('SourceAlpha')));
  });
  for (final name in <String>['BackgroundImage', 'BackgroundAlpha']) {
    test('unsupported special input produces a diagnostic: $name', () {
      final FilterContext c = context(<String, String>{});
      addTearDown(c.dispose);
      expect(() => c.input(name), throwsUnsupportedError);
    });
  }
  for (final (String input, String color, List<int> expected) in <(String, String, List<int>)>[
    ('FillPaint', 'fill="#ff0000"', <int>[255, 0, 0, 255]),
    ('StrokePaint', 'stroke="#0000ff" stroke-opacity="0.5"', <int>[0, 0, 255, 128]),
  ]) {
    test('$input uses the filtered element paint beyond its geometry', () async {
      final Image image = await renderSvg('''
<svg width="128" height="128">
  <defs><filter id="f" filterUnits="userSpaceOnUse" x="0" y="0" width="128" height="128">
    <feOffset in="$input" dx="16"/>
  </filter></defs>
  <rect x="32" y="32" width="32" height="32" $color filter="url(#f)"/>
</svg>''');
      try {
        final Uint8List data = await pixels(image);
        expect(data.sublist((8 * 128 + 8) * 4, (8 * 128 + 8) * 4 + 4), expected);
      } finally {
        image.dispose();
      }
    });
  }
  test('FillPaint none is transparent', () async {
    final Image image = await renderSvg('''
<svg width="128" height="128">
  <defs><filter id="f" filterUnits="userSpaceOnUse" x="0" y="0" width="128" height="128">
    <feOffset in="FillPaint"/>
  </filter></defs>
  <rect x="32" y="32" width="32" height="32" fill="none" filter="url(#f)"/>
</svg>''');
    try {
      final Uint8List data = await pixels(image);
      expect(data[(40 * 128 + 40) * 4 + 3], 0);
    } finally {
      image.dispose();
    }
  });
  test('FillPaint inherits the filtered group color', () async {
    final Image image = await renderSvg('''
<svg width="128" height="128">
  <defs><filter id="f" filterUnits="userSpaceOnUse" x="0" y="0" width="128" height="128">
    <feOffset in="FillPaint"/>
  </filter></defs>
  <g fill="#00ff00" filter="url(#f)"><rect x="32" y="32" width="32" height="32"/></g>
</svg>''');
    try {
      final Uint8List data = await pixels(image);
      expect(data.sublist((8 * 128 + 8) * 4, (8 * 128 + 8) * 4 + 4), <int>[0, 255, 0, 255]);
    } finally {
      image.dispose();
    }
  });
  test("a shared filter uses each element's FillPaint", () async {
    final Image image = await renderSvg('''
<svg width="128" height="128">
  <defs><filter id="f" x="0" y="0" width="100%" height="100%">
    <feOffset in="FillPaint"/>
  </filter></defs>
  <rect x="0" y="0" width="32" height="32" fill="red" filter="url(#f)"/>
  <rect x="64" y="0" width="32" height="32" fill="blue" filter="url(#f)"/>
</svg>''');
    try {
      final Uint8List data = await pixels(image);
      expect(data.sublist((16 * 128 + 16) * 4, (16 * 128 + 16) * 4 + 4), <int>[255, 0, 0, 255]);
      expect(data.sublist((16 * 128 + 80) * 4, (16 * 128 + 80) * 4 + 4), <int>[0, 0, 255, 255]);
    } finally {
      image.dispose();
    }
  });
  test('gradient FillPaint reports the unsupported paint type', () async {
    await expectLater(
      renderSvg('''
<svg width="128" height="128">
  <defs>
    <linearGradient id="g"><stop stop-color="red"/><stop offset="1" stop-color="blue"/></linearGradient>
    <filter id="f"><feOffset in="FillPaint"/></filter>
  </defs>
  <rect x="32" y="32" width="32" height="32" fill="url(#g)" filter="url(#f)"/>
</svg>'''),
      throwsA(
        isA<Object>().having(
          (Object error) => error.toString(),
          'diagnostic',
          contains('SVG filter input FillPaint requires a solid paint'),
        ),
      ),
    );
  });
  test('negative dimensions rejected', () {
    expect(() => context(<String, String>{'width': '-1'}), throwsFormatException);
  });
  test('unknown operation produces an explicit diagnostic', () async {
    await expectLater(renderSvg(filterSvg('<feNotImplemented/>')), throwsA(anything));
  });
}
