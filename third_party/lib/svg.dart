import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';
import 'dart:ui' show Picture;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show AssetBundle;
import 'package:flutter/widgets.dart';

import 'parser.dart';
import 'src/picture_provider.dart';
import 'src/picture_stream.dart';
import 'src/render_picture.dart';
import 'src/unbounded_color_filtered.dart';
import 'src/vector_drawable.dart';

/// Instance for [Svg]'s utility methods, which can produce a [DrawableRoot]
/// or [PictureInfo] from [String] or [Uint8List].
final Svg svg = Svg._();

/// A utility class for decoding SVG data to a [DrawableRoot] or a [PictureInfo].
///
/// These methods are used by [SvgPicture], but can also be directly used e.g.
/// to create a [DrawableRoot] you manipulate or render to your own [Canvas].
/// Access to this class is provided by the exported [svg] member.
class Svg {
  Svg._();

  /// A global override flag for [SvgPicture.cacheColorFilter].
  ///
  /// If this is null, the value in [SvgPicture.cacheColorFilter] is used. If it
  /// is not null, it will override that value.
  bool? cacheColorFilterOverride;

  /// Produces a [PictureInfo] from a [Uint8List] of SVG byte data (assumes UTF8 encoding).
  ///
  /// The `allowDrawingOutsideOfViewBox` parameter should be used with caution -
  /// if set to true, it will not clip the canvas used internally to the view box,
  /// meaning the picture may draw beyond the intended area and lead to undefined
  /// behavior or additional memory overhead.
  ///
  /// The `colorFilter` property will be applied to any [Paint] objects used during drawing.
  ///
  /// The [key] will be used for debugging purposes.
  Future<PictureInfo> svgPictureDecoder(
    Uint8List raw,
    bool allowDrawingOutsideOfViewBox,
    ColorFilter? colorFilter,
    String key,
  ) async {
    final DrawableRoot svgRoot = await fromSvgBytes(raw, key);
    final Picture pic = svgRoot.toPicture(
      clipToViewBox: allowDrawingOutsideOfViewBox == true ? false : true,
      colorFilter: colorFilter,
    );
    return PictureInfo(
      picture: pic,
      viewport: svgRoot.viewport.viewBoxRect,
      size: svgRoot.viewport.size,
    );
  }

  /// Produces a [PictureInfo] from a [String] of SVG data.
  ///
  /// The `allowDrawingOutsideOfViewBox` parameter should be used with caution -
  /// if set to true, it will not clip the canvas used internally to the view box,
  /// meaning the picture may draw beyond the intended area and lead to undefined
  /// behavior or additional memory overhead.
  ///
  /// The `colorFilter` property will be applied to any [Paint] objects used during drawing.
  ///
  /// The [key] will be used for debugging purposes.
  Future<PictureInfo> svgPictureStringDecoder(
      String raw,
      bool allowDrawingOutsideOfViewBox,
      ColorFilter? colorFilter,
      String key) async {
    final DrawableRoot svg = await fromSvgString(raw, key);
    return PictureInfo(
      picture: svg.toPicture(
        clipToViewBox: allowDrawingOutsideOfViewBox == true ? false : true,
        colorFilter: colorFilter,
        size: svg.viewport.viewBox,
      ),
      viewport: svg.viewport.viewBoxRect,
      size: svg.viewport.size,
    );
  }

  /// Produces a [Drawableroot] from a [Uint8List] of SVG byte data (assumes UTF8 encoding).
  ///
  /// The [key] will be used for debugging purposes.
  Future<DrawableRoot> fromSvgBytes(Uint8List raw, String key) async {
    // TODO(dnfield): do utf decoding in another thread?
    // Might just have to live with potentially slow(ish) decoding, this is causing errors.
    // See: https://github.com/dart-lang/sdk/issues/31954
    // See: https://github.com/flutter/flutter/blob/bf3bd7667f07709d0b817ebfcb6972782cfef637/packages/flutter/lib/src/services/asset_bundle.dart#L66
    // if (raw.lengthInBytes < 20 * 1024) {
    return fromSvgString(utf8.decode(raw), key);
    // } else {
    //   final String str =
    //       await compute(_utf8Decode, raw, debugLabel: 'UTF8 decode for SVG');
    //   return fromSvgString(str);
    // }
  }

  // String _utf8Decode(Uint8List data) {
  //   return utf8.decode(data);
  // }

  /// Creates a [DrawableRoot] from a string of SVG data.
  ///
  /// The `key` is used for debugging purposes.
  Future<DrawableRoot> fromSvgString(String rawSvg, String key) async {
    final SvgParser parser = SvgParser();
    return await parser.parse(rawSvg, key: key);
  }
}

/// Prefetches an SVG Picture into the picture cache.
///
/// Returns a [Future] that will complete when the first image yielded by the
/// [PictureProvider] is available or failed to load.
///
/// If the image is later used by an [SvgPicture], it will probably be loaded
/// faster. The consumer of the image does not need to use the same
/// [PictureProvider] instance. The [PictureCache] will find the picture
/// as long as both pictures share the same key.
///
/// The `onError` argument can be used to manually handle errors while precaching.
///
/// See also:
///
///  * [PictureCache], which holds images that may be reused.
Future<void> precachePicture(
  PictureProvider provider,
  BuildContext? context, {
  Rect? viewBox,
  ColorFilter? colorFilterOverride,
  Color? color,
  BlendMode? colorBlendMode,
  PictureErrorListener? onError,
}) {
  final PictureConfiguration config = createLocalPictureConfiguration(
    context,
    viewBox: viewBox,
    colorFilterOverride: colorFilterOverride,
    color: color,
    colorBlendMode: colorBlendMode,
  );
  final Completer<void> completer = Completer<void>();
  PictureStream? stream;

  void listener(PictureInfo? picture, bool synchronous) {
    completer.complete();
    stream?.removeListener(listener);
  }

  void errorListener(Object exception, StackTrace stackTrace) {
    if (onError != null) {
      onError(exception, stackTrace);
    } else {
      FlutterError.reportError(FlutterErrorDetails(
        context: ErrorDescription('picture failed to precache'),
        library: 'SVG',
        exception: exception,
        stack: stackTrace,
        silent: true,
      ));
    }
    completer.complete();
    stream?.removeListener(listener);
  }

  stream = provider.resolve(config, onError: errorListener)
    ..addListener(listener, onError: errorListener);
  return completer.future;
}

/// A widget that will parse SVG data into a [Picture] using a [PictureProvider].
///
/// The picture will be cached using the [PictureCache], incorporating any color
/// filtering used into the key (meaning the same SVG with two different `color`
/// arguments applied would be two cache entries).
class SvgPicture extends StatefulWidget {
  /// Instantiates a widget that renders an SVG picture using the `pictureProvider`.
  ///
  /// Either the [width] and [height] arguments should be specified, or the
  /// widget should be placed in a context that sets tight layout constraints.
  /// Otherwise, the image dimensions will change as the image is loaded, which
  /// will result in ugly layout changes.
  ///
  /// If `matchTextDirection` is set to true, the picture will be flipped
  /// horizontally in [TextDirection.rtl] contexts.
  ///
  /// The `allowDrawingOutsideOfViewBox` parameter should be used with caution -
  /// if set to true, it will not clip the canvas used internally to the view box,
  /// meaning the picture may draw beyond the intended area and lead to undefined
  /// behavior or additional memory overhead.
  ///
  /// A custom `placeholderBuilder` can be specified for cases where decoding or
  /// acquiring data may take a noticeably long time, e.g. for a network picture.
  ///
  /// The `semanticsLabel` can be used to identify the purpose of this picture for
  /// screen reading software.
  ///
  /// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
  const SvgPicture(
    this.pictureProvider, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.matchTextDirection = false,
    this.allowDrawingOutsideViewBox = false,
    this.placeholderBuilder,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.clipBehavior = Clip.hardEdge,
    this.colorFilter,
    this.cacheColorFilter = false,
  }) : super(key: key);

  /// Instantiates a widget that renders an SVG picture from an [AssetBundle].
  ///
  /// The key will be derived from the `assetName`, `package`, and `bundle`
  /// arguments. The `package` argument must be non-null when displaying an SVG
  /// from a package and null otherwise. See the `Assets in packages` section for
  /// details.
  ///
  /// Either the [width] and [height] arguments should be specified, or the
  /// widget should be placed in a context that sets tight layout constraints.
  /// Otherwise, the image dimensions will change as the image is loaded, which
  /// will result in ugly layout changes.
  ///
  /// If `matchTextDirection` is set to true, the picture will be flipped
  /// horizontally in [TextDirection.rtl] contexts.
  ///
  /// The `allowDrawingOutsideOfViewBox` parameter should be used with caution -
  /// if set to true, it will not clip the canvas used internally to the view box,
  /// meaning the picture may draw beyond the intended area and lead to undefined
  /// behavior or additional memory overhead.
  ///
  /// A custom `placeholderBuilder` can be specified for cases where decoding or
  /// acquiring data may take a noticeably long time.
  ///
  /// The `color` and `colorBlendMode` arguments, if specified, will be used to set a
  /// [ColorFilter] on any [Paint]s created for this drawing.
  ///
  /// ## Assets in packages
  ///
  /// To create the widget with an asset from a package, the [package] argument
  /// must be provided. For instance, suppose a package called `my_icons` has
  /// `icons/heart.svg` .
  ///
  /// Then to display the image, use:
  ///
  /// ```dart
  /// SvgPicture.asset('icons/heart.svg', package: 'my_icons')
  /// ```
  ///
  /// Assets used by the package itself should also be displayed using the
  /// [package] argument as above.
  ///
  /// If the desired asset is specified in the `pubspec.yaml` of the package, it
  /// is bundled automatically with the app. In particular, assets used by the
  /// package itself must be specified in its `pubspec.yaml`.
  ///
  /// A package can also choose to have assets in its 'lib/' folder that are not
  /// specified in its `pubspec.yaml`. In this case for those images to be
  /// bundled, the app has to specify which ones to include. For instance a
  /// package named `fancy_backgrounds` could have:
  ///
  /// ```
  /// lib/backgrounds/background1.svg
  /// lib/backgrounds/background2.svg
  /// lib/backgrounds/background3.svg
  ///```
  ///
  /// To include, say the first image, the `pubspec.yaml` of the app should
  /// specify it in the assets section:
  ///
  /// ```yaml
  ///  assets:
  ///    - packages/fancy_backgrounds/backgrounds/background1.svg
  /// ```
  ///
  /// The `lib/` is implied, so it should not be included in the asset path.
  ///
  ///
  /// See also:
  ///
  ///  * [AssetPicture], which is used to implement the behavior when the scale is
  ///    omitted.
  ///  * [ExactAssetPicture], which is used to implement the behavior when the
  ///    scale is present.
  ///  * <https://flutter.io/assets-and-images/>, an introduction to assets in
  ///    Flutter.
  ///
  /// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
  SvgPicture.asset(
    String assetName, {
    Key? key,
    this.matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.allowDrawingOutsideViewBox = false,
    this.placeholderBuilder,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.clipBehavior = Clip.hardEdge,
    this.cacheColorFilter = false,
  })  : pictureProvider = ExactAssetPicture(
          allowDrawingOutsideViewBox == true
              ? svgStringDecoderOutsideViewBox
              : svgStringDecoder,
          assetName,
          bundle: bundle,
          package: package,
          colorFilter: svg.cacheColorFilterOverride ?? cacheColorFilter
              ? _getColorFilter(color, colorBlendMode)
              : null,
        ),
        colorFilter = _getColorFilter(color, colorBlendMode),
        super(key: key);

  /// Creates a widget that displays a [PictureStream] obtained from the network.
  ///
  /// The [url] argument must not be null.
  ///
  /// Either the [width] and [height] arguments should be specified, or the
  /// widget should be placed in a context that sets tight layout constraints.
  /// Otherwise, the image dimensions will change as the image is loaded, which
  /// will result in ugly layout changes.
  ///
  /// If `matchTextDirection` is set to true, the picture will be flipped
  /// horizontally in [TextDirection.rtl] contexts.
  ///
  /// The `allowDrawingOutsideOfViewBox` parameter should be used with caution -
  /// if set to true, it will not clip the canvas used internally to the view box,
  /// meaning the picture may draw beyond the intended area and lead to undefined
  /// behavior or additional memory overhead.
  ///
  /// A custom `placeholderBuilder` can be specified for cases where decoding or
  /// acquiring data may take a noticeably long time, such as high latency scenarios.
  ///
  /// The `color` and `colorBlendMode` arguments, if specified, will be used to set a
  /// [ColorFilter] on any [Paint]s created for this drawing.
  ///
  /// All network images are cached regardless of HTTP headers.
  ///
  /// An optional `headers` argument can be used to send custom HTTP headers
  /// with the image request.
  ///
  /// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
  SvgPicture.network(
    String url, {
    Key? key,
    Map<String, String>? headers,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.matchTextDirection = false,
    this.allowDrawingOutsideViewBox = false,
    this.placeholderBuilder,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.clipBehavior = Clip.hardEdge,
    this.cacheColorFilter = false,
  })  : pictureProvider = NetworkPicture(
          allowDrawingOutsideViewBox == true
              ? svgByteDecoderOutsideViewBox
              : svgByteDecoder,
          url,
          headers: headers,
          colorFilter: svg.cacheColorFilterOverride ?? cacheColorFilter
              ? _getColorFilter(color, colorBlendMode)
              : null,
        ),
        colorFilter = _getColorFilter(color, colorBlendMode),
        super(key: key);

  /// Creates a widget that displays a [PictureStream] obtained from a [File].
  ///
  /// The [file] argument must not be null.
  ///
  /// Either the [width] and [height] arguments should be specified, or the
  /// widget should be placed in a context that sets tight layout constraints.
  /// Otherwise, the image dimensions will change as the image is loaded, which
  /// will result in ugly layout changes.
  ///
  /// If `matchTextDirection` is set to true, the picture will be flipped
  /// horizontally in [TextDirection.rtl] contexts.
  ///
  /// The `allowDrawingOutsideOfViewBox` parameter should be used with caution -
  /// if set to true, it will not clip the canvas used internally to the view box,
  /// meaning the picture may draw beyond the intended area and lead to undefined
  /// behavior or additional memory overhead.
  ///
  /// A custom `placeholderBuilder` can be specified for cases where decoding or
  /// acquiring data may take a noticeably long time.
  ///
  /// The `color` and `colorBlendMode` arguments, if specified, will be used to set a
  /// [ColorFilter] on any [Paint]s created for this drawing.
  ///
  /// On Android, this may require the
  /// `android.permission.READ_EXTERNAL_STORAGE` permission.
  ///
  /// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
  SvgPicture.file(
    File file, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.matchTextDirection = false,
    this.allowDrawingOutsideViewBox = false,
    this.placeholderBuilder,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.clipBehavior = Clip.hardEdge,
    this.cacheColorFilter = false,
  })  : pictureProvider = FilePicture(
          allowDrawingOutsideViewBox == true
              ? svgByteDecoderOutsideViewBox
              : svgByteDecoder,
          file,
          colorFilter: svg.cacheColorFilterOverride ?? cacheColorFilter
              ? _getColorFilter(color, colorBlendMode)
              : null,
        ),
        colorFilter = _getColorFilter(color, colorBlendMode),
        super(key: key);

  /// Creates a widget that displays a [PictureStream] obtained from a [Uint8List].
  ///
  /// The [bytes] argument must not be null.
  ///
  /// Either the [width] and [height] arguments should be specified, or the
  /// widget should be placed in a context that sets tight layout constraints.
  /// Otherwise, the image dimensions will change as the image is loaded, which
  /// will result in ugly layout changes.
  ///
  /// If `matchTextDirection` is set to true, the picture will be flipped
  /// horizontally in [TextDirection.rtl] contexts.
  ///
  /// The `allowDrawingOutsideOfViewBox` parameter should be used with caution -
  /// if set to true, it will not clip the canvas used internally to the view box,
  /// meaning the picture may draw beyond the intended area and lead to undefined
  /// behavior or additional memory overhead.
  ///
  /// A custom `placeholderBuilder` can be specified for cases where decoding or
  /// acquiring data may take a noticeably long time.
  ///
  /// The `color` and `colorBlendMode` arguments, if specified, will be used to set a
  /// [ColorFilter] on any [Paint]s created for this drawing.
  ///
  /// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
  SvgPicture.memory(
    Uint8List bytes, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.matchTextDirection = false,
    this.allowDrawingOutsideViewBox = false,
    this.placeholderBuilder,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.clipBehavior = Clip.hardEdge,
    this.cacheColorFilter = false,
  })  : pictureProvider = MemoryPicture(
          allowDrawingOutsideViewBox == true
              ? svgByteDecoderOutsideViewBox
              : svgByteDecoder,
          bytes,
          colorFilter: svg.cacheColorFilterOverride ?? cacheColorFilter
              ? _getColorFilter(color, colorBlendMode)
              : null,
        ),
        colorFilter = _getColorFilter(color, colorBlendMode),
        super(key: key);

  /// Creates a widget that displays a [PictureStream] obtained from a [String].
  ///
  /// The [bytes] argument must not be null.
  ///
  /// Either the [width] and [height] arguments should be specified, or the
  /// widget should be placed in a context that sets tight layout constraints.
  /// Otherwise, the image dimensions will change as the image is loaded, which
  /// will result in ugly layout changes.
  ///
  /// If `matchTextDirection` is set to true, the picture will be flipped
  /// horizontally in [TextDirection.rtl] contexts.
  ///
  /// The `allowDrawingOutsideOfViewBox` parameter should be used with caution -
  /// if set to true, it will not clip the canvas used internally to the view box,
  /// meaning the picture may draw beyond the intended area and lead to undefined
  /// behavior or additional memory overhead.
  ///
  /// A custom `placeholderBuilder` can be specified for cases where decoding or
  /// acquiring data may take a noticeably long time.
  ///
  /// The `color` and `colorBlendMode` arguments, if specified, will be used to set a
  /// [ColorFilter] on any [Paint]s created for this drawing.
  ///
  /// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
  SvgPicture.string(
    String bytes, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.matchTextDirection = false,
    this.allowDrawingOutsideViewBox = false,
    this.placeholderBuilder,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.clipBehavior = Clip.hardEdge,
    this.cacheColorFilter = false,
  })  : pictureProvider = StringPicture(
          allowDrawingOutsideViewBox == true
              ? svgStringDecoderOutsideViewBox
              : svgStringDecoder,
          bytes,
          colorFilter: svg.cacheColorFilterOverride ?? cacheColorFilter
              ? _getColorFilter(color, colorBlendMode)
              : null,
        ),
        colorFilter = _getColorFilter(color, colorBlendMode),
        super(key: key);

  /// The default placeholder for a SVG that may take time to parse or
  /// retrieve, e.g. from a network location.
  static WidgetBuilder defaultPlaceholderBuilder =
      (BuildContext ctx) => const LimitedBox();

  static ColorFilter? _getColorFilter(Color? color, BlendMode colorBlendMode) =>
      color == null ? null : ColorFilter.mode(color, colorBlendMode);

  /// A [PictureInfoDecoder] for [Uint8List]s that will clip to the viewBox.
  static final PictureInfoDecoder<Uint8List> svgByteDecoder =
      (Uint8List bytes, ColorFilter? colorFilter, String key) =>
          svg.svgPictureDecoder(bytes, false, colorFilter, key);

  /// A [PictureInfoDecoder] for strings that will clip to the viewBox.
  static final PictureInfoDecoder<String> svgStringDecoder =
      (String data, ColorFilter? colorFilter, String key) =>
          svg.svgPictureStringDecoder(data, false, colorFilter, key);

  /// A [PictureInfoDecoder] for [Uint8List]s that will not clip to the viewBox.
  static final PictureInfoDecoder<Uint8List> svgByteDecoderOutsideViewBox =
      (Uint8List bytes, ColorFilter? colorFilter, String key) =>
          svg.svgPictureDecoder(bytes, true, colorFilter, key);

  /// A [PictureInfoDecoder] for [String]s that will not clip to the viewBox.
  static final PictureInfoDecoder<String> svgStringDecoderOutsideViewBox =
      (String data, ColorFilter? colorFilter, String key) =>
          svg.svgPictureStringDecoder(data, true, colorFilter, key);

  /// If specified, the width to use for the SVG.  If unspecified, the SVG
  /// will take the width of its parent.
  final double? width;

  /// If specified, the height to use for the SVG.  If unspecified, the SVG
  /// will take the height of its parent.
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

  /// The [PictureProvider] used to resolve the SVG.
  final PictureProvider pictureProvider;

  /// The placeholder to use while fetching, decoding, and parsing the SVG data.
  final WidgetBuilder? placeholderBuilder;

  /// If true, will horizontally flip the picture in [TextDirection.rtl] contexts.
  final bool matchTextDirection;

  /// If true, will allow the SVG to be drawn outside of the clip boundary of its
  /// viewBox.
  final bool allowDrawingOutsideViewBox;

  /// The [Semantics.label] for this picture.
  ///
  /// The value indicates the purpose of the picture, and will be
  /// read out by screen readers.
  final String? semanticsLabel;

  /// Whether to exclude this picture from semantics.
  ///
  /// Useful for pictures which do not contribute meaningful information to an
  /// application.
  final bool excludeFromSemantics;

  /// The content will be clipped (or not) according to this option.
  ///
  /// See the enum [Clip] for details of all possible options and their common
  /// use cases.
  ///
  /// Defaults to [Clip.hardEdge], and must not be null.
  final Clip clipBehavior;

  /// The color filter, if any, to apply to this widget.
  final ColorFilter? colorFilter;

  /// Whether to cache the picture with the [colorFilter] applied or not.
  ///
  /// This value should be set to true if the same SVG will be rendered with
  /// multiple colors, but false if it will always (or almost always) be
  /// rendered with the same [colorFilter].
  ///
  /// If [Svg.cacheColorFilterOverride] is not null, it will override this value
  /// for all widgets, regardless of what is specified for an individual widget.
  ///
  /// This defaults to false and must not be null.
  final bool cacheColorFilter;

  @override
  State<SvgPicture> createState() => _SvgPictureState();
}

class _SvgPictureState extends State<SvgPicture> {
  PictureInfo? _picture;
  PictureStream? _pictureStream;
  bool _isListeningToStream = false;

  @override
  void didChangeDependencies() {
    _resolveImage();

    if (TickerMode.of(context)) {
      _listenToStream();
    } else {
      _stopListeningToStream();
    }
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SvgPicture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pictureProvider != oldWidget.pictureProvider) {
      _resolveImage();
    }
  }

  @override
  void reassemble() {
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  void _resolveImage() {
    final PictureStream newStream = widget.pictureProvider
        .resolve(createLocalPictureConfiguration(context));
    assert(newStream != null); // ignore: unnecessary_null_comparison
    _updateSourceStream(newStream);
  }

  void _handleImageChanged(PictureInfo? imageInfo, bool synchronousCall) {
    setState(() {
      _picture = imageInfo;
    });
  }

  // Update _pictureStream to newStream, and moves the stream listener
  // registration from the old stream to the new stream (if a listener was
  // registered).
  void _updateSourceStream(PictureStream newStream) {
    if (_pictureStream?.key == newStream.key) {
      return;
    }

    if (_isListeningToStream)
      _pictureStream!.removeListener(_handleImageChanged);

    _pictureStream = newStream;
    if (_isListeningToStream) {
      _pictureStream!.addListener(_handleImageChanged);
    }
  }

  void _listenToStream() {
    if (_isListeningToStream) {
      return;
    }
    _pictureStream!.addListener(_handleImageChanged);
    _isListeningToStream = true;
  }

  void _stopListeningToStream() {
    if (!_isListeningToStream) {
      return;
    }
    _pictureStream!.removeListener(_handleImageChanged);
    _isListeningToStream = false;
  }

  @override
  void dispose() {
    assert(_pictureStream != null);
    _stopListeningToStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late Widget child;
    if (_picture != null) {
      final Rect viewport = Offset.zero & _picture!.viewport.size;

      double? width = widget.width;
      double? height = widget.height;
      if (height != null && width == null) {
        width = height / viewport.height * viewport.width;
      } else if (height == null && width != null) {
        height = width / viewport.width * viewport.height;
      }

      child = FittedBox(
        fit: widget.fit,
        alignment: widget.alignment,
        clipBehavior: widget.clipBehavior,
        child: SizedBox.fromSize(
          size: viewport.size,
          child: RawPicture(
            _picture,
            matchTextDirection: widget.matchTextDirection,
            allowDrawingOutsideViewBox: widget.allowDrawingOutsideViewBox,
          ),
        ),
      );
      if (width != null && height != null) {
        child = SizedBox(
          width: width,
          height: height,
          child: child,
        );
      }

      if (widget.pictureProvider.colorFilter == null &&
          widget.colorFilter != null) {
        child = UnboundedColorFiltered(
          colorFilter: widget.colorFilter,
          child: child,
        );
      }
    } else {
      child = widget.placeholderBuilder == null
          ? _getDefaultPlaceholder(context, widget.width, widget.height)
          : widget.placeholderBuilder!(context);
    }
    if (!widget.excludeFromSemantics) {
      child = Semantics(
        container: widget.semanticsLabel != null,
        image: true,
        label: widget.semanticsLabel == null ? '' : widget.semanticsLabel,
        child: child,
      );
    }
    return child;
  }

  Widget _getDefaultPlaceholder(
      BuildContext context, double? width, double? height) {
    if (width != null || height != null) {
      return SizedBox(width: width, height: height);
    }

    return SvgPicture.defaultPlaceholderBuilder(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(
      DiagnosticsProperty<PictureStream>('stream', _pictureStream),
    );
  }
}
