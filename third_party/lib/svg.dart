import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle, AssetBundle;
import 'package:flutter/widgets.dart';

import 'src/svg_painter.dart';

class SvgImage extends StatelessWidget {
  final Size size;
  final Future<String> future;
  final bool clipToViewBox;

  const SvgImage._(this.future, this.size, {this.clipToViewBox = true, Key key})
      : super(key: key);

  factory SvgImage.asset(
    String assetName,
    Size size, {
    Key key,
    AssetBundle bundle,
    String package,
    bool clipToViewBox = true,
  }) {
    return new SvgImage._(
      loadAsset(assetName, bundle, package),
      size,
      clipToViewBox: clipToViewBox,
      key: key,
    );
  }

  factory SvgImage.network(
    String uri,
    Size size, {
    Map<String, String> headers,
    Key key,
    bool clipToViewBox = true,
  }) {
    return new SvgImage._(
      loadNetworkAsset2(uri),
      size,
      clipToViewBox: clipToViewBox,
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

Future<String> loadAsset(String assetName,
    [AssetBundle bundle, String package]) async {
  bundle ??= rootBundle;
  return await bundle
      .loadString(package == null ? assetName : 'packages/$package/$assetName');
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
