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
        WidgetsBinding;
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
/// This class extends [BitmapDescriptor] to support asset images, considering
/// device pixel ratio and image scaling. It's particularly useful for
/// displaying resolution-aware images on maps or similar widgets.
///
/// The following example demonstrates how to create an [AssetMapBitmap] from
/// an asset image:
///
/// ```dart
/// Size imageSize = Size(64, 64); // Desired size in logical pixels.
/// ImageConfiguration config = ImageConfiguration(size: imageSize);
/// AssetMapBitmap assetMapBitmap = AssetMapBitmap(
///  config,
///  'assets/images/map_icon.png',
///  imagePixelRatio: 1.0,
/// );
/// ```
///
/// To create an instance of [AssetMapBitmap] from mipmapped assets, use the
/// asynchronous [fromMipmaps] method. Following example demonstrates how to
/// create an[AssetMapBitmap] using mipmapping:
///
/// ```dart
/// AssetMapBitmap assetMapBitmap = await AssetMapBitmap.fromMipmaps(
///   ImageConfiguration.empty,
///   'assets/images/map_icon.png',
/// );
/// ```
class AssetMapBitmap extends BitmapDescriptor {
  /// Creates a [AssetMapBitmap] from an asset image.
  ///
  /// [configuration.size] is used to resize the asset image to a
  /// specific size in logical pixels. If [ImageConfiguration.size] is null,
  /// the image is rendered at its native resolution.
  ///
  /// [configuration.devicePixelRatio] is used to specify the pixel
  /// density of the asset. If [ImageConfiguration.devicePixelRatio] is null,
  /// the current device pixel ratio is used. [imagePixelRatio] can be given to
  /// override the value.
  ///
  /// Optional [bitmapScaling] scaling parameter determines how the image is
  /// scaled. Defaults to [BitmapScaling.auto], which automatically scales the
  /// image using the [imagePixelRatio] and [size] parameters. Set to
  /// [BitmapScaling.noScaling] to render the image without scaling and ignore
  /// size and pixel ratio of the image.
  ///
  /// The following example demonstrates how to create an [AssetMapBitmap] from
  /// an asset image:
  ///
  /// ```dart
  /// Size imageSize = Size(64, 64); // Desired size in logical pixels.
  /// ImageConfiguration config = ImageConfiguration(size: imageSize);
  /// AssetMapBitmap assetMapBitmap = AssetMapBitmap(
  ///  config,
  ///  'assets/images/map_icon.png',
  /// );
  /// ```
  ///
  /// Note: Image scaling with [ImageConfiguration.size] parameter does not
  /// maintain the aspect ratio. If a proportional resize is required, ensure to
  /// provide a [ImageConfiguration.size] with the correct aspect ratio.
  AssetMapBitmap(
    ImageConfiguration configuration,
    String assetName, {
    BitmapScaling bitmapScaling = BitmapScaling.auto,
    double? imagePixelRatio,
  }) : this._(
          configuration: configuration,
          assetName: assetName,
          bitmapScaling: bitmapScaling,
          imagePixelRatio: imagePixelRatio ??
              configuration.devicePixelRatio ??
              WidgetsBinding
                  .instance.platformDispatcher.views.first.devicePixelRatio,
          size: configuration.size,
        );

  /// Internal constructor for creating a [AssetMapBitmap].
  AssetMapBitmap._({
    required this.configuration,
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

  /// The scaling of the bitmap.
  final BitmapScaling bitmapScaling;

  /// The pixel ratio of the image.
  final double imagePixelRatio;

  /// The size of the image.
  final Size? size;

  /// The [ImageConfiguration] used to load the asset.
  final ImageConfiguration configuration;

  /// Creates a [AssetMapBitmap] from an asset image with mipmapping.
  ///
  /// [assetName] is the name of the asset. The asset is resolved in the
  /// context of the specified [bundle] and [package].
  ///
  /// To render asset with specific size in *logical pixels*, the size can be
  /// provided in the [configuration.size] parameter.
  ///
  /// [configuration.devicePixelRatio] is ignored when mipmapping is enabled.
  ///
  /// Optional [bitmapScaling] scaling parameter determines how the image is
  /// scaled. Defaults to [BitmapScaling.auto], which automatically scales the
  /// image using the [imagePixelRatio] and [size] parameters. Set to
  /// [BitmapScaling.noScaling] to render the image without scaling.
  ///
  /// Returns a Future that completes with an [AssetMapBitmap] instance.
  ///
  /// The following example demonstrates how to create an [AssetMapBitmap] using
  /// mipmapping:
  ///
  /// ```dart
  /// AssetMapBitmap assetMapBitmap = await AssetMapBitmap.fromMipmaps(
  ///   ImageConfiguration.empty,
  ///   'assets/images/map_icon.png',
  /// );
  /// ```
  ///
  /// Note: Image scaling with [ImageConfiguration.size] parameter does not
  /// maintain the aspect ratio. If a proportional resize is required, ensure to
  /// provide a [ImageConfiguration.size] with the correct aspect ratio.
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
      configuration: configuration,
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
/// must be encoded as PNG.
///
/// This class extends [BitmapDescriptor] to support images encoded in byte
/// arrays, particularly useful for displaying dynamic or generated images on
/// maps or similar widgets.
///
/// ```dart
/// Uint8List byteData = await _loadImageData('path/to/image.png');
/// Size imageSize = Size(64, 64); // Desired size in logical pixels.
/// double imagePixelRatio = 2.0; // Pixel density of the image.
///
/// BytesMapBitmap bytesMapBitmap = BytesMapBitmap(
///   byteData,
///   size: imageSize,
///   imagePixelRatio: imagePixelRatio,
/// );
/// ```
///
/// Note: If the [size] parameter is provided, the aspect ratio of the image
/// will not be automatically maintained. To preserve the image's proper
/// aspect ratio, ensure that the [size] parameter is given in
/// correct aspect ratio.
class BytesMapBitmap extends BitmapDescriptor {
  /// Constructs a [BytesMapBitmap] using an array of bytes that must be encoded
  /// as PNG.
  ///
  /// The byte array represents the image in a compressed format, which will be
  /// decoded and rendered by the platform. The optional [size] parameter and
  /// [imagePixelRatio] are used to correctly scale the image for display,
  /// taking into account the screen's pixel density.
  /// If [imagePixelRatio] is null, the current device pixel ratio is used.
  ///
  /// The optional [size] parameter represents the *logical size* of the
  /// bitmap, regardless of the actual resolution of the encoded PNG.
  /// [imagePixelRatio] value can be used to scale the image to
  /// proper size across platforms.
  ///
  /// Throws an [AssertionError] if [byteData] is empty or if incompatible
  /// scaling options are provided.
  ///
  /// Note: If the [size] parameter is provided, the aspect ratio of the image
  /// will not be automatically maintained. To preserve the image's proper
  /// aspect ratio, ensure that the [size] parameter is given in
  /// correct aspect ratio.
  BytesMapBitmap(
    this.byteData, {
    this.bitmapScaling = BitmapScaling.auto,
    this.imagePixelRatio,
    this.size,
  })  : assert(byteData.isNotEmpty,
            'Cannot create BitmapDescriptor with empty byteData.'),
        assert(
            bitmapScaling != BitmapScaling.noScaling || imagePixelRatio == null,
            'If bitmapScaling is set to BitmapScaling.noScaling, imagePixelRatio parameter cannot be used.'),
        assert(bitmapScaling != BitmapScaling.noScaling || size == null,
            'If bitmapScaling is set to BitmapScaling.noScaling, size parameter cannot be used.'),
        super._(const <Object>[]);

  /// The type of the MapBitmap object, used for the JSON serialization.
  static const String type = 'bytes';

  /// The bytes of the image.
  final Uint8List byteData;

  /// The scaling of the bitmap.
  final BitmapScaling bitmapScaling;

  /// The pixel ratio of the image.
  final double? imagePixelRatio;

  /// The size of the image.
  final Size? size;

  @override
  Object toJson() {
    return <Object>[
      type,
      byteData,
      bitmapScaling.name,
      imagePixelRatio ??
          WidgetsBinding
              .instance.platformDispatcher.views.first.devicePixelRatio,
      if (size != null)
        <Object>[
          size!.width,
          size!.height,
        ],
    ];
  }
}
