import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Picture;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetBundle;
import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart' hide parse;
import 'package:xml/xml.dart' as xml show parse;

import 'src/picture_provider.dart';
import 'src/picture_stream.dart';
import 'src/render_picture.dart';
import 'src/svg/xml_parsers.dart';
import 'src/svg_parser.dart';
import 'src/vector_drawable.dart';

final Svg svg = new Svg._();

class Svg {
  Svg._();

  FutureOr<PictureInfo> svgPictureDecoder(Uint8List raw,
      bool allowDrawingOutsideOfViewBox, ColorFilter colorFilter, String key) async {
    final DrawableRoot svgRoot = await fromSvgBytes(raw, key);
    final Picture pic = svgRoot.toPicture(
        clipToViewBox: allowDrawingOutsideOfViewBox == true ? false : true,
        colorFilter: colorFilter);
    return new PictureInfo(picture: pic, viewBox: svgRoot.viewBox);
  }

  FutureOr<PictureInfo> svgPictureStringDecoder(
      String raw, bool allowDrawingOutsideOfViewBox, ColorFilter colorFilter, String key) {
    final DrawableRoot svg = fromSvgString(raw, key);
    return new PictureInfo(
        picture: svg.toPicture(
            clipToViewBox: allowDrawingOutsideOfViewBox == true ? false : true,
            colorFilter: colorFilter),
        viewBox: svg.viewBox);
  }

  FutureOr<DrawableRoot> fromSvgBytes(Uint8List raw, String key) async {
    // TODO - do utf decoding in another thread?
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
  DrawableRoot fromSvgString(String rawSvg, String key) {
    final XmlElement svg = xml.parse(rawSvg).rootElement;
    final Rect viewBox = parseViewBox(svg);
    //final Map<String, PaintServer> paintServers = <String, PaintServer>{};
    final DrawableDefinitionServer definitions = new DrawableDefinitionServer();
    final DrawableStyle style = parseStyle(svg, definitions, viewBox, null);

    final List<Drawable> children = svg.children
        .where((XmlNode child) => child is XmlElement)
        .map(
          (XmlNode child) => parseSvgElement(
                child,
                definitions,
                viewBox,
                style,
                key,
              ),
        )
        .toList();
    return new DrawableRoot(
      viewBox,
      children,
      definitions,
      parseStyle(svg, definitions, viewBox, null),
    );
  }
}

class SvgPicture extends StatefulWidget {
  static WidgetBuilder defaultPlaceholderBuilder =
      (BuildContext ctx) => const LimitedBox();

  const SvgPicture(this.pictureProvider,
      {Key key,
      this.matchTextDirection = false,
      this.allowDrawingOutsideViewBox = false,
      this.placeholderBuilder})
      : super(key: key);

  SvgPicture.asset(String assetName,
      {Key key,
      this.matchTextDirection = false,
      AssetBundle bundle,
      String package,
      this.allowDrawingOutsideViewBox = false,
      this.placeholderBuilder,
      Color color,
      BlendMode colorBlendMode = BlendMode.srcIn})
      : pictureProvider = new ExactAssetPicture(
            allowDrawingOutsideViewBox == true
                ? svgByteDecoderOutsideViewBox
                : svgByteDecoder,
            assetName,
            bundle: bundle,
            package: package,
            colorFilter: _getColorFilter(color, colorBlendMode)),
        super(key: key);

  SvgPicture.network(String url,
      {Key key,
      Map<String, String> headers,
      this.matchTextDirection = false,
      this.allowDrawingOutsideViewBox = false,
      this.placeholderBuilder,
      Color color,
      BlendMode colorBlendMode = BlendMode.srcIn})
      : pictureProvider = new NetworkPicture(
            allowDrawingOutsideViewBox == true
                ? svgByteDecoderOutsideViewBox
                : svgByteDecoder,
            url,
            headers: headers,
            colorFilter: _getColorFilter(color, colorBlendMode)),
        super(key: key);

  SvgPicture.file(File file,
      {Key key,
      this.matchTextDirection = false,
      this.allowDrawingOutsideViewBox = false,
      this.placeholderBuilder,
      Color color,
      BlendMode colorBlendMode = BlendMode.srcIn})
      : pictureProvider = new FilePicture(
            allowDrawingOutsideViewBox == true
                ? svgByteDecoderOutsideViewBox
                : svgByteDecoder,
            file,
            colorFilter: _getColorFilter(color, colorBlendMode)),
        super(key: key);

  SvgPicture.memory(Uint8List bytes,
      {Key key,
      this.matchTextDirection = false,
      this.allowDrawingOutsideViewBox = false,
      this.placeholderBuilder,
      Color color,
      BlendMode colorBlendMode = BlendMode.srcIn})
      : pictureProvider = new MemoryPicture(
            allowDrawingOutsideViewBox == true
                ? svgByteDecoderOutsideViewBox
                : svgByteDecoder,
            bytes,
            colorFilter: _getColorFilter(color, colorBlendMode)),
        super(key: key);

  SvgPicture.string(String bytes,
      {Key key,
      this.matchTextDirection = false,
      this.allowDrawingOutsideViewBox = false,
      this.placeholderBuilder,
      Color color,
      BlendMode colorBlendMode = BlendMode.srcIn})
      : pictureProvider = new StringPicture(
            allowDrawingOutsideViewBox == true
                ? svgStringDecoderOutsideViewBox
                : svgStringDecoder,
            bytes,
            colorFilter: _getColorFilter(color, colorBlendMode)),
        super(key: key);

  static ColorFilter _getColorFilter(Color color, BlendMode colorBlendMode) =>
      color == null
          ? null
          : new ColorFilter.mode(color, colorBlendMode ?? BlendMode.srcIn);

  static final PictureInfoDecoder<Uint8List> svgByteDecoder =
      (Uint8List bytes, ColorFilter colorFilter, String key) =>
          svg.svgPictureDecoder(bytes, false, colorFilter, key);
  static final PictureInfoDecoder<String> svgStringDecoder =
      (String data, ColorFilter colorFilter, String key) =>
          svg.svgPictureStringDecoder(data, false, colorFilter, key);
  static final PictureInfoDecoder<Uint8List> svgByteDecoderOutsideViewBox =
      (Uint8List bytes, ColorFilter colorFilter, String key) =>
          svg.svgPictureDecoder(bytes, true, colorFilter, key);
  static final PictureInfoDecoder<String> svgStringDecoderOutsideViewBox =
      (String data, ColorFilter colorFilter, String key) =>
          svg.svgPictureStringDecoder(data, true, colorFilter, key);

  final PictureProvider pictureProvider;
  final WidgetBuilder placeholderBuilder;
  final bool matchTextDirection;
  final bool allowDrawingOutsideViewBox;

  @override
  State<SvgPicture> createState() => new _SvgPictureState();
}

class _SvgPictureState extends State<SvgPicture> {
  PictureInfo _picture;
  PictureStream _pictureStream;
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
    assert(newStream != null);
    _updateSourceStream(newStream);
  }

  void _handleImageChanged(PictureInfo imageInfo, bool synchronousCall) {
    setState(() {
      _picture = imageInfo;
    });
  }

  // Update _pictureStream to newStream, and moves the stream listener
  // registration from the old stream to the new stream (if a listener was
  // registered).
  void _updateSourceStream(PictureStream newStream) {
    if (_pictureStream?.key == newStream?.key) {
      return;
    }

    if (_isListeningToStream)
      _pictureStream.removeListener(_handleImageChanged);

    _pictureStream = newStream;
    if (_isListeningToStream) {
      _pictureStream.addListener(_handleImageChanged);
    }
  }

  void _listenToStream() {
    if (_isListeningToStream) {
      return;
    }
    _pictureStream.addListener(_handleImageChanged);
    _isListeningToStream = true;
  }

  void _stopListeningToStream() {
    if (!_isListeningToStream) {
      return;
    }
    _pictureStream.removeListener(_handleImageChanged);
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
    if (_picture != null) {
      return new RawPicture(
        _picture,
        matchTextDirection: widget.matchTextDirection,
        allowDrawingOutsideViewBox: widget.allowDrawingOutsideViewBox,
      );
    }
    return widget.placeholderBuilder == null
        ? SvgPicture.defaultPlaceholderBuilder(context)
        : widget.placeholderBuilder(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description
        .add(new DiagnosticsProperty<PictureStream>('stream', _pictureStream));
  }
}
