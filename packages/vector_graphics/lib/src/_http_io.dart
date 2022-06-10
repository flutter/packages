// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
// ignore this while we wait for framework to catch up with g3.
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

/// Fetches an HTTP resource from the specified [uri] using the specified [headers].
Future<Uint8List> httpGet(Uri uri, {Map<String, String>? headers}) async {
  final HttpClient httpClient = HttpClient();
  final HttpClientRequest request = await httpClient.getUrl(uri);
  headers?.forEach(request.headers.add);
  final HttpClientResponse response = await request.close();

  if (response.statusCode != HttpStatus.ok) {
    // The network may be only temporarily unavailable, or the file will be
    // added on the server later. Avoid having future calls fail to check the
    // network again.
    await response.drain<List<int>>(<int>[]);
    throw HttpException('Could not get network asset', uri: uri);
  }
  return consolidateHttpClientResponseBytes(response);
}
