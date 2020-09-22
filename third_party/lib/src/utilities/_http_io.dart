import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

/// Fetches an HTTP resource from the specified [url] using the specified [headers].
Future<Uint8List> httpGet(String url, {Map<String, String> headers}) async {
  final HttpClient httpClient = HttpClient();
  final Uri uri = Uri.base.resolve(url);
  final HttpClientRequest request = await httpClient.getUrl(uri);
  if (headers != null) {
    headers.forEach((String key, String value) {
      request.headers.add(key, value);
    });
  }
  final HttpClientResponse response = await request.close();

  if (response.statusCode != HttpStatus.ok) {
    throw HttpException('Could not get network asset', uri: uri);
  }
  return consolidateHttpClientResponseBytes(response);
}
