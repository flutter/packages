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
    referenceDescription('integration_flood_clip'),
    () => expectBrowserReference('integration_flood_clip'),
  );
  test(
    referenceDescription('integration_flood_mask'),
    () => expectBrowserReference('integration_flood_mask'),
  );
  test(
    referenceDescription('integration_flood_shape_opacity'),
    () => expectBrowserReference('integration_flood_shape_opacity'),
  );
  test(
    referenceDescription('integration_flood_group_opacity'),
    () => expectBrowserReference('integration_flood_group_opacity'),
  );
  test(
    referenceDescription('integration_flood_ancestor_opacity'),
    () => expectBrowserReference('integration_flood_ancestor_opacity'),
  );
  test(
    referenceDescription('integration_flood_ancestor_zero'),
    () => expectBrowserReference('integration_flood_ancestor_zero'),
  );
  test(
    referenceDescription('integration_flood_nested'),
    () => expectBrowserReference('integration_flood_nested'),
  );
  test(
    referenceDescription('integration_flood_pattern'),
    () => expectBrowserReference('integration_flood_pattern'),
  );
  test(
    referenceDescription('integration_flood_pattern_opacity'),
    () => expectBrowserReference('integration_flood_pattern_opacity'),
  );
  test(
    referenceDescription('integration_flood_root'),
    () => expectBrowserReference('integration_flood_root'),
  );
  test(
    referenceDescription('integration_flood_root_opacity'),
    () => expectBrowserReference('integration_flood_root_opacity'),
  );
  test(
    referenceDescription('integration_flood_use'),
    () => expectBrowserReference('integration_flood_use'),
  );
  test(
    referenceDescription('integration_flood_use_opacity'),
    () => expectBrowserReference('integration_flood_use_opacity'),
  );
  test(
    referenceDescription('integration_flood_filtered_use_opacity'),
    () => expectBrowserReference('integration_flood_filtered_use_opacity'),
  );

  test(
    referenceDescription('integration_mask_red'),
    () => expectBrowserReference('integration_mask_red'),
  );
  test(
    referenceDescription('integration_mask_green'),
    () => expectBrowserReference('integration_mask_green'),
  );
  test(
    referenceDescription('integration_mask_blue'),
    () => expectBrowserReference('integration_mask_blue'),
  );
  test(
    referenceDescription('integration_mask_hex808080'),
    () => expectBrowserReference('integration_mask_hex808080'),
  );
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
    referenceDescription('integration_filtered_mask'),
    () => expectBrowserReference('integration_filtered_mask'),
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
  for (final color in <String>['white', 'black', 'red', 'lime', 'blue', '#808080']) {
    for (final alpha in <double>[0, .25, .5, 1]) {
      for (final filtered in <bool>[false, true]) {
        test('mask alpha multiplies luminance $color $alpha filtered=$filtered', () async {
          final filter = filtered
              ? '<filter id="f" filterUnits="userSpaceOnUse" x="0" y="0" width="128" height="128"><feFlood flood-color="red"/></filter>'
              : '';
          final ui.Image image = await renderSvg(
            '<svg width="128" height="128"><defs>$filter<mask id="m"><rect width="128" height="128" fill="$color" fill-opacity="$alpha"/></mask></defs><rect width="128" height="128" fill="red" mask="url(#m)" ${filtered ? 'filter="url(#f)"' : ''}/></svg>',
          );
          final Uint8List data = await pixels(image);
          image.dispose();
          final double luminance = switch (color) {
            'white' => 1,
            'black' => 0,
            'red' => .2126,
            'lime' => .7152,
            'blue' => .0722,
            _ => 128 / 255,
          };
          expect(data[(64 * 128 + 64) * 4 + 3], closeTo(luminance * alpha * 255, 2));
        });
      }
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
  test('mask bounds do not enlarge the geometry used by a surrounding filter', () async {
    final ui.Image image = await renderSvg(
      '<svg width="128" height="128"><defs><filter id="f"><feFlood flood-color="red"/></filter><mask id="m"><rect width="128" height="128" fill="white"/></mask></defs><g filter="url(#f)"><rect x="32" y="32" width="32" height="32" mask="url(#m)"/></g></svg>',
    );
    final Uint8List data = await pixels(image);
    image.dispose();
    expect(data[(16 * 128 + 16) * 4 + 3], 0);
    expect(data[(40 * 128 + 40) * 4 + 3], 255);
    expect(data[(80 * 128 + 80) * 4 + 3], 0);
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
