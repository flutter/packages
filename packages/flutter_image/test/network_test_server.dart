// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

const int _kTestServerPort = 11111;

Future<void> main() async {
  final HttpServer testServer =
      await HttpServer.bind(InternetAddress.loopbackIPv4, _kTestServerPort);
  await for (final HttpRequest request in testServer) {
    if (request.uri.path.endsWith('/immediate_success.png')) {
      request.response.add(_kTransparentImage);
    } else if (request.uri.path.endsWith('/error.png')) {
      request.response.statusCode = 500;
    } else if (request.uri.path.endsWith('/extra_header.png') &&
        request.headers.value('ExtraHeader') == 'special') {
      request.response.add(_kTransparentImage);
    } else {
      request.response.statusCode = 404;
    }

    await request.response.flush();
    await request.response.close();
  }
}

const List<int> _kTransparentImage = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
];
