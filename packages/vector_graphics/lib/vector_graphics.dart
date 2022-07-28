// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'src/http.dart';
import 'src/listener.dart';
import 'src/render_vector_graphics.dart';

export 'src/listener.dart' show PictureInfo;

/// A widget that displays a [VectorGraphicsCodec] encoded asset.
///
/// This widget will ask the loader to load the bytes whenever its
/// dependencies change or it is configured with a new loader. A loader may
/// or may not choose to cache its responses, potentially resulting in multiple
/// disk or network accesses for the same bytes.
class VectorGraphic extends StatefulWidget {
  /// A widget that displays a vector graphics created via a
  /// [VectorGraphicsCodec].
  ///
  /// The [semanticsLabel] can be used to identify the purpose of this picture for
  /// screen reading software.
  ///
  /// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
  ///
  /// See [VectorGraphic].
  const VectorGraphic({
    super.key,
    required this.loader,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.placeholderBuilder,
    this.colorFilter,
    this.opacity,
  });

  /// A delegate for fetching the raw bytes of the vector graphic.
  ///
  /// The [BytesLoader.loadBytes] method will be called with this
  /// widget's [BuildContext] whenever dependencies change or the widget
  /// configuration changes the loader.
  final BytesLoader loader;

  /// If specified, the width to use for the vector graphic. If unspecified,
  /// the vector graphic will take the width of its parent.
  final double? width;

  /// If specified, the height to use for the vector graphic. If unspecified,
  /// the vector graphic will take the height of its parent.
  final double? height;

  /// How to inscribe the picture into the space allocated during layout.
  /// The default is [BoxFit.contain].
  final BoxFit fit;

  /// How to align the picture within its parent widget.
  ///
  /// The alignment aligns the given position in the picture to the given position
  /// in the layout bounds. For example, an [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while a
  /// [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
  /// picture with the bottom right corner of its layout bounds. Similarly, an
  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
  /// middle of the bottom edge of its layout bounds.
  ///
  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
  /// [AlignmentDirectional]), then a [TextDirection] must be available
  /// when the picture is painted.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// The [Semantics.label] for this picture.
  ///
  /// The value indicates the purpose of the picture, and will be read out by
  /// screen readers.
  final String? semanticsLabel;

  /// Whether to exclude this picture from semantics.
  ///
  /// Useful for pictures which do not contribute meaningful semantic information to an
  /// application.
  final bool excludeFromSemantics;

  /// The placeholder to use while fetching, decoding, and parsing the vector_graphics data.
  final WidgetBuilder? placeholderBuilder;

  /// If provided, a color filter to apply to the vector graphic when painting.
  ///
  /// For example, `ColorFilter.mode(Colors.red, BlendMode.srcIn)` to give the vector
  /// graphic a solid red color.
  ///
  /// This is more efficient than using a [ColorFiltered] widget to wrap the vector
  /// graphic, since this avoids creating a new composited layer. Composited layers
  /// may double memory usage as the image is painted onto an offscreen render target.
  ///
  /// Example:
  ///
  /// ```dart
  /// VectorGraphic(loader: _assetLoader, colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn));
  /// ```
  final ColorFilter? colorFilter;

  /// If non-null, the value from the Animation is multiplied with the opacity
  /// of each vector graphic pixel before painting onto the canvas.
  ///
  /// This is more efficient than using FadeTransition to change the opacity of an image,
  /// since this avoids creating a new composited layer. Composited layers may double memory
  /// usage as the image is painted onto an offscreen render target.
  ///
  /// This value does not apply to the widgets created by a [placeholderBuilder].
  ///
  /// To provide a fixed opacity value, or to convert from a callback based API that
  /// does not use animation objects, consider using an [AlwaysStoppedAnimation].
  ///
  /// Example:
  ///
  /// ```dart
  /// VectorGraphic(loader: _assetLoader, opacity: const AlwaysStoppedAnimation(0.33));
  /// ```
  final Animation<double>? opacity;

  @override
  State<VectorGraphic> createState() => _VectorGraphicWidgetState();
}

class _PictureData {
  _PictureData(this.pictureInfo, this.count, this.key);

  final PictureInfo pictureInfo;
  _PictureKey key;
  int count = 0;
}

@immutable
class _PictureKey {
  const _PictureKey(this.cacheKey, this.locale, this.textDirection);

  final Object cacheKey;
  final Locale? locale;
  final TextDirection? textDirection;

  @override
  int get hashCode => Object.hash(cacheKey, locale, textDirection);

  @override
  bool operator ==(Object other) =>
      other is _PictureKey &&
      other.cacheKey == cacheKey &&
      other.locale == locale &&
      other.textDirection == textDirection;
}

class _VectorGraphicWidgetState extends State<VectorGraphic> {
  _PictureData? _pictureInfo;
  Locale? locale;
  TextDirection? textDirection;

  static final Map<_PictureKey, _PictureData> _livePictureCache =
      <_PictureKey, _PictureData>{};
  static final Map<_PictureKey, Future<_PictureData>> _pendingPictures =
      <_PictureKey, Future<_PictureData>>{};

  @override
  void didChangeDependencies() {
    locale = Localizations.maybeLocaleOf(context);
    textDirection = Directionality.maybeOf(context);
    _loadAssetBytes();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant VectorGraphic oldWidget) {
    if (oldWidget.loader != widget.loader) {
      _loadAssetBytes();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _maybeReleasePicture(_pictureInfo);
    _pictureInfo = null;
    super.dispose();
  }

  void _maybeReleasePicture(_PictureData? data) {
    if (data == null) {
      return;
    }
    data.count -= 1;
    if (data.count == 0 && _livePictureCache.containsKey(data.key)) {
      _livePictureCache.remove(data.key);
      data.pictureInfo.picture.dispose();
    }
  }

  static Future<_PictureData> _loadPicture(
      BuildContext context, _PictureKey key, BytesLoader loader) {
    if (_pendingPictures.containsKey(key)) {
      return _pendingPictures[key]!;
    }
    final Future<_PictureData> result =
        loader.loadBytes(context).then((ByteData data) {
      return decodeVectorGraphics(
        data,
        locale: key.locale,
        textDirection: key.textDirection,
      );
    }).then((PictureInfo pictureInfo) {
      return _PictureData(pictureInfo, 0, key);
    });
    _pendingPictures[key] = result;
    result.whenComplete(() {
      _pendingPictures.remove(key);
    });
    return result;
  }

  void _loadAssetBytes() {
    // First check if we have an avilable picture and use this immediately.
    final Object loaderKey = widget.loader.cacheKey(context);
    final _PictureKey key = _PictureKey(loaderKey, locale, textDirection);
    final _PictureData? data = _livePictureCache[key];
    if (data != null) {
      data.count += 1;
      setState(() {
        _maybeReleasePicture(_pictureInfo);
        _pictureInfo = data;
      });
      return;
    }
    // If not, then check if there is a pending load.
    final BytesLoader loader = widget.loader;
    _loadPicture(context, key, loader).then((_PictureData data) {
      data.count += 1;

      // The widget may have changed, requesting a new vector graphic before
      // this operation could complete.
      if (!mounted || loader != widget.loader) {
        _maybeReleasePicture(data);
        return;
      }
      if (data.count == 1) {
        _livePictureCache[key] = data;
      }
      setState(() {
        _maybeReleasePicture(_pictureInfo);
        _pictureInfo = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final PictureInfo? pictureInfo = _pictureInfo?.pictureInfo;

    Widget child;
    if (pictureInfo != null) {
      // If the caller did not specify a width or height, fall back to the
      // size of the graphic.
      // If the caller did specify a width or height, preserve the aspect ratio
      // of the graphic and center it within that width and height.
      double? width = widget.width;
      double? height = widget.height;

      if (width == null && height == null) {
        width = pictureInfo.size.width;
        height = pictureInfo.size.height;
      } else if (height != null && !pictureInfo.size.isEmpty) {
        width = height / pictureInfo.size.height * pictureInfo.size.width;
      } else if (width != null && !pictureInfo.size.isEmpty) {
        height = width / pictureInfo.size.width * pictureInfo.size.height;
      }

      assert(width != null && height != null);

      double scale = 1.0;
      scale = math.min(
        pictureInfo.size.width / width!,
        pictureInfo.size.height / height!,
      );

      child = SizedBox(
        width: width,
        height: height,
        child: FittedBox(
          fit: widget.fit,
          alignment: widget.alignment,
          clipBehavior: Clip.hardEdge,
          child: SizedBox.fromSize(
            size: pictureInfo.size,
            child: _RawVectorGraphicWidget(
              pictureInfo: pictureInfo,
              assetKey: _pictureInfo!.key,
              colorFilter: widget.colorFilter,
              opacity: widget.opacity,
              scale: scale,
            ),
          ),
        ),
      );
    } else {
      child = widget.placeholderBuilder?.call(context) ??
          SizedBox(width: widget.width, height: widget.height);
    }

    if (!widget.excludeFromSemantics) {
      child = Semantics(
        container: widget.semanticsLabel != null,
        image: true,
        label: widget.semanticsLabel ?? '',
        child: child,
      );
    }
    return child;
  }
}

/// An interface that can be implemented to support decoding vector graphic
/// binary assets from different byte sources.
///
/// A bytes loader class should not be constructed directly in a build method,
/// if this is done the corresponding [VectorGraphic] widget may repeatedly
/// reload the bytes.
///
/// See also:
///   * [AssetBytesLoader], for loading from the asset bundle.
///   * [NetworkBytesLoader], for loading network bytes.
@immutable
abstract class BytesLoader {
  /// Const constructor to allow subtypes to be const.
  const BytesLoader();

  /// Load the byte data for a vector graphic binary asset.
  Future<ByteData> loadBytes(BuildContext context);

  /// Create an object that can be used to uniquely identify this asset
  /// and loader combination.
  ///
  /// For most [BytesLoader] subclasses, this can safely return the same
  /// instance. If the loader looks up additional dependencies using the
  /// [context] argument of [loadBytes], then those objects should be
  /// incorporated into a new cache key.
  Object cacheKey(BuildContext context) => this;
}

/// Loads vector graphics data from an asset bundle.
///
/// This loader does not cache bytes by default. The Flutter framework
/// implementations of [AssetBundle] also do not typically cache binary data.
///
/// Callers that would benefit from caching should provide a custom
/// [AssetBundle] that caches data, or should create their own implementation
/// of an asset bytes loader.
class AssetBytesLoader extends BytesLoader {
  /// A loader that retrieves bytes from an [AssetBundle].
  ///
  /// See [AssetBytesLoader].
  const AssetBytesLoader(
    this.assetName, {
    this.packageName,
    this.assetBundle,
  });

  /// The name of the asset to load.
  final String assetName;

  /// The package name to load from, if any.
  final String? packageName;

  /// The asset bundle to use.
  ///
  /// If unspecified, [DefaultAssetBundle.of] the current context will be used.
  final AssetBundle? assetBundle;

  @override
  Future<ByteData> loadBytes(BuildContext context) {
    return (assetBundle ?? DefaultAssetBundle.of(context)).load(assetName);
  }

  @override
  int get hashCode => Object.hash(assetName, packageName, assetBundle);

  @override
  bool operator ==(Object other) {
    return other is AssetBytesLoader &&
        other.assetName == assetName &&
        other.assetBundle == assetBundle &&
        other.packageName == packageName;
  }

  @override
  Object cacheKey(BuildContext context) {
    return _AssetByteLoaderCacheKey(
      assetName,
      packageName,
      assetBundle ?? DefaultAssetBundle.of(context),
    );
  }
}

// Replaces the cache key for [AssetBytesLoader] to account for the fact that
// different widgets may select a different asset bundle based on the return
// value of `DefaultAssetBundle.of(context)`.
@immutable
class _AssetByteLoaderCacheKey {
  const _AssetByteLoaderCacheKey(
      this.assetName, this.packageName, this.assetBundle);

  final String assetName;
  final String? packageName;

  final AssetBundle assetBundle;

  @override
  int get hashCode => Object.hash(assetName, packageName, assetBundle);

  @override
  bool operator ==(Object other) {
    return other is _AssetByteLoaderCacheKey &&
        other.assetName == assetName &&
        other.assetBundle == assetBundle &&
        other.packageName == packageName;
  }
}

/// A controller for loading vector graphics data from over the network.
///
/// This loader does not cache bytes requested from the network.
class NetworkBytesLoader extends BytesLoader {
  /// Creates a new loading context for network bytes.
  const NetworkBytesLoader(
    this.url, {
    this.headers,
  });

  /// The HTTP headers to use for the network request.
  final Map<String, String>? headers;

  /// The [Uri] of the resource to request.
  final Uri url;

  @override
  Future<ByteData> loadBytes(BuildContext context) async {
    final Uint8List bytes = await httpGet(url, headers: headers);
    return bytes.buffer.asByteData();
  }

  @override
  int get hashCode => Object.hash(url, headers);

  @override
  bool operator ==(Object other) {
    return other is NetworkBytesLoader &&
        other.headers == headers &&
        other.url == url;
  }
}

class _RawVectorGraphicWidget extends SingleChildRenderObjectWidget {
  const _RawVectorGraphicWidget({
    required this.pictureInfo,
    required this.colorFilter,
    required this.opacity,
    required this.scale,
    required this.assetKey,
  });

  final PictureInfo pictureInfo;
  final ColorFilter? colorFilter;
  final double scale;
  final Animation<double>? opacity;
  final Object assetKey;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderVectorGraphic(
      pictureInfo,
      assetKey,
      colorFilter,
      MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0,
      opacity,
      scale,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderVectorGraphic renderObject,
  ) {
    renderObject
      ..pictureInfo = pictureInfo
      ..assetKey = assetKey
      ..colorFilter = colorFilter
      ..devicePixelRatio = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0
      ..opacity = opacity
      ..scale = scale;
  }
}

/// Utility functionality for interaction with vector graphic assets.
class VectorGraphicUtilities {
  const VectorGraphicUtilities._();

  /// Load the [PictureInfo] from a given [loader].
  ///
  /// It is the caller's responsibility to handle disposing the picture when
  /// they are done with it.
  Future<PictureInfo> loadPicture(
    BytesLoader loader,
    BuildContext context,
  ) async {
    // This intentionally does not use the picture cache so that disposal does not
    // happen automatically.
    final Locale? locale = Localizations.maybeLocaleOf(context);
    final TextDirection? textDirection = Directionality.maybeOf(context);
    return loader.loadBytes(context).then((ByteData data) {
      return decodeVectorGraphics(
        data,
        locale: locale,
        textDirection: textDirection,
      );
    });
  }
}

/// The [VectorGraphicUtilities] instance.
const VectorGraphicUtilities vg = VectorGraphicUtilities._();
