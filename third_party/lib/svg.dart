import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle, AssetBundle;
import 'package:flutter/widgets.dart';

import 'package:flutter_svg/src/svg_painter.dart';

class SvgImage extends StatelessWidget {
  final Size size;
  final Future<String> future;
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
      loadNetworkAsset2(uri),
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

Future<String> loadAsset(String assetName,
    [AssetBundle bundle, String package]) async {
  bundle ??= rootBundle;
  return await bundle
      .loadString(package == null ? assetName : 'packages/$package/$assetName');
}

final HttpClient _httpClient = new HttpClient();

Future<String> loadNetworkAsset2(String url) async {
  final Uri uri = Uri.base.resolve(url);
  print('trying $uri');
  final HttpClientRequest request = await _httpClient.getUrl(uri);
  final HttpClientResponse response = await request.close();
  print(response.statusCode);
  if (response.statusCode != HttpStatus.OK) throw new FlutterError('Could not get network SVG asset');
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
