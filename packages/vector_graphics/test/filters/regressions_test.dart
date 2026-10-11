// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// XML adjacency preserves SVG text whitespace.
// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/filters/filter_context.dart';
import 'package:vector_graphics/src/filters/filter_executor.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'helpers.dart';

Future<ui.Rect> paintedBounds(ui.Image image) async {
  final Uint8List data = await pixels(image);
  ui.Rect bounds = ui.Rect.zero;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (data[(y * image.width + x) * 4 + 3] == 0) {
        continue;
      }
      final rect = ui.Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1);
      bounds = bounds.isEmpty ? rect : bounds.expandToInclude(rect);
    }
  }
  return bounds;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final attributes in <String>[
    'flood-color=" red " flood-opacity="50%"',
    'flood-color="red" flood-opacity=" 50% "',
    'flood-color=" currentColor " flood-opacity=" 50% " color=" red "',
  ]) {
    test('filter presentation whitespace: $attributes', () async {
      String svg(String attributes) =>
          '<svg width="128" height="128"><filter id="f"><feFlood $attributes/></filter>'
          '<rect width="128" height="128" filter="url(#f)"/></svg>';
      final ui.Image actual = await renderSvg(svg(attributes));
      final ui.Image expected = await renderSvg(svg('flood-color="red" flood-opacity="50%"'));
      addTearDown(actual.dispose);
      addTearDown(expected.dispose);
      expect(await pixels(actual), await pixels(expected));
    });
  }

  for (final tag in <String>['g', 'a']) {
    for (final reuse in <bool>[false, true]) {
      test('self-closing $tag paints its filter and preserves siblings, use=$reuse', () async {
        String svg(bool selfClosing) {
          final group = '<$tag id="empty" filter="url(#f)"${selfClosing ? '/>' : '></$tag>'}';
          return '<svg width="128" height="128"><defs><filter id="f" filterUnits="userSpaceOnUse" '
              'x="0" y="0" width="128" height="128"><feFlood flood-color="red"/></filter>'
              '${reuse ? group : ''}</defs>${reuse ? '<use href="#empty"/>' : group}'
              '<rect x="64" width="64" height="128" fill="blue"/></svg>';
        }

        final ui.Image actual = await renderSvg(svg(true));
        final ui.Image expected = await renderSvg(svg(false));
        addTearDown(actual.dispose);
        addTearDown(expected.dispose);
        final Uint8List reference = await pixels(expected);
        expect(reference.sublist(0, 4), <int>[255, 0, 0, 255]);
        expect(reference.sublist(64 * 4, 64 * 4 + 4), <int>[0, 0, 255, 255]);
        expect(await pixels(actual), reference);
      });
    }
  }

  test('unpainted filtered geometry retains element opacity', () async {
    final ui.Image image = await renderSvg(
      '<svg width="128" height="128"><filter id="f"><feFlood flood-color="red"/></filter>'
      '<rect x="32" y="32" width="32" height="32" fill="none" opacity=".5" filter="url(#f)"/></svg>',
    );
    addTearDown(image.dispose);
    final Uint8List data = await pixels(image);
    expect(data.sublist((40 * 128 + 40) * 4, (40 * 128 + 40) * 4 + 3), <int>[255, 0, 0]);
    expect(data[(40 * 128 + 40) * 4 + 3], closeTo(128, 1));
  });

  for (final anchor in <String>['middle', 'end']) {
    for (final layer in <String>[
      'opacity=".5"',
      'filter="url(#f)"',
      'clip-path="url(#c)"',
      'mask="url(#m)"',
    ]) {
      test('$anchor text anchoring spans $layer', () async {
        String svg(String text) =>
            '<svg width="128" height="128"><defs><filter id="f"><feOffset/></filter>'
            '<clipPath id="c"><rect width="128" height="128"/></clipPath>'
            '<mask id="m"><rect width="128" height="128" fill="white"/></mask></defs>'
            '<text x="100" y="70" font-size="12" text-anchor="$anchor">$text</text></svg>';
        final ui.Image actual = await renderSvg(svg('AA<tspan $layer>BB</tspan>CC'));
        final ui.Image expected = await renderSvg(svg('AABBCC'));
        addTearDown(actual.dispose);
        addTearDown(expected.dispose);
        expect(await paintedBounds(actual), await paintedBounds(expected));
      });
    }
  }

  for (final operation in <String>['feMerge']) {
    test('repeated $operation inputs have bounded playback and preserve pixels', () async {
      final children = <VectorFilter>[
        VectorFilter('feFlood', const <String, String>{'flood-color-argb': '4294901760'}),
        for (var i = 0; i < 32; i++)
          VectorFilter(
            operation,
            <String, String>{
              'result': 'r$i',
              if (i > 0 && operation != 'feMerge') 'in2': 'r${i - 1}',
            },
            operation == 'feMerge'
                ? <VectorFilter>[
                    VectorFilter('feMergeNode', const <String, String>{}),
                    VectorFilter('feMergeNode', const <String, String>{}),
                  ]
                : const <VectorFilter>[],
          ),
      ];
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder);
      final context = FilterContext(
        VectorFilter('filter', const <String, String>{
          'x': '0',
          'y': '0',
          'width': '1',
          'height': '1',
          'color-interpolation-filters': 'sRGB',
        }, children),
        recorder.endRecording(),
        const ui.Rect.fromLTWH(0, 0, 16, 16),
        const ui.Size(16, 16),
      );
      addTearDown(context.dispose);
      final FilterImage result = executeFilter(context);
      expect(context.requiresRasterResolution, isTrue);
      expect(result.replayCost, lessThanOrEqualTo(FilterContext.maxPictureReplays));
      final ui.Image image = await result.picture.toImage(16, 16);
      addTearDown(image.dispose);
      expect((await pixels(image)).sublist(0, 4), <int>[255, 0, 0, 255]);
    });
  }
}
