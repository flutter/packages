import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle, AssetBundle;
import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart' hide parse;
import 'package:xml/xml.dart' as xml show parse;

import 'src/svg/xml_parsers.dart';
import 'src/svg_parser.dart';
import 'src/vector_painter.dart';
import 'vector_drawable.dart';

/// Extends [VectorDrawableImage] to parse SVG data to [Drawable].
class SvgImage extends VectorDrawableImage {
  const SvgImage._(Future<DrawableRoot> future, Size size,
      {bool clipToViewBox,
      Key key,
      Widget child,
      PaintLocation paintLocation,
      ErrorWidgetBuilder errorWidgetBuilder,
      WidgetBuilder loadingPlaceholderBuilder})
      : super(future, size,
            clipToViewBox: clipToViewBox,
            child: child,
            key: key,
            paintLocation: paintLocation,
            errorWidgetBuilder: errorWidgetBuilder,
            loadingPlaceholderBuilder: loadingPlaceholderBuilder);

  factory SvgImage.fromString(String svg, Size size,
      {Key key,
      bool clipToViewBox = true,
      PaintLocation paintLocation = PaintLocation.background,
      Widget child,
      ErrorWidgetBuilder errorWidgetBuilder,
      WidgetBuilder loadingPlaceholderBuilder,
      ColorReplacer colorReplacer}) {
    return new SvgImage._(
      new Future<DrawableRoot>.value(
          fromSvgString(svg, size, colorReplacer: colorReplacer)),
      size,
      clipToViewBox: clipToViewBox,
      child: child,
      key: key,
      paintLocation: paintLocation,
      errorWidgetBuilder: errorWidgetBuilder,
      loadingPlaceholderBuilder: loadingPlaceholderBuilder,
    );
  }

  /// Creates an [SvgImage] from a bundled asset (possibly from a [package]).
  factory SvgImage.asset(String assetName, Size size,
      {Key key,
      AssetBundle bundle,
      String package,
      bool clipToViewBox = true,
      PaintLocation paintLocation = PaintLocation.background,
      Widget child,
      ErrorWidgetBuilder errorWidgetBuilder,
      WidgetBuilder loadingPlaceholderBuilder,
      ColorReplacer colorReplacer}) {
    return new SvgImage._(
      loadAsset(assetName, size,
          bundle: bundle, package: package, colorReplacer: colorReplacer),
      size,
      clipToViewBox: clipToViewBox,
      child: child,
      key: key,
      paintLocation: paintLocation,
      errorWidgetBuilder: errorWidgetBuilder,
      loadingPlaceholderBuilder: loadingPlaceholderBuilder,
    );
  }

  /// Creates an [SvgImage] from a HTTP [uri].
  factory SvgImage.network(String uri, Size size,
      {Map<String, String> headers,
      Key key,
      bool clipToViewBox = true,
      Widget child,
      PaintLocation paintLocation = PaintLocation.background,
      ErrorWidgetBuilder errorWidgetBuilder,
      WidgetBuilder loadingPlaceholderBuilder,
      ColorReplacer colorReplacer}) {
    return new SvgImage._(
      loadNetworkAsset(uri, size, colorReplacer: colorReplacer),
      size,
      clipToViewBox: clipToViewBox,
      child: child,
      key: key,
      paintLocation: paintLocation,
      errorWidgetBuilder: errorWidgetBuilder,
      loadingPlaceholderBuilder: loadingPlaceholderBuilder,
    );
  }
}

/// Creates a [DrawableRoot] from a string of SVG data.  [size] specifies the
/// size of the coordinate space to draw to.
DrawableRoot fromSvgString(
  String rawSvg,
  Size size, {
  ColorReplacer colorReplacer,
}) {
  final XmlElement svg = xml.parse(rawSvg).rootElement;
  final Rect viewBox = parseViewBox(svg);
  //final Map<String, PaintServer> paintServers = <String, PaintServer>{};
  final DrawableDefinitionServer definitions =
      new DrawableDefinitionServer(colorReplacer: colorReplacer);
  final DrawableStyle style = parseStyle(svg, definitions, viewBox, null);

  final List<Drawable> children = svg.children
      .where((XmlNode child) => child is XmlElement)
      .map(
        (XmlNode child) => parseSvgElement(
              child,
              definitions,
              new Rect.fromPoints(
                Offset.zero,
                new Offset(size.width, size.height),
              ),
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

/// Creates a [DrawableRoot] from a bundled asset.  [size] specifies the size
/// of the coordinate space to draw to.
Future<DrawableRoot> loadAsset(
  String assetName,
  Size size, {
  ColorReplacer colorReplacer,
  AssetBundle bundle,
  String package,
}) async {
  bundle ??= rootBundle;
  final String rawSvg = await bundle.loadString(
    package == null ? assetName : 'packages/$package/$assetName',
  );
  return fromSvgString(rawSvg, size, colorReplacer: colorReplacer);
}

final HttpClient _httpClient = new HttpClient();

/// Creates a [DrawableRoot] from a network asset with an HTTP get request.
/// [size] specifies the size of the coordinate space to draw to.
Future<DrawableRoot> loadNetworkAsset(
  String url,
  Size size, {
  ColorReplacer colorReplacer,
}) async {
  final Uri uri = Uri.base.resolve(url);
  final HttpClientRequest request = await _httpClient.getUrl(uri);
  final HttpClientResponse response = await request.close();

  if (response.statusCode != HttpStatus.OK) {
    throw new HttpException('Could not get network SVG asset', uri: uri);
  }
  final String rawSvg = await _consolidateHttpClientResponse(response);

  return fromSvgString(rawSvg, size, colorReplacer: colorReplacer);
}

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
