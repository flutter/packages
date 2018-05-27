import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Picture;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle, AssetBundle;
import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart' hide parse;
import 'package:xml/xml.dart' as xml show parse;

import 'src/picture_provider.dart';
import 'src/picture_stream.dart';
import 'src/render_picture.dart';
import 'src/svg/xml_parsers.dart';
import 'src/svg_parser.dart';
import 'src/vector_drawable.dart';
import 'vector_drawable.dart';

@deprecated

/// Extends [VectorDrawableImage] to parse SVG data to [Drawable].
class SvgImage extends VectorDrawableImage {
  const SvgImage._(Future<DrawableRoot> future, Size size,
      {Key key,
      Widget child,
      PaintLocation paintLocation,
      ErrorWidgetBuilder errorWidgetBuilder,
      WidgetBuilder loadingPlaceholderBuilder,
      Color color,
      BlendMode colorBlendMode})
      : super(future, size,
            child: child,
            key: key,
            paintLocation: paintLocation,
            errorWidgetBuilder: errorWidgetBuilder,
            loadingPlaceholderBuilder: loadingPlaceholderBuilder,
            color: color,
            colorBlendMode: colorBlendMode);

  factory SvgImage.fromString(String svgString, Size size,
      {Key key,
      PaintLocation paintLocation = PaintLocation.background,
      Widget child,
      ErrorWidgetBuilder errorWidgetBuilder,
      WidgetBuilder loadingPlaceholderBuilder,
      Color color,
      BlendMode colorBlendMode}) {
    return new SvgImage._(
      new Future<DrawableRoot>.value(svg.fromSvgString(svgString)),
      size,
      child: child,
      key: key,
      paintLocation: paintLocation,
      errorWidgetBuilder: errorWidgetBuilder,
      loadingPlaceholderBuilder: loadingPlaceholderBuilder,
      color: color,
      colorBlendMode: colorBlendMode,
    );
  }

  /// Creates an [SvgImage] from a bundled asset (possibly from a [package]).
  factory SvgImage.asset(String assetName, Size size,
      {Key key,
      AssetBundle bundle,
      String package,
      PaintLocation paintLocation = PaintLocation.background,
      Widget child,
      ErrorWidgetBuilder errorWidgetBuilder,
      WidgetBuilder loadingPlaceholderBuilder,
      Color color,
      BlendMode colorBlendMode}) {
    return new SvgImage._(
      svg.loadAsset(assetName, bundle: bundle, package: package),
      size,
      child: child,
      key: key,
      paintLocation: paintLocation,
      errorWidgetBuilder: errorWidgetBuilder,
      loadingPlaceholderBuilder: loadingPlaceholderBuilder,
      color: color,
      colorBlendMode: colorBlendMode,
    );
  }

  /// Creates an [SvgImage] from a HTTP [uri].
  factory SvgImage.network(String uri, Size size,
      {Map<String, String> headers,
      Key key,
      Widget child,
      PaintLocation paintLocation = PaintLocation.background,
      ErrorWidgetBuilder errorWidgetBuilder,
      WidgetBuilder loadingPlaceholderBuilder,
      Color color,
      BlendMode colorBlendMode}) {
    return new SvgImage._(
      svg.loadNetworkAsset(uri,
          colorFilter: ColorFilter.mode(color, colorBlendMode)),
      size,
      child: child,
      key: key,
      paintLocation: paintLocation,
      errorWidgetBuilder: errorWidgetBuilder,
      loadingPlaceholderBuilder: loadingPlaceholderBuilder,
    );
  }
}

final Svg svg = new Svg._();

class Svg {
  Svg._();

  FutureOr<PictureInfo> svgPictureDecoder(Uint8List raw) async {
    final DrawableRoot svgRoot = await fromSvgBytes(raw);
    final Picture pic = svgRoot.toPicture();
    return new PictureInfo(picture: pic, viewBox: svgRoot.viewBox);
  }

  FutureOr<PictureInfo> svgPictureStringDecoder(String raw) {
    final DrawableRoot svg = fromSvgString(raw);
    return new PictureInfo(picture: svg.toPicture(), viewBox: svg.viewBox);
  }

  FutureOr<DrawableRoot> fromSvgBytes(Uint8List raw) async {
    // TODO - do utf decoding in another thread?
    // Might just have to live with potentially slow(ish) decoding, this is causing errors.
    // See: https://github.com/dart-lang/sdk/issues/31954
    // See: https://github.com/flutter/flutter/blob/bf3bd7667f07709d0b817ebfcb6972782cfef637/packages/flutter/lib/src/services/asset_bundle.dart#L66
    // if (raw.lengthInBytes < 20 * 1024) {
    return fromSvgString(utf8.decode(raw));
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
  DrawableRoot fromSvgString(String rawSvg) {
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

  /// Creates a [DrawableRoot] from a bundled asset.
  @deprecated
  Future<DrawableRoot> loadAsset(String assetName,
      {AssetBundle bundle, String package}) async {
    bundle ??= rootBundle;
    final String rawSvg = await bundle.loadString(
      package == null ? assetName : 'packages/$package/$assetName',
    );
    return fromSvgString(rawSvg);
  }

  @deprecated
  final HttpClient _httpClient = new HttpClient();

  /// Creates a [DrawableRoot] from a network asset with an HTTP get request.
  @deprecated
  Future<DrawableRoot> loadNetworkAsset(String url,
      {ColorFilter colorFilter}) async {
    final Uri uri = Uri.base.resolve(url);
    final HttpClientRequest request = await _httpClient.getUrl(uri);
    final HttpClientResponse response = await request.close();

    if (response.statusCode != HttpStatus.OK) {
      throw new HttpException('Could not get network SVG asset', uri: uri);
    }
    final String rawSvg = await _consolidateHttpClientResponse(response);

    return fromSvgString(rawSvg);
  }

  @deprecated
  Future<String> _consolidateHttpClientResponse(
      HttpClientResponse response) async {
    final Completer<String> completer = new Completer<String>.sync();
    final StringBuffer buffer = new StringBuffer();

    response.transform(utf8.decoder).listen((String chunk) {
      buffer.write(chunk);
    }, onDone: () {
      completer.complete(buffer.toString());
    }, onError: completer.completeError, cancelOnError: true);

    return completer.future;
  }
}

class SvgPicture extends StatefulWidget {
  const SvgPicture(this.pictureProvider,
      {Key key,
      this.matchTextDirection = false,
      this.allowDrawingOutsideViewBox = false})
      : super(key: key);

  SvgPicture.asset(String assetName,
      {Key key,
      this.matchTextDirection = false,
      AssetBundle bundle,
      String package,
      this.allowDrawingOutsideViewBox = false})
      : pictureProvider = new ExactAssetPicture(svgByteDecoder, assetName,
            bundle: bundle, package: package),
        super(key: key);

  SvgPicture.network(String url,
      {Key key,
      Map<String, String> headers,
      this.matchTextDirection = false,
      this.allowDrawingOutsideViewBox = false})
      : pictureProvider =
            new NetworkPicture(svgByteDecoder, url, headers: headers),
        super(key: key);

  SvgPicture.file(File file,
      {Key key,
      this.matchTextDirection = false,
      this.allowDrawingOutsideViewBox = false})
      : pictureProvider = new FilePicture(svgByteDecoder, file),
        super(key: key);

  SvgPicture.memory(Uint8List bytes,
      {Key key,
      this.matchTextDirection = false,
      this.allowDrawingOutsideViewBox = false})
      : pictureProvider = new MemoryPicture(svgByteDecoder, bytes),
        super(key: key);

  static final PictureInfoDecoder<Uint8List> svgByteDecoder =
      (Uint8List bytes) => svg.svgPictureDecoder(bytes);
  static final PictureInfoDecoder<String> svgStringDecoder =
      (String bytes) => svg.svgPictureStringDecoder(bytes);

  final PictureProvider pictureProvider;
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
    final PictureStream newStream = widget.pictureProvider.resolve(null);
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
    return new RawPicture(
      _picture,
      matchTextDirection: widget.matchTextDirection,
      allowDrawingOutsideViewBox: widget.allowDrawingOutsideViewBox,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description
        .add(new DiagnosticsProperty<PictureStream>('stream', _pictureStream));
  }
}
