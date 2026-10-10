// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// XML text adjacency is intentional in the layout regression fixtures.
// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final name in <String>[
    'offset_unpainted_bbox',
    'offset_unpainted_transform',
    'offset_unpainted_use',
    'offset_unpainted_nested',
    'offset_unpainted_clip',
    'offset_unpainted_mask',
    'offset_dashed_bbox',
    'offset_metadata',
    'offset_physical_units',
    'offset_font_units',
  ]) {
    test(referenceDescription(name), () => expectBrowserReference(name));
  }

  for (final scale in <double>[1, 2, 3]) {
    test('unpainted geometry controls objectBoundingBox at scale $scale', () async {
      final ui.Image image = await renderSvg(
        '<svg width="128" height="128"><defs><filter id="f" '
        'filterUnits="userSpaceOnUse" x="0" y="0" width="128" height="128" '
        'primitiveUnits="objectBoundingBox"><feOffset dx=".5"/></filter></defs>'
        '<g filter="url(#f)"><rect width="100" height="100" fill="none"/>'
        '<rect x="16" y="16" width="16" height="16" fill="red"/></g></svg>',
        scale: scale,
      );
      final Uint8List data = await pixels(image);
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final bool inside =
              x >= 66 * scale && x < 82 * scale && y >= 16 * scale && y < 32 * scale;
          expect(data[(y * image.width + x) * 4 + 3], inside ? 255 : 0, reason: '($x, $y)');
        }
      }
      image.dispose();
    });
  }

  for (final anchor in <String>['start', 'middle', 'end']) {
    test('unpainted text retains bounds and pen advance with $anchor anchoring', () async {
      String svg(String paint) =>
          '<svg width="128" height="128"><defs>'
          '<filter id="f" filterUnits="userSpaceOnUse" x="0" y="0" width="128" height="128" '
          'primitiveUnits="objectBoundingBox"><feOffset dx=".25"/></filter></defs>'
          '<g filter="url(#f)"><text x="40" y="50" font-size="12" text-anchor="$anchor">'
          '<tspan $paint>WIDE</tspan><tspan fill="red">TEXT</tspan></text>'
          '<rect x="10" y="10" width="5" height="5" fill="red"/></g></svg>';
      final ui.Image absent = await renderSvg(svg('fill="none"'));
      final ui.Image transparent = await renderSvg(svg('fill="red" fill-opacity="0"'));
      expect(await pixels(absent), await pixels(transparent));
      absent.dispose();
      transparent.dispose();
    });
  }
}
