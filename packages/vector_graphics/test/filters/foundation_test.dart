// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
  for (final name in <String>['BackgroundImage', 'BackgroundAlpha', 'FillPaint', 'StrokePaint']) {
    test('unsupported special input produces a diagnostic: $name', () {
      final FilterContext c = context(<String, String>{});
      addTearDown(c.dispose);
      expect(() => c.input(name), throwsUnsupportedError);
    });
  }
  test('negative dimensions rejected', () {
    expect(() => context(<String, String>{'width': '-1'}), throwsFormatException);
  });
  test('unknown operation produces an explicit diagnostic', () async {
    await expectLater(renderSvg(filterSvg('<feNotImplemented/>')), throwsA(anything));
  });
}
