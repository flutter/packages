import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle, AssetBundle;
import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart' as xml;

import 'src/vector_painter.dart';
import 'src/svg_parser.dart';
import 'src/svg/xml_parsers.dart';

enum PaintLocation { Foreground, Background }

class SvgImage extends StatelessWidget {
  final Size size;
  final Future<String> future;
  final bool clipToViewBox;
  final PaintLocation paintLocation;

  const SvgImage._(this.future, this.size,
      {this.clipToViewBox = true,
      Key key,
      this.paintLocation = PaintLocation.Background})
      : super(key: key);

  factory SvgImage.asset(String assetName, Size size,
      {Key key,
      AssetBundle bundle,
      String package,
      bool clipToViewBox = true,
      PaintLocation paintLocation = PaintLocation.Background}) {
    return new SvgImage._(
      loadAsset(assetName, bundle, package),
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
      loadNetworkAsset2(uri),
      size,
      clipToViewBox: clipToViewBox,
      key: key,
      paintLocation: paintLocation,
    );
  }

  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: future,
      builder: ((context, snapShot) {
        if (snapShot.hasData) {
          final xml.XmlElement svg = xml.parse(snapShot.data).rootElement;
          final Rect viewBox = parseViewBox(svg);
          Map<String, PaintServer> paintServers = <String, PaintServer>{};
          final List<Drawable> children = svg.children
              .where((xml.XmlNode child) => child is xml.XmlElement)
              .map((xml.XmlNode child) =>
                  parseSvgElement(child, paintServers, size))
              .toList();
          final DrawableRoot root = new DrawableRoot(viewBox, children);
          final CustomPainter painter = new VectorPainter(root, paintServers,
              clipToViewBox: clipToViewBox);
          return new CustomPaint(
              painter:
                  paintLocation == PaintLocation.Background ? painter : null,
              foregroundPainter:
                  paintLocation == PaintLocation.Foreground ? painter : null,
              size: size);
        }
        return new LimitedBox();
      }),
    );
  }
}

Future<String> loadAsset(String assetName,
    [AssetBundle bundle, String package]) async {
  bundle ??= rootBundle;
  return await bundle.loadString(
      package == null ? assetName : 'packages/$package/$assetName',
      cache: false);
}

final HttpClient _httpClient = new HttpClient();

Future<String> loadNetworkAsset2(String url) async {
  final Uri uri = Uri.base.resolve(url);
  final HttpClientRequest request = await _httpClient.getUrl(uri);
  final HttpClientResponse response = await request.close();
  if (response.statusCode != HttpStatus.OK)
    throw new HttpException('Could not get network SVG asset', uri: uri);
  return await consolidateHttpClientResponse(response);
}

Future<String> consolidateHttpClientResponse(
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
