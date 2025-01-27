// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'html_render_vector_graphics.dart';
import 'listener.dart';
import 'loader.dart';
import 'render_object_selection.dart';
import 'render_vector_graphic.dart';

export 'listener.dart' show PictureInfo;
export 'loader.dart';

/// How the vector graphic will be rendered by the Flutter framework.
///
/// This is ultimately a performance versus fidelity tradeoff. While the
/// raster strategy performs better than the picture strategy in most benchmarks,
/// it can be more difficult to use. Any parent transforms that are not
/// accounted by the application developer can cause the vector graphic to
/// appear pixelated. The picture strategy has no such trade-off, and roughly
/// corresponds to the previous behavior of flutter_svg
///
/// Consider using the raster strategy for very large or complicated vector graphics
/// that are used as backdrops at fixed scales. The picture strategy makes a better
/// default choice for icon-like vector graphics or vector graphics that have
/// small dimensions.
enum RenderingStrategy {
  /// Draw the vector graphic as a raster.
  ///
  /// This raster is reused from frame to frame which can significantly improve
  /// performance if the vector graphic is complicated.
  raster,

  /// Draw the vector graphic as a picture.
  picture,
}

/// The signature that [VectorGraphic.errorBuilder] uses to report exceptions.
typedef VectorGraphicsErrorWidget = Widget Function(
  BuildContext context,
  Object error,
  StackTrace stackTrace,
);

/// A vector graphic/flutter_svg compatibility shim.
VectorGraphic createCompatVectorGraphic({
  Key? key,
  required BytesLoader loader,
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
  AlignmentGeometry alignment = Alignment.center,
  String? semanticsLabel,
  bool excludeFromSemantics = false,
  Clip clipBehavior = Clip.hardEdge,
  WidgetBuilder? placeholderBuilder,
  VectorGraphicsErrorWidget? errorBuilder,
  ColorFilter? colorFilter,
  Animation<double>? opacity,
  RenderingStrategy strategy = RenderingStrategy.picture,
  bool clipViewbox = true,
  bool matchTextDirection = false,
}) {
  return VectorGraphic._(
    key: key,
    loader: loader,
    width: width,
    height: height,
    fit: fit,
    alignment: alignment,
    semanticsLabel: semanticsLabel,
    excludeFromSemantics: excludeFromSemantics,
    clipBehavior: clipBehavior,
    placeholderBuilder: placeholderBuilder,
    errorBuilder: errorBuilder,
    colorFilter: colorFilter,
    opacity: opacity,
    strategy: strategy,
    clipViewbox: clipViewbox,
    matchTextDirection: matchTextDirection,
  );
}

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
  /// If `matchTextDirection` is set to true, the picture will be flipped
  /// horizontally in [TextDirection.rtl] contexts.
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
    this.clipBehavior = Clip.hardEdge,
    this.placeholderBuilder,
    this.errorBuilder,
    this.colorFilter,
    this.opacity,
    this.clipViewbox = true,
    this.matchTextDirection = false,
  }) : strategy = RenderingStrategy.raster;

  /// A specialized constructor for flutter_svg interop.
  const VectorGraphic._({
    super.key,
    required this.loader,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.clipBehavior = Clip.hardEdge,
    this.placeholderBuilder,
    this.errorBuilder,
    this.colorFilter,
    this.opacity,
    this.strategy = RenderingStrategy.picture,
    this.clipViewbox = true,
    this.matchTextDirection = false,
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

  /// If true, will horizontally flip the picture in [TextDirection.rtl] contexts.
  final bool matchTextDirection;

  /// The [Semantics] label for this picture.
  ///
  /// The value indicates the purpose of the picture, and will be read out by
  /// screen readers.
  final String? semanticsLabel;

  /// Whether to exclude this picture from semantics.
  ///
  /// Useful for pictures which do not contribute meaningful semantic information to an
  /// application.
  final bool excludeFromSemantics;

  /// The content will be clipped (or not) according to this option.
  ///
  /// See the enum [Clip] for details of all possible options and their common
  /// use cases.
  ///
  /// Defaults to [Clip.hardEdge], and must not be null.
  final Clip clipBehavior;

  /// The placeholder to use while fetching, decoding, and parsing the vector_graphics data.
  final WidgetBuilder? placeholderBuilder;

  /// A callback that fires if some exception happens during data acquisition or decoding.
  final VectorGraphicsErrorWidget? errorBuilder;

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

  /// The rendering strategy used by the vector graphic.
  ///
  /// By default this is [RenderingStrategy.raster].
  final RenderingStrategy strategy;

  /// Whether the graphic should be clipped to its viewbox.
  ///
  /// If true, this adds a clip sized to the dimensions of the graphic before
  /// drawing. This prevents the graphic from accidentally drawing outside of
  /// its specified dimensions. Some graphics intentionally draw outside of
  /// their specified dimensions and thus must not be clipped.
  final bool clipViewbox;

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
  const _PictureKey(
      this.cacheKey, this.locale, this.textDirection, this.clipViewbox);

  final Object cacheKey;
  final Locale? locale;
  final TextDirection? textDirection;
  final bool clipViewbox;

  @override
  int get hashCode => Object.hash(cacheKey, locale, textDirection, clipViewbox);

  @override
  bool operator ==(Object other) =>
      other is _PictureKey &&
      other.cacheKey == cacheKey &&
      other.locale == locale &&
      other.textDirection == textDirection &&
      other.clipViewbox == clipViewbox;
}

class _VectorGraphicWidgetState extends State<VectorGraphic> {
  _PictureData? _pictureInfo;
  Object? _error;
  StackTrace? _stackTrace;
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
    unawaited(_loadAssetBytes());
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant VectorGraphic oldWidget) {
    if (oldWidget.loader != widget.loader) {
      unawaited(_loadAssetBytes());
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

  Future<_PictureData> _loadPicture(
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
        clipViewbox: key.clipViewbox,
        loader: loader,
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

  void _handleError(Object error, StackTrace? stackTrace) {
    if (!mounted) {
      return;
    }

    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });
  }

  Future<void> _loadAssetBytes() async {
    // First check if we have an avilable picture and use this immediately.
    final Object loaderKey = widget.loader.cacheKey(context);
    final _PictureKey key =
        _PictureKey(loaderKey, locale, textDirection, widget.clipViewbox);
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

    try {
      final _PictureData data = await _loadPicture(context, key, loader);
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
    } catch (error, stackTrace) {
      _handleError(error, stackTrace);
    }
  }

  static final bool _webRenderObject = useHtmlRenderObject();

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

      if (_webRenderObject) {
        child = _RawWebVectorGraphicWidget(
          pictureInfo: pictureInfo,
          assetKey: _pictureInfo!.key,
          colorFilter: widget.colorFilter,
          opacity: widget.opacity,
        );
      } else if (widget.strategy == RenderingStrategy.raster) {
        child = _RawVectorGraphicWidget(
          pictureInfo: pictureInfo,
          assetKey: _pictureInfo!.key,
          colorFilter: widget.colorFilter,
          opacity: widget.opacity,
          scale: scale,
        );
      } else {
        child = _RawPictureVectorGraphicWidget(
          pictureInfo: pictureInfo,
          assetKey: _pictureInfo!.key,
          colorFilter: widget.colorFilter,
          opacity: widget.opacity,
        );
      }

      if (widget.matchTextDirection) {
        final TextDirection direction = Directionality.of(context);
        if (direction == TextDirection.rtl) {
          child = Transform(
            transform: Matrix4.identity()
              ..translate(pictureInfo.size.width)
              ..scale(-1.0, 1.0),
            child: child,
          );
        }
      }

      child = SizedBox(
        width: width,
        height: height,
        child: FittedBox(
          fit: widget.fit,
          alignment: widget.alignment,
          clipBehavior: widget.clipBehavior,
          child: SizedBox.fromSize(
            size: pictureInfo.size,
            child: child,
          ),
        ),
      );
    } else if (_error != null && widget.errorBuilder != null) {
      child = widget.errorBuilder!(
        context,
        _error!,
        _stackTrace ?? StackTrace.empty,
      );
    } else {
      child = widget.placeholderBuilder?.call(context) ??
          SizedBox(
            width: widget.width,
            height: widget.height,
          );
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

class _RawWebVectorGraphicWidget extends SingleChildRenderObjectWidget {
  const _RawWebVectorGraphicWidget({
    required this.pictureInfo,
    required this.colorFilter,
    required this.opacity,
    required this.assetKey,
  });

  final PictureInfo pictureInfo;
  final ColorFilter? colorFilter;
  final Animation<double>? opacity;
  final Object assetKey;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderWebVectorGraphic(
      pictureInfo,
      assetKey,
      colorFilter,
      opacity,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderWebVectorGraphic renderObject,
  ) {
    renderObject
      ..pictureInfo = pictureInfo
      ..assetKey = assetKey
      ..colorFilter = colorFilter
      ..opacity = opacity;
  }
}

class _RawPictureVectorGraphicWidget extends SingleChildRenderObjectWidget {
  const _RawPictureVectorGraphicWidget({
    required this.pictureInfo,
    required this.colorFilter,
    required this.opacity,
    required this.assetKey,
  });

  final PictureInfo pictureInfo;
  final ColorFilter? colorFilter;
  final Animation<double>? opacity;
  final Object assetKey;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPictureVectorGraphic(
      pictureInfo,
      colorFilter,
      opacity,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderPictureVectorGraphic renderObject,
  ) {
    renderObject
      ..pictureInfo = pictureInfo
      ..colorFilter = colorFilter
      ..opacity = opacity;
  }
}

/// Utility functionality for interaction with vector graphic assets.
class VectorGraphicUtilities {
  const VectorGraphicUtilities._();

  /// A future that completes when any in-flight vector graphic decodes have
  /// completed.
  ///
  /// A vector graphic may require asynchronous work during decoding, for
  /// example to decode an image that was embedded in the source graphic. This
  /// method may be useful in golden image unit tests.
  ///
  /// ```dart
  /// await tester.pumpWidget(MyWidgetThatHasVectorGraphics());
  /// await tester.runAsync(() => vg.waitForPendingDecodes());
  /// await expect(
  ///   find.byType(MyWidgetThatHasVectorGraphics),
  ///   matchesGoldenFile('golden_file.png'),
  /// );
  /// ```
  ///
  /// Without the `waitForPendingDecodes` call, the golden file would have the
  /// placeholder for the [VectorGraphic] widgets, which defaults to a blank
  /// sized box.
  @visibleForTesting
  Future<void> waitForPendingDecodes() {
    if (kDebugMode) {
      // ignore: invalid_use_of_visible_for_testing_member
      return Future.wait(debugGetPendingDecodeTasks);
    }
    throw UnsupportedError(
      'This method is only for use in tests in debug mode for tests.',
    );
  }

  /// Load the [PictureInfo] from a given [loader].
  ///
  /// It is the caller's responsibility to handle disposing the picture when
  /// they are done with it.
  Future<PictureInfo> loadPicture(
    BytesLoader loader,
    BuildContext? context, {
    bool clipViewbox = true,
    VectorGraphicsErrorListener? onError,
  }) async {
    TextDirection textDirection = TextDirection.ltr;
    Locale locale = ui.PlatformDispatcher.instance.locale;
    if (context != null) {
      locale = Localizations.maybeLocaleOf(context) ?? locale;
      textDirection = Directionality.maybeOf(context) ?? textDirection;
    }
    return loader.loadBytes(context).then((ByteData data) {
      try {
        return decodeVectorGraphics(
          data,
          locale: locale,
          textDirection: textDirection,
          loader: loader,
          clipViewbox: clipViewbox,
          onError: onError,
        );
      } catch (e) {
        debugPrint('Failed to decode $loader');
        rethrow;
      }
    });
  }
}

/// The [VectorGraphicUtilities] instance.
const VectorGraphicUtilities vg = VectorGraphicUtilities._();
