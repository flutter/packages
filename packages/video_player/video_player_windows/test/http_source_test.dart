// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_windows/src/http_source.dart';

void main() {
  late HttpClient client;

  setUp(() {
    client = HttpClient()..autoUncompress = false;
  });
  tearDown(() => client.close(force: true));

  Future<HttpServer> serve(void Function(HttpRequest) handler) async {
    final HttpServer server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen(handler);
    addTearDown(() => server.close(force: true));
    return server;
  }

  Uri url(HttpServer server) => Uri.parse('http://127.0.0.1:${server.port}/media');

  Future<HttpSource> source(HttpServer server, Map<String, String> headers) async {
    final HttpSource result = await HttpSource.open(url(server), headers);
    addTearDown(result.close);
    return result;
  }

  test('forwards custom headers, HEAD and decoder ranges with response metadata', () async {
    final seen = <HttpHeaders>[];
    final HttpServer server = await serve((HttpRequest request) async {
      seen.add(request.headers);
      request.response.statusCode = 206;
      request.response.headers.set('content-range', 'bytes 2-4/10');
      request.response.headers.set('accept-ranges', 'bytes');
      request.response.headers.set('connection', 'x-private');
      request.response.headers.set('x-private', 'must not cross');
      request.response.contentLength = 3;
      if (request.method != 'HEAD') {
        request.response.add(<int>[2, 3, 4]);
      }
      await request.response.close();
    });
    final HttpSource relay = await source(server, <String, String>{
      'Authorization': 'Bearer test',
      'X-Custom': 'custom',
      'Range': 'bytes=0-',
    });
    for (final method in <String>['GET', 'HEAD']) {
      final HttpClientRequest request = await client.openUrl(method, relay.uri);
      request.headers.set('range', 'bytes=2-4');
      request.headers.set('if-range', '"version"');
      final HttpClientResponse response = await request.close();
      expect(response.statusCode, 206);
      expect(response.headers.value('content-range'), 'bytes 2-4/10');
      expect(response.contentLength, 3);
      expect(response.headers.value('x-private'), isNull);
      final List<int> body = await response.expand((List<int> data) => data).toList();
      expect(body, method == 'GET' ? <int>[2, 3, 4] : isEmpty);
    }
    for (final headers in seen) {
      expect(headers.value('authorization'), 'Bearer test');
      expect(headers.value('x-custom'), 'custom');
      expect(headers.value('range'), 'bytes=2-4');
      expect(headers.value('if-range'), '"version"');
    }
  });

  test('preserves encoded bytes and authentication error status', () async {
    final List<int> compressed = gzip.encode(utf8.encode('media bytes'));
    final HttpServer server = await serve((HttpRequest request) async {
      request.response.statusCode = 401;
      request.response.headers.set('content-encoding', 'gzip');
      request.response.contentLength = compressed.length;
      request.response.add(compressed);
      await request.response.close();
    });
    final HttpSource relay = await source(server, <String, String>{'Authorization': 'bad'});
    final HttpClientResponse response = await (await client.getUrl(relay.uri)).close();
    expect(response.statusCode, 401);
    expect(response.headers.value('content-encoding'), 'gzip');
    expect(await response.expand((List<int> data) => data).toList(), compressed);
  });

  test('keeps headers on same-origin redirect and strips them after crossing origins', () async {
    final headers = <HttpHeaders>[];
    late HttpServer first;
    final HttpServer second = await serve((HttpRequest request) async {
      headers.add(request.headers);
      request.response.statusCode = 302;
      request.response.headers.set('location', url(first).replace(path: '/final').toString());
      await request.response.close();
    });
    first = await serve((HttpRequest request) async {
      headers.add(request.headers);
      if (request.uri.path != '/final') {
        request.response.statusCode = 307;
        request.response.headers.set(
          'location',
          request.uri.path == '/media' ? '/same' : url(second).toString(),
        );
      }
      await request.response.close();
    });
    final HttpSource relay = await source(first, <String, String>{
      'Authorization': 'secret',
      'Cookie': 'session=value',
      'X-Token': 'secret',
    });
    final HttpClientResponse response = await (await client.getUrl(relay.uri)).close();
    await response.drain<void>();
    expect(headers, hasLength(4));
    for (var i = 0; i < headers.length; i++) {
      expect(headers[i].value('authorization'), i < 2 ? 'secret' : isNull);
      expect(headers[i].value('cookie'), i < 2 ? 'session=value' : isNull);
      expect(headers[i].value('x-token'), i < 2 ? 'secret' : isNull);
    }
  });

  test('rejects unknown paths, methods and invalid headers', () async {
    var contacted = false;
    final HttpServer server = await serve((HttpRequest request) {
      contacted = true;
    });
    final HttpSource relay = await source(server, <String, String>{'X-Test': 'value'});
    for (final MapEntry<String, Uri> entry in <String, Uri>{
      'GET': relay.uri.replace(path: '/unknown'),
      'POST': relay.uri,
    }.entries) {
      final HttpClientResponse response = await (await client.openUrl(
        entry.key,
        entry.value,
      )).close();
      expect(response.statusCode, entry.key == 'GET' ? 404 : 405);
      await response.drain<void>();
    }
    expect(contacted, isFalse);
    for (final headers in <Map<String, String>>[
      <String, String>{'bad\r\nname': 'value'},
      <String, String>{'X-Test': 'value\r\nInjected: true'},
      <String, String>{'Host': 'other'},
      <String, String>{'Content-Length': '100'},
    ]) {
      await expectLater(HttpSource.open(url(server), headers), throwsArgumentError);
    }
  });

  test('cancels discarded redirect bodies before following or rejecting them', () async {
    for (final destination in <String>['/final', 'file:///not-allowed']) {
      final disconnected = Completer<void>();
      final HttpServer server = await serve((HttpRequest request) async {
        if (request.uri.path == '/final') {
          await request.response.close();
          return;
        }

        // Following the redirect must cancel this intentionally unfinished body.
        final Socket socket = await request.response.detachSocket(writeHeaders: false);
        socket.write(
          'HTTP/1.1 302 Found\r\nLocation: $destination\r\nContent-Length: 100000\r\n\r\n',
        );
        await socket.flush();
        socket.listen((_) {}, onDone: disconnected.complete);
      });

      final HttpSource relay = await source(server, <String, String>{'X-Test': 'value'});
      final HttpClientResponse response = await (await client.getUrl(relay.uri)).close();
      expect(response.statusCode, destination == '/final' ? 200 : 502);
      await response.drain<void>();
      await disconnected.future.timeout(const Duration(seconds: 2));
    }
  });

  test('adaptive resources retain queries, headers, ranges and the final redirect base', () async {
    final seen = <HttpRequest>[];
    final HttpServer server = await serve((HttpRequest request) async {
      seen.add(request);
      if (request.uri.path == '/start') {
        request.response.statusCode = 307;
        request.response.headers.set('location', '/nested/segment.m4s?token=a%2Bb');
      } else {
        request.response.statusCode = 206;
        request.response.headers.set('content-range', 'bytes 2-3/4');
        request.response.add(<int>[2, 3]);
      }
      await request.response.close();
    });
    final HttpSource relay = await source(server, <String, String>{'X-Token': 'fixture'});
    final Uri resource = relay.uri.replace(
      path: '${relay.uri.path}/resource',
      queryParameters: <String, String>{'url': url(server).replace(path: '/start').toString()},
    );
    final HttpClientRequest request = await client.getUrl(resource);
    request.headers.set('range', 'bytes=2-3');
    final HttpClientResponse response = await request.close();
    expect(response.statusCode, 206);
    expect(
      response.headers.value('x-video-player-location'),
      url(server).replace(path: '/nested/segment.m4s', query: 'token=a%2Bb').toString(),
    );
    expect(await response.expand((List<int> chunk) => chunk).toList(), <int>[2, 3]);
    expect(seen.last.uri.queryParameters['token'], 'a+b');
    for (final request in seen) {
      expect(request.headers.value('x-token'), 'fixture');
      expect(request.headers.value('range'), 'bytes=2-3');
    }
  });

  test(
    'cross-origin adaptive resources never receive caller credentials, including redirects back',
    () async {
      final seen = <HttpHeaders>[];
      final HttpServer original = await serve((HttpRequest request) async {
        seen.add(request.headers);
        await request.response.close();
      });
      final HttpServer other = await serve((HttpRequest request) async {
        seen.add(request.headers);
        request.response.statusCode = 302;
        request.response.headers.set('location', url(original).toString());
        await request.response.close();
      });
      final HttpSource relay = await source(original, <String, String>{
        'Authorization': 'secret',
        'X-Token': 'secret',
        'Cookie': 'secret',
      });
      final Uri resource = relay.uri.replace(
        path: '${relay.uri.path}/resource',
        queryParameters: <String, String>{'url': url(other).toString()},
      );
      await (await (await client.getUrl(resource)).close()).drain<void>();
      expect(seen, hasLength(2));
      for (final headers in seen) {
        expect(headers.value('authorization'), isNull);
        expect(headers.value('x-token'), isNull);
        expect(headers.value('cookie'), isNull);
      }
    },
  );

  test('adaptive resource routes reject unsafe targets without contacting them', () async {
    var contacted = false;
    final HttpServer server = await serve((HttpRequest request) {
      contacted = true;
    });
    final HttpSource relay = await HttpSource.open(
      Uri.parse('https://example.com/master.m3u8'),
      <String, String>{},
    );
    addTearDown(relay.close);
    for (final target in <String>[
      url(server).toString(),
      'file:///video',
      'https://user:password@example.com/video',
      'relative.ts',
    ]) {
      final Uri resource = relay.uri.replace(
        path: '${relay.uri.path}/resource',
        queryParameters: <String, String>{'url': target},
      );
      final HttpClientResponse response = await (await client.getUrl(resource)).close();
      expect(response.statusCode, 404);
      await response.drain<void>();
    }
    expect(contacted, isFalse);
  });

  test('closing aborts a server stalled before response headers', () async {
    final arrived = Completer<void>();
    final HttpServer server = await serve((HttpRequest request) {
      arrived.complete();
    });
    final HttpSource relay = await source(server, <String, String>{'X-Test': 'value'});
    final Future<void> pending = () async {
      try {
        final HttpClientResponse response = await (await client.getUrl(relay.uri)).close();
        await response.drain<void>();
      } on IOException {
        return;
      }
    }();
    await arrived.future.timeout(const Duration(seconds: 5));
    await relay.close().timeout(const Duration(seconds: 2));
    await pending.timeout(const Duration(seconds: 2));
    await relay.close();
  });

  test('closing aborts a body stalled after response headers', () async {
    final HttpServer server = await serve((HttpRequest request) async {
      request.response.contentLength = 1024 * 1024;
      request.response.bufferOutput = false;
      request.response.add(List<int>.filled(64 * 1024, 1));
      await request.response.flush();
    });
    final HttpSource relay = await source(server, <String, String>{'X-Test': 'value'});
    final HttpClientResponse response = await (await client.getUrl(relay.uri)).close();
    final received = Completer<void>();
    final ended = Completer<void>();
    response.listen(
      (List<int> bytes) {
        if (!received.isCompleted) {
          received.complete();
        }
      },
      onError: (Object error) {
        expect(error, isA<IOException>());
      },
      onDone: ended.complete,
    );
    await received.future.timeout(const Duration(seconds: 5));
    await relay.close().timeout(const Duration(seconds: 2));
    await ended.future.timeout(const Duration(seconds: 2));
  });
}
