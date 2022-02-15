// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show Image, Codec, FrameInfo, instantiateImageCodec;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as path;

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

Future<FakeImageProvider> loadImage(String name) async {
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
  final Map<String, FakeImageProvider> testImages =
      <String, FakeImageProvider>{};
  for (final String name in imageNames) {
    testImages[name] = await loadImage('$name.png');
  }

  testWidgets('Initialize the image cache', (WidgetTester tester) async {
    // We need to have a testWidgets test in order to initialize the image
    // cache for the other tests, but they timeout if they too are testWidgets
    // tests.
    tester.pumpWidget(const Placeholder());
  });

  test(
      "PaletteGenerator.fromByteData throws when the size doesn't match the byte data size",
      () {
    expect(
      () async {
        final ByteData? data =
            await testImages['tall_blue']!._image.toByteData();
        await PaletteGenerator.fromByteData(
          EncodedImage(
            data!,
            width: 1,
            height: 1,
          ),
        );
      },
      throwsAssertionError,
    );
  });

  test('PaletteGenerator.fromImage works', () async {
    final PaletteGenerator palette =
        await PaletteGenerator.fromImage(testImages['tall_blue']!._image);
    expect(palette.paletteColors.length, equals(1));
    expect(palette.paletteColors[0].color,
        within<Color>(distance: 8, from: const Color(0xff0000ff)));
  });

  test('PaletteGenerator works on 1-pixel tall blue image', () async {
    final PaletteGenerator palette =
        await PaletteGenerator.fromImageProvider(testImages['tall_blue']!);
    expect(palette.paletteColors.length, equals(1));
    expect(palette.paletteColors[0].color,
        within<Color>(distance: 8, from: const Color(0xff0000ff)));
  });

  test('PaletteGenerator works on 1-pixel wide red image', () async {
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
    expect(palette.dominantColor, isNotNull);
    expect(palette.dominantColor!.color,
        within<Color>(distance: 8, from: const Color(0xff0000ff)));
    expect(palette.dominantColor!.titleTextColor,
        within<Color>(distance: 8, from: const Color(0x8affffff)));
    expect(palette.dominantColor!.bodyTextColor,
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
    expect(palette.dominantColor, isNotNull);
    expect(palette.dominantColor!.color,
        within<Color>(distance: 8, from: const Color(0xff0000ff)));

    region = const Rect.fromLTRB(0.0, 0.0, 10.0, 10.0);
    palette = await PaletteGenerator.fromImageProvider(imageProvider,
        region: region, size: size);
    expect(palette.paletteColors.length, equals(1));
    expect(palette.dominantColor, isNotNull);
    expect(palette.dominantColor!.color,
        within<Color>(distance: 8, from: const Color(0xffff0000)));

    region = const Rect.fromLTRB(0.0, 0.0, 30.0, 20.0);
    palette = await PaletteGenerator.fromImageProvider(imageProvider,
        region: region, size: size);
    expect(palette.paletteColors.length, equals(3));
    expect(palette.dominantColor, isNotNull);
    expect(palette.dominantColor!.color,
        within<Color>(distance: 8, from: const Color(0xff00ff00)));
  });

  test('PaletteGenerator works as expected on a real image', () async {
    final PaletteGenerator palette =
        await PaletteGenerator.fromImageProvider(testImages['landscape']!);
    final List<PaletteColor> expectedSwatches = <PaletteColor>[
      PaletteColor(const Color(0xff3f630c), 10137),
      PaletteColor(const Color(0xff3c4b2a), 4773),
      PaletteColor(const Color(0xff81b2e9), 4762),
      PaletteColor(const Color(0xffc0d6ec), 4714),
      PaletteColor(const Color(0xff4c4f50), 2465),
      PaletteColor(const Color(0xff5c635b), 2463),
      PaletteColor(const Color(0xff6e80a2), 2421),
      PaletteColor(const Color(0xff9995a3), 1214),
      PaletteColor(const Color(0xff676c4d), 1213),
      PaletteColor(const Color(0xffc4b2b2), 1173),
      PaletteColor(const Color(0xff445166), 1040),
      PaletteColor(const Color(0xff475d83), 1019),
      PaletteColor(const Color(0xff7e7360), 589),
      PaletteColor(const Color(0xfff6b835), 286),
      PaletteColor(const Color(0xffb9983d), 152),
      PaletteColor(const Color(0xffe3ab35), 149),
    ];
    final Iterable<Color> expectedColors =
        expectedSwatches.map<Color>((PaletteColor swatch) => swatch.color);
    expect(palette.paletteColors, containsAll(expectedSwatches));
    expect(palette.vibrantColor, isNotNull);
    expect(palette.lightVibrantColor, isNotNull);
    expect(palette.darkVibrantColor, isNotNull);
    expect(palette.mutedColor, isNotNull);
    expect(palette.lightMutedColor, isNotNull);
    expect(palette.darkMutedColor, isNotNull);
    expect(palette.vibrantColor!.color,
        within<Color>(distance: 8, from: const Color(0xfff6b835)));
    expect(palette.lightVibrantColor!.color,
        within<Color>(distance: 8, from: const Color(0xff82b2e9)));
    expect(palette.darkVibrantColor!.color,
        within<Color>(distance: 8, from: const Color(0xff3f630c)));
    expect(palette.mutedColor!.color,
        within<Color>(distance: 8, from: const Color(0xff6c7fa2)));
    expect(palette.lightMutedColor!.color,
        within<Color>(distance: 8, from: const Color(0xffc4b2b2)));
    expect(palette.darkMutedColor!.color,
        within<Color>(distance: 8, from: const Color(0xff3c4b2a)));
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

  test('PaletteGenerator filters work', () async {
    final ImageProvider imageProvider = testImages['landscape']!;
    // First, test that supplying the default filter is the same as not supplying one.
    List<PaletteFilter> filters = <PaletteFilter>[
      avoidRedBlackWhitePaletteFilter
    ];
    PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        filters: filters);
    final List<PaletteColor> expectedSwatches = <PaletteColor>[
      PaletteColor(const Color(0xff3f630c), 10137),
      PaletteColor(const Color(0xff3c4b2a), 4773),
      PaletteColor(const Color(0xff81b2e9), 4762),
      PaletteColor(const Color(0xffc0d6ec), 4714),
      PaletteColor(const Color(0xff4c4f50), 2465),
      PaletteColor(const Color(0xff5c635b), 2463),
      PaletteColor(const Color(0xff6e80a2), 2421),
      PaletteColor(const Color(0xff9995a3), 1214),
      PaletteColor(const Color(0xff676c4d), 1213),
      PaletteColor(const Color(0xffc4b2b2), 1173),
      PaletteColor(const Color(0xff445166), 1040),
      PaletteColor(const Color(0xff475d83), 1019),
      PaletteColor(const Color(0xff7e7360), 589),
      PaletteColor(const Color(0xfff6b835), 286),
      PaletteColor(const Color(0xffb9983d), 152),
      PaletteColor(const Color(0xffe3ab35), 149),
    ];
    final Iterable<Color> expectedColors =
        expectedSwatches.map<Color>((PaletteColor swatch) => swatch.color);
    expect(palette.paletteColors, containsAll(expectedSwatches));
    expect(palette.dominantColor, isNotNull);
    expect(palette.dominantColor!.color,
        within<Color>(distance: 8, from: const Color(0xff3f630c)));
    expect(palette.colors, containsAllInOrder(expectedColors));

    // A non-default filter works (and the default filter isn't applied too).
    filters = <PaletteFilter>[onlyBluePaletteFilter];
    palette = await PaletteGenerator.fromImageProvider(imageProvider,
        filters: filters);
    final List<PaletteColor> blueSwatches = <PaletteColor>[
      PaletteColor(const Color(0xff4c5c75), 1515),
      PaletteColor(const Color(0xff7483a1), 1505),
      PaletteColor(const Color(0xff515661), 1476),
      PaletteColor(const Color(0xff769dd4), 1470),
      PaletteColor(const Color(0xff3e4858), 777),
      PaletteColor(const Color(0xff98a3bc), 760),
      PaletteColor(const Color(0xffb4c7e0), 760),
      PaletteColor(const Color(0xff99bbe5), 742),
      PaletteColor(const Color(0xffcbdef0), 701),
      PaletteColor(const Color(0xff1c212b), 429),
      PaletteColor(const Color(0xff393c46), 417),
      PaletteColor(const Color(0xff526483), 394),
      PaletteColor(const Color(0xff61708b), 372),
      PaletteColor(const Color(0xff5e8ccc), 345),
      PaletteColor(const Color(0xff587ab4), 194),
      PaletteColor(const Color(0xff5584c8), 182),
    ];
    final Iterable<Color> expectedBlues =
        blueSwatches.map<Color>((PaletteColor swatch) => swatch.color);

    expect(palette.paletteColors, containsAll(blueSwatches));
    expect(palette.dominantColor, isNotNull);
    expect(palette.dominantColor!.color,
        within<Color>(distance: 8, from: const Color(0xff4c5c75)));
    expect(palette.colors, containsAllInOrder(expectedBlues));

    // More than one filter is the intersection of the two filters.
    filters = <PaletteFilter>[onlyBluePaletteFilter, onlyCyanPaletteFilter];
    palette = await PaletteGenerator.fromImageProvider(imageProvider,
        filters: filters);
    final List<PaletteColor> blueGreenSwatches = <PaletteColor>[
      PaletteColor(const Color(0xffc8e8f8), 87),
      PaletteColor(const Color(0xff5c6c74), 73),
      PaletteColor(const Color(0xff6f8088), 49),
      PaletteColor(const Color(0xff687880), 49),
      PaletteColor(const Color(0xff506068), 45),
      PaletteColor(const Color(0xff485860), 39),
      PaletteColor(const Color(0xff405058), 21),
      PaletteColor(const Color(0xffd6ebf3), 11),
      PaletteColor(const Color(0xff2f3f47), 7),
      PaletteColor(const Color(0xff0f1f27), 6),
      PaletteColor(const Color(0xffc0e0f0), 6),
      PaletteColor(const Color(0xff203038), 3),
      PaletteColor(const Color(0xff788890), 2),
      PaletteColor(const Color(0xff384850), 2),
      PaletteColor(const Color(0xff98a8b0), 1),
      PaletteColor(const Color(0xffa8b8c0), 1),
    ];
    final Iterable<Color> expectedBlueGreens =
        blueGreenSwatches.map<Color>((PaletteColor swatch) => swatch.color);

    expect(palette.paletteColors, containsAll(blueGreenSwatches));
    expect(palette.dominantColor, isNotNull);
    expect(palette.dominantColor!.color,
        within<Color>(distance: 8, from: const Color(0xffc8e8f8)));
    expect(palette.colors, containsAllInOrder(expectedBlueGreens));

    // Mutually exclusive filters return an empty palette.
    filters = <PaletteFilter>[onlyBluePaletteFilter, onlyGreenPaletteFilter];
    palette = await PaletteGenerator.fromImageProvider(imageProvider,
        filters: filters);
    expect(palette.paletteColors, isEmpty);
    expect(palette.dominantColor, isNull);
    expect(palette.colors, isEmpty);
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
    expect(selectedSwatchesFirst, isNotNull);
    expect(selectedSwatchesSecond, isNotNull);
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
      expect(palette.dominantColor, isNotNull);
      expect(lastPalette.dominantColor, isNotNull);
      expect(palette.dominantColor!.color,
          within<Color>(distance: 8, from: lastPalette.dominantColor!.color));
      lastPalette = palette;
    }
  });

  // TODO(gspencergoog): rewrite to use fromImageProvider when https://github.com/flutter/flutter/issues/10647 is resolved,
  // since fromImageProvider calls fromImage which calls fromByteData

  test('PaletteGenerator.fromByteData works in non-root isolate', () async {
    final ui.Image image = testImages['tall_blue']!._image;
    final ByteData? data = await image.toByteData();
    final PaletteGenerator palette =
        await compute<EncodedImage, PaletteGenerator>(
      _computeFromByteData,
      EncodedImage(data!, width: image.width, height: image.height),
    );
    expect(palette.paletteColors.length, equals(1));
    expect(palette.paletteColors[0].color,
        within<Color>(distance: 8, from: const Color(0xff0000ff)));
  });

  test('PaletteColor == does not crash on invalid comparisons', () {
    final PaletteColor paletteColorA = PaletteColor(const Color(0xFFFFFFFF), 1);
    final PaletteColor paletteColorB = PaletteColor(const Color(0xFFFFFFFF), 1);
    final Object object = Object();

    expect(paletteColorA == paletteColorB, true);
    expect(paletteColorA == object, false);
  });

  test('PaletteTarget == does not crash on invalid comparisons', () {
    final PaletteTarget paletteTargetA = PaletteTarget();
    final PaletteTarget paletteTargetB = PaletteTarget();
    final Object object = Object();

    expect(paletteTargetA == paletteTargetB, true);
    expect(paletteTargetA == object, false);
  });
}

Future<PaletteGenerator> _computeFromByteData(EncodedImage encodedImage) async {
  return PaletteGenerator.fromByteData(encodedImage);
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
