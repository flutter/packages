import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle, AssetBundle;
import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart' hide parse;
import 'package:xml/xml.dart' as xml show parse;

import 'src/vector_painter.dart';
import 'src/svg_parser.dart';
import 'src/svg/xml_parsers.dart';

enum PaintLocation { Foreground, Background }

/// Handles rendering [Drawables] to a canvas.
class VectorDrawableImage extends StatelessWidget {
  final Size size;
  final Future<DrawableRoot> future;
  final bool clipToViewBox;
  final PaintLocation paintLocation;

  const VectorDrawableImage._(this.future, this.size,
      {this.clipToViewBox = true,
      Key key,
      this.paintLocation = PaintLocation.Background})
      : super(key: key);

  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: future,
      builder: ((context, snapShot) {
        if (snapShot.hasData) {
          final CustomPainter painter =
              new VectorPainter(snapShot.data, clipToViewBox: clipToViewBox);
          return new RepaintBoundary.wrap(
              CustomPaint(
                painter:
                    paintLocation == PaintLocation.Background ? painter : null,
                foregroundPainter:
                    paintLocation == PaintLocation.Foreground ? painter : null,
                size: size,
                isComplex: true,
                willChange: false,
              ),
              0);
        }
        return new LimitedBox();
      }),
    );
  }
}

/// Extends [VectorDrawableImage] to parse SVG data to [Drawable].
class SvgImage extends VectorDrawableImage {
  SvgImage._(Future<DrawableRoot> future, Size size,
      {bool clipToViewBox, Key key, PaintLocation paintLocation})
      : super._(future, size,
            clipToViewBox: clipToViewBox,
            key: key,
            paintLocation: paintLocation);

  factory SvgImage.fromString(String svg, Size size,
      {Key key,
      bool clipToViewBox = true,
      PaintLocation paintLocation = PaintLocation.Background}) {
    return new SvgImage._(
      new Future.value(fromSvgString(svg, size)),
      size,
      clipToViewBox: clipToViewBox,
      key: key,
      paintLocation: paintLocation,
    );
  }

  factory SvgImage.asset(String assetName, Size size,
      {Key key,
      AssetBundle bundle,
      String package,
      bool clipToViewBox = true,
      PaintLocation paintLocation = PaintLocation.Background}) {
    return new SvgImage._(
      loadAsset(assetName, size, bundle: bundle, package: package),
      size,
      clipToViewBox: clipToViewBox,
      key: key,
      paintLocation: paintLocation,
    );
  }

  factory SvgImage.network(String uri, Size size,
      {Map<String, String> headers,
      Key key,
      bool clipToViewBox = true,
      PaintLocation paintLocation = PaintLocation.Background}) {
    return new SvgImage._(
      loadNetworkAsset(uri, size),
      size,
      clipToViewBox: clipToViewBox,
      key: key,
      paintLocation: paintLocation,
    );
  }
}

/// Creates a [DrawableRoot] from a string of SVG data.
DrawableRoot fromSvgString(String rawSvg, Size size) {
  final XmlElement svg = xml.parse(rawSvg).rootElement;
  final Rect viewBox = parseViewBox(svg);
  Map<String, PaintServer> paintServers = <String, PaintServer>{};
  final List<Drawable> children = svg.children
      .where((XmlNode child) => child is XmlElement)
      .map((XmlNode child) => parseSvgElement(child, paintServers, size))
      .toList();
  return new DrawableRoot(viewBox, children, <String, PaintServer>{});
}

/// Creates a [DrawableRoot] from a bundled asset.
Future<DrawableRoot> loadAsset(String assetName, Size size,
    {AssetBundle bundle, String package}) async {
  bundle ??= rootBundle;
  final String rawSvg = await bundle.loadString(
    package == null ? assetName : 'packages/$package/$assetName',
  );
  return fromSvgString(rawSvg, size);
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
  return fromSvgString(rawSvg, size);
}

Future<String> _consolidateHttpClientResponse(
    HttpClientResponse response) async {
  final Completer<String> completer = new Completer<String>.sync();
  final StringBuffer buffer = new StringBuffer();

  response.transform(utf8.decoder).listen((String chunk) {
    buffer.write(chunk);
  }, onDone: () {
    print(buffer.toString());
    completer.complete(buffer.toString());
  }, onError: completer.completeError, cancelOnError: true);

  return completer.future;
}
