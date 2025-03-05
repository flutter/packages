// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(goderbauer): Fix this warning for the classes in this file.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui' show Color, ImageByteFormat;

import 'package:collection/collection.dart'
    show HeapPriorityQueue, PriorityQueue;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A description of an encoded image.
///
/// Used in [PaletteGenerator.fromByteData].
class EncodedImage {
  /// Creates a description of an encoded image.
  const EncodedImage(
    this.byteData, {
    required this.width,
    required this.height,
  });

  /// Encoded image byte data.
  final ByteData byteData;

  /// Image width.
  final int width;

  /// Image height.
  final int height;
}

/// A class to extract prominent colors from an image for use as user interface
/// colors.
///
/// To create a new [PaletteGenerator], use the asynchronous
/// [PaletteGenerator.fromImage] static function.
///
/// A number of color paletteColors with different profiles are chosen from the
/// image:
///
///   * [vibrantColor]
///   * [darkVibrantColor]
///   * [lightVibrantColor]
///   * [mutedColor]
///   * [darkMutedColor]
///   * [lightMutedColor]
///
/// You may add your own target palette color types by supplying them to the
/// `targets` parameter for [PaletteGenerator.fromImage].
///
/// In addition, the population-sorted list of discovered [colors] is available,
/// and a [paletteColors] list providing contrasting title text and body text
/// colors for each palette color.
///
/// The palette is created using a color quantizer based on the Median-cut
/// algorithm, but optimized for picking out distinct colors rather than
/// representative colors.
///
/// The color space is represented as a 3-dimensional cube with each dimension
/// being one component of an RGB image. The cube is then repeatedly divided
/// until the color space is reduced to the requested number of colors. An
/// average color is then generated from each cube.
///
/// What makes this different from a median-cut algorithm is that median-cut
/// divides cubes so that all of the cubes have roughly the same population,
/// where the quantizer that is used to create the palette divides cubes based
/// on their color volume. This means that the color space is divided into
/// distinct colors, rather than representative colors.
///
/// See also:
///
///   * [PaletteColor], to contain various pieces of metadata about a chosen
///     palette color.
///   * [PaletteTarget], to be able to create your own target color types.
///   * [PaletteFilter], a function signature for filtering the allowed colors
///     in the palette.
class PaletteGenerator with Diagnosticable {
  /// Create a [PaletteGenerator] from a set of paletteColors and targets.
  ///
  /// The usual way to create a [PaletteGenerator] is to use the asynchronous
  /// [PaletteGenerator.fromImage] static function. This constructor is mainly
  /// used for cases when you have your own source of color information and
  /// would like to use the target selection and scoring methods here.
  PaletteGenerator.fromColors(
    this.paletteColors, {
    this.targets = const <PaletteTarget>[],
  }) : selectedSwatches = <PaletteTarget, PaletteColor>{} {
    _sortSwatches();
    _selectSwatches();
  }

  // TODO(gspencergoog): remove `dart:ui` paragraph from [fromByteData] method when https://github.com/flutter/flutter/issues/10647 is resolved

  /// Create a [PaletteGenerator] asynchronously from encoded image [ByteData],
  /// width, and height. These parameters are packed in [EncodedImage].
  ///
  /// The image encoding must be RGBA with 8 bits per channel, this corresponds to
  /// [ImageByteFormat.rawRgba] or [ImageByteFormat.rawStraightRgba].
  ///
  /// In contast with [fromImage] and [fromImageProvider] this method can be used
  /// in non-root isolates, because it doesn't involve interaction with the
  /// `dart:ui` library, which is currently not supported, see https://github.com/flutter/flutter/issues/10647.
  ///
  /// The [region] specifies the part of the image to inspect for color
  /// candidates. By default it uses the entire image. Must not be equal to
  /// [Rect.zero], and must not be larger than the image dimensions.
  ///
  /// The [maximumColorCount] sets the maximum number of colors that will be
  /// returned in the [PaletteGenerator]. The default is 16 colors.
  ///
  /// The [filters] specify a lost of [PaletteFilter] instances that can be used
  /// to include certain colors in the list of colors. The default filter is
  /// an instance of [AvoidRedBlackWhitePaletteFilter], which stays away from
  /// whites, blacks, and low-saturation reds.
  ///
  /// The [targets] are a list of target color types, specified by creating
  /// custom [PaletteTarget]s. By default, this is the list of targets in
  /// [PaletteTarget.baseTargets].
  static Future<PaletteGenerator> fromByteData(
    EncodedImage encodedImage, {
    Rect? region,
    int maximumColorCount = _defaultCalculateNumberColors,
    List<PaletteFilter> filters = const <PaletteFilter>[
      avoidRedBlackWhitePaletteFilter
    ],
    List<PaletteTarget> targets = const <PaletteTarget>[],
  }) async {
    assert(region == null || region != Rect.zero);
    assert(
        region == null ||
            (region.topLeft.dx >= 0.0 && region.topLeft.dy >= 0.0),
        'Region $region is outside the image ${encodedImage.width}x${encodedImage.height}');
    assert(
        region == null ||
            (region.bottomRight.dx <= encodedImage.width &&
                region.bottomRight.dy <= encodedImage.height),
        'Region $region is outside the image ${encodedImage.width}x${encodedImage.height}');
    assert(
      encodedImage.byteData.lengthInBytes ~/ 4 ==
          encodedImage.width * encodedImage.height,
      "Image byte data doesn't match the image size, or has invalid encoding. "
      'The encoding must be RGBA with 8 bits per channel.',
    );

    final _ColorCutQuantizer quantizer = _ColorCutQuantizer(
      encodedImage,
      maxColors: maximumColorCount,
      filters: filters,
      region: region,
    );
    final List<PaletteColor> colors = await quantizer.quantizedColors;
    return PaletteGenerator.fromColors(
      colors,
      targets: targets,
    );
  }

  /// Create a [PaletteGenerator] from an [dart:ui.Image] asynchronously.
  ///
  /// The [region] specifies the part of the image to inspect for color
  /// candidates. By default it uses the entire image. Must not be equal to
  /// [Rect.zero], and must not be larger than the image dimensions.
  ///
  /// The [maximumColorCount] sets the maximum number of colors that will be
  /// returned in the [PaletteGenerator]. The default is 16 colors.
  ///
  /// The [filters] specify a lost of [PaletteFilter] instances that can be used
  /// to include certain colors in the list of colors. The default filter is
  /// an instance of [AvoidRedBlackWhitePaletteFilter], which stays away from
  /// whites, blacks, and low-saturation reds.
  ///
  /// The [targets] are a list of target color types, specified by creating
  /// custom [PaletteTarget]s. By default, this is the list of targets in
  /// [PaletteTarget.baseTargets].
  static Future<PaletteGenerator> fromImage(
    ui.Image image, {
    Rect? region,
    int maximumColorCount = _defaultCalculateNumberColors,
    List<PaletteFilter> filters = const <PaletteFilter>[
      avoidRedBlackWhitePaletteFilter
    ],
    List<PaletteTarget> targets = const <PaletteTarget>[],
  }) async {
    final ByteData? imageData = await image.toByteData();
    if (imageData == null) {
      throw StateError('Failed to encode the image.');
    }

    return PaletteGenerator.fromByteData(
      EncodedImage(
        imageData,
        width: image.width,
        height: image.height,
      ),
      region: region,
      maximumColorCount: maximumColorCount,
      filters: filters,
      targets: targets,
    );
  }

  /// Create a [PaletteGenerator] from an [ImageProvider], like [FileImage], or
  /// [AssetImage], asynchronously.
  ///
  /// The [size] is the desired size of the image. The image will be resized to
  /// this size before creating the [PaletteGenerator] from it.
  ///
  /// The [region] specifies the part of the (resized) image to inspect for
  /// color candidates. By default it uses the entire image. Must not be equal
  /// to [Rect.zero], and must not be larger than the image dimensions.
  ///
  /// The [maximumColorCount] sets the maximum number of colors that will be
  /// returned in the [PaletteGenerator]. The default is 16 colors.
  ///
  /// The [filters] specify a lost of [PaletteFilter] instances that can be used
  /// to include certain colors in the list of colors. The default filter is
  /// an instance of [AvoidRedBlackWhitePaletteFilter], which stays away from
  /// whites, blacks, and low-saturation reds.
  ///
  /// The [targets] are a list of target color types, specified by creating
  /// custom [PaletteTarget]s. By default, this is the list of targets in
  /// [PaletteTarget.baseTargets].
  ///
  /// The [timeout] describes how long to wait for the image to load before
  /// giving up on it. A value of Duration.zero implies waiting forever. The
  /// default timeout is 15 seconds.
  static Future<PaletteGenerator> fromImageProvider(
    ImageProvider imageProvider, {
    Size? size,
    Rect? region,
    int maximumColorCount = _defaultCalculateNumberColors,
    List<PaletteFilter> filters = const <PaletteFilter>[
      avoidRedBlackWhitePaletteFilter
    ],
    List<PaletteTarget> targets = const <PaletteTarget>[],
    Duration timeout = const Duration(seconds: 15),
  }) async {
    assert(region == null || size != null);
    assert(region == null || region != Rect.zero);
    assert(
        region == null ||
            (region.topLeft.dx >= 0.0 && region.topLeft.dy >= 0.0),
        'Region $region is outside the image ${size!.width}x${size.height}');
    assert(region == null || size!.contains(region.topLeft),
        'Region $region is outside the image $size');
    assert(
        region == null ||
            (region.bottomRight.dx <= size!.width &&
                region.bottomRight.dy <= size.height),
        'Region $region is outside the image $size');
    final ImageStream stream = imageProvider.resolve(
      ImageConfiguration(size: size, devicePixelRatio: 1.0),
    );
    final Completer<ui.Image> imageCompleter = Completer<ui.Image>();
    Timer? loadFailureTimeout;
    late ImageStreamListener listener;
    listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
      loadFailureTimeout?.cancel();
      stream.removeListener(listener);
      imageCompleter.complete(info.image);
    });

    if (timeout != Duration.zero) {
      loadFailureTimeout = Timer(timeout, () {
        stream.removeListener(listener);
        imageCompleter.completeError(
          TimeoutException(
              'Timeout occurred trying to load from $imageProvider'),
        );
      });
    }
    stream.addListener(listener);
    final ui.Image image = await imageCompleter.future;
    ui.Rect? newRegion = region;
    if (size != null && region != null) {
      final double wScale = image.width / size.width;
      final double hScale = image.height / size.height;
      newRegion = Rect.fromLTRB(
        region.left * wScale,
        region.top * hScale,
        region.right * wScale,
        region.bottom * hScale,
      );
    }
    return PaletteGenerator.fromImage(
      image,
      region: newRegion,
      maximumColorCount: maximumColorCount,
      filters: filters,
      targets: targets,
    );
  }

  static const int _defaultCalculateNumberColors = 16;

  /// Provides a map of the selected paletteColors for each target in [targets].
  final Map<PaletteTarget, PaletteColor> selectedSwatches;

  /// The list of [PaletteColor]s that make up the palette, sorted from most
  /// dominant color to least dominant color.
  final List<PaletteColor> paletteColors;

  /// The list of targets that the palette uses for custom color selection.
  ///
  /// By default, this contains the entire list of predefined targets in
  /// [PaletteTarget.baseTargets].
  final List<PaletteTarget> targets;

  /// Returns a list of colors in the [paletteColors], sorted from most
  /// dominant to least dominant color.
  Iterable<Color> get colors sync* {
    for (final PaletteColor paletteColor in paletteColors) {
      yield paletteColor.color;
    }
  }

  /// Returns a vibrant color from the palette. Might be null if an appropriate
  /// target color could not be found.
  PaletteColor? get vibrantColor => selectedSwatches[PaletteTarget.vibrant];

  /// Returns a light and vibrant color from the palette. Might be null if an
  /// appropriate target color could not be found.
  PaletteColor? get lightVibrantColor =>
      selectedSwatches[PaletteTarget.lightVibrant];

  /// Returns a dark and vibrant color from the palette. Might be null if an
  /// appropriate target color could not be found.
  PaletteColor? get darkVibrantColor =>
      selectedSwatches[PaletteTarget.darkVibrant];

  /// Returns a muted color from the palette. Might be null if an appropriate
  /// target color could not be found.
  PaletteColor? get mutedColor => selectedSwatches[PaletteTarget.muted];

  /// Returns a muted and light color from the palette. Might be null if an
  /// appropriate target color could not be found.
  PaletteColor? get lightMutedColor =>
      selectedSwatches[PaletteTarget.lightMuted];

  /// Returns a muted and dark color from the palette. Might be null if an
  /// appropriate target color could not be found.
  PaletteColor? get darkMutedColor => selectedSwatches[PaletteTarget.darkMuted];

  /// The dominant color (the color with the largest population).
  PaletteColor? get dominantColor => _dominantColor;
  PaletteColor? _dominantColor;

  void _sortSwatches() {
    if (paletteColors.isEmpty) {
      _dominantColor = null;
      return;
    }
    // Sort from most common to least common.
    paletteColors.sort((PaletteColor a, PaletteColor b) {
      return b.population.compareTo(a.population);
    });
    _dominantColor = paletteColors[0];
  }

  void _selectSwatches() {
    final Set<PaletteTarget> allTargets =
        Set<PaletteTarget>.from(targets + PaletteTarget.baseTargets);
    final Set<Color> usedColors = <Color>{};
    for (final PaletteTarget target in allTargets) {
      target._normalizeWeights();
      final PaletteColor? targetScore =
          _generateScoredTarget(target, usedColors);
      if (targetScore != null) {
        selectedSwatches[target] = targetScore;
      }
    }
  }

  PaletteColor? _generateScoredTarget(
      PaletteTarget target, Set<Color> usedColors) {
    final PaletteColor? maxScoreSwatch =
        _getMaxScoredSwatchForTarget(target, usedColors);
    if (maxScoreSwatch != null && target.isExclusive) {
      // If we have a color, and the target is exclusive, add the color to the
      // used list.
      usedColors.add(maxScoreSwatch.color);
    }
    return maxScoreSwatch;
  }

  PaletteColor? _getMaxScoredSwatchForTarget(
      PaletteTarget target, Set<Color> usedColors) {
    double maxScore = 0.0;
    PaletteColor? maxScoreSwatch;
    for (final PaletteColor paletteColor in paletteColors) {
      if (_shouldBeScoredForTarget(paletteColor, target, usedColors)) {
        final double score = _generateScore(paletteColor, target);
        if (maxScoreSwatch == null || score > maxScore) {
          maxScoreSwatch = paletteColor;
          maxScore = score;
        }
      }
    }
    return maxScoreSwatch;
  }

  bool _shouldBeScoredForTarget(
      PaletteColor paletteColor, PaletteTarget target, Set<Color> usedColors) {
    // Check whether the HSL lightness is within the correct range, and that
    // this color hasn't been used yet.
    final HSLColor hslColor = HSLColor.fromColor(paletteColor.color);
    return hslColor.saturation >= target.minimumSaturation &&
        hslColor.saturation <= target.maximumSaturation &&
        hslColor.lightness >= target.minimumLightness &&
        hslColor.lightness <= target.maximumLightness &&
        !usedColors.contains(paletteColor.color);
  }

  double _generateScore(PaletteColor paletteColor, PaletteTarget target) {
    final HSLColor hslColor = HSLColor.fromColor(paletteColor.color);

    double saturationScore = 0.0;
    double valueScore = 0.0;
    double populationScore = 0.0;

    if (target.saturationWeight > 0.0) {
      saturationScore = target.saturationWeight *
          (1.0 - (hslColor.saturation - target.targetSaturation).abs());
    }
    if (target.lightnessWeight > 0.0) {
      valueScore = target.lightnessWeight *
          (1.0 - (hslColor.lightness - target.targetLightness).abs());
    }
    if (_dominantColor != null && target.populationWeight > 0.0) {
      populationScore = target.populationWeight *
          (paletteColor.population / _dominantColor!.population);
    }

    return saturationScore + valueScore + populationScore;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<PaletteColor>(
        'paletteColors', paletteColors,
        defaultValue: <PaletteColor>[]));
    properties.add(IterableProperty<PaletteTarget>('targets', targets,
        defaultValue: PaletteTarget.baseTargets));
  }
}

/// A class which allows custom selection of colors when a [PaletteGenerator] is
/// generated.
///
/// To add a target, supply it to the `targets` list in
/// [PaletteGenerator.fromImage] or [PaletteGenerator..fromColors].
///
/// See also:
///
///   * [PaletteGenerator], a class for selecting color palettes from images.
class PaletteTarget with Diagnosticable {
  /// Creates a [PaletteTarget] for custom palette selection.
  PaletteTarget({
    this.minimumSaturation = 0.0,
    this.targetSaturation = 0.5,
    this.maximumSaturation = 1.0,
    this.minimumLightness = 0.0,
    this.targetLightness = 0.5,
    this.maximumLightness = 1.0,
    this.isExclusive = true,
  });

  /// The minimum saturation value for this target.
  final double minimumSaturation;

  /// The target saturation value for this target.
  final double targetSaturation;

  /// The maximum saturation value for this target.
  final double maximumSaturation;

  /// The minimum lightness value for this target.
  final double minimumLightness;

  /// The target lightness value for this target.
  final double targetLightness;

  /// The maximum lightness value for this target.
  final double maximumLightness;

  /// Returns whether any color selected for this target is exclusive for this
  /// target only.
  ///
  /// If false, then the color can also be selected for other targets. Defaults
  /// to true.
  final bool isExclusive;

  /// The weight of importance that a color's saturation value has on selection.
  double saturationWeight = _weightSaturation;

  /// The weight of importance that a color's lightness value has on selection.
  double lightnessWeight = _weightLightness;

  /// The weight of importance that a color's population value has on selection.
  double populationWeight = _weightPopulation;

  static const double _targetDarkLightness = 0.26;
  static const double _maxDarkLightness = 0.45;

  static const double _minLightLightness = 0.55;
  static const double _targetLightLightness = 0.74;

  static const double _minNormalLightness = 0.3;
  static const double _maxNormalLightness = 0.7;

  static const double _targetMutedSaturation = 0.3;
  static const double _maxMutedSaturation = 0.4;

  static const double _targetVibrantSaturation = 1.0;
  static const double _minVibrantSaturation = 0.35;

  static const double _weightSaturation = 0.24;
  static const double _weightLightness = 0.52;
  static const double _weightPopulation = 0.24;

  /// A target which has the characteristics of a vibrant color which is light
  /// in luminance.
  ///
  /// One of the base set of `targets` for [PaletteGenerator.fromImage], in [baseTargets].
  static final PaletteTarget lightVibrant = PaletteTarget(
    targetLightness: _targetLightLightness,
    minimumLightness: _minLightLightness,
    minimumSaturation: _minVibrantSaturation,
    targetSaturation: _targetVibrantSaturation,
  );

  /// A target which has the characteristics of a vibrant color which is neither
  /// light or dark.
  ///
  /// One of the base set of `targets` for [PaletteGenerator.fromImage], in [baseTargets].
  static final PaletteTarget vibrant = PaletteTarget(
    minimumLightness: _minNormalLightness,
    maximumLightness: _maxNormalLightness,
    minimumSaturation: _minVibrantSaturation,
    targetSaturation: _targetVibrantSaturation,
  );

  /// A target which has the characteristics of a vibrant color which is dark in
  /// luminance.
  ///
  /// One of the base set of `targets` for [PaletteGenerator.fromImage], in [baseTargets].
  static final PaletteTarget darkVibrant = PaletteTarget(
    targetLightness: _targetDarkLightness,
    maximumLightness: _maxDarkLightness,
    minimumSaturation: _minVibrantSaturation,
    targetSaturation: _targetVibrantSaturation,
  );

  /// A target which has the characteristics of a muted color which is light in
  /// luminance.
  ///
  /// One of the base set of `targets` for [PaletteGenerator.fromImage], in [baseTargets].
  static final PaletteTarget lightMuted = PaletteTarget(
    targetLightness: _targetLightLightness,
    minimumLightness: _minLightLightness,
    targetSaturation: _targetMutedSaturation,
    maximumSaturation: _maxMutedSaturation,
  );

  /// A target which has the characteristics of a muted color which is neither
  /// light or dark.
  ///
  /// One of the base set of `targets` for [PaletteGenerator.fromImage], in [baseTargets].
  static final PaletteTarget muted = PaletteTarget(
    minimumLightness: _minNormalLightness,
    maximumLightness: _maxNormalLightness,
    targetSaturation: _targetMutedSaturation,
    maximumSaturation: _maxMutedSaturation,
  );

  /// A target which has the characteristics of a muted color which is dark in
  /// luminance.
  ///
  /// One of the base set of `targets` for [PaletteGenerator.fromImage], in [baseTargets].
  static final PaletteTarget darkMuted = PaletteTarget(
    targetLightness: _targetDarkLightness,
    maximumLightness: _maxDarkLightness,
    targetSaturation: _targetMutedSaturation,
    maximumSaturation: _maxMutedSaturation,
  );

  /// A list of all the available predefined targets.
  ///
  /// The base set of `targets` for [PaletteGenerator.fromImage].
  static final List<PaletteTarget> baseTargets = <PaletteTarget>[
    lightVibrant,
    vibrant,
    darkVibrant,
    lightMuted,
    muted,
    darkMuted,
  ];

  void _normalizeWeights() {
    final double sum = saturationWeight + lightnessWeight + populationWeight;
    if (sum != 0.0) {
      saturationWeight /= sum;
      lightnessWeight /= sum;
      populationWeight /= sum;
    }
  }

  @override
  bool operator ==(Object other) {
    return other is PaletteTarget &&
        minimumSaturation == other.minimumSaturation &&
        targetSaturation == other.targetSaturation &&
        maximumSaturation == other.maximumSaturation &&
        minimumLightness == other.minimumLightness &&
        targetLightness == other.targetLightness &&
        maximumLightness == other.maximumLightness &&
        saturationWeight == other.saturationWeight &&
        lightnessWeight == other.lightnessWeight &&
        populationWeight == other.populationWeight;
  }

  @override
  int get hashCode {
    return Object.hash(
      minimumSaturation,
      targetSaturation,
      maximumSaturation,
      minimumLightness,
      targetLightness,
      maximumLightness,
      saturationWeight,
      lightnessWeight,
      populationWeight,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final PaletteTarget defaultTarget = PaletteTarget();
    properties.add(DoubleProperty('minimumSaturation', minimumSaturation,
        defaultValue: defaultTarget.minimumSaturation));
    properties.add(DoubleProperty('targetSaturation', targetSaturation,
        defaultValue: defaultTarget.targetSaturation));
    properties.add(DoubleProperty('maximumSaturation', maximumSaturation,
        defaultValue: defaultTarget.maximumSaturation));
    properties.add(DoubleProperty('minimumLightness', minimumLightness,
        defaultValue: defaultTarget.minimumLightness));
    properties.add(DoubleProperty('targetLightness', targetLightness,
        defaultValue: defaultTarget.targetLightness));
    properties.add(DoubleProperty('maximumLightness', maximumLightness,
        defaultValue: defaultTarget.maximumLightness));
    properties.add(DoubleProperty('saturationWeight', saturationWeight,
        defaultValue: defaultTarget.saturationWeight));
    properties.add(DoubleProperty('lightnessWeight', lightnessWeight,
        defaultValue: defaultTarget.lightnessWeight));
    properties.add(DoubleProperty('populationWeight', populationWeight,
        defaultValue: defaultTarget.populationWeight));
  }
}

typedef _ContrastCalculator = double Function(Color a, Color b, int alpha);

/// A color palette color generated by the [PaletteGenerator].
///
/// This palette color represents a dominant [color] in an image, and has a
/// [population] of how many pixels in the source image it represents. It picks
/// a [titleTextColor] and a [bodyTextColor] that contrast sufficiently with the
/// source [color] for comfortable reading.
///
/// See also:
///
///   * [PaletteGenerator], a class for selecting color palettes from images.
class PaletteColor with Diagnosticable {
  /// Generate a [PaletteColor].
  PaletteColor(this.color, this.population);

  static const double _minContrastTitleText = 3.0;
  static const double _minContrastBodyText = 4.5;

  /// The color that this palette color represents.
  final Color color;

  /// The number of pixels in the source image that this palette color
  /// represents.
  final int population;

  /// The color of title text for use with this palette color.
  Color get titleTextColor {
    if (_titleTextColor == null) {
      _ensureTextColorsGenerated();
    }
    return _titleTextColor!;
  }

  Color? _titleTextColor;

  /// The color of body text for use with this palette color.
  Color get bodyTextColor {
    if (_bodyTextColor == null) {
      _ensureTextColorsGenerated();
    }
    return _bodyTextColor!;
  }

  Color? _bodyTextColor;

  void _ensureTextColorsGenerated() {
    if (_titleTextColor == null || _bodyTextColor == null) {
      const Color white = Color(0xffffffff);
      const Color black = Color(0xff000000);
      // First check white, as most colors will be dark
      final int? lightBodyAlpha =
          _calculateMinimumAlpha(white, color, _minContrastBodyText);
      final int? lightTitleAlpha =
          _calculateMinimumAlpha(white, color, _minContrastTitleText);

      if (lightBodyAlpha != null && lightTitleAlpha != null) {
        // If we found valid light values, use them and return
        _bodyTextColor = white.withAlpha(lightBodyAlpha);
        _titleTextColor = white.withAlpha(lightTitleAlpha);
        return;
      }

      final int? darkBodyAlpha =
          _calculateMinimumAlpha(black, color, _minContrastBodyText);
      final int? darkTitleAlpha =
          _calculateMinimumAlpha(black, color, _minContrastTitleText);

      if (darkBodyAlpha != null && darkTitleAlpha != null) {
        // If we found valid dark values, use them and return
        _bodyTextColor = black.withAlpha(darkBodyAlpha);
        _titleTextColor = black.withAlpha(darkTitleAlpha);
        return;
      }

      // If we reach here then we can not find title and body values which use
      // the same lightness, we need to use mismatched values
      _bodyTextColor = lightBodyAlpha != null
          ? white.withAlpha(lightBodyAlpha)
          : black.withAlpha(darkBodyAlpha ?? 255);
      _titleTextColor = lightTitleAlpha != null
          ? white.withAlpha(lightTitleAlpha)
          : black.withAlpha(darkTitleAlpha ?? 255);
    }
  }

  /// Returns the contrast ratio between [foreground] and [background].
  /// [background] must be opaque.
  ///
  /// Formula defined [here](http://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef).
  static double _calculateContrast(Color foreground, Color background) {
    assert(background.alpha == 0xff,
        'background can not be translucent: $background.');
    if (foreground.alpha < 0xff) {
      // If the foreground is translucent, composite the foreground over the
      // background
      foreground = Color.alphaBlend(foreground, background);
    }
    final double lightness1 = foreground.computeLuminance() + 0.05;
    final double lightness2 = background.computeLuminance() + 0.05;
    return math.max(lightness1, lightness2) / math.min(lightness1, lightness2);
  }

  // Calculates the minimum alpha value which can be applied to foreground that
  // would have a contrast value of at least [minContrastRatio] when compared to
  // background.
  //
  // The background must be opaque (alpha of 255).
  //
  // Returns the alpha value in the range 0-255, or null if no value could be
  // calculated.
  static int? _calculateMinimumAlpha(
      Color foreground, Color background, double minContrastRatio) {
    assert(background.alpha == 0xff,
        'The background cannot be translucent: $background.');
    double contrastCalculator(Color fg, Color bg, int alpha) {
      final Color testForeground = fg.withAlpha(alpha);
      return _calculateContrast(testForeground, bg);
    }

    // First lets check that a fully opaque foreground has sufficient contrast
    final double testRatio = contrastCalculator(foreground, background, 0xff);
    if (testRatio < minContrastRatio) {
      // Fully opaque foreground does not have sufficient contrast, return error
      return null;
    }
    foreground = foreground.withAlpha(0xff);
    return _binaryAlphaSearch(
        foreground, background, minContrastRatio, contrastCalculator);
  }

  // Calculates the alpha value using binary search based on a given contrast
  // evaluation function and target contrast that needs to be satisfied.
  //
  // The background must be opaque (alpha of 255).
  //
  // Returns the alpha value in the range [0, 255].
  static int _binaryAlphaSearch(
    Color foreground,
    Color background,
    double minContrastRatio,
    _ContrastCalculator calculator,
  ) {
    assert(background.alpha == 0xff,
        'The background cannot be translucent: $background.');
    const int minAlphaSearchMaxIterations = 10;
    const int minAlphaSearchPrecision = 1;

    // Binary search to find a value with the minimum value which provides
    // sufficient contrast
    int numIterations = 0;
    int minAlpha = 0;
    int maxAlpha = 0xff;
    while (numIterations <= minAlphaSearchMaxIterations &&
        (maxAlpha - minAlpha) > minAlphaSearchPrecision) {
      final int testAlpha = (minAlpha + maxAlpha) ~/ 2;
      final double testRatio = calculator(foreground, background, testAlpha);
      if (testRatio < minContrastRatio) {
        minAlpha = testAlpha;
      } else {
        maxAlpha = testAlpha;
      }
      numIterations++;
    }
    // Conservatively return the max of the range of possible alphas, which is
    // known to pass.
    return maxAlpha;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Color>('color', color));
    properties
        .add(DiagnosticsProperty<Color>('titleTextColor', titleTextColor));
    properties.add(DiagnosticsProperty<Color>('bodyTextColor', bodyTextColor));
    properties.add(IntProperty('population', population, defaultValue: 0));
  }

  @override
  int get hashCode => Object.hash(color, population);

  @override
  bool operator ==(Object other) {
    return other is PaletteColor &&
        color == other.color &&
        population == other.population;
  }
}

/// Hook to allow clients to be able filter colors from selected in a
/// [PaletteGenerator]. Returns true if the [color] is allowed.
///
/// See also:
///
///   * [PaletteGenerator.fromImage], which takes a list of these for its
///    `filters` parameter.
///   * [avoidRedBlackWhitePaletteFilter], the default filter for
///     [PaletteGenerator].
typedef PaletteFilter = bool Function(HSLColor color);

/// A basic [PaletteFilter], which rejects colors near black, white and low
/// saturation red.
///
/// Use this as an element in the `filters` list given to [PaletteGenerator.fromImage].
///
/// See also:
///  * [PaletteGenerator], a class for selecting color palettes from images.
bool avoidRedBlackWhitePaletteFilter(HSLColor color) {
  bool isBlack(HSLColor hslColor) {
    const double blackMaxLightness = 0.05;
    return hslColor.lightness <= blackMaxLightness;
  }

  bool isWhite(HSLColor hslColor) {
    const double whiteMinLightness = 0.95;
    return hslColor.lightness >= whiteMinLightness;
  }

  // Returns true if the color is close to the red side of the I line.
  bool isNearRedILine(HSLColor hslColor) {
    const double redLineMinHue = 10.0;
    const double redLineMaxHue = 37.0;
    const double redLineMaxSaturation = 0.82;
    return hslColor.hue >= redLineMinHue &&
        hslColor.hue <= redLineMaxHue &&
        hslColor.saturation <= redLineMaxSaturation;
  }

  return !isWhite(color) && !isBlack(color) && !isNearRedILine(color);
}

enum _ColorComponent {
  red,
  green,
  blue,
}

/// A box that represents a volume in the RGB color space.
class _ColorVolumeBox {
  _ColorVolumeBox(
      this._lowerIndex, this._upperIndex, this.histogram, this.colors) {
    _fitMinimumBox();
  }

  final _ColorHistogram histogram;
  final List<Color> colors;

  // The lower and upper index are inclusive.
  final int _lowerIndex;
  int _upperIndex;

  // The population of colors within this box.
  late int _population;

  // Bounds in each of the dimensions.
  late int _minRed;
  late int _maxRed;
  late int _minGreen;
  late int _maxGreen;
  late int _minBlue;
  late int _maxBlue;

  int getVolume() {
    return (_maxRed - _minRed + 1) *
        (_maxGreen - _minGreen + 1) *
        (_maxBlue - _minBlue + 1);
  }

  bool canSplit() {
    return getColorCount() > 1;
  }

  int getColorCount() {
    return 1 + _upperIndex - _lowerIndex;
  }

  /// Recomputes the boundaries of this box to tightly fit the colors within the
  /// box.
  void _fitMinimumBox() {
    // Reset the min and max to opposite values
    int minRed = 256;
    int minGreen = 256;
    int minBlue = 256;
    int maxRed = -1;
    int maxGreen = -1;
    int maxBlue = -1;
    int count = 0;
    for (int i = _lowerIndex; i <= _upperIndex; i++) {
      final Color color = colors[i];
      count += histogram[color]!.value;
      if (color.red > maxRed) {
        maxRed = color.red;
      }
      if (color.red < minRed) {
        minRed = color.red;
      }
      if (color.green > maxGreen) {
        maxGreen = color.green;
      }
      if (color.green < minGreen) {
        minGreen = color.green;
      }
      if (color.blue > maxBlue) {
        maxBlue = color.blue;
      }
      if (color.blue < minBlue) {
        minBlue = color.blue;
      }
    }
    _minRed = minRed;
    _maxRed = maxRed;
    _minGreen = minGreen;
    _maxGreen = maxGreen;
    _minBlue = minBlue;
    _maxBlue = maxBlue;
    _population = count;
  }

  /// Split this color box at the mid-point along it's longest dimension.
  ///
  /// Returns the new ColorBox.
  _ColorVolumeBox splitBox() {
    assert(canSplit(), "Can't split a box with only 1 color");
    // find median along the longest dimension
    final int splitPoint = _findSplitPoint();
    final _ColorVolumeBox newBox =
        _ColorVolumeBox(splitPoint + 1, _upperIndex, histogram, colors);
    // Now change this box's upperIndex and recompute the color boundaries
    _upperIndex = splitPoint;
    _fitMinimumBox();
    return newBox;
  }

  /// Returns the largest dimension of this color box.
  _ColorComponent _getLongestColorDimension() {
    final int redLength = _maxRed - _minRed;
    final int greenLength = _maxGreen - _minGreen;
    final int blueLength = _maxBlue - _minBlue;
    if (redLength >= greenLength && redLength >= blueLength) {
      return _ColorComponent.red;
    } else if (greenLength >= redLength && greenLength >= blueLength) {
      return _ColorComponent.green;
    } else {
      return _ColorComponent.blue;
    }
  }

  // Finds where to split this box between _lowerIndex and _upperIndex.
  //
  // The split point is calculated by finding the longest color dimension, and
  // then sorting the sub-array based on that dimension value in each color.
  // The colors are then iterated over until a color is found with the
  // midpoint closest to the whole box's dimension midpoint.
  //
  // Returns the index of the split point in the colors array.
  int _findSplitPoint() {
    final _ColorComponent longestDimension = _getLongestColorDimension();
    int compareColors(Color a, Color b) {
      int makeValue(int first, int second, int third) {
        return first << 16 | second << 8 | third;
      }

      switch (longestDimension) {
        case _ColorComponent.red:
          final int aValue = makeValue(a.red, a.green, a.blue);
          final int bValue = makeValue(b.red, b.green, b.blue);
          return aValue.compareTo(bValue);
        case _ColorComponent.green:
          final int aValue = makeValue(a.green, a.red, a.blue);
          final int bValue = makeValue(b.green, b.red, b.blue);
          return aValue.compareTo(bValue);
        case _ColorComponent.blue:
          final int aValue = makeValue(a.blue, a.green, a.red);
          final int bValue = makeValue(b.blue, b.green, b.red);
          return aValue.compareTo(bValue);
      }
    }

    // We need to sort the colors in this box based on the longest color
    // dimension.
    final List<Color> colorSubset =
        colors.sublist(_lowerIndex, _upperIndex + 1);
    colorSubset.sort(compareColors);
    colors.replaceRange(_lowerIndex, _upperIndex + 1, colorSubset);
    final int median = (_population / 2).round();
    for (int i = 0, count = 0; i <= colorSubset.length; i++) {
      count += histogram[colorSubset[i]]!.value;
      if (count >= median) {
        // We never want to split on the upperIndex, as this will result in the
        // same box.
        return math.min(_upperIndex - 1, i + _lowerIndex);
      }
    }
    return _lowerIndex;
  }

  PaletteColor getAverageColor() {
    int redSum = 0;
    int greenSum = 0;
    int blueSum = 0;
    int totalPopulation = 0;
    for (int i = _lowerIndex; i <= _upperIndex; i++) {
      final Color color = colors[i];
      final int colorPopulation = histogram[color]!.value;
      totalPopulation += colorPopulation;
      redSum += colorPopulation * color.red;
      greenSum += colorPopulation * color.green;
      blueSum += colorPopulation * color.blue;
    }
    final int redMean = (redSum / totalPopulation).round();
    final int greenMean = (greenSum / totalPopulation).round();
    final int blueMean = (blueSum / totalPopulation).round();
    return PaletteColor(
      Color.fromARGB(0xff, redMean, greenMean, blueMean),
      totalPopulation,
    );
  }
}

/// Holds mutable count for a color.
// Using a mutable count rather than replacing value in the histogram
// in the _ColorCutQuantizer speeds up building the histogram significantly.
class _ColorCount {
  int value = 0;
}

class _ColorHistogram {
  final Map<int, Map<int, Map<int, _ColorCount>>> _hist =
      <int, Map<int, Map<int, _ColorCount>>>{};
  final DoubleLinkedQueue<Color> _keys = DoubleLinkedQueue<Color>();

  _ColorCount? operator [](Color color) {
    final Map<int, Map<int, _ColorCount>>? redMap = _hist[color.red];
    if (redMap == null) {
      return null;
    }
    final Map<int, _ColorCount>? blueMap = redMap[color.blue];
    if (blueMap == null) {
      return null;
    }
    return blueMap[color.green];
  }

  void operator []=(Color key, _ColorCount value) {
    final int red = key.red;
    final int blue = key.blue;
    final int green = key.green;

    bool newColor = false;

    Map<int, Map<int, _ColorCount>>? redMap = _hist[red];
    if (redMap == null) {
      _hist[red] = redMap = <int, Map<int, _ColorCount>>{};
      newColor = true;
    }

    Map<int, _ColorCount>? blueMap = redMap[blue];
    if (blueMap == null) {
      redMap[blue] = blueMap = <int, _ColorCount>{};
      newColor = true;
    }

    if (blueMap[green] == null) {
      newColor = true;
    }
    blueMap[green] = value;

    if (newColor) {
      _keys.add(key);
    }
  }

  void removeWhere(bool Function(Color key) predicate) {
    for (final Color key in _keys) {
      if (predicate(key)) {
        _hist[key.red]?[key.blue]?.remove(key.green);
      }
    }
    _keys.removeWhere((Color color) => predicate(color));
  }

  Iterable<Color> get keys {
    return _keys;
  }

  int get length {
    return _keys.length;
  }
}

class _ColorCutQuantizer {
  _ColorCutQuantizer(
    this.encodedImage, {
    this.maxColors = PaletteGenerator._defaultCalculateNumberColors,
    this.region,
    this.filters = const <PaletteFilter>[avoidRedBlackWhitePaletteFilter],
  }) : assert(region == null || region != Rect.zero);

  final EncodedImage encodedImage;
  final int maxColors;
  final Rect? region;
  final List<PaletteFilter> filters;

  Completer<List<PaletteColor>>? _paletteColorsCompleter;
  FutureOr<List<PaletteColor>> get quantizedColors async {
    if (_paletteColorsCompleter == null) {
      _paletteColorsCompleter = Completer<List<PaletteColor>>();
      _paletteColorsCompleter!.complete(_quantizeColors());
    }
    return _paletteColorsCompleter!.future;
  }

  Iterable<Color> _getImagePixels(ByteData pixels, int width, int height,
      {Rect? region}) sync* {
    final int rowStride = width * 4;
    int rowStart;
    int rowEnd;
    int colStart;
    int colEnd;
    if (region != null) {
      rowStart = region.top.floor();
      rowEnd = region.bottom.floor();
      colStart = region.left.floor();
      colEnd = region.right.floor();
      assert(rowStart >= 0);
      assert(rowEnd <= height);
      assert(colStart >= 0);
      assert(colEnd <= width);
    } else {
      rowStart = 0;
      rowEnd = height;
      colStart = 0;
      colEnd = width;
    }
    int byteCount = 0;
    for (int row = rowStart; row < rowEnd; ++row) {
      for (int col = colStart; col < colEnd; ++col) {
        final int position = row * rowStride + col * 4;
        // Convert from RGBA to ARGB.
        final int pixel = pixels.getUint32(position);
        final Color result = Color((pixel << 24) | (pixel >> 8));
        byteCount += 4;
        yield result;
      }
    }
    assert(byteCount == ((rowEnd - rowStart) * (colEnd - colStart) * 4));
  }

  bool _shouldIgnoreColor(Color color) {
    final HSLColor hslColor = HSLColor.fromColor(color);
    if (filters.isNotEmpty) {
      for (final PaletteFilter filter in filters) {
        if (!filter(hslColor)) {
          return true;
        }
      }
    }
    return false;
  }

  List<PaletteColor> _quantizeColors() {
    const int quantizeWordWidth = 5;
    const int quantizeChannelWidth = 8;
    const int quantizeShift = quantizeChannelWidth - quantizeWordWidth;
    const int quantizeWordMask =
        ((1 << quantizeWordWidth) - 1) << quantizeShift;

    Color quantizeColor(Color color) {
      return Color.fromARGB(
        color.alpha,
        color.red & quantizeWordMask,
        color.green & quantizeWordMask,
        color.blue & quantizeWordMask,
      );
    }

    final List<PaletteColor> paletteColors = <PaletteColor>[];
    final Iterable<Color> pixels = _getImagePixels(
      encodedImage.byteData,
      encodedImage.width,
      encodedImage.height,
      region: region,
    );
    final _ColorHistogram hist = _ColorHistogram();
    Color? currentColor;
    _ColorCount? currentColorCount;

    for (final Color pixel in pixels) {
      // Update the histogram, but only for non-zero alpha values, and for the
      // ones we do add, make their alphas opaque so that we can use a Color as
      // the histogram key.
      final Color quantizedColor = quantizeColor(pixel);
      final Color colorKey = quantizedColor.withAlpha(0xff);
      // Skip pixels that are entirely transparent.
      if (quantizedColor.alpha == 0x0) {
        continue;
      }
      if (currentColor != colorKey) {
        currentColor = colorKey;
        currentColorCount = hist[colorKey];
        if (currentColorCount == null) {
          hist[colorKey] = currentColorCount = _ColorCount();
        }
      }
      currentColorCount!.value = currentColorCount.value + 1;
    }
    // Now let's remove any colors that the filters want to ignore.
    hist.removeWhere((Color color) {
      return _shouldIgnoreColor(color);
    });
    if (hist.length <= maxColors) {
      // The image has fewer colors than the maximum requested, so just return
      // the colors.
      paletteColors.clear();
      for (final Color color in hist.keys) {
        paletteColors.add(PaletteColor(color, hist[color]!.value));
      }
    } else {
      // We need use quantization to reduce the number of colors
      paletteColors.clear();
      paletteColors.addAll(_quantizePixels(maxColors, hist));
    }
    return paletteColors;
  }

  List<PaletteColor> _quantizePixels(
    int maxColors,
    _ColorHistogram histogram,
  ) {
    int volumeComparator(_ColorVolumeBox a, _ColorVolumeBox b) {
      return b.getVolume().compareTo(a.getVolume());
    }

    // Create the priority queue which is sorted by volume descending. This
    // means we always split the largest box in the queue
    final PriorityQueue<_ColorVolumeBox> priorityQueue =
        HeapPriorityQueue<_ColorVolumeBox>(volumeComparator);
    // To start, offer a box which contains all of the colors
    priorityQueue.add(_ColorVolumeBox(
        0, histogram.length - 1, histogram, histogram.keys.toList()));
    // Now go through the boxes, splitting them until we have reached maxColors
    // or there are no more boxes to split
    _splitBoxes(priorityQueue, maxColors);
    // Finally, return the average colors of the color boxes.
    return _generateAverageColors(priorityQueue);
  }

  // Iterate through the [PriorityQueue], popping [_ColorVolumeBox] objects
  // from the queue and splitting them. Once split, the new box and the
  // remaining box are offered back to the queue.
  //
  // The `maxSize` is the maximum number of boxes to split.
  void _splitBoxes(PriorityQueue<_ColorVolumeBox> queue, final int maxSize) {
    while (queue.length < maxSize) {
      final _ColorVolumeBox colorVolumeBox = queue.removeFirst();
      if (colorVolumeBox.canSplit()) {
        // First split the box, and offer the result
        queue.add(colorVolumeBox.splitBox());
        // Then offer the box back
        queue.add(colorVolumeBox);
      } else {
        // If we get here then there are no more boxes to split, so return
        return;
      }
    }
  }

  // Generates the average colors from each of the boxes in the queue.
  List<PaletteColor> _generateAverageColors(
      PriorityQueue<_ColorVolumeBox> colorVolumeBoxes) {
    final List<PaletteColor> colors = <PaletteColor>[];
    for (final _ColorVolumeBox colorVolumeBox in colorVolumeBoxes.toList()) {
      final PaletteColor paletteColor = colorVolumeBox.getAverageColor();
      if (!_shouldIgnoreColor(paletteColor.color)) {
        colors.add(paletteColor);
      }
    }
    return colors;
  }
}
