// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

void main() {
  for (final value in <String>[
    '96',
    '96px',
    '1in',
    '2.54cm',
    '25.4mm',
    '101.6Q',
    '72pt',
    '6pc',
    '9.6e1px',
  ]) {
    test('physical length $value resolves to 96 CSS pixels', () {
      expect(parseSvgLength(value), closeTo(96, 1e-10));
      expect(parseSvgLength(' -$value '), closeTo(-96, 1e-10));
    });
  }
  test('font and percentage contexts stay independent', () {
    expect(parseSvgLength('2em', fontSize: 20), 40);
    expect(parseSvgLength('2ex', fontSize: 20, xHeight: 7), 14);
    expect(parseSvgLength('2rem', fontSize: 20, rootFontSize: 12), 24);
    expect(parseSvgLength('25%', percentageRef: 240), 60);
    expect(parseSvgLength('-.5%', percentageRef: 200), -1);
    expect(parseSvgLength('0%', percentageRef: 0), 0);
  });
  for (final value in <String>[
    '',
    'NaN',
    'Infinity',
    '1e999in',
    '1furlong',
    '1pxjunk',
    '1 2',
    '1 em',
    '20%',
  ]) {
    test('invalid or unresolved length $value fails explicitly', () {
      expect(() => parseSvgLength(value), throwsFormatException);
    });
  }
}
