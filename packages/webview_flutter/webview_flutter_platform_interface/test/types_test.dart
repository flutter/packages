// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/src/types/types.dart';

void main() {
  group('types', () {
    test('WebResourceRequest', () {
      final Uri uri = Uri.parse('https://www.google.com');
      final WebResourceRequest request = WebResourceRequest(uri: uri);
      expect(request.uri, uri);
    });

    test('WebResourceResponse', () {
      final Uri uri = Uri.parse('https://www.google.com');
      const int statusCode = 404;
      const Map<String, String> headers = <String, String>{'a': 'header'};

      final WebResourceResponse response = WebResourceResponse(
        uri: uri,
        statusCode: statusCode,
        headers: headers,
      );

      expect(response.uri, uri);
      expect(response.statusCode, statusCode);
      expect(response.headers, headers);
    });
  });
}
