import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle, AssetBundle;
import 'package:flutter/widgets.dart';

import 'package:flutter_svg/src/svg_painter.dart';

import 'package:xml/xml.dart';

class SvgImage extends StatelessWidget {
  final Size size;
  final Future<XmlDocument> future;
  final bool clipToViewBox;

  const SvgImage._(this.future, this.size, {this.clipToViewBox = true, Key key})
      : super(key: key);

  factory SvgImage.asset(String assetName, Size size,
      {Key key, AssetBundle bundle, String package}) {
    return new SvgImage._(
      loadAsset(assetName, bundle, package),
      size,
      key: key,
    );
  }

  factory SvgImage.network(String uri, Size size,
      {Map<String, String> headers, Key key}) {
    return new SvgImage._(
      loadNetworkAsset(uri, headers),
      size,
      key: key,
    );
  }

  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: future,
      builder: ((context, snapShot) {
        if (snapShot.hasData) {
          return new CustomPaint(
              painter:
                  new SvgPainter(snapShot.data, clipToViewBox: clipToViewBox),
              size: size);
        }
        return new LimitedBox();
      }),
    );
  }
}

Future<XmlDocument> loadAsset(String assetName,
    [AssetBundle bundle, String package]) async {
  bundle ??= rootBundle;
  final xml = await bundle
      .loadString(package == null ? assetName : 'packages/$package/$assetName');
  return parse(xml);
}

final HttpClient _httpClient = new HttpClient();

Future<XmlDocument> loadNetworkAsset(
  String uri,
  Map<String, String> headers,
) async {
  final Uri resolved = Uri.base.resolve(uri);
  print('trying $resolved');
  final HttpClientRequest request = await _httpClient.getUrl(resolved);
  headers?.forEach((String name, String value) {
    request.headers.add(name, value);
  });
  request.headers.removeAll(HttpHeaders.ACCEPT_ENCODING);
  final HttpClientResponse response = await request.close();
  if (response.statusCode != HttpStatus.OK) {
    throw new Exception(
        'HTTP request failed, statusCode: ${response?.statusCode}, $resolved');
  }

  final String xml = await consolidateHttpClientResponse(response);
  if (xml.length == 0)
    throw new Exception('NetworkImage is an empty file: $resolved');

  print('$resolved headers: ${response.headers}');
  print(xml);
  assert(xml.endsWith('</svg>'));
  return parse(xml);
}

Future<String> consolidateHttpClientResponse(HttpClientResponse response) {
  final Completer<String> completer = new Completer<String>.sync();
  final StringBuffer buffer = new StringBuffer();

  response.transform(utf8.decoder).listen((String chunk) {
    buffer.write(chunk);
  }, onDone: () {
    completer.complete(buffer.toString());
  }, onError: completer.completeError, cancelOnError: true);

  return completer.future;
}
