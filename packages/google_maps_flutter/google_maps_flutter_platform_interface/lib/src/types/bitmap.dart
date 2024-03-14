// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async' show Future;
import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart'
    show
        AssetBundleImageKey,
        AssetImage,
        ImageConfiguration,
        Size,
        createLocalImageConfiguration;
import 'package:flutter/services.dart' show AssetBundle;

/// Type of bitmap scaling to use on BitmapDescriptor creation.
enum BitmapScaling {
  /// Automatically scale image with devices pixel ratio or to given size,
  /// to keep marker sizes same between platforms and devices.
  auto,

  /// Render marker to the map as without scaling.
  ///
  /// This can be used if the image is already pre-scaled, or to increase performance
  /// with a large numbers of markers.
  noScaling,
}

// The default pixel ratio for custom bitmaps.
const double _naturalPixelRatio = 1.0;

/// Defines a bitmap image. For a marker, this class can be used to set the
/// image of the marker icon. For a ground overlay, it can be used to set the
/// image to place on the surface of the earth.
class BitmapDescriptor {
  const BitmapDescriptor._(this._json);

  /// The inverse of .toJson.
  // TODO(stuartmorgan): Remove this in the next breaking change.
  @Deprecated('No longer supported')
  BitmapDescriptor.fromJson(Object json) : _json = json {
    assert(_json is List<dynamic>);
    final List<dynamic> jsonList = json as List<dynamic>;
    assert(_validTypes.contains(jsonList[0]));
    switch (jsonList[0]) {
      case _defaultMarker:
        assert(jsonList.length <= 2);
        if (jsonList.length == 2) {
          assert(jsonList[1] is num);
          final num secondElement = jsonList[1] as num;
          assert(0 <= secondElement && secondElement < 360);
        }
      case _fromBytes:
        assert(jsonList.length == 2);
        assert(jsonList[1] != null && jsonList[1] is List<int>);
        assert((jsonList[1] as List<int>).isNotEmpty);
      case _fromAsset:
        assert(jsonList.length <= 3);
        assert(jsonList[1] != null && jsonList[1] is String);
        assert((jsonList[1] as String).isNotEmpty);
        if (jsonList.length == 3) {
          assert(jsonList[2] != null && jsonList[2] is String);
          assert((jsonList[2] as String).isNotEmpty);
        }
      case _fromAssetImage:
        assert(jsonList.length <= 4);
        assert(jsonList[1] != null && jsonList[1] is String);
        assert((jsonList[1] as String).isNotEmpty);
        assert(jsonList[2] != null && jsonList[2] is double);
        if (jsonList.length == 4) {
          assert(jsonList[3] != null && jsonList[3] is List<dynamic>);
          assert((jsonList[3] as List<dynamic>).length == 2);
        }
      case AssetMapBitmap.type:
        assert(jsonList.length == 4 || jsonList.length == 5);
        assert(jsonList[1] != null && jsonList[1] is String);
        assert((jsonList[1] as String).isNotEmpty);
        assert(jsonList[2] != null && jsonList[2] is String);
        assert(jsonList[3] != null && jsonList[3] is double);
        if (jsonList.length == 5) {
          assert(jsonList[4] != null && jsonList[4] is List<dynamic>);
          assert((jsonList[4] as List<dynamic>).length == 2);
        }
      case BytesMapBitmap.type:
        assert(jsonList.length == 4 || jsonList.length == 5);
        assert(jsonList[1] != null && jsonList[1] is List<int>);
        assert(jsonList[2] != null && jsonList[2] is String);
        assert(jsonList[3] != null && jsonList[3] is double);
        if (jsonList.length == 5) {
          assert(jsonList[4] != null && jsonList[4] is List<dynamic>);
          assert((jsonList[4] as List<dynamic>).length == 2);
        }
        assert((jsonList[2] as String) != BitmapScaling.noScaling.name ||
            jsonList.length == 4);
        assert((jsonList[2] as String) != BitmapScaling.noScaling.name ||
            (jsonList[3] as double) == 1.0);
      default:
        break;
    }
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
  static const BitmapDescriptor defaultMarker =
      BitmapDescriptor._(<Object>[_defaultMarker]);

  /// Creates a BitmapDescriptor that refers to a colorization of the default
  /// marker image. For convenience, there is a predefined set of hue values.
  /// See e.g. [hueYellow].
  static BitmapDescriptor defaultMarkerWithHue(double hue) {
    assert(0.0 <= hue && hue < 360.0);
    return BitmapDescriptor._(<Object>[_defaultMarker, hue]);
  }

  /// Creates a [BitmapDescriptor] from an asset image.
  ///
  /// Asset images in flutter are stored per:
  /// https://flutter.dev/docs/development/ui/assets-and-images#declaring-resolution-aware-image-assets
  /// This method takes into consideration various asset resolutions
  /// and scales the images to the right resolution depending on the dpi.
  /// Set `mipmaps` to false to load the exact dpi version of the image,
  /// `mipmap` is true by default.
  @Deprecated(
      'Switch to using AssetMapBitmap and AssetMapBitmap.fromMipmaps instead')
  static Future<BitmapDescriptor> fromAssetImage(
    ImageConfiguration configuration,
    String assetName, {
    AssetBundle? bundle,
    String? package,
    bool mipmaps = true,
  }) async {
    final double? devicePixelRatio = configuration.devicePixelRatio;
    if (!mipmaps && devicePixelRatio != null) {
      return BitmapDescriptor._(<Object>[
        _fromAssetImage,
        assetName,
        devicePixelRatio,
      ]);
    }
    final AssetImage assetImage =
        AssetImage(assetName, package: package, bundle: bundle);
    final AssetBundleImageKey assetBundleImageKey =
        await assetImage.obtainKey(configuration);
    final Size? size = configuration.size;
    return BitmapDescriptor._(<Object>[
      _fromAssetImage,
      assetBundleImageKey.name,
      assetBundleImageKey.scale,
      if (kIsWeb && size != null)
        <Object>[
          size.width,
          size.height,
        ],
    ]);
  }

  /// Creates a BitmapDescriptor using an array of bytes that must be encoded
  /// as PNG.
  /// On the web, the [size] parameter represents the *physical size* of the
  /// bitmap, regardless of the actual resolution of the encoded PNG.
  /// This helps the browser to render High-DPI images at the correct size.
  /// `size` is not required (and ignored, if passed) in other platforms.
  @Deprecated('Switch to using BytesMapBitmap instead')
  static BitmapDescriptor fromBytes(Uint8List byteData, {Size? size}) {
    assert(byteData.isNotEmpty,
        'Cannot create BitmapDescriptor with empty byteData');
    return BitmapDescriptor._(<Object>[
      _fromBytes,
      byteData,
      if (kIsWeb && size != null)
        <Object>[
          size.width,
          size.height,
        ]
    ]);
  }

  final Object _json;

  /// Convert the object to a Json format.
  Object toJson() => _json;
}

/// Represents a [BitmapDescriptor] that is created from an asset image.
///
/// This class extends [BitmapDescriptor] to support loading images from assets
/// and mipmaps.
///
/// {@template bitmap_scaling_note}
/// By default, [bitmapScaling] is set to [BitmapScaling.auto], which
/// automatically scales the bitmap using the [imagePixelRatio] and [size]
/// parameters to match the devices pixel ratio, to keep the marker sizes
/// consistent between platforms and devices. This behaviour upscales and
/// downscales the image to match the devices pixel ratio. To disable automatic
/// scaling, set the [bitmapScaling] parameter to [BitmapScaling.noScaling].
/// {@endtemplate}
///
/// To create an instance of [AssetMapBitmap] from mipmapped assets, use the
/// asynchronous [AssetMapBitmap.fromMipmaps] method.
///
/// {@template asset_map_bitmap_from_mipmaps}
/// Asset mipmap is resolved using the devices pixel ratio from the
/// [ImageConfiguration.devicePixelRatio] parameter. To initialize the
/// [ImageConfiguration] with the devices pixel ratio, use the
/// [createLocalImageConfiguration] method.
///
/// Following example demonstrates how to create an [AssetMapBitmap]
/// using mipmapping:
///
/// ```dart
/// Future<void> _getAssetMapBitmap(BuildContext context) async {
///   final ImageConfiguration imageConfiguration = createLocalImageConfiguration(
///     context,
//    );
///   AssetMapBitmap assetMapBitmap = await AssetMapBitmap.fromMipmaps(
///     imageConfiguration,
///     'assets/images/map_icon.png',
///   );
///   return assetMapBitmap;
/// }
/// ```
///
/// To give specific size in logical pixels to the mipmapped image, provide size
/// in the [ImageConfiguration.size] parameter.
///
/// ```dart
/// Future<void> _getAssetMapBitmap(BuildContext context) async {
///   final ImageConfiguration imageConfiguration = createLocalImageConfiguration(
///     context,
///     size: Size(64, 64), // Desired size in logical pixels.
//    );
///   AssetMapBitmap assetMapBitmap = await AssetMapBitmap.fromMipmaps(
///     imageConfiguration,
///     'assets/images/map_icon.png',
///   );
///   return assetMapBitmap;
/// }
/// ```
/// {@endtemplate}
///
/// {@template asset_map_bitmap_constructor}
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
/// {@endtemplate}
///
/// {@template size_parameter_note}
/// Note: Bitmap scaling with size parameter does not maintain the aspect ratio.
/// If a proportional resize is required, ensure to provide a
/// [ImageConfiguration.size] with the correct aspect ratio.
/// {@endtemplate}
class AssetMapBitmap extends BitmapDescriptor {
  /// Creates a [AssetMapBitmap] from an asset image.
  ///
  /// To create an instance of [AssetMapBitmap] from mipmapped assets, use the
  /// asynchronous [AssetMapBitmap.fromMipmaps] method.
  ///
  /// The [imagePixelRatio] parameter allows to give correct pixel ratio of the
  /// asset image. If the [imagePixelRatio] is not provided, value is defaulted
  /// to the natural resolution of 1.0. To render the asset as sharp as possible,
  /// set the [imagePixelRatio] to the devices pixel ratio.
  ///
  /// {@macro bitmap_scaling_note}
  ///
  /// {@macro asset_map_bitmap_constructor}
  ///
  /// {@macro size_parameter_note}
  AssetMapBitmap(
    String assetName, {
    BitmapScaling bitmapScaling = BitmapScaling.auto,
    double? imagePixelRatio,
    Size? size,
  }) : this._(
          assetName: assetName,
          bitmapScaling: bitmapScaling,
          imagePixelRatio: imagePixelRatio ?? _naturalPixelRatio,
          size: size,
        );

  /// Internal constructor for creating a [AssetMapBitmap].
  AssetMapBitmap._({
    required this.assetName,
    required this.bitmapScaling,
    required this.imagePixelRatio,
    this.size,
  })  : assert(assetName.isNotEmpty, 'The asset name must not be empty.'),
        assert(imagePixelRatio > 0.0,
            'The imagePixelRatio must be greater than 0.'),
        assert(bitmapScaling != BitmapScaling.noScaling || size == null,
            'If bitmapScaling is set to BitmapScaling.noScaling, size parameter cannot be used.'),
        super._(const <Object>[]);

  /// The type of the [BitmapDescriptor] object, used for the
  /// JSON serialization.
  static const String type = 'asset';

  /// The name of the asset.
  final String assetName;

  /// The scaling method of the bitmap.
  final BitmapScaling bitmapScaling;

  /// The pixel ratio of the bitmap.
  final double imagePixelRatio;

  /// The target size of the bitmap in logical pixels.
  final Size? size;

  /// Creates a [AssetMapBitmap] from an asset image with mipmapping.
  ///
  /// [assetName] is the name of the asset. The asset is resolved in the
  /// context of the specified [bundle] and [package].
  ///
  /// To render asset with specific size in *logical pixels*, the size can be
  /// provided in the [configuration.size] parameter.
  ///
  /// [configuration.devicePixelRatio] is used to find matching asset mipmap.
  /// [imagePixelRatio] is initialized with the mipmapped asset's pixel ratio.
  ///
  /// Returns a Future that completes with an [AssetMapBitmap] instance.
  ///
  /// {@macro bitmap_scaling_note}
  ///
  /// {@macro asset_map_bitmap_from_mipmaps}
  ///
  /// {@macro size_parameter_note}
  static Future<AssetMapBitmap> fromMipmaps(
    ImageConfiguration configuration,
    String assetName, {
    AssetBundle? bundle,
    String? package,
    BitmapScaling bitmapScaling = BitmapScaling.auto,
  }) async {
    assert(assetName.isNotEmpty, 'The asset name must not be empty.');
    final AssetImage assetImage =
        AssetImage(assetName, package: package, bundle: bundle);
    final AssetBundleImageKey assetBundleImageKey =
        await assetImage.obtainKey(configuration);

    return AssetMapBitmap._(
      assetName: assetBundleImageKey.name,
      imagePixelRatio: assetBundleImageKey.scale,
      bitmapScaling: bitmapScaling,
      size: configuration.size,
    );
  }

  @override
  Object toJson() => <Object>[
        type,
        assetName,
        bitmapScaling.name,
        imagePixelRatio,
        if (size != null)
          <Object>[
            size!.width,
            size!.height,
          ],
      ];
}

/// Represents a [BitmapDescriptor] that is created from an array of bytes that
/// must be encoded as `PNG` in [Uint8List].
///
/// {@template bytes_map_bitmap_constructor}
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
/// To render the bitmap in desired size in *logical pixels*, give the size
/// in the [size] parameter:
///
/// ```dart
/// Uint8List byteData = await _loadImageData('path/to/image.png');
/// Size imageSize = Size(64, 64); // Desired size in logical pixels.
/// BytesMapBitmap bytesMapBitmap = BytesMapBitmap(
///   byteData,
///   size: imageSize,
/// );
/// ```
///
/// To render the bitmap as sharply as possible, set the [imagePixelRatio] to
/// the device's pixel ratio. This renders the asset at a pixel-to-pixel ratio
/// on the screen, but may result in different logical marker sizes across
/// devices with varying pixel densities.
///
///```dart
/// Uint8List byteData = await _loadImageData('path/to/image.png');
/// BytesMapBitmap bytesMapBitmap = BytesMapBitmap(
///   byteData,
///   imagePixelRatio: MediaQuery.maybeDevicePixelRatioOf(context),
/// );
/// ```
/// {@endtemplate}
/// {@macro size_parameter_note}
class BytesMapBitmap extends BitmapDescriptor {
  /// Constructs a [BytesMapBitmap] that is created from an array of bytes that
  /// must be encoded as `PNG` in [Uint8List].
  ///
  /// The [byteData] represents the image in a `PNG` format, which will be
  /// decoded and rendered by the platform. The optional [size] or
  /// [imagePixelRatio] parameters are used to correctly scale the image for
  /// display, taking into account the devices pixel ratio.
  ///
  /// The [imagePixelRatio] parameter allows to give correct pixel ratio of the
  /// image. If the [imagePixelRatio] is not provided, value is defaulted
  /// to the natural resolution of 1.0. To render the asset as sharp as possible,
  /// set the [imagePixelRatio] to the devices pixel ratio.
  ///
  /// {@macro bitmap_scaling_note}
  ///
  /// The optional [size] parameter represents the *logical size* of the
  /// bitmap, regardless of the actual resolution of the encoded PNG.
  /// [imagePixelRatio] value can be used to scale the image to
  /// proper size across platforms.
  ///
  /// Throws an [AssertionError] if [byteData] is empty or if incompatible
  /// scaling options are provided.
  ///
  /// {@macro bytes_map_bitmap_constructor}
  /// {@macro size_parameter_note}
  BytesMapBitmap(
    this.byteData, {
    this.bitmapScaling = BitmapScaling.auto,
    double? imagePixelRatio,
    this.size,
  })  : assert(byteData.isNotEmpty,
            'Cannot create BitmapDescriptor with empty byteData.'),
        assert(
            bitmapScaling != BitmapScaling.noScaling || imagePixelRatio == null,
            'If bitmapScaling is set to BitmapScaling.noScaling, imagePixelRatio parameter cannot be used.'),
        assert(bitmapScaling != BitmapScaling.noScaling || size == null,
            'If bitmapScaling is set to BitmapScaling.noScaling, size parameter cannot be used.'),
        imagePixelRatio = imagePixelRatio ?? _naturalPixelRatio,
        super._(const <Object>[]);

  /// The type of the MapBitmap object, used for the JSON serialization.
  static const String type = 'bytes';

  /// The bytes of the bitmap.
  final Uint8List byteData;

  /// The scaling method of the bitmap.
  final BitmapScaling bitmapScaling;

  /// The pixel ratio of the bitmap.
  final double imagePixelRatio;

  /// The target size of the bitmap in logical pixels.
  final Size? size;

  @override
  Object toJson() {
    return <Object>[
      type,
      byteData,
      bitmapScaling.name,
      imagePixelRatio,
      if (size != null)
        <Object>[
          size!.width,
          size!.height,
        ],
    ];
  }
}
