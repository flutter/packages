import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show Picture;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart';

import 'src/avd/xml_parsers.dart';
import 'src/avd_parser.dart';
import 'src/picture_provider.dart';
import 'src/picture_stream.dart';
import 'src/render_picture.dart';
import 'src/unbounded_color_filtered.dart';
import 'src/vector_drawable.dart';

/// Instance for [Avd]'s utility methods, which can produce [DrawableRoot] or
/// [PictureInfo] objects from [String] and [Uint8List]s.
final Avd avd = Avd._();

/// A set of helper methods for decoding Android Vector Drawables to [Drawable].
///
/// AVD support is experimental and very incomplete. Use at your own risk.
class Avd {
  Avd._();

  /// Decodes an Android Vector Drawable from a [Uint8List] to a [PictureInfo]
  /// object.
  Future<PictureInfo> avdPictureDecoder(
      Uint8List raw,
      bool allowDrawingOutsideOfViewBox,
      ColorFilter? colorFilter,
      String key) async {
    final DrawableRoot avdRoot = await fromAvdBytes(raw, key);
    final Picture pic = avdRoot.toPicture(
        clipToViewBox: allowDrawingOutsideOfViewBox == true ? false : true,
        colorFilter: colorFilter);
    return PictureInfo(picture: pic, viewport: avdRoot.viewport.viewBoxRect);
  }

  /// Decodes an Android Vector Drawable from a [String] to a [PictureInfo]
  /// object.
  Future<PictureInfo> avdPictureStringDecoder(
    String raw,
    bool allowDrawingOutsideOfViewBox,
    ColorFilter? colorFilter,
    String key,
  ) async {
    final DrawableRoot avd = fromAvdString(raw, key);
    return PictureInfo(
      picture: avd.toPicture(
          clipToViewBox: allowDrawingOutsideOfViewBox == true ? false : true,
          colorFilter: colorFilter),
      viewport: avd.viewport.viewBoxRect,
      size: avd.viewport.size,
    );
  }

  /// Produces a [Drawableroot] from a [Uint8List] of AVD byte data (assumes
  /// UTF8 encoding).
  ///
  /// The `key` parameter is used for debugging purposes.
  Future<DrawableRoot> fromAvdBytes(Uint8List raw, String key) async {
    // TODO(dnfield): do utf decoding in another thread?
    // Might just have to live with potentially slow(ish) decoding, this is causing errors.
    // See: https://github.com/dart-lang/sdk/issues/31954
    // See: https://github.com/flutter/flutter/blob/bf3bd7667f07709d0b817ebfcb6972782cfef637/packages/flutter/lib/src/services/asset_bundle.dart#L66
    // if (raw.lengthInBytes < 20 * 1024) {
    return fromAvdString(utf8.decode(raw), key);
    // } else {
    //   final String str =
    //       await compute(_utf8Decode, raw, debugLabel: 'UTF8 decode for SVG');
    //   return fromSvgString(str);
    // }
  }

  // String _utf8Decode(Uint8List data) {
  //   return utf8.decode(data);
  // }

  /// Creates a [DrawableRoot] from a string of Android Vector Drawable data.
  DrawableRoot fromAvdString(String rawSvg, String key) {
    final XmlElement svg = XmlDocument.parse(rawSvg).rootElement;
    final DrawableViewport viewBox = parseViewBox(svg.attributes);
    final List<Drawable> children = svg.children
        .whereType<XmlElement>()
        .map((XmlElement child) => parseAvdElement(child, viewBox.viewBoxRect))
        .toList();
    // todo : style on root
    return DrawableRoot(getAttribute(svg.attributes, 'id', def: ''), viewBox,
        children, DrawableDefinitionServer(), null);
  }
}

/// A widget that draws Android Vector Drawable data into a [Picture] using a
/// [PictureProvider].
///
/// Support for AVD is incomplete and experimental at this time.
class AvdPicture extends StatefulWidget {
  /// Instantiates a widget that renders an AVD picture using the `pictureProvider`.
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
  const AvdPicture(
    this.pictureProvider, {
    Key? key,
    this.matchTextDirection = false,
    this.allowDrawingOutsideViewBox = false,
    this.placeholderBuilder,
    this.colorFilter,
  }) : super(key: key);

  /// Draws an [AvdPicture] from a raw string of XML.
  AvdPicture.string(String bytes,
      {bool matchTextDirection = false,
      bool allowDrawingOutsideViewBox = false,
      WidgetBuilder? placeholderBuilder,
      Color? color,
      BlendMode colorBlendMode = BlendMode.srcIn,
      Key? key})
      : this(
            StringPicture(
              allowDrawingOutsideViewBox == true
                  ? (_) => avdStringDecoderOutsideViewBox
                  : (_) => avdStringDecoder,
              bytes,
            ),
            colorFilter: _getColorFilter(color, colorBlendMode),
            matchTextDirection: matchTextDirection,
            allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
            placeholderBuilder: placeholderBuilder,
            key: key);

  /// Draws an [AvdPicture] from an asset.
  AvdPicture.asset(String assetName,
      {Key? key,
      bool matchTextDirection = false,
      AssetBundle? bundle,
      String? package,
      bool allowDrawingOutsideViewBox = false,
      WidgetBuilder? placeholderBuilder,
      Color? color,
      BlendMode colorBlendMode = BlendMode.srcIn})
      : this(
            ExactAssetPicture(
              allowDrawingOutsideViewBox == true
                  ? (_) => avdStringDecoderOutsideViewBox
                  : (_) => avdStringDecoder,
              assetName,
              bundle: bundle,
              package: package,
            ),
            colorFilter: _getColorFilter(color, colorBlendMode),
            matchTextDirection: matchTextDirection,
            allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
            placeholderBuilder: placeholderBuilder,
            key: key);

  /// The default placeholder for an AVD that may take time to parse or
  /// retrieve, e.g. from a network location.
  static WidgetBuilder defaultPlaceholderBuilder =
      (BuildContext ctx) => const LimitedBox();

  static ColorFilter? _getColorFilter(Color? color, BlendMode colorBlendMode) =>
      color == null ? null : ColorFilter.mode(color, colorBlendMode);

  /// A [PictureInfoDecoder] for [Uint8List]s that will clip to the viewBox.
  static final PictureInfoDecoder<Uint8List> avdByteDecoder =
      (Uint8List bytes, ColorFilter? colorFilter, String key) =>
          avd.avdPictureDecoder(bytes, false, colorFilter, key);

  /// A [PictureInfoDecoder] for strings that will clip to the viewBox.
  static final PictureInfoDecoder<String> avdStringDecoder =
      (String data, ColorFilter? colorFilter, String key) =>
          avd.avdPictureStringDecoder(data, false, colorFilter, key);

  /// A [PictureInfoDecoder] for [Uint8List]s that will not clip to the viewBox.
  static final PictureInfoDecoder<Uint8List> avdByteDecoderOutsideViewBox =
      (Uint8List bytes, ColorFilter? colorFilter, String key) =>
          avd.avdPictureDecoder(bytes, true, colorFilter, key);

  /// A [PictureInfoDecoder] for [String]s that will not clip to the viewBox.
  static final PictureInfoDecoder<String> avdStringDecoderOutsideViewBox =
      (String data, ColorFilter? colorFilter, String key) =>
          avd.avdPictureStringDecoder(data, true, colorFilter, key);

  /// The [PictureProvider] used to resolve the AVD.
  final PictureProvider pictureProvider;

  /// The placeholder to use while fetching, decoding, and parsing the AVD data.
  final WidgetBuilder? placeholderBuilder;

  /// If true, will horizontally flip the picture in [TextDirection.rtl] contexts.
  final bool matchTextDirection;

  /// If true, will allow the AVD to be drawn outside of the clip boundary of its
  /// viewBox.
  final bool allowDrawingOutsideViewBox;

  /// The color filter, if any, to apply to this widget.
  final ColorFilter? colorFilter;

  @override
  State<StatefulWidget> createState() => _AvdPictureState();
}

class _AvdPictureState extends State<AvdPicture> {
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
  void didUpdateWidget(AvdPicture oldWidget) {
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

      child = SizedBox(
        width: viewport.width,
        height: viewport.height,
        child: FittedBox(
          clipBehavior: Clip.hardEdge,
          child: SizedBox.fromSize(
            size: viewport.size,
            child: RawPicture(
              _picture,
              matchTextDirection: widget.matchTextDirection,
              allowDrawingOutsideViewBox: widget.allowDrawingOutsideViewBox,
            ),
          ),
        ),
      );

      if (widget.pictureProvider.colorFilter == null &&
          widget.colorFilter != null) {
        child = UnboundedColorFiltered(
          colorFilter: widget.colorFilter,
          child: child,
        );
      }
    } else {
      child = AvdPicture.defaultPlaceholderBuilder(context);
    }
    return child;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(
      DiagnosticsProperty<PictureStream>('stream', _pictureStream),
    );
  }
}
