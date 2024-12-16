// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async' show Future;
import 'dart:typed_data' show Uint8List;
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/material.dart'
    show
        AssetBundleImageKey,
        AssetImage,
        BoxFit,
        ImageConfiguration,
        Size,
        createLocalImageConfiguration;
import 'package:flutter/services.dart' show AssetBundle;

/// Type of bitmap scaling to use on BitmapDescriptor creation.
enum MapBitmapScaling {
  /// Automatically scale image with devices pixel ratio or to given size,
  /// to keep marker sizes same between platforms and devices.
  auto,

  /// Render marker to the map as without scaling.
  ///
  /// This can be used if the image is already pre-scaled, or to increase
  /// performance with a large numbers of markers.
  none,
}

/// Convert a string from provided JSON to a MapBitmapScaling enum.
@visibleForTesting
MapBitmapScaling mapBitmapScalingFromString(String mode) => switch (mode) {
      'auto' => MapBitmapScaling.auto,
      'none' => MapBitmapScaling.none,
      _ => throw ArgumentError('Unrecognized MapBitmapScaling $mode', 'mode'),
    };

// The default pixel ratio for custom bitmaps.
const double _naturalPixelRatio = 1.0;

/// Defines a bitmap image. For a marker, this class can be used to set the
/// image of the marker icon. For a ground overlay, it can be used to set the
/// image to place on the surface of the earth.
///
/// Use the [BitmapDescriptor.asset] or [AssetMapBitmap.create] to create a
/// [BitmapDescriptor] image from an asset.
/// Use the [BitmapDescriptor.bytes] or [BytesMapBitmap] to create a
/// [BitmapDescriptor] image from a list of bytes.
/// Use the [BitmapDescriptor.defaultMarker] to create a [BitmapDescriptor] for
/// a default marker icon.
/// Use the [BitmapDescriptor.defaultMarkerWithHue] to create a
/// [BitmapDescriptor] for a default marker icon with a hue value.
/// Use the [BitmapDescriptor.pinConfig] to create a custom icon for
/// [AdvancedMarker].
abstract class BitmapDescriptor {
  const BitmapDescriptor._();

  /// The inverse of .toJson.
  // TODO(stuartmorgan): Remove this in the next breaking change.
  @Deprecated('No longer supported')
  static BitmapDescriptor fromJson(Object json) {
    assert(json is List<dynamic>);
    final List<dynamic> jsonList = json as List<dynamic>;
    assert(_validTypes.contains(jsonList[0]));
    switch (jsonList[0]) {
      case _defaultMarker:
        assert(jsonList.length <= 2);
        if (jsonList.length == 2) {
          assert(jsonList[1] is num);
          final num secondElement = jsonList[1] as num;
          assert(0 <= secondElement && secondElement < 360);
          return DefaultMarker(hue: secondElement);
        }
        return const DefaultMarker();
      case _fromBytes:
        assert(jsonList.length == 2);
        assert(jsonList[1] != null && jsonList[1] is List<int>);
        assert((jsonList[1] as List<int>).isNotEmpty);
        return BytesBitmap(byteData: jsonList[1] as Uint8List);
      case _fromAsset:
        assert(jsonList.length <= 3);
        assert(jsonList[1] != null && jsonList[1] is String);
        assert((jsonList[1] as String).isNotEmpty);
        if (jsonList.length == 3) {
          assert(jsonList[2] != null && jsonList[2] is String);
          assert((jsonList[2] as String).isNotEmpty);
          return AssetBitmap(
              name: jsonList[1] as String, package: jsonList[2] as String);
        }
        return AssetBitmap(name: jsonList[1] as String);
      case _fromAssetImage:
        assert(jsonList.length <= 4);
        assert(jsonList[1] != null && jsonList[1] is String);
        assert((jsonList[1] as String).isNotEmpty);
        assert(jsonList[2] != null && jsonList[2] is double);
        if (jsonList.length == 4) {
          assert(jsonList[3] != null && jsonList[3] is List<dynamic>);
          assert((jsonList[3] as List<dynamic>).length == 2);
          final List<dynamic> sizeList = jsonList[3] as List<dynamic>;
          return AssetImageBitmap(
              name: jsonList[1] as String,
              scale: jsonList[2] as double,
              size: Size((sizeList[0] as num).toDouble(),
                  (sizeList[1] as num).toDouble()));
        }
        return AssetImageBitmap(
            name: jsonList[1] as String, scale: jsonList[2] as double);
      case AssetMapBitmap.type:
        assert(jsonList.length == 2);
        assert(jsonList[1] != null && jsonList[1] is Map<String, dynamic>);
        final Map<String, dynamic> jsonMap =
            jsonList[1] as Map<String, dynamic>;
        assert(jsonMap.containsKey('assetName'));
        assert(jsonMap.containsKey('bitmapScaling'));
        assert(jsonMap.containsKey('imagePixelRatio'));
        assert(jsonMap['assetName'] is String);
        assert(jsonMap['bitmapScaling'] is String);
        assert(jsonMap['imagePixelRatio'] is double);
        assert(!jsonMap.containsKey('width') || jsonMap['width'] is double);
        assert(!jsonMap.containsKey('height') || jsonMap['height'] is double);
        final double? width =
            jsonMap.containsKey('width') ? jsonMap['width'] as double : null;
        final double? height =
            jsonMap.containsKey('height') ? jsonMap['height'] as double : null;
        return AssetMapBitmap(jsonMap['assetName'] as String,
            bitmapScaling:
                mapBitmapScalingFromString(jsonMap['bitmapScaling'] as String),
            imagePixelRatio: jsonMap['imagePixelRatio'] as double,
            width: width,
            height: height);
      case BytesMapBitmap.type:
        assert(jsonList.length == 2);
        assert(jsonList[1] != null && jsonList[1] is Map<String, dynamic>);
        final Map<String, dynamic> jsonMap =
            jsonList[1] as Map<String, dynamic>;
        assert(jsonMap.containsKey('byteData'));
        assert(jsonMap.containsKey('bitmapScaling'));
        assert(jsonMap.containsKey('imagePixelRatio'));
        assert(jsonMap['byteData'] is Uint8List);
        assert(jsonMap['bitmapScaling'] is String);
        assert(jsonMap['imagePixelRatio'] is double);
        assert(!jsonMap.containsKey('width') || jsonMap['width'] is double);
        assert(!jsonMap.containsKey('height') || jsonMap['height'] is double);
        final double? width =
            jsonMap.containsKey('width') ? jsonMap['width'] as double : null;
        final double? height =
            jsonMap.containsKey('height') ? jsonMap['height'] as double : null;
        return BytesMapBitmap(jsonMap['byteData'] as Uint8List,
            bitmapScaling:
                mapBitmapScalingFromString(jsonMap['bitmapScaling'] as String),
            width: width,
            height: height,
            imagePixelRatio: jsonMap['imagePixelRatio'] as double);
      default:
        break;
    }
    throw ArgumentError('Unrecognized BitmapDescriptor type ${jsonList[0]}');
  }

  static const String _defaultMarker = 'defaultMarker';

  static const String _fromAsset = 'fromAsset';
  static const String _fromAssetImage = 'fromAssetImage';
  static const String _fromBytes = 'fromBytes';

  static const Set<String> _validTypes = <String>{
    _defaultMarker,
    _fromAsset,
    _fromAssetImage,
    _fromBytes,
    AssetMapBitmap.type,
    BytesMapBitmap.type,
  };

  /// Convenience hue value representing red.
  static const double hueRed = 0.0;

  /// Convenience hue value representing orange.
  static const double hueOrange = 30.0;

  /// Convenience hue value representing yellow.
  static const double hueYellow = 60.0;

  /// Convenience hue value representing green.
  static const double hueGreen = 120.0;

  /// Convenience hue value representing cyan.
  static const double hueCyan = 180.0;

  /// Convenience hue value representing azure.
  static const double hueAzure = 210.0;

  /// Convenience hue value representing blue.
  static const double hueBlue = 240.0;

  /// Convenience hue value representing violet.
  static const double hueViolet = 270.0;

  /// Convenience hue value representing magenta.
  static const double hueMagenta = 300.0;

  /// Convenience hue value representing rose.
  static const double hueRose = 330.0;

  /// Creates a BitmapDescriptor that refers to the default marker image.
  static const BitmapDescriptor defaultMarker = DefaultMarker();

  /// Creates a BitmapDescriptor that refers to a colorization of the default
  /// marker image. For convenience, there is a predefined set of hue values.
  /// See e.g. [hueYellow].
  ///
  /// Doesn't work with [AdvancedMarker]s, [BitmapDescriptor.pinConfig] should
  /// be used instead.
  static BitmapDescriptor defaultMarkerWithHue(double hue) {
    assert(0.0 <= hue && hue < 360.0);
    return DefaultMarker(hue: hue);
  }

  /// Creates a [BitmapDescriptor] from an asset image.
  ///
  /// Asset images in flutter are stored per:
  /// https://flutter.dev/to/resolution-aware-images
  /// This method takes into consideration various asset resolutions
  /// and scales the images to the right resolution depending on the dpi.
  /// Set `mipmaps` to false to load the exact dpi version of the image,
  /// `mipmap` is true by default.
  @Deprecated('Use BitmapDescriptor.asset method instead.')
  static Future<BitmapDescriptor> fromAssetImage(
    ImageConfiguration configuration,
    String assetName, {
    AssetBundle? bundle,
    String? package,
    bool mipmaps = true,
  }) async {
    final double? devicePixelRatio = configuration.devicePixelRatio;
    if (!mipmaps && devicePixelRatio != null) {
      return AssetImageBitmap(name: assetName, scale: devicePixelRatio);
    }
    final AssetImage assetImage =
        AssetImage(assetName, package: package, bundle: bundle);
    final AssetBundleImageKey assetBundleImageKey =
        await assetImage.obtainKey(configuration);
    final Size? size = kIsWeb ? configuration.size : null;
    return AssetImageBitmap(
        name: assetBundleImageKey.name,
        scale: assetBundleImageKey.scale,
        size: size);
  }

  /// Creates a BitmapDescriptor using an array of bytes that must be encoded
  /// as PNG.
  /// On the web, the [size] parameter represents the *physical size* of the
  /// bitmap, regardless of the actual resolution of the encoded PNG.
  /// This helps the browser to render High-DPI images at the correct size.
  /// `size` is not required (and ignored, if passed) in other platforms.
  @Deprecated('Use BitmapDescriptor.bytes method instead.')
  static BitmapDescriptor fromBytes(Uint8List byteData, {Size? size}) {
    assert(byteData.isNotEmpty,
        'Cannot create BitmapDescriptor with empty byteData');
    return BytesBitmap(byteData: byteData, size: size);
  }

  /// Creates a [BitmapDescriptor] from an asset using [AssetMapBitmap].
  ///
  /// This method wraps [AssetMapBitmap.create] for ease of use within the
  /// context of creating [BitmapDescriptor] instances. It dynamically resolves
  /// the correct asset version based on the device's pixel ratio, ensuring
  /// optimal resolution without manual configuration.
  ///
  /// [configuration] provides the image configuration for the asset.
  /// [assetName] is the name of the asset to load.
  /// [bundle] and [package] specify the asset's location if outside of the
  /// default.
  /// [width] and [height] can optionally control the dimensions of the rendered
  /// image.
  /// [imagePixelRatio] controls the scale of the image relative to the device's
  /// pixel ratio. It defaults resolved asset image pixel ratio. The value is
  /// ignored if [width] or [height] is provided.
  ///
  /// See [AssetMapBitmap.create] for more information on the parameters.
  ///
  /// Returns a Future that completes with a new [AssetMapBitmap] instance.
  static Future<AssetMapBitmap> asset(
    ImageConfiguration configuration,
    String assetName, {
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    double? imagePixelRatio,
    MapBitmapScaling bitmapScaling = MapBitmapScaling.auto,
  }) async {
    return AssetMapBitmap.create(
      configuration,
      assetName,
      bundle: bundle,
      package: package,
      width: width,
      height: height,
      imagePixelRatio: imagePixelRatio,
      bitmapScaling: bitmapScaling,
    );
  }

  /// Creates a [BitmapDescriptor] from byte data using [BytesMapBitmap].
  ///
  /// This method wraps [BytesMapBitmap] constructor for ease of use within the
  /// context of creating [BitmapDescriptor] instances.
  ///
  /// [byteData] is the PNG-encoded image data.
  /// [imagePixelRatio] controls the scale of the image relative to the device's
  /// pixel ratio. It defaults to the natural resolution if not specified.
  /// The value is ignored if [width] or [height] is provided.
  /// [width] and [height] can optionally control the dimensions of the rendered
  /// image.
  ///
  /// See [BytesMapBitmap] for more information on the parameters.
  ///
  /// Returns a new [BytesMapBitmap] instance.
  static BytesMapBitmap bytes(
    Uint8List byteData, {
    double? imagePixelRatio,
    double? width,
    double? height,
    MapBitmapScaling bitmapScaling = MapBitmapScaling.auto,
  }) {
    return BytesMapBitmap(
      byteData,
      imagePixelRatio: imagePixelRatio,
      width: width,
      height: height,
      bitmapScaling: bitmapScaling,
    );
  }

  /// Creates a [BitmapDescriptor] that can be used to customize
  /// [AdvancedMarker]'s pin.
  ///
  /// [backgroundColor] is the color of the pin's background.
  /// [borderColor] is the color of the pin's border.
  /// [glyph] is the pin's glyph to be displayed on the pin.
  ///
  /// See [PinConfig] for more information on the parameters.
  ///
  /// Returns a new [PinConfig] instance.
  static BitmapDescriptor pinConfig({
    Color? backgroundColor,
    Color? borderColor,
    AdvancedMarkerGlyph? glyph,
  }) {
    return PinConfig(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      glyph: glyph,
    );
  }

  /// Convert the object to a Json format.
  Object toJson();
}

/// A BitmapDescriptor using the default marker.
class DefaultMarker extends BitmapDescriptor {
  /// Provide an optional [hue] for the default marker.
  const DefaultMarker({this.hue}) : super._();

  /// Optional hue of the colorization of the default marker.
  final num? hue;

  @override
  Object toJson() => (hue == null)
      ? const <Object>[BitmapDescriptor._defaultMarker]
      : <Object>[BitmapDescriptor._defaultMarker, hue!];
}

/// A BitmapDescriptor using an array of bytes that must be encoded
/// as PNG.
@Deprecated('Use BytesMapBitmap instead')
class BytesBitmap extends BitmapDescriptor {
  /// On the web, the [size] parameter represents the *physical size* of the
  /// bitmap, regardless of the actual resolution of the encoded PNG.
  /// This helps the browser to render High-DPI images at the correct size.
  /// `size` is not required (and ignored, if passed) in other platforms.
  @Deprecated('Use BytesMapBitmap instead')
  const BytesBitmap({required Uint8List byteData, Size? size})
      : this._(byteData, kIsWeb ? size : null);

  @Deprecated('Use BytesMapBitmap instead')
  const BytesBitmap._(this.byteData, this.size) : super._();

  /// Array of bytes encoding a PNG.
  final Uint8List byteData;

  /// On web, the physical size of the bitmap. Null on all other platforms.
  final Size? size;

  @override
  Object toJson() => <Object>[
        BitmapDescriptor._fromBytes,
        byteData,
        if (size != null) <Object>[size!.width, size!.height]
      ];
}

/// A bitmap specified by a name and optional package.
class AssetBitmap extends BitmapDescriptor {
  /// Provides an asset name with [name] and optionally a [package].
  const AssetBitmap({required this.name, this.package}) : super._();

  /// Name of the asset backing the bitmap.
  final String name;

  /// Optional package of the asset.
  final String? package;

  @override
  Object toJson() => <Object>[
        BitmapDescriptor._fromAsset,
        name,
        if (package != null) package!
      ];
}

/// A [BitmapDescriptor] from an asset image.
@Deprecated('Use AssetMapBitmap instead')
class AssetImageBitmap extends BitmapDescriptor {
  /// Creates a [BitmapDescriptor] from an asset image with specified [name] and [scale], and an optional [size].
  /// Asset images in flutter are stored per:
  /// https://flutter.dev/to/resolution-aware-images
  /// This method takes into consideration various asset resolutions
  /// and scales the images to the right resolution depending on the dpi.
  @Deprecated('Use AssetMapBitmap instead')
  const AssetImageBitmap({required this.name, required this.scale, this.size})
      : super._();

  /// Name of the image asset.
  final String name;

  /// Scaling factor for the asset image.
  final double scale;

  /// Size of the image if using mipmaps.
  final Size? size;

  @override
  Object toJson() => <Object>[
        BitmapDescriptor._fromAssetImage,
        name,
        scale,
        if (size != null) <Object>[size!.width, size!.height]
      ];
}

/// Represents a [BitmapDescriptor] base class for map bitmaps.
///
/// See [AssetMapBitmap] and [BytesMapBitmap] for concrete implementations.
///
/// The [imagePixelRatio] should be set to the correct pixel ratio of bitmap
/// image. If the [width] or [height] is provided, the [imagePixelRatio]
/// value is ignored.
///
/// [bitmapScaling] controls the scaling behavior:
/// - [MapBitmapScaling.auto] automatically upscales and downscales the image
///   to match the device's pixel ratio or the specified dimensions,
///   maintaining consistency across devices.
/// - [MapBitmapScaling.none] disables automatic scaling, which is
///   useful when performance is a concern or if the asset is already scaled
///   appropriately.
///
/// Optionally, [width] and [height] can be specified to control the dimensions
/// of the rendered image:
/// - If both [width] and [height] are non-null, the image will have the
///   specified dimensions, which might distort the original aspect ratio,
///   similar to [BoxFit.fill].
/// - If only one of [width] and [height] is non-null, then the output image
///   will be scaled to the associated width or height, and the other dimension
///   will take whatever value is needed to maintain the image's original aspect
///   ratio. These cases are similar to [BoxFit.fitWidth] and
///   [BoxFit.fitHeight], respectively.
abstract class MapBitmap extends BitmapDescriptor {
  MapBitmap._({
    required this.bitmapScaling,
    required this.imagePixelRatio,
    this.width,
    this.height,
  }) : super._();

  /// The scaling method of the bitmap.
  final MapBitmapScaling bitmapScaling;

  /// The pixel ratio of the bitmap.
  ///
  /// If the [width] or [height] is provided, the [imagePixelRatio]
  /// value is ignored.
  final double imagePixelRatio;

  /// The target width of the bitmap in logical pixels.
  ///
  /// - If [width] is provided and [height] is null, the image will be scaled to
  ///   the associated width, and the height will take whatever value is needed
  ///   to maintain the image's original aspect ratio. This is similar to
  ///   [BoxFit.fitWidth].
  /// - If both [width] and [height] are non-null, the image will have the
  ///   specified dimensions, which might distort the original aspect ratio,
  ///   similar to [BoxFit.fill].
  /// - If neither [width] nor [height] is provided, the image will be rendered
  ///   using the [imagePixelRatio] value.
  final double? width;

  /// The target height of the bitmap in logical pixels.
  ///
  /// - If [height] is provided and [width] is null, the image will be scaled to
  ///   the associated height, and the width will take whatever value is needed
  ///   to maintain the image's original aspect ratio. This is similar to
  ///   [BoxFit.fitHeight].
  /// - If both [width] and [height] are non-null, the image will have the
  ///   specified dimensions, which might distort the original aspect ratio,
  ///   similar to [BoxFit.fill].
  /// - If neither [width] nor [height] is provided, the image will be rendered
  ///   using the [imagePixelRatio] value.
  final double? height;
}

/// Represents a [BitmapDescriptor] that is created from an asset image.
///
/// This class extends [BitmapDescriptor] to support loading images from assets
/// and mipmaps. It allows resolving the assets that are optimized
/// for the device's screen resolution and pixel density.
///
/// Use [AssetMapBitmap.create] as the default method for generating
/// instances of this class. It dynamically resolves the correct asset version
/// based on the device's pixel ratio, ensuring optimal resolution without
/// manual configuration.
/// See https://flutter.dev/to/resolution-aware-images
/// for more information on resolution-aware assets.
///
/// Note that it's important to either provide high-resolution
/// assets to gain sharp images on high-density screens or set the
/// [imagePixelRatio], [width] or [height] values to control the render size.
///
/// Following example demonstrates how to create an [AssetMapBitmap]
/// using asset resolving:
///
/// ```dart
/// Future<void> _getAssetMapBitmap(BuildContext context) async {
///   final ImageConfiguration imageConfiguration = createLocalImageConfiguration(
///     context,
//    );
///   AssetMapBitmap assetMapBitmap = await AssetMapBitmap.create(
///     imageConfiguration,
///     'assets/images/map_icon.png',
///   );
///   return assetMapBitmap;
/// }
/// ```
///
/// Optionally, [width] and [height] can be specified to control the dimensions
/// of the rendered image:
/// - If both [width] and [height] are non-null, the image will have the
///   specified dimensions, which might distort the original aspect ratio,
///   similar to [BoxFit.fill].
/// - If only one of [width] and [height] is non-null, then the output image
///   will be scaled to the associated width or height, and the other dimension
///   will take whatever value is needed to maintain the image's original aspect
///   ratio. These cases are similar to [BoxFit.fitWidth] and
///   [BoxFit.fitHeight], respectively.
///
/// ```dart
/// Future<void> _getAssetMapBitmap(BuildContext context) async {
///   final ImageConfiguration imageConfiguration = createLocalImageConfiguration(
///     context,
///    );
///   // Render the image at exact size of 64x64 logical pixels.
///   AssetMapBitmap assetMapBitmap = await AssetMapBitmap.create(
///     imageConfiguration,
///     'assets/images/map_icon.png',
///     width: 64, // Desired width in logical pixels.
///     height: 64, // Desired height in logical pixels.
///   );
///   return assetMapBitmap;
/// }
/// ```
///
/// The following example demonstrates how to create an [AssetMapBitmap] from
/// an asset image without automatic mipmap resolving:
///
/// ```dart
/// AssetMapBitmap assetMapBitmap = AssetMapBitmap(
///   'assets/images/map_icon.png',
/// );
/// ```
///
/// To render the bitmap as sharply as possible, set the [imagePixelRatio] to
/// the device's pixel ratio. This renders the asset at a pixel-to-pixel ratio
/// on the screen, but may result in different logical marker sizes across
/// devices with varying pixel densities.
///
///```dart
/// AssetMapBitmap assetMapBitmap = AssetMapBitmap(
///   'assets/images/map_icon.png',
///   imagePixelRatio: MediaQuery.maybeDevicePixelRatioOf(context),
/// );
/// ```
class AssetMapBitmap extends MapBitmap {
  /// Creates a [AssetMapBitmap] from an asset image.
  ///
  /// To create an instance of [AssetMapBitmap] from mipmapped assets, use the
  /// asynchronous [AssetMapBitmap.create] method instead of this constructor.
  ///
  /// The [imagePixelRatio] parameter allows to give correct pixel ratio of the
  /// asset image. If the [imagePixelRatio] is not provided, value is defaulted
  /// to the natural resolution of 1.0. To render the asset as sharp as
  /// possible, set the [imagePixelRatio] to the devices pixel ratio.
  ///
  /// [bitmapScaling] controls the scaling behavior:
  /// - [MapBitmapScaling.auto] automatically upscales and downscales the image
  ///   to match the device's pixel ratio or the specified dimensions,
  ///   maintaining consistency across devices.
  /// - [MapBitmapScaling.none] disables automatic scaling, which is
  ///   useful when performance is a concern or if the asset is already scaled
  ///   appropriately.
  ///
  /// Optionally, [width] and [height] can be specified to control the dimensions
  /// of the rendered image:
  /// - If both [width] and [height] are non-null, the image will have the
  ///   specified dimensions, which might distort the original aspect ratio,
  ///   similar to [BoxFit.fill].
  /// - If only one of [width] and [height] is non-null, then the output image
  ///   will be scaled to the associated width or height, and the other dimension
  ///   will take whatever value is needed to maintain the image's original aspect
  ///   ratio. These cases are similar to [BoxFit.fitWidth] and
  ///   [BoxFit.fitHeight], respectively.
  ///
  /// If [width] or [height] is provided, [imagePixelRatio] value is ignored.
  ///
  /// The following example demonstrates how to create an [AssetMapBitmap] from
  /// an asset image without automatic asset resolving:
  ///
  /// ```dart
  /// AssetMapBitmap mapBitmap = AssetMapBitmap(
  ///   'assets/images/map_icon.png',
  ///   bitmapScaling: MapBitmapScaling.auto,
  ///   width: 40, // Desired width in logical pixels.
  /// );
  /// ```
  ///
  /// To render the bitmap as sharply as possible, set the [imagePixelRatio] to
  /// the device's pixel ratio. This renders the asset at a pixel-to-pixel ratio
  /// on the screen, but may result in different logical marker sizes across
  /// devices with varying pixel densities.
  ///
  ///```dart
  /// AssetMapBitmap assetMapBitmap = AssetMapBitmap(
  ///   'assets/images/map_icon.png',
  ///   imagePixelRatio: MediaQuery.maybeDevicePixelRatioOf(context),
  /// );
  /// ```
  AssetMapBitmap(
    String assetName, {
    MapBitmapScaling bitmapScaling = MapBitmapScaling.auto,
    double? imagePixelRatio,
    double? width,
    double? height,
  }) : this._(
          assetName: assetName,
          bitmapScaling: bitmapScaling,
          imagePixelRatio: imagePixelRatio ?? _naturalPixelRatio,
          width: width,
          height: height,
        );

  /// Internal constructor for creating a [AssetMapBitmap].
  AssetMapBitmap._({
    required this.assetName,
    required super.imagePixelRatio,
    required super.bitmapScaling,
    super.width,
    super.height,
  })  : assert(assetName.isNotEmpty, 'The asset name must not be empty.'),
        assert(imagePixelRatio > 0.0,
            'The imagePixelRatio must be greater than 0.'),
        assert(bitmapScaling != MapBitmapScaling.none || width == null,
            'If bitmapScaling is set to MapBitmapScaling.none, width parameter cannot be used.'),
        assert(bitmapScaling != MapBitmapScaling.none || height == null,
            'If bitmapScaling is set to MapBitmapScaling.none, height parameter cannot be used.'),
        super._();

  /// The type of the [BitmapDescriptor] object, used for the
  /// JSON serialization.
  static const String type = 'asset';

  /// The name of the asset.
  final String assetName;

  /// Creates a [AssetMapBitmap] from an asset image with asset resolving and
  /// mipmapping enabled.
  ///
  /// This method dynamically resolves the correct asset version based on the
  /// device's pixel ratio, ensuring optimal resolution without manual
  /// configuration. It is the preferred method for creating instances of
  /// [AssetMapBitmap] due to its automatic asset resolution capabilities.
  ///
  /// [assetName] is the name of the asset. The asset is resolved in the context
  /// of the specified [bundle] and [package].
  ///
  /// Optionally, [width] and [height] can be specified to control the
  /// dimensions of the rendered image:
  /// - If both [width] and [height] are non-null, the image will have the
  ///   specified dimensions, which might distort the original aspect ratio,
  ///   similar to [BoxFit.fill].
  /// - If only one of [width] and [height] is non-null, then the output image
  ///   will be scaled to the associated width or height, and the other
  ///   dimension will take whatever value is needed to maintain the image's
  ///   original aspect ratio. These cases are similar to [BoxFit.fitWidth] and
  ///   [BoxFit.fitHeight], respectively.
  ///
  /// [bitmapScaling] controls the scaling behavior:
  /// - [MapBitmapScaling.auto] automatically upscales and downscales the image
  ///   to match the device's pixel ratio or the specified dimensions,
  ///   maintaining consistency across devices.
  /// - [MapBitmapScaling.none] disables automatic scaling, which is
  ///   useful when performance is a concern or if the asset is already scaled
  ///   appropriately.
  ///
  /// Asset mipmap is resolved using the devices pixel ratio from the
  /// [ImageConfiguration.devicePixelRatio] parameter. To initialize the
  /// [ImageConfiguration] with the devices pixel ratio, use the
  /// [createLocalImageConfiguration] method.
  ///
  /// [imagePixelRatio] can be provided to override the resolved asset's pixel
  /// ratio. Specifying [imagePixelRatio] can be useful in scenarios where
  /// custom scaling is needed. [imagePixelRatio] is ignored if [width] or
  /// [height] is provided.
  ///
  /// Returns a Future that completes with an [AssetMapBitmap] instance.
  ///
  /// Following example demonstrates how to create an [AssetMapBitmap]
  /// using asset resolving:
  ///
  /// ```dart
  /// Future<void> _getAssetMapBitmap(BuildContext context) async {
  ///   final ImageConfiguration imageConfiguration = createLocalImageConfiguration(
  ///     context,
  //    );
  ///   AssetMapBitmap assetMapBitmap = await AssetMapBitmap.create(
  ///     imageConfiguration,
  ///     'assets/images/map_icon.png',
  ///   );
  ///   return assetMapBitmap;
  /// }
  /// ```
  ///
  /// Optionally, [width] and [height] can be specified to control the
  /// asset's dimensions:
  ///
  /// ```dart
  /// Future<void> _getAssetMapBitmap(BuildContext context) async {
  ///   final ImageConfiguration imageConfiguration = createLocalImageConfiguration(
  ///     context,
  ///    );
  ///   AssetMapBitmap assetMapBitmap = await AssetMapBitmap.create(
  ///     imageConfiguration,
  ///     'assets/images/map_icon.png',
  ///     width: 64, // Desired width in logical pixels.
  ///     height: 64, // Desired height in logical pixels.
  ///   );
  ///   return assetMapBitmap;
  /// }
  /// ```
  static Future<AssetMapBitmap> create(
    ImageConfiguration configuration,
    String assetName, {
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    double? imagePixelRatio,
    MapBitmapScaling bitmapScaling = MapBitmapScaling.auto,
  }) async {
    assert(assetName.isNotEmpty, 'The asset name must not be empty.');
    final AssetImage assetImage =
        AssetImage(assetName, package: package, bundle: bundle);
    final AssetBundleImageKey assetBundleImageKey =
        await assetImage.obtainKey(configuration);

    return AssetMapBitmap._(
        assetName: assetBundleImageKey.name,
        imagePixelRatio: imagePixelRatio ?? assetBundleImageKey.scale,
        bitmapScaling: bitmapScaling,
        width: width ?? configuration.size?.width,
        height: height ?? configuration.size?.height);
  }

  @override
  Object toJson() => <Object>[
        type,
        <String, Object?>{
          'assetName': assetName,
          'bitmapScaling': bitmapScaling.name,
          'imagePixelRatio': imagePixelRatio,
          if (width != null) 'width': width,
          if (height != null) 'height': height,
        }
      ];
}

/// Represents a [BitmapDescriptor] that is created from an array of bytes
/// encoded as `PNG` in [Uint8List].
///
/// The [byteData] represents the image in a `PNG` format, which will be
/// decoded and rendered by the platform. The optional [width], [height] or
/// [imagePixelRatio] parameters are used to correctly scale the image for
/// display, taking into account the devices pixel ratio.
///
/// [bitmapScaling] controls the scaling behavior:
/// - [MapBitmapScaling.auto] automatically upscales and downscales the image
///   to match the device's pixel ratio or the specified dimensions,
///   maintaining consistency across devices.
/// - [MapBitmapScaling.none] disables automatic scaling, which is
///   useful when performance is a concern or if the asset is already scaled
///   appropriately.
///
/// The [imagePixelRatio] parameter allows to give correct pixel ratio of the
/// image. If the [imagePixelRatio] is not provided, value is defaulted
/// to the natural resolution of 1.0. To render the asset as sharp as possible,
/// set the [imagePixelRatio] to the devices pixel ratio. [imagePixelRatio] is
/// ignored if [width] or [height] is provided.
///
/// Optionally, [width] and [height] can be specified to control the
/// dimensions of the rendered image:
/// - If both [width] and [height] are non-null, the image will have the
///   specified dimensions, which might distort the original aspect ratio,
///   similar to [BoxFit.fill].
/// - If only one of [width] and [height] is non-null, then the output image
///   will be scaled to the associated width or height, and the other
///   dimension will take whatever value is needed to maintain the image's
///   original aspect ratio. These cases are similar to [BoxFit.fitWidth] and
///   [BoxFit.fitHeight], respectively.
///
/// The following example demonstrates how to create an [BytesMapBitmap] from
/// a list of bytes in [Uint8List] format:
///
/// ```dart
/// Uint8List byteData = imageBuffer.asUint8List()
/// double imagePixelRatio = 2.0; // Pixel density of the image.
/// BytesMapBitmap bytesMapBitmap = BytesMapBitmap(
///   byteData,
///   imagePixelRatio: imagePixelRatio,
/// );
/// ```
///
/// Optionally, [width] and [height] can be specified to control the
/// asset's dimensions:
///
/// ```dart
/// Uint8List byteData = imageBuffer.asUint8List()
/// BytesMapBitmap bytesMapBitmap = BytesMapBitmap(
///   byteData,
///   width: 64, // Desired width in logical pixels.
/// );
/// ```
///
/// To render the bitmap as sharply as possible, set the [imagePixelRatio] to
/// the device's pixel ratio. This renders the asset at a pixel-to-pixel ratio
/// on the screen, but may result in different logical marker sizes across
/// devices with varying pixel densities.
///
///```dart
/// Uint8List byteData = imageBuffer.asUint8List()
/// BytesMapBitmap bytesMapBitmap = BytesMapBitmap(
///   byteData,
///   imagePixelRatio: MediaQuery.maybeDevicePixelRatioOf(context),
/// );
/// ```
class BytesMapBitmap extends MapBitmap {
  /// Constructs a [BytesMapBitmap] that is created from an array of bytes that
  /// must be encoded as `PNG` in [Uint8List].
  ///
  /// The [byteData] represents the image in a `PNG` format, which will be
  /// decoded and rendered by the platform. The optional [width], [height] or
  /// [imagePixelRatio] parameters are used to correctly scale the image for
  /// display, taking into account the devices pixel ratio.
  ///
  /// [bitmapScaling] controls the scaling behavior:
  /// - [MapBitmapScaling.auto] automatically upscales and downscales the image
  ///   to match the device's pixel ratio or the specified dimensions,
  ///   maintaining consistency across devices.
  /// - [MapBitmapScaling.none] disables automatic scaling, which is
  ///   useful when performance is a concern or if the asset is already scaled
  ///   appropriately.
  ///
  /// The [imagePixelRatio] parameter allows to give correct pixel ratio of the
  /// image. If the [imagePixelRatio] is not provided, value is defaulted
  /// to the natural resolution of 1.0. To render the asset as sharp as possible,
  /// set the [imagePixelRatio] to the devices pixel ratio. [imagePixelRatio] is
  /// ignored if [width] or [height] is provided.
  ///
  /// Optionally, [width] and [height] can be specified to control the
  /// dimensions of the rendered image:
  /// - If both [width] and [height] are non-null, the image will have the
  ///   specified dimensions, which might distort the original aspect ratio,
  ///   similar to [BoxFit.fill].
  /// - If only one of [width] and [height] is non-null, then the output image
  ///   will be scaled to the associated width or height, and the other
  ///   dimension will take whatever value is needed to maintain the image's
  ///   original aspect ratio. These cases are similar to [BoxFit.fitWidth] and
  ///   [BoxFit.fitHeight], respectively.
  ///
  /// Throws an [AssertionError] if [byteData] is empty or if incompatible
  /// scaling options are provided.
  ///
  /// The following example demonstrates how to create an [BytesMapBitmap] from
  /// a list of bytes in [Uint8List] format:
  ///
  /// ```dart
  /// Uint8List byteData = await _loadImageData('path/to/image.png');
  /// double imagePixelRatio = 2.0; // Pixel density of the image.
  /// BytesMapBitmap bytesMapBitmap = BytesMapBitmap(
  ///   byteData,
  ///   imagePixelRatio: imagePixelRatio,
  /// );
  /// ```
  ///
  /// Optionally, [width] and [height] can be specified to control the
  /// asset's dimensions:
  ///
  /// ```dart
  /// Uint8List byteData = imageBuffer.asUint8List()
  /// BytesMapBitmap bytesMapBitmap = BytesMapBitmap(
  ///   byteData,
  ///   width: 64, // Desired width in logical pixels.
  /// );
  /// ```
  ///
  /// To render the bitmap as sharply as possible, set the [imagePixelRatio] to
  /// the device's pixel ratio. This renders the asset at a pixel-to-pixel ratio
  /// on the screen, but may result in different logical marker sizes across
  /// devices with varying pixel densities.
  ///
  ///```dart
  /// Uint8List byteData = imageBuffer.asUint8List()
  /// BytesMapBitmap bytesMapBitmap = BytesMapBitmap(
  ///   byteData,
  ///   imagePixelRatio: MediaQuery.maybeDevicePixelRatioOf(context),
  /// );
  /// ```
  BytesMapBitmap(
    this.byteData, {
    super.bitmapScaling = MapBitmapScaling.auto,
    super.width,
    super.height,
    double? imagePixelRatio,
  })  : assert(byteData.isNotEmpty,
            'Cannot create BitmapDescriptor with empty byteData.'),
        assert(
            bitmapScaling != MapBitmapScaling.none || imagePixelRatio == null,
            'If bitmapScaling is set to MapBitmapScaling.none, imagePixelRatio parameter cannot be used.'),
        assert(bitmapScaling != MapBitmapScaling.none || width == null,
            'If bitmapScaling is set to MapBitmapScaling.none, width parameter cannot be used.'),
        assert(bitmapScaling != MapBitmapScaling.none || height == null,
            'If bitmapScaling is set to MapBitmapScaling.none, height parameter cannot be used.'),
        super._(imagePixelRatio: imagePixelRatio ?? _naturalPixelRatio);

  /// The type of the MapBitmap object, used for the JSON serialization.
  static const String type = 'bytes';

  /// The bytes of the bitmap.
  final Uint8List byteData;

  @override
  Object toJson() => <Object>[
        type,
        <String, Object?>{
          'byteData': byteData,
          'bitmapScaling': bitmapScaling.name,
          'imagePixelRatio': imagePixelRatio,
          if (width != null) 'width': width,
          if (height != null) 'height': height,
        }
      ];
}

/// Represents a [BitmapDescriptor] that is created from a pin configuration.
/// Can only be used with [AdvancedMarker]s.
///
/// The [backgroundColor] and [borderColor] are used to define the color of the
/// standard pin marker.
///
/// The [glyph] parameter is used to define the glyph that is displayed on the
/// pin marker (default glyph is a circle).
///
/// The following example demonstrates how to change colors of the default map
/// pin to white and blue:
///
/// ```dart
/// PinConfig(
///   backgroundColor: Colors.blue,
///   borderColor: Colors.white,
///   glyph: Glyph.color(Colors.blue)
/// )
/// ```
///
/// The following example demonstrates how to customize a marker pin by showing
/// a short text on the pin:
///
/// ```dart
/// PinConfig(
///   backgroundColor: Colors.blue,
///   glyph: Glyph.text('Pin', Colors.white)
/// )
/// ```
///
/// The following example demonstrates how to customize a marker pin by showing
/// a custom image on the pin:
///
/// ```dart
/// PinConfig(
///   glyph: Glyph.bitmapDescriptor(
///     BitmapDescriptor.asset(
///       ImageConfiguration(size: Size(12, 12)),
///       'assets/cat.png'
///    )
/// )
/// ```
///
class PinConfig extends BitmapDescriptor {
  /// Constructs a [PinConfig] that is created from a pin configuration.
  ///
  /// The [backgroundColor] and [borderColor] are used to define the color of
  /// the standard pin marker.
  ///
  /// The [glyph] parameter is used to define the glyph that is displayed on the
  /// pin marker.
  const PinConfig({
    this.backgroundColor,
    this.borderColor,
    this.glyph,
  })  : assert(
          backgroundColor != null || borderColor != null || glyph != null,
          'Cannot create PinConfig with all parameters being null.',
        ),
        super._();

  /// The type of the MapBitmap object, used for the JSON serialization.
  static const String type = 'pinConfig';

  /// The background color of the pin.
  final Color? backgroundColor;

  /// The border color of the pin.
  final Color? borderColor;

  /// The glyph that is displayed on the pin marker.
  final AdvancedMarkerGlyph? glyph;

  @override
  Object toJson() => <Object>[
        type,
        <String, Object?>{
          if (backgroundColor != null)
            'backgroundColor': backgroundColor?.value,
          if (borderColor != null) 'borderColor': borderColor?.value,
          if (glyph != null) 'glyph': glyph?.toJson(),
        }
      ];
}

/// Defines a glyph (the element at the center of an [AdvancedMarker] icon).
abstract class AdvancedMarkerGlyph extends BitmapDescriptor {
  const AdvancedMarkerGlyph._() : super._();
}

/// Defines a glyph using the default circle, but with a custom color.
class CircleGlyph extends AdvancedMarkerGlyph {
  /// Constructs a glyph instance, using the default circle, but with
  /// a custom color.
  const CircleGlyph({
    required this.color,
  }) : super._();

  /// Color of the circular icon.
  final Color color;

  @override
  Object toJson() => <Object>[
        'circleGlyph',
        <String, Object>{
          'color': color.value,
        }
      ];
}

/// Defines a glyph instance with a specified bitmap.
class BitmapGlyph extends AdvancedMarkerGlyph {
  /// Constructs a glyph with the specified [bitmap].
  const BitmapGlyph({
    required this.bitmap,
  })  : assert(
          bitmap is! AdvancedMarkerGlyph,
          'BitmapDescriptor cannot be an AdvancedMarkerGlyph.',
        ),
        super._();

  /// Bitmap image to be displayed in the center of the glyph.
  final BitmapDescriptor bitmap;

  @override
  Object toJson() => <Object>[
        'bitmapGlyph',
        <String, Object>{
          'bitmap': bitmap.toJson(),
        }
      ];
}

/// Defines a glyph instance with a specified text and color.
class TextGlyph extends AdvancedMarkerGlyph {
  /// Constructs a glyph with the specified [text] and [textColor].
  const TextGlyph({
    required this.text,
    required this.textColor,
  }) : super._();

  /// Text to be displayed in the glyph.
  final String text;

  /// Color of the text.
  final Color? textColor;

  @override
  Object toJson() {
    return <Object>[
      'textGlyph',
      <String, Object>{
        'text': text,
        if (textColor != null) 'textColor': textColor!.value,
      }
    ];
  }
}
