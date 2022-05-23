// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'src/http.dart';
import 'src/listener.dart';
import 'src/render_vector_graphics.dart';

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

class _VectorGraphicWidgetState extends State<VectorGraphic> {
  PictureInfo? _pictureInfo;

  @override
  void didChangeDependencies() {
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
    _pictureInfo?.picture.dispose();
    _pictureInfo = null;
    super.dispose();
  }

  void _loadAssetBytes() {
    widget.loader.loadBytes(context).then((ByteData data) {
      final PictureInfo pictureInfo = decodeVectorGraphics(
        data,
        locale: Localizations.maybeLocaleOf(context),
        textDirection: Directionality.maybeOf(context),
      );
      setState(() {
        _pictureInfo?.picture.dispose();
        _pictureInfo = pictureInfo;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final PictureInfo? pictureInfo = _pictureInfo;

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
              colorFilter: widget.colorFilter,
              opacity: widget.opacity,
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
  });

  final PictureInfo pictureInfo;
  final ColorFilter? colorFilter;
  final Animation<double>? opacity;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderVectorGraphic(
      pictureInfo,
      colorFilter,
      MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0,
      opacity,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderVectorGraphic renderObject,
  ) {
    renderObject
      ..pictureInfo = pictureInfo
      ..colorFilter = colorFilter
      ..devicePixelRatio = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0
      ..opacity = opacity;
  }
}
