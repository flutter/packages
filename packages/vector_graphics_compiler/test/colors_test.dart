// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/src/svg/colors.dart';

void main() {
  group('parseCssRgb - record output validation', () {
    // --- POSITIVE MATCHES: LEGACY SYNTAX ---
    test('Legacy RGB', () {
      expect(parseCssRgb('rgb(255, 0, 0)'), (r: '255', g: '0', b: '0', a: '1'));
    });

    test('Legacy RGBA', () {
      expect(parseCssRgb('rgba(255, 0, 0, 0.5)'), (
        r: '255',
        g: '0',
        b: '0',
        a: '0.5',
      ));
    });

    test('Legacy Percentages', () {
      expect(parseCssRgb('rgb(10%, 20%, 30%)'), (
        r: '10%',
        g: '20%',
        b: '30%',
        a: '1',
      ));
    });

    // --- POSITIVE MATCHES: MODERN SYNTAX ---
    test('Modern Space RGB', () {
      expect(parseCssRgb('rgb(255 0 0)'), (r: '255', g: '0', b: '0', a: '1'));
    });

    test('Modern Space RGBA (no alpha)', () {
      expect(parseCssRgb('rgba(255 0 0)'), (r: '255', g: '0', b: '0', a: '1'));
    });

    test('Modern Alpha Slash', () {
      expect(parseCssRgb('rgb(255 0 0 / 0.5)'), (
        r: '255',
        g: '0',
        b: '0',
        a: '0.5',
      ));
    });

    test('Modern Alpha Percentage', () {
      expect(parseCssRgb('rgba(255 0 0 / 50%)'), (
        r: '255',
        g: '0',
        b: '0',
        a: '50%',
      ));
    });

    // --- POSITIVE MATCHES: NEGATIVES, DECIMALS, WHITESPACE ---
    test('Leading decimal and negative', () {
      expect(parseCssRgb('rgb(-10, 5, .5)'), (
        r: '-10',
        g: '5',
        b: '.5',
        a: '1',
      ));
    });

    test('Trailing and leading decimals', () {
      expect(parseCssRgb('rgb(5. 5. 5. / .1)'), (
        r: '5.',
        g: '5.',
        b: '5.',
        a: '.1',
      ));
    });

    test('Negative percentage/alpha', () {
      expect(parseCssRgb('rgb(-50% 120% 0 / -1)'), (
        r: '-50%',
        g: '120%',
        b: '0',
        a: '-1',
      ));
    });

    test('Case/Tight spacing', () {
      expect(parseCssRgb('RGBA( 255,255,255 )'), (
        r: '255',
        g: '255',
        b: '255',
        a: '1',
      ));
    });

    test('Extra spacing', () {
      expect(parseCssRgb('rgb(  0  0  0  /  0  )'), (
        r: '0',
        g: '0',
        b: '0',
        a: '0',
      ));
    });

    // --- NEGATIVE MATCHES (Should return null) ---
    test('Mixed comma/space returns null', () {
      expect(parseCssRgb('rgb(255, 255 255)'), isNull);
    });

    test('Mixed space/comma returns null', () {
      expect(parseCssRgb('rgb(255 255, 255)'), isNull);
    });

    test('Mixed legacy with slash returns null', () {
      expect(parseCssRgb('rgba(255, 255, 255 / 0.5)'), isNull);
    });

    test('Modern missing slash returns null', () {
      expect(parseCssRgb('rgb(255 255 255 0.5)'), isNull);
    });

    test('Missing blue returns null', () {
      expect(parseCssRgb('rgb(255, 255)'), isNull);
    });

    test('Too many args returns null', () {
      expect(parseCssRgb('rgba(255, 255, 255, 1, 1)'), isNull);
    });

    test('Missing parens returns null', () {
      expect(parseCssRgb('rgb 255, 255, 255'), isNull);
    });

    test('Named colors returns null', () {
      expect(parseCssRgb('rgb(red, green, blue)'), isNull);
    });

    test('Empty returns null', () {
      expect(parseCssRgb('rgb()'), isNull);
    });
  });

  group('parseCssHsl - record output validation', () {
    // --- POSITIVE MATCHES: LEGACY SYNTAX ---
    test('Legacy HSL', () {
      expect(parseCssHsl('hsl(270, 100%, 76%)'), (
        h: '270',
        s: '100%',
        l: '76%',
        a: '1',
      ));
    });

    test('Legacy HSLA', () {
      expect(parseCssHsl('hsla(270, 100%, 76%, 0.5)'), (
        h: '270',
        s: '100%',
        l: '76%',
        a: '0.5',
      ));
    });

    test('Legacy alpha percentage', () {
      expect(parseCssHsl('hsla(270, 100%, 76%, 50%)'), (
        h: '270',
        s: '100%',
        l: '76%',
        a: '50%',
      ));
    });

    // --- POSITIVE MATCHES: MODERN SYNTAX ---
    test('Modern Space HSL', () {
      expect(parseCssHsl('hsl(270 100% 76%)'), (
        h: '270',
        s: '100%',
        l: '76%',
        a: '1',
      ));
    });

    test('Modern Space HSLA (no alpha)', () {
      expect(parseCssHsl('hsla(270 100% 76%)'), (
        h: '270',
        s: '100%',
        l: '76%',
        a: '1',
      ));
    });

    test('Modern Alpha Slash', () {
      expect(parseCssHsl('hsla(270 100% 76% / 0.5)'), (
        h: '270',
        s: '100%',
        l: '76%',
        a: '0.5',
      ));
    });

    test('Modern Alpha Percentage', () {
      expect(parseCssHsl('hsla(270 100% 76% / 50%)'), (
        h: '270',
        s: '100%',
        l: '76%',
        a: '50%',
      ));
    });

    // --- POSITIVE MATCHES: NEGATIVES, DECIMALS, WHITESPACE ---
    test('Leading decimal and negative', () {
      expect(parseCssHsl('hsl(-.5 100% 76%)'), (
        h: '-.5',
        s: '100%',
        l: '76%',
        a: '1',
      ));
    });

    test('Trailing and leading decimals', () {
      expect(parseCssHsl('hsl(270. 100% 76. / .5)'), (
        h: '270.',
        s: '100%',
        l: '76.',
        a: '.5',
      ));
    });

    test('Negative percentage/alpha', () {
      expect(parseCssHsl('hsl(270 -10% 120% / -1)'), (
        h: '270',
        s: '-10%',
        l: '120%',
        a: '-1',
      ));
    });

    test('Case/Tight spacing', () {
      expect(parseCssHsl('HSLA( 270,100%,76% )'), (
        h: '270',
        s: '100%',
        l: '76%',
        a: '1',
      ));
    });

    test('Extra spacing', () {
      expect(parseCssHsl('hsl(  270  100%  76%  /  0  )'), (
        h: '270',
        s: '100%',
        l: '76%',
        a: '0',
      ));
    });

    // --- NEGATIVE MATCHES (Should return null) ---
    test('Mixed comma/space returns null', () {
      expect(parseCssHsl('hsl(270, 100% 76%)'), isNull);
    });

    test('Mixed space/comma returns null', () {
      expect(parseCssHsl('hsl(270 100%, 76%)'), isNull);
    });

    test('Mixed legacy with slash returns null', () {
      expect(parseCssHsl('hsla(270, 100%, 76% / 0.5)'), isNull);
    });

    test('Modern missing slash returns null', () {
      expect(parseCssHsl('hsl(270 100% 76% 0.5)'), isNull);
    });

    test('Missing lightness returns null', () {
      expect(parseCssHsl('hsl(270, 100%)'), isNull);
    });

    test('Too many args returns null', () {
      expect(parseCssHsl('hsla(270, 100%, 76%, 1, 1)'), isNull);
    });

    test('Missing parens returns null', () {
      expect(parseCssHsl('hsl 270, 100%, 76%'), isNull);
    });

    test('Named colors returns null', () {
      expect(parseCssHsl('hsl(red, 100%, 76%)'), isNull);
    });

    test('Empty returns null', () {
      expect(parseCssHsl('hsl()'), isNull);
    });

    test('Empty value returns null', () {
      expect(parseCssHsl('hsl(270,,76%)'), isNull);
    });

    test('Trailing comma returns null', () {
      expect(parseCssHsl('hsl(270, 100%, 76%,)'), isNull);
    });
  });
}
