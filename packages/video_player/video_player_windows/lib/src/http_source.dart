// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Bridges caller headers to Media Foundation without buffering the entire media.
class HttpSource {
  HttpSource._(this._server, this._source, this._headers, this._path) {
    _client.autoUncompress = false;
    _client.connectionTimeout = const Duration(seconds: 15);
    _server.autoCompress = false;
    _server.listen(_serve);
  }

  static const Set<String> _hopHeaders = <String>{
    'connection',
    'keep-alive',
    'proxy-authenticate',
    'proxy-authorization',
    'te',
    'trailer',
    'transfer-encoding',
    'upgrade',
  };
  final HttpServer _server;
  final Uri _source;
  final Map<String, String> _headers;
  final String _path;
  final HttpClient _client = HttpClient();
  Future<void>? _closing;

  /// Only the random path grants access; the URL contains no upstream credentials.
  Uri get uri => Uri(scheme: 'http', host: '127.0.0.1', port: _server.port, path: _path);

  /// Caller headers are dropped permanently after a redirect to another origin.
  static Future<HttpSource> open(Uri source, Map<String, String> headers) async {
    final normalized = <String, String>{};
    for (final MapEntry<String, String> header in headers.entries) {
      final String name = header.key.toLowerCase();
      if (!RegExp(r"^[!#$%&'*+.^_`|~0-9a-z-]+$").hasMatch(name) ||
          header.value.codeUnits.any((int c) => c == 127 || c > 255 || (c < 32 && c != 9)) ||
          _hopHeaders.contains(name) ||
          name == 'host' ||
          name == 'content-length') {
        throw ArgumentError('Invalid or transport-controlled HTTP header: ${header.key}');
      }
      normalized[name] = header.value;
    }
    final random = Random.secure();
    final String token = base64Url.encode(List<int>.generate(32, (_) => random.nextInt(256)));
    final HttpServer server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    return HttpSource._(server, source, normalized, '/$token/media');
  }

  /// Must finish before native shutdown, which can wait for outstanding reads.
  Future<void> close() => _closing ??= _close();

  Future<void> _close() async {
    _client.close(force: true);
    await _server.close(force: true);
  }

  Future<void> _serve(HttpRequest request) async {
    HttpClientRequest? upstream;
    var disconnected = false;
    unawaited(
      request.response.done.then<void>(
        (_) {
          disconnected = true;
          upstream?.abort();
        },
        onError: (Object _, StackTrace _) {
          disconnected = true;
          upstream?.abort();
        },
      ),
    );
    try {
      Uri? requestedTarget;
      if (request.uri.path == _path && !request.uri.hasQuery) {
        requestedTarget = _source;
      } else if (request.uri.path == '$_path/resource' &&
          request.uri.queryParametersAll.length == 1 &&
          request.uri.queryParametersAll['url']?.length == 1) {
        requestedTarget = Uri.tryParse(request.uri.queryParameters['url']!);
      }

      if (requestedTarget == null ||
          !requestedTarget.hasAuthority ||
          !<String>{'http', 'https'}.contains(requestedTarget.scheme) ||
          requestedTarget.userInfo.isNotEmpty ||
          (_source.scheme == 'https' && requestedTarget.scheme != 'https')) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }
      if (request.method != 'GET' && request.method != 'HEAD') {
        request.response.statusCode = HttpStatus.methodNotAllowed;
        await request.response.close();
        return;
      }

      Uri target = requestedTarget;
      // Manifest references can cross origins without an HTTP redirect.
      var includeHeaders = target.origin == _source.origin;
      for (var redirects = 0; ; redirects++) {
        upstream = await _client.openUrl(request.method, target);
        if (disconnected || _closing != null) {
          upstream.abort();
          return;
        }

        upstream.followRedirects = false;
        if (includeHeaders) {
          _headers.forEach(upstream.headers.set);
        }
        // Media Foundation's byte range must override an initial caller range after a seek.
        for (final name in <String>['range', 'if-range']) {
          final String? value = request.headers.value(name);
          if (value != null) {
            upstream.headers.set(name, value);
          }
        }
        final HttpClientResponse response = await upstream.close().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            upstream?.abort();
            throw TimeoutException('The media server did not respond.');
          },
        );
        final String? location = response.headers.value(HttpHeaders.locationHeader);
        if (<int>{301, 302, 303, 307, 308}.contains(response.statusCode) && location != null) {
          // Redirect bodies can remain open indefinitely; cancel the subscription
          // rather than waiting for the body to finish before following the redirect.
          await response.listen(null).cancel();
          if (redirects >= 5) {
            throw const HttpException('Too many media redirects.');
          }
          final Uri next = target.resolve(location);
          if (!<String>{'http', 'https'}.contains(next.scheme) ||
              (target.scheme == 'https' && next.scheme != 'https') ||
              next.userInfo.isNotEmpty) {
            throw const HttpException('Unsafe media redirect.');
          }
          if (next.origin != target.origin) {
            includeHeaders = false;
          }
          target = next;
          continue;
        }

        request.response.statusCode = response.statusCode;
        final blocked = <String>{
          ..._hopHeaders,
          ...?response.headers[HttpHeaders.connectionHeader]?.expand(
            (String value) => value.split(',').map((String name) => name.trim().toLowerCase()),
          ),
        };
        response.headers.forEach((String name, List<String> values) {
          if (!blocked.contains(name.toLowerCase())) {
            request.response.headers.set(name, values);
          }
        });

        request.response.headers.set('x-video-player-location', target.toString());
        request.response.bufferOutput = false;
        await request.response.flush();
        await request.response.addStream(response.timeout(const Duration(seconds: 30)));
        await request.response.close();
        return;
      }
    } on Object {
      upstream?.abort();
      try {
        request.response.statusCode = HttpStatus.badGateway;
        await request.response.close();
      } on Object {
        try {
          (await request.response.detachSocket(writeHeaders: false)).destroy();
        } on Object {
          // A decoder that already disconnected has no socket left to terminate.
        }
      }
    }
  }
}
