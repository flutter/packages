// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/listener.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    referenceDescription('integration_mask_inside_filter'),
    () => expectBrowserReference('integration_mask_inside_filter'),
  );
  test(
    referenceDescription('integration_mask_inside_transformed_filter'),
    () => expectBrowserReference('integration_mask_inside_transformed_filter'),
  );
  test(
    referenceDescription('integration_nested_masks'),
    () => expectBrowserReference('integration_nested_masks'),
  );
  test(
    referenceDescription('integration_mask_clip_layers'),
    () => expectBrowserReference('integration_mask_clip_layers'),
  );

  for (final opacity in <double>[0, .25, .5, 1]) {
    for (final fill in <double>[0, .25, .5, 1]) {
      test(
        'group opacity follows filter, fill opacity belongs to each source shape: $opacity $fill',
        () async {
          final ui.Image image = await renderSvg(
            filterSvg(
              '<feOffset/>',
              shape:
                  '<rect x="16" y="16" width="64" height="64" fill="red"/><rect x="48" y="16" width="64" height="64" fill="red"/>',
            ).replaceFirst('<g filter=', '<g opacity="$opacity" fill-opacity="$fill" filter='),
          );
          final Uint8List data = await pixels(image);
          image.dispose();
          final double a = (fill * 255).round() / 255;
          expect(data[(32 * 128 + 32) * 4 + 3], closeTo(a * opacity * 255, 1));
          expect(data[(32 * 128 + 64) * 4 + 3], closeTo((2 * a - a * a) * opacity * 255, 2));
        },
      );
    }
  }
  for (final opacity in <double>[.25, .5, 1]) {
    test('text is filtered once and keeps opacity outside the filter: $opacity', () async {
      const content = '<text x="24" y="64" font-size="24" fill="red">Hi</text>';
      const defs =
          '<defs><filter id="f" filterUnits="userSpaceOnUse" x="0" y="0" width="128" height="128"><feOffset dx="8" dy="4"/></filter></defs>';
      final ui.Image filtered = await renderSvg(
        '<svg width="128" height="128">$defs${content.replaceFirst('<text ', '<text filter="url(#f)" opacity="$opacity" ')}</svg>',
      );
      final ui.Image explicit = await renderSvg(
        '<svg width="128" height="128">$defs<g transform="translate(8 4)" opacity="$opacity">$content</g></svg>',
      );
      final Uint8List actual = await pixels(filtered), expected = await pixels(explicit);
      filtered.dispose();
      explicit.dispose();
      expect(actual, expected);
      expect(actual.where((int c) => c > 0), isNotEmpty);
    });
  }
  test('pending text does not move into the following clipped layer', () async {
    const first = '<text x="16" y="48" font-size="24" fill="red">Hi</text>';
    const defs =
        '<defs><filter id="f"><feOffset/></filter><clipPath id="c"><rect x="64" width="64" height="128"/></clipPath></defs>';
    final ui.Image a = await renderSvg(
      '<svg width="128" height="128">$defs$first<g opacity=".5" clip-path="url(#c)"><rect x="72" y="64" width="32" height="32" fill="blue"/></g></svg>',
    );
    final ui.Image b = await renderSvg(
      '<svg width="128" height="128">$defs<g>$first</g><rect x="72" y="64" width="32" height="32" fill="blue" fill-opacity=".5"/></svg>',
    );
    expect(await pixels(a), await pixels(b));
    a.dispose();
    b.dispose();
  });
  test('aborting open nested mask recorders is idempotent', () {
    final listener = FlutterVectorGraphicsListener();
    listener.onMask();
    listener.onMask();
    listener.abort();
    listener.abort();
  });
  test('unclosed masks produce a diagnostic and can be aborted', () {
    final listener = FlutterVectorGraphicsListener();
    listener.onMask();
    expect(listener.toPicture, throwsFormatException);
    listener.abort();
  });
  test(
    referenceDescription('integration_pattern_contains_filter'),
    () => expectBrowserReference('integration_pattern_contains_filter'),
  );
  test(
    referenceDescription('integration_pattern_contains_mask'),
    () => expectBrowserReference('integration_pattern_contains_mask'),
  );
  test(
    referenceDescription('integration_pattern_contains_nested'),
    () => expectBrowserReference('integration_pattern_contains_nested'),
  );
  final identity = Float64List.fromList(<double>[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
  for (final value in <double>[0, -1, double.nan, double.infinity]) {
    test('invalid pattern size $value is rejected without retaining a recorder', () {
      final listener = FlutterVectorGraphicsListener();
      expect(() => listener.onPatternStart(0, 0, 0, value, 16, identity), throwsFormatException);
      listener.abort();
      listener.abort();
    });
  }
  test('pattern allocation uses the shared dimension budget', () {
    final listener = FlutterVectorGraphicsListener();
    listener.onPatternStart(0, 0, 0, 10000, 1, identity);
    expect(listener.onRestoreLayer, throwsStateError);
    listener.abort();
  });
  test('aborting nested pattern and mask captures closes every recorder', () {
    final listener = FlutterVectorGraphicsListener();
    listener.onPatternStart(0, 0, 0, 16, 16, identity);
    listener.onPatternStart(1, 0, 0, 8, 8, identity);
    listener.onMask();
    listener.abort();
    listener.abort();
  });
}
