// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/filters/filter_context.dart';
import 'package:vector_graphics/src/filters/filter_executor.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';
import 'helpers.dart';

Future<List<int>> pixel(String svg, int x, int y) async {
  final ui.Image image = await renderSvg(svg);
  try {
    final Uint8List data = await pixels(image);
    return data.sublist((y * 128 + x) * 4, (y * 128 + x) * 4 + 4);
  } finally {
    image.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('legacy unpruned definitions execute named live inputs without dead shaders', () async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder);
    final context = FilterContext(
      VectorFilter(
        'filter',
        const <String, String>{
          'filterUnits': 'userSpaceOnUse',
          'x': '0',
          'y': '0',
          'width': '128',
          'height': '128',
        },
        <VectorFilter>[
          VectorFilter('feFlood', const <String, String>{
            'result': 'ink',
            'flood-color-argb': '4294901760',
            'x': '32',
            'y': '32',
            'width': '32',
            'height': '32',
          }),
          VectorFilter('feGaussianBlur', const <String, String>{'stdDeviation': '10000'}),
          VectorFilter('feOffset', const <String, String>{'in': 'ink', 'dx': '8'}),
        ],
      ),
      recorder.endRecording(),
      const ui.Rect.fromLTWH(0, 0, 128, 128),
      const ui.Size(128, 128),
    );
    try {
      final FilterImage output = executeFilter(context);
      final ui.Image image = await output.picture.toImage(128, 128);
      try {
        final Uint8List data = await pixels(image);
        expect(data.sublist((48 * 128 + 48) * 4, (48 * 128 + 48) * 4 + 4), <int>[255, 0, 0, 255]);
        expect(data[(48 * 128 + 36) * 4 + 3], 0);
        expect(context.requiresRasterResolution, isFalse);
      } finally {
        image.dispose();
      }
    } finally {
      context.dispose();
    }
  });
  test('unused oversized blur does not prevent an independent flood', () async {
    final ui.Image image = await renderSvg(
      filterSvg(
        '<feGaussianBlur stdDeviation="10000" result="unused"/> '
        '<feFlood flood-color="red"/>',
      ),
      filterRasterScale: 4,
    );
    try {
      expect((await pixels(image)).sublist(0, 4), <int>[255, 0, 0, 255]);
    } finally {
      image.dispose();
    }
  });

  test('unused malformed filter cannot fail a valid graphic', () async {
    final String svg = filterSvg(
      '<feFlood flood-color="red"/>',
    ).replaceFirst('<defs>', '<defs><filter id="unused" width="bogus"><feOffset/></filter>');
    expect(await pixel(svg, 48, 48), [255, 0, 0, 255]);
  });
  test('unused cyclic filter cannot fail a valid graphic', () async {
    final String svg = filterSvg(
      '<feFlood flood-color="red"/>',
    ).replaceFirst('<defs>', '<defs><filter id="a" href="#b"/><filter id="b" href="#a"/>');
    expect(await pixel(svg, 48, 48), [255, 0, 0, 255]);
  });
}
