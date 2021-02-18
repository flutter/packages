// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show Image, Codec, FrameInfo, instantiateImageCodec;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:palette_generator/palette_generator.dart';

/// An image provider implementation for testing that takes a pre-loaded image.
/// This avoids handling asynchronous I/O in the test zone, which is
/// problematic.
class FakeImageProvider extends ImageProvider<FakeImageProvider> {
  const FakeImageProvider(this._image, {this.scale = 1.0});

  final ui.Image _image;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  @override
  Future<FakeImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<FakeImageProvider>(this);
  }

  @override
  ImageStreamCompleter load(FakeImageProvider key, DecoderCallback decode) {
    assert(key == this);
    return OneFrameImageStreamCompleter(
      SynchronousFuture<ImageInfo>(
        ImageInfo(image: _image, scale: scale),
      ),
    );
  }
}

Future<ImageProvider> loadImage(String name) async {
  File imagePath = File(path.joinAll(<String>['assets', name]));
  if (path.split(Directory.current.absolute.path).last != 'test') {
    imagePath = File(path.join('test', imagePath.path));
  }
  final Uint8List data = Uint8List.fromList(imagePath.readAsBytesSync());
  final ui.Codec codec = await ui.instantiateImageCodec(data);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  return FakeImageProvider(frameInfo.image);
}

Future<void> main() async {
  // Load the images outside of the test zone so that IO doesn't get
  // complicated.
  final List<String> imageNames = <String>[
    'tall_blue',
    'wide_red',
    'dominant',
    'landscape'
  ];
  final Map<String, ImageProvider> testImages = <String, ImageProvider>{};
  for (String name in imageNames) {
    testImages[name] = await loadImage('$name.png');
  }

  testWidgets('Initialize the image cache', (WidgetTester tester) async {
    // We need to have a testWidgets test in order to initialize the image
    // cache for the other tests, but they timeout if they too are testWidgets
    // tests.
    tester.pumpWidget(const Placeholder());
  });

  test('PaletteGenerator works on 1-pixel wide blue image', () async {
    final PaletteGenerator palette =
        await PaletteGenerator.fromImageProvider(testImages['tall_blue']!);
    expect(palette.paletteColors.length, equals(1));
    expect(palette.paletteColors[0].color,
        within<Color>(distance: 8, from: const Color(0xff0000ff)));
  });

  test('PaletteGenerator works on 1-pixel high red image', () async {
    final PaletteGenerator palette =
        await PaletteGenerator.fromImageProvider(testImages['wide_red']!);
    expect(palette.paletteColors.length, equals(1));
    expect(palette.paletteColors[0].color,
        within<Color>(distance: 8, from: const Color(0xffff0000)));
  });

  test('PaletteGenerator finds dominant color and text colors', () async {
    final PaletteGenerator palette =
        await PaletteGenerator.fromImageProvider(testImages['dominant']!);
    expect(palette.paletteColors.length, equals(3));
    expect(palette.dominantColor.color,
        within<Color>(distance: 8, from: const Color(0xff0000ff)));
    expect(palette.dominantColor.titleTextColor,
        within<Color>(distance: 8, from: const Color(0x8affffff)));
    expect(palette.dominantColor.bodyTextColor,
        within<Color>(distance: 8, from: const Color(0xb2ffffff)));
  });

  test('PaletteGenerator works with regions', () async {
    final ImageProvider imageProvider = testImages['dominant']!;
    Rect region = const Rect.fromLTRB(0.0, 0.0, 100.0, 100.0);
    const Size size = Size(100.0, 100.0);
    PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        region: region,
        size: size);
    expect(palette.paletteColors.length, equals(3));
    expect(palette.dominantColor.color,
        within<Color>(distance: 8, from: const Color(0xff0000ff)));

    region = const Rect.fromLTRB(0.0, 0.0, 10.0, 10.0);
    palette = await PaletteGenerator.fromImageProvider(imageProvider,
        region: region, size: size);
    expect(palette.paletteColors.length, equals(1));
    expect(palette.dominantColor.color,
        within<Color>(distance: 8, from: const Color(0xffff0000)));

    region = const Rect.fromLTRB(0.0, 0.0, 30.0, 20.0);
    palette = await PaletteGenerator.fromImageProvider(imageProvider,
        region: region, size: size);
    expect(palette.paletteColors.length, equals(3));
    expect(palette.dominantColor.color,
        within<Color>(distance: 8, from: const Color(0xff00ff00)));
  });

  test('PaletteGenerator works as expected on a real image', () async {
    final PaletteGenerator palette =
        await PaletteGenerator.fromImageProvider(testImages['landscape']!);
    final List<PaletteColor> expectedSwatches = <PaletteColor>[
      PaletteColor(color: const Color(0xff3f630c), population: 10137),
      PaletteColor(color: const Color(0xff3c4b2a), population:  4773),
      PaletteColor(color: const Color(0xff81b2e9), population:  4762),
      PaletteColor(color: const Color(0xffc0d6ec), population:  4714),
      PaletteColor(color: const Color(0xff4c4f50), population:  2465),
      PaletteColor(color: const Color(0xff5c635b), population:  2463),
      PaletteColor(color: const Color(0xff6e80a2), population:  2421),
      PaletteColor(color: const Color(0xff9995a3), population:  1214),
      PaletteColor(color: const Color(0xff676c4d), population:  1213),
      PaletteColor(color: const Color(0xffc4b2b2), population:  1173),
      PaletteColor(color: const Color(0xff445166), population:  1040),
      PaletteColor(color: const Color(0xff475d83), population:  1019),
      PaletteColor(color: const Color(0xff7e7360), population:  589),
      PaletteColor(color: const Color(0xfff6b835), population:  286),
      PaletteColor(color: const Color(0xffb9983d), population:  152),
      PaletteColor(color: const Color(0xffe3ab35), population:  149),
    ];
    final Iterable<Color> expectedColors =
        expectedSwatches.map<Color>((PaletteColor swatch) => swatch.color);
    expect(palette.paletteColors, containsAll(expectedSwatches));
    expect(palette.vibrantColor.color,
        within<Color>(distance: 8, from: const Color(0xfff6b835)));
    expect(palette.lightVibrantColor.color,
        within<Color>(distance: 8, from: const Color(0xff82b2e9)));
    expect(palette.darkVibrantColor.color,
        within<Color>(distance: 8, from: const Color(0xff3f630c)));
    expect(palette.mutedColor.color,
        within<Color>(distance: 8, from: const Color(0xff6c7fa2)));
    expect(palette.lightMutedColor.color,
        within<Color>(distance: 8, from: const Color(0xffc4b2b2)));
    expect(palette.darkMutedColor.color,
        within<Color>(distance: 8, from: const Color(0xff3c4b2a)));

    for (final PaletteColor paletteColor in palette.paletteColors) {
      expect(paletteColor.isTargetColorFound, true);
    }

    expect(palette.colors, containsAllInOrder(expectedColors));
    expect(palette.colors.length, equals(palette.paletteColors.length));
  });

  test('PaletteGenerator limits max colors', () async {
    final ImageProvider imageProvider = testImages['landscape']!;
    PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 32);
    expect(palette.paletteColors.length, equals(31));
    palette = await PaletteGenerator.fromImageProvider(imageProvider,
        maximumColorCount: 1);
    expect(palette.paletteColors.length, equals(1));
    palette = await PaletteGenerator.fromImageProvider(imageProvider,
        maximumColorCount: 15);
    expect(palette.paletteColors.length, equals(15));
  });

  test('PaletteGenerator Filters work', () async {
    final ImageProvider imageProvider = testImages['landscape']!;
    // First, test that supplying the default filter is the same as not supplying one.
    List<PaletteFilter> filters = <PaletteFilter>[
      avoidRedBlackWhitePaletteFilter
    ];
    PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        filters: filters);
    final List<PaletteColor> expectedSwatches = <PaletteColor>[
      PaletteColor(color: const Color(0xff3f630c), population:   10137),
      PaletteColor(color: const Color(0xff3c4b2a), population:   4773),
      PaletteColor(color: const Color(0xff81b2e9), population:   4762),
      PaletteColor(color: const Color(0xffc0d6ec), population:   4714),
      PaletteColor(color: const Color(0xff4c4f50), population:   2465),
      PaletteColor(color: const Color(0xff5c635b), population:   2463),
      PaletteColor(color: const Color(0xff6e80a2), population:   2421),
      PaletteColor(color: const Color(0xff9995a3), population:   1214),
      PaletteColor(color: const Color(0xff676c4d), population:   1213),
      PaletteColor(color: const Color(0xffc4b2b2), population:   1173),
      PaletteColor(color: const Color(0xff445166), population:   1040),
      PaletteColor(color: const Color(0xff475d83), population:   1019),
      PaletteColor(color: const Color(0xff7e7360), population:   589),
      PaletteColor(color: const Color(0xfff6b835), population:   286),
      PaletteColor(color: const Color(0xffb9983d), population:   152),
      PaletteColor(color: const Color(0xffe3ab35), population:   149),
    ];
    final Iterable<Color> expectedColors =
        expectedSwatches.map<Color>((PaletteColor swatch) => swatch.color);
    expect(palette.paletteColors, containsAll(expectedSwatches));
    expect(palette.dominantColor.color,
        within<Color>(distance: 8, from: const Color(0xff3f630c)));
    expect(palette.colors, containsAllInOrder(expectedColors));

    // A non-default filter works (and the default filter isn't applied too).
    filters = <PaletteFilter>[onlyBluePaletteFilter];
    palette = await PaletteGenerator.fromImageProvider(imageProvider,
        filters: filters);
    final List<PaletteColor> blueSwatches = <PaletteColor>[
      PaletteColor(color: const Color(0xff4c5c75), population:   1515),
      PaletteColor(color: const Color(0xff7483a1), population:   1505),
      PaletteColor(color: const Color(0xff515661), population:   1476),
      PaletteColor(color: const Color(0xff769dd4), population:   1470),
      PaletteColor(color: const Color(0xff3e4858), population:   777),
      PaletteColor(color: const Color(0xff98a3bc), population:   760),
      PaletteColor(color: const Color(0xffb4c7e0), population:   760),
      PaletteColor(color: const Color(0xff99bbe5), population:   742),
      PaletteColor(color: const Color(0xffcbdef0), population:   701),
      PaletteColor(color: const Color(0xff1c212b), population:   429),
      PaletteColor(color: const Color(0xff393c46), population:   417),
      PaletteColor(color: const Color(0xff526483), population:   394),
      PaletteColor(color: const Color(0xff61708b), population:   372),
      PaletteColor(color: const Color(0xff5e8ccc), population:   345),
      PaletteColor(color: const Color(0xff587ab4), population:   194),
      PaletteColor(color: const Color(0xff5584c8), population:   182),
    ];
    final Iterable<Color> expectedBlues =
        blueSwatches.map<Color>((PaletteColor swatch) => swatch.color);

    expect(palette.paletteColors, containsAll(blueSwatches));
    expect(palette.dominantColor.color,
        within<Color>(distance: 8, from: const Color(0xff4c5c75)));
    expect(palette.colors, containsAllInOrder(expectedBlues));

    // More than one filter is the intersection of the two filters.
    filters = <PaletteFilter>[onlyBluePaletteFilter, onlyCyanPaletteFilter];
    palette = await PaletteGenerator.fromImageProvider(imageProvider,
        filters: filters);
    final List<PaletteColor> blueGreenSwatches = <PaletteColor>[
      PaletteColor(color: const Color(0xffc8e8f8), population:   87),
      PaletteColor(color: const Color(0xff5c6c74), population:   73),
      PaletteColor(color: const Color(0xff6f8088), population:   49),
      PaletteColor(color: const Color(0xff687880), population:   49),
      PaletteColor(color: const Color(0xff506068), population:   45),
      PaletteColor(color: const Color(0xff485860), population:   39),
      PaletteColor(color: const Color(0xff405058), population:   21),
      PaletteColor(color: const Color(0xffd6ebf3), population:   11),
      PaletteColor(color: const Color(0xff2f3f47), population:   7),
      PaletteColor(color: const Color(0xff0f1f27), population:   6),
      PaletteColor(color: const Color(0xffc0e0f0), population:   6),
      PaletteColor(color: const Color(0xff203038), population:   3),
      PaletteColor(color: const Color(0xff788890), population:   2),
      PaletteColor(color: const Color(0xff384850), population:   2),
      PaletteColor(color: const Color(0xff98a8b0), population:   1),
      PaletteColor(color: const Color(0xffa8b8c0), population:   1),
    ];
    final Iterable<Color> expectedBlueGreens =
        blueGreenSwatches.map<Color>((PaletteColor swatch) => swatch.color);

    expect(palette.paletteColors, containsAll(blueGreenSwatches));
    expect(palette.dominantColor.color,
        within<Color>(distance: 8, from: const Color(0xffc8e8f8)));
    expect(palette.colors, containsAllInOrder(expectedBlueGreens));

    // Mutually exclusive filters return an empty palette.
    filters = <PaletteFilter>[onlyBluePaletteFilter, onlyGreenPaletteFilter];
    palette = await PaletteGenerator.fromImageProvider(imageProvider,
        filters: filters);
    expect(palette.paletteColors, isEmpty);

    expect(palette.dominantColor, PaletteColor());

    expect(palette.colors, isEmpty);
    for (final PaletteColor paletteColor in palette.paletteColors) {
      expect(paletteColor.isTargetColorFound, false);
    }
  });

  test('PaletteGenerator targets work', () async {
    final ImageProvider imageProvider = testImages['landscape']!;
    // Passing an empty set of targets works the same as passing a null targets
    // list.
    PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        targets: <PaletteTarget>[]);
    expect(palette.selectedSwatches, isNotEmpty);
    expect(palette.vibrantColor, isNotNull);
    expect(palette.lightVibrantColor, isNotNull);
    expect(palette.darkVibrantColor, isNotNull);
    expect(palette.mutedColor, isNotNull);
    expect(palette.lightMutedColor, isNotNull);
    expect(palette.darkMutedColor, isNotNull);

    // Passing targets augments the baseTargets, and those targets are found.
    final List<PaletteTarget> saturationExtremeTargets = <PaletteTarget>[
      PaletteTarget(minimumSaturation: 0.85),
      PaletteTarget(maximumSaturation: .25),
    ];
    palette = await PaletteGenerator.fromImageProvider(imageProvider,
        targets: saturationExtremeTargets);
    expect(palette.vibrantColor, isNotNull);
    expect(palette.lightVibrantColor, isNotNull);
    expect(palette.darkVibrantColor, isNotNull);
    expect(palette.mutedColor, isNotNull);
    expect(palette.lightMutedColor, isNotNull);
    expect(palette.darkMutedColor, isNotNull);
    expect(palette.selectedSwatches.length,
        equals(PaletteTarget.baseTargets.length + 2));
    final PaletteColor? selectedSwatchesFirst =
        palette.selectedSwatches[saturationExtremeTargets[0]];
    final PaletteColor? selectedSwatchesSecond =
        palette.selectedSwatches[saturationExtremeTargets[1]];
    expect(selectedSwatchesFirst!.color, equals(const Color(0xfff6b835)));
    expect(selectedSwatchesSecond!.color, equals(const Color(0xff6e80a2)));
  });

  test('PaletteGenerator produces consistent results', () async {
    final ImageProvider imageProvider = testImages['landscape']!;

    PaletteGenerator lastPalette =
        await PaletteGenerator.fromImageProvider(imageProvider);
    for (int i = 0; i < 5; ++i) {
      final PaletteGenerator palette =
          await PaletteGenerator.fromImageProvider(imageProvider);
      expect(palette.paletteColors.length, lastPalette.paletteColors.length);
      expect(palette.vibrantColor, equals(lastPalette.vibrantColor));
      expect(palette.lightVibrantColor, equals(lastPalette.lightVibrantColor));
      expect(palette.darkVibrantColor, equals(lastPalette.darkVibrantColor));
      expect(palette.mutedColor, equals(lastPalette.mutedColor));
      expect(palette.lightMutedColor, equals(lastPalette.lightMutedColor));
      expect(palette.darkMutedColor, equals(lastPalette.darkMutedColor));
      expect(palette.dominantColor.color,
          within<Color>(distance: 8, from: lastPalette.dominantColor.color));
      lastPalette = palette;
    }
  });
}

bool onlyBluePaletteFilter(HSLColor hslColor) {
  const double blueLineMinHue = 185.0;
  const double blueLineMaxHue = 260.0;
  const double blueLineMaxSaturation = 0.82;
  return hslColor.hue >= blueLineMinHue &&
      hslColor.hue <= blueLineMaxHue &&
      hslColor.saturation <= blueLineMaxSaturation;
}

bool onlyCyanPaletteFilter(HSLColor hslColor) {
  const double cyanLineMinHue = 165.0;
  const double cyanLineMaxHue = 200.0;
  const double cyanLineMaxSaturation = 0.82;
  return hslColor.hue >= cyanLineMinHue &&
      hslColor.hue <= cyanLineMaxHue &&
      hslColor.saturation <= cyanLineMaxSaturation;
}

bool onlyGreenPaletteFilter(HSLColor hslColor) {
  const double greenLineMinHue = 80.0;
  const double greenLineMaxHue = 165.0;
  const double greenLineMaxSaturation = 0.82;
  return hslColor.hue >= greenLineMinHue &&
      hslColor.hue <= greenLineMaxHue &&
      hslColor.saturation <= greenLineMaxSaturation;
}
