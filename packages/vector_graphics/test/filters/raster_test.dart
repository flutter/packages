// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/filters/filter_context.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart' show encodeSvg;

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('native filter decodes at different resolutions leave no pending work', () async {
    final Uint8List data = encodeSvg(
      xml: filterSvg(''),
      debugName: 'concurrent resolutions',
      enableClippingOptimizer: false,
      enableMaskingOptimizer: false,
      enableOverdrawOptimizer: false,
    );
    const loader = AssetBytesLoader('shared-filter-loader');
    final futures = <Future<PictureInfo>>[
      for (final scale in <double>[1, 2])
        decodeVectorGraphics(
          data.buffer.asByteData(),
          locale: null,
          textDirection: TextDirection.ltr,
          clipViewbox: true,
          loader: loader,
          filterRasterScale: scale,
        ),
    ];
    expect(debugGetPendingDecodeTasks, isEmpty);
    for (final PictureInfo info in await Future.wait(futures)) {
      info.picture.dispose();
    }
    expect(debugGetPendingDecodeTasks, isEmpty);
  });

  test('malformed filter metadata leaves no pending decode', () async {
    final data = ByteData(6)
      ..setUint32(0, 0x00882d62, Endian.little)
      ..setUint8(4, 2)
      ..setUint8(5, 255);
    await expectLater(
      () => decodeVectorGraphics(
        data,
        locale: null,
        textDirection: TextDirection.ltr,
        clipViewbox: true,
        loader: const AssetBytesLoader('malformed-filter-metadata'),
      ),
      throwsA(isA<VectorGraphicsDecodeException>()),
    );
    expect(debugGetPendingDecodeTasks, isEmpty);
  });

  test('failed filtered decodes remove pending work', () async {
    await expectLater(
      renderSvg(filterSvg('<feUnsupported/>')),
      throwsA(isA<VectorGraphicsDecodeException>()),
    );
    expect(debugGetPendingDecodeTasks, isEmpty);
  });
  test('abort closes the outer recorder and can be called twice', () {
    final factory = _RecordingFactory();
    final listener = FlutterVectorGraphicsListener(pictureFactory: factory);
    expect(factory.recorder.isRecording, isTrue);
    listener.abort();
    expect(factory.recorder.isRecording, isFalse);
    listener.abort();
  });
  for (final scale in <double>[0, -1, double.infinity, double.nan]) {
    test('invalid decode scale is diagnosed: $scale', () async {
      await expectLater(
        renderSvg(filterSvg(''), filterRasterScale: scale),
        throwsA(isA<VectorGraphicsDecodeException>()),
      );
      expect(debugGetPendingDecodeTasks, isEmpty);
    });
  }
  FilterContext context({double scale = 1, FilterRasterBudget? budget}) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(const Rect.fromLTWH(16, 24, 32, 40), Paint()..color = const Color(0x804080c0));
    return FilterContext(
      VectorFilter('filter', const <String, String>{
        'filterUnits': 'userSpaceOnUse',
        'x': '0',
        'y': '0',
        'width': '128',
        'height': '128',
      }),
      recorder.endRecording(),
      const Rect.fromLTWH(16, 24, 32, 40),
      const Size(128, 128),
      rasterScale: scale,
      rasterBudget: budget,
    );
  }

  for (final offset in <double>[-48, 48]) {
    test('SourceAlpha keeps pixels outside filter region before offset $offset', () async {
      final recorder = PictureRecorder();
      Canvas(
        recorder,
      ).drawRect(Rect.fromLTWH(32 - offset, 32, 16, 16), Paint()..color = const Color(0x804080c0));
      final c = FilterContext(
        VectorFilter('filter', const <String, String>{
          'filterUnits': 'userSpaceOnUse',
          'x': '32',
          'y': '32',
          'width': '16',
          'height': '16',
        }),
        recorder.endRecording(),
        Rect.fromLTWH(32 - offset, 32, 16, 16),
        const Size(128, 128),
      );
      final FilterImage alpha = c.input('SourceAlpha');
      expect(c.input('SourceAlpha'), same(alpha));
      final output = PictureRecorder();
      Canvas(output)
        ..translate(offset, 0)
        ..drawPicture(alpha.picture);
      final Picture picture = output.endRecording();
      c.dispose();
      final Image image = await picture.toImage(128, 128);
      picture.dispose();
      final Uint8List bytes = await pixels(image);
      image.dispose();
      expect(bytes.sublist((40 * 128 + 40) * 4, (40 * 128 + 40) * 4 + 4), <int>[0, 0, 0, 128]);
    });
  }

  for (final scale in <double>[.5, 1, 2, 3]) {
    test('sampling scale, origin, alpha, and retained image lifetime $scale', () async {
      final FilterContext c = context(scale: scale);
      const domain = Rect.fromLTWH(8, 8, 64, 80);
      final Image input = c.sample(c.sourceGraphic, domain);
      expect(input.width, (64 * scale).ceil());
      expect(input.height, (80 * scale).ceil());
      final FilterImage result = c.raster(c.sourceGraphic, domain);
      final recorder = PictureRecorder();
      Canvas(recorder).drawPicture(result.picture);
      final Picture retained = recorder.endRecording();
      c.dispose();
      c.dispose();
      final Image output = await retained.toImage(128, 128);
      retained.dispose();
      final Uint8List data = (await output.toByteData(
        format: ImageByteFormat.rawStraightRgba,
      ))!.buffer.asUint8List();
      output.dispose();
      for (var channel = 0; channel < 4; channel++) {
        expect(data[(40 * 128 + 32) * 4 + channel], closeTo(<int>[64, 128, 192, 128][channel], 2));
      }
      expect(data[(10 * 128 + 10) * 4 + 3], 0);
      expect(data[(80 * 128 + 80) * 4 + 3], 0);
      if (scale >= 1) {
        for (var y = 0; y < 128; y++) {
          for (var x = 0; x < 128; x++) {
            final bool inside = x >= 16 && x < 48 && y >= 24 && y < 64;
            if (data[(y * 128 + x) * 4 + 3] != (inside ? 128 : 0)) {
              fail('Unexpected sampled coverage at ($x,$y), scale $scale');
            }
          }
        }
      }
    });
  }
  for (final scale in <double>[0, -1, double.nan, double.infinity]) {
    test('reject invalid sample scale $scale', () {
      expect(() => context(scale: scale), throwsArgumentError);
    });
  }
  for (final domain in const <Rect>[
    Rect.zero,
    Rect.fromLTWH(0, 0, 9000, 1),
    Rect.fromLTWH(0, 0, 1, 9000),
    Rect.fromLTWH(0, 0, double.infinity, 1),
  ]) {
    test('reject invalid or oversized sampling domain $domain', () {
      final FilterContext c = context();
      addTearDown(c.dispose);
      expect(() => c.sample(c.sourceGraphic, domain), throwsA(anything));
    });
  }
  test('shared inputs and materialized outputs reuse texture allocations', () async {
    final FilterContext c = context(budget: FilterRasterBudget(maxPixels: 128));
    addTearDown(c.dispose);
    const domain = Rect.fromLTWH(16, 24, 8, 8);
    final Image input = c.sample(c.sourceGraphic, domain);
    expect(c.sample(c.sourceGraphic, domain), same(input));
    final FilterImage output = c.raster(c.sourceGraphic, domain);
    final Image sampled = c.sample(output, domain);
    expect(c.sample(output, domain), same(sampled));
    expect(() => c.sample(output, domain, scale: 2), throwsStateError);
  });

  test('nested contexts share a cumulative intermediate budget', () {
    final budget = FilterRasterBudget(maxPixels: 64);
    final FilterContext a = context(budget: budget), b = context(budget: budget);
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    a.sample(a.sourceGraphic, const Rect.fromLTWH(0, 0, 8, 8));
    expect(() => b.sample(b.sourceGraphic, const Rect.fromLTWH(0, 0, 1, 1)), throwsStateError);
  });
  test('fractional dimensions round up without dropping pixels', () {
    final FilterContext c = context();
    addTearDown(c.dispose);
    final Image image = c.sample(c.sourceGraphic, const Rect.fromLTWH(-.25, -.5, 10.25, 12.75));
    expect(image.width, 11);
    expect(image.height, 13);
  });

  for (final step in <double>[.1, 1 / 3, 128 / 86, 128 / 52, 2.5]) {
    for (final origin in <double>[0, 17, -12.25]) {
      for (final count in <int>[1, 7, 45]) {
        test('explicit grid preserves $count steps of $step at $origin', () {
          final FilterContext c = context();
          addTearDown(c.dispose);
          final domain = Rect.fromLTRB(
            origin,
            origin,
            origin + count * step,
            origin + count * step,
          );
          final Image image = c.sample(c.sourceGraphic, domain, pixelSize: Size(step, step));
          expect(image.width, count);
          expect(image.height, count);
        });
      }
    }
  }
  for (final delta in <double>[1e-7, .01, .25, .999]) {
    test('explicit grid still covers fractional pixel remainder $delta', () {
      final FilterContext c = context();
      addTearDown(c.dispose);
      final Image image = c.sample(
        c.sourceGraphic,
        Rect.fromLTWH(0, 0, (8 + delta) * 1.5, (12 + delta) * 2.5),
        pixelSize: const Size(1.5, 2.5),
      );
      expect(image.width, 9);
      expect(image.height, 13);
    });
  }
  test('explicit grid snaps round-off before enforcing the dimension limit', () {
    final FilterContext c = context();
    addTearDown(c.dispose);
    final Image image = c.sample(
      c.sourceGraphic,
      const Rect.fromLTWH(0, 0, 8192 + 1e-12, 1),
      pixelSize: const Size(1, 1),
    );
    expect(image.width, 8192);
    expect(
      () => c.sample(
        c.sourceGraphic,
        const Rect.fromLTWH(0, 0, 8192.0001, 1),
        pixelSize: const Size(1, 1),
      ),
      throwsStateError,
    );
  });
  test('default device grid retains strict outward rounding', () {
    final FilterContext c = context();
    addTearDown(c.dispose);
    final Image image = c.sample(c.sourceGraphic, const Rect.fromLTWH(0, 0, 8 + 1e-12, 12 + 1e-12));
    expect(image.width, 9);
    expect(image.height, 13);
  });
  test('tiny positive scales retain a nonzero texture', () {
    final FilterContext c = context(scale: double.minPositive);
    addTearDown(c.dispose);
    final Image image = c.sample(c.sourceGraphic, const Rect.fromLTWH(0, 0, 1, 1));
    expect(image.width, 1);
    expect(image.height, 1);
  });
  test('disposed context cannot allocate', () {
    final FilterContext c = context();
    c.dispose();
    expect(() => c.sample(c.sourceGraphic, const Rect.fromLTWH(0, 0, 1, 1)), throwsStateError);
    expect(() => c.record(Rect.zero, (Canvas canvas) {}), throwsStateError);
  });
}

class _RecordingFactory implements PictureFactory {
  late PictureRecorder recorder;

  @override
  PictureRecorder createPictureRecorder() => recorder = PictureRecorder();

  @override
  Canvas createCanvas(PictureRecorder recorder) => Canvas(recorder);
}
