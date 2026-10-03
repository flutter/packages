// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(referenceDescription('flood_defaults'), () => expectBrowserReference('flood_defaults'));
  test(referenceDescription('flood_named'), () => expectBrowserReference('flood_named'));
  test(referenceDescription('flood_hex'), () => expectBrowserReference('flood_hex'));
  test(referenceDescription('flood_rgba'), () => expectBrowserReference('flood_rgba'));
  test(referenceDescription('flood_hex_alpha'), () => expectBrowserReference('flood_hex_alpha'));
  test(
    referenceDescription('flood_rgb_percent'),
    () => expectBrowserReference('flood_rgb_percent'),
  );
  test(
    referenceDescription('flood_transparent'),
    () => expectBrowserReference('flood_transparent'),
  );
  test(referenceDescription('flood_opacity'), () => expectBrowserReference('flood_opacity'));
  test(
    referenceDescription('flood_opacity_percent'),
    () => expectBrowserReference('flood_opacity_percent'),
  );
  test(
    referenceDescription('flood_opacity_negative'),
    () => expectBrowserReference('flood_opacity_negative'),
  );
  test(
    referenceDescription('flood_opacity_over'),
    () => expectBrowserReference('flood_opacity_over'),
  );
  test(
    referenceDescription('flood_alpha_product'),
    () => expectBrowserReference('flood_alpha_product'),
  );
  test(referenceDescription('flood_style'), () => expectBrowserReference('flood_style'));
  test(
    referenceDescription('flood_current_color'),
    () => expectBrowserReference('flood_current_color'),
  );
  test(
    referenceDescription('flood_explicit_inherit'),
    () => expectBrowserReference('flood_explicit_inherit'),
  );
  test(
    referenceDescription('flood_not_inherited'),
    () => expectBrowserReference('flood_not_inherited'),
  );
  test(referenceDescription('flood_subregion'), () => expectBrowserReference('flood_subregion'));
  test(
    referenceDescription('flood_zero_region'),
    () => expectBrowserReference('flood_zero_region'),
  );
  test(
    referenceDescription('flood_ignored_input'),
    () => expectBrowserReference('flood_ignored_input'),
  );
  test(referenceDescription('flood_bbox'), () => expectBrowserReference('flood_bbox'));
  test(
    referenceDescription('flood_chain'),
    () => expectBrowserReference('flood_chain', allowOnePixelClipRounding: true),
  );
  test(
    referenceDescription('flood_linear_color'),
    () => expectBrowserReference('flood_linear_color', allowOnePixelClipRounding: true),
  );

  for (final (String opacity, int expected) in <(String, int)>[
    ('0', 0),
    ('.25', 64),
    ('.5', 128),
    ('1', 255),
    ('-1', 0),
    ('2', 255),
    ('25%', 64),
    ('50%', 128),
    ('100%', 255),
    ('200%', 255),
  ]) {
    test('independent opacity expectation $opacity', () async {
      final ui.Image image = await renderSvg(
        filterSvg('<feFlood flood-color="#ff0000" flood-opacity="$opacity"/>'),
      );
      try {
        final Uint8List data = await pixels(image);
        for (final point in <int>[0, 40 * 128 + 40, 127 * 128 + 127]) {
          expect(data[point * 4 + 3], closeTo(expected, 1));
          if (expected > 0) {
            expect(data[point * 4], 255);
          }
        }
      } finally {
        image.dispose();
      }
    });
  }
  for (final value in <String>['NaN', 'Infinity', 'bad', '1px', '1 2']) {
    test('invalid flood-opacity=$value uses initial opacity', () async {
      final ui.Image image = await renderSvg(filterSvg('<feFlood flood-opacity="$value"/>'));
      try {
        final Uint8List data = await pixels(image);
        expect(data.sublist((48 * 128 + 48) * 4, (48 * 128 + 48) * 4 + 4), <int>[0, 0, 0, 255]);
      } finally {
        image.dispose();
      }
    });
  }
  test('color alpha multiplies primitive opacity', () async {
    final ui.Image image = await renderSvg(
      filterSvg('<feFlood flood-color="rgba(255,0,0,.5)" flood-opacity=".5"/>'),
    );
    final Uint8List data = await pixels(image);
    image.dispose();
    expect(data.sublist(0, 4), <int>[255, 0, 0, 64]);
  });
  test('invalid flood color falls back to initial black', () async {
    final ui.Image image = await renderSvg(filterSvg('<feFlood flood-color="bogus"/>'));
    try {
      final Uint8List data = await pixels(image);
      expect(data.sublist((48 * 128 + 48) * 4, (48 * 128 + 48) * 4 + 4), <int>[0, 0, 0, 255]);
    } finally {
      image.dispose();
    }
  });
  test('invalid opacity in style retains the presentation attribute', () async {
    final ui.Image image = await renderSvg(
      filterSvg('<feFlood flood-color="red" flood-opacity=".25" style="flood-opacity: bogus"/>'),
    );
    try {
      final Uint8List data = await pixels(image);
      expect(data.sublist((48 * 128 + 48) * 4, (48 * 128 + 48) * 4 + 4), <int>[255, 0, 0, 64]);
    } finally {
      image.dispose();
    }
  });
}
