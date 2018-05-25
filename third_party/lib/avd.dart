import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle, AssetBundle;
import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart' hide parse;
import 'package:xml/xml.dart' as xml show parse;

import 'src/avd/xml_parsers.dart';
import 'src/avd_parser.dart';
import 'src/vector_drawable.dart';
import 'vector_drawable.dart';

/// Extends [VectorDrawableImage] to parse SVG data to [Drawable].
class AvdImage extends VectorDrawableImage {
  const AvdImage._(Future<DrawableRoot> future, Size size,
      {Key key,
      PaintLocation paintLocation,
      ErrorWidgetBuilder errorWidgetBuilder,
      WidgetBuilder loadingPlaceholderBuilder})
      : super(future, size,
            key: key,
            paintLocation: paintLocation,
            errorWidgetBuilder: errorWidgetBuilder,
            loadingPlaceholderBuilder: loadingPlaceholderBuilder);

  factory AvdImage.fromString(String svg, Size size,
      {Key key,
      PaintLocation paintLocation = PaintLocation.background,
      ErrorWidgetBuilder errorWidgetBuilder,
      WidgetBuilder loadingPlaceholderBuilder}) {
    return new AvdImage._(
      new Future<DrawableRoot>.value(fromAvdString(svg, size)),
      size,
      key: key,
      paintLocation: paintLocation,
      errorWidgetBuilder: errorWidgetBuilder,
      loadingPlaceholderBuilder: loadingPlaceholderBuilder,
    );
  }

  factory AvdImage.asset(String assetName, Size size,
      {Key key,
      AssetBundle bundle,
      String package,
      PaintLocation paintLocation = PaintLocation.background,
      ErrorWidgetBuilder errorWidgetBuilder,
      WidgetBuilder loadingPlaceholderBuilder}) {
    return new AvdImage._(
      loadAsset(assetName, size, bundle: bundle, package: package),
      size,
      key: key,
      paintLocation: paintLocation,
      errorWidgetBuilder: errorWidgetBuilder,
      loadingPlaceholderBuilder: loadingPlaceholderBuilder,
    );
  }

  factory AvdImage.network(String uri, Size size,
      {Map<String, String> headers,
      Key key,
      PaintLocation paintLocation = PaintLocation.background,
      ErrorWidgetBuilder errorWidgetBuilder,
      WidgetBuilder loadingPlaceholderBuilder}) {
    return new AvdImage._(
      loadNetworkAsset(uri, size),
      size,
      key: key,
      paintLocation: paintLocation,
      errorWidgetBuilder: errorWidgetBuilder,
      loadingPlaceholderBuilder: loadingPlaceholderBuilder,
    );
  }
}

/// Creates a [DrawableRoot] from a string of SVG data.
DrawableRoot fromAvdString(String rawSvg, Size size) {
  final XmlElement svg = xml.parse(rawSvg).rootElement;
  final Rect viewBox = parseViewBox(svg);
  final List<Drawable> children = svg.children
      .where((XmlNode child) => child is XmlElement)
      .map((XmlNode child) => parseAvdElement(
          child,
          new Rect.fromPoints(
              Offset.zero, new Offset(size.width, size.height))))
      .toList();
  // todo : style on root
  return new DrawableRoot(
      viewBox, children, new DrawableDefinitionServer(), null);
}

/// Creates a [DrawableRoot] from a bundled asset.
Future<DrawableRoot> loadAsset(String assetName, Size size,
    {AssetBundle bundle, String package}) async {
  bundle ??= rootBundle;
  final String rawSvg = await bundle.loadString(
    package == null ? assetName : 'packages/$package/$assetName',
  );
  return fromAvdString(rawSvg, size);
}

final HttpClient _httpClient = new HttpClient();

/// Creates a [DrawableRoot] from a network asset with an HTTP get request.
Future<DrawableRoot> loadNetworkAsset(String url, Size size) async {
  final Uri uri = Uri.base.resolve(url);
  final HttpClientRequest request = await _httpClient.getUrl(uri);
  final HttpClientResponse response = await request.close();
  if (response.statusCode != HttpStatus.OK)
    throw new HttpException('Could not get network SVG asset', uri: uri);
  final String rawSvg = await _consolidateHttpClientResponse(response);
  return fromAvdString(rawSvg, size);
}

Future<String> _consolidateHttpClientResponse(
    HttpClientResponse response) async {
  final Completer<String> completer = new Completer<String>.sync();
  final StringBuffer buffer = new StringBuffer();

  response.transform(utf8.decoder).listen((String chunk) {
    buffer.write(chunk);
  }, onDone: () {
    // There's a bug right now where sometimes GZIP encoded payloads aren't coming all the way through..
    completer.complete(buffer.toString());
  }, onError: completer.completeError, cancelOnError: true);

  return completer.future;
}
