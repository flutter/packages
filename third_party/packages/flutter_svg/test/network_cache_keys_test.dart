import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  setUp(() {
    svg.cache.clear();
    svg.cache.maximumSize = 100;
  });

  test('equivalent HTTP header maps share one compiled SVG', () async {
    final client = _CountingSvgClient();
    final first = SvgNetworkLoader(
      'https://example.com/logo.svg',
      headers: const <String, String>{'Accept': 'image/svg+xml', 'X-Test': 'yes'},
      httpClient: client,
    );
    final second = SvgNetworkLoader(
      'https://example.com/logo.svg',
      headers: const <String, String>{'X-Test': 'yes', 'Accept': 'image/svg+xml'},
      httpClient: client,
    );

    expect(first, equals(second));
    expect(first.hashCode, second.hashCode);
    expect(first.cacheKey(null), second.cacheKey(null));

    final ByteData firstBytes = await first.loadBytes(null);
    final ByteData secondBytes = await second.loadBytes(null);
    expect(identical(firstBytes, secondBytes), isTrue);
    expect(client.requests, 1);
  });

  test('different headers or injected clients cannot share network data', () async {
    final firstClient = _CountingSvgClient();
    final secondClient = _CountingSvgClient();
    final first = SvgNetworkLoader(
      'https://example.com/logo.svg',
      headers: const <String, String>{'Authorization': 'A'},
      httpClient: firstClient,
    );
    final differentHeader = SvgNetworkLoader(
      'https://example.com/logo.svg',
      headers: const <String, String>{'Authorization': 'B'},
      httpClient: firstClient,
    );
    final differentClient = SvgNetworkLoader(
      'https://example.com/logo.svg',
      headers: const <String, String>{'Authorization': 'A'},
      httpClient: secondClient,
    );

    expect(first, isNot(equals(differentHeader)));
    expect(first.cacheKey(null), isNot(equals(differentHeader.cacheKey(null))));
    expect(first, isNot(equals(differentClient)));
    expect(first.cacheKey(null), isNot(equals(differentClient.cacheKey(null))));

    await first.loadBytes(null);
    await differentHeader.loadBytes(null);
    await differentClient.loadBytes(null);
    expect(firstClient.requests, 2);
    expect(secondClient.requests, 1);
    expect(svg.cache.count, 3);
  });

  test('cache keys snapshot mutable request headers', () {
    final headers = <String, String>{'Authorization': 'old'};
    final loader = SvgNetworkLoader('https://example.com/logo.svg', headers: headers);
    final SvgCacheKey original = loader.cacheKey(null);

    headers['Authorization'] = 'new';
    final SvgCacheKey changed = loader.cacheKey(null);
    expect(original, isNot(equals(changed)));

    // Reconstructing the original request recovers the same stable key.
    final SvgCacheKey originalAgain = const SvgNetworkLoader(
      'https://example.com/logo.svg',
      headers: <String, String>{'Authorization': 'old'},
    ).cacheKey(null);
    expect(original, originalAgain);
  });

  test('mutating headers preserves existing cache entries and eviction', () async {
    final client = _CountingSvgClient();
    final headers = <String, String>{'Authorization': 'old'};
    final loader = SvgNetworkLoader(
      'https://example.com/logo.svg',
      headers: headers,
      httpClient: client,
    );
    final SvgCacheKey originalKey = loader.cacheKey(null);
    final ByteData original = await loader.loadBytes(null);
    headers['Authorization'] = 'new';
    await loader.loadBytes(null);
    final originalLoader = SvgNetworkLoader(
      'https://example.com/logo.svg',
      headers: const <String, String>{'Authorization': 'old'},
      httpClient: client,
    );

    expect(identical(await originalLoader.loadBytes(null), original), isTrue);
    expect(client.requests, 2);
    expect(svg.cache.evict(originalKey), isTrue);
    expect(svg.cache.count, 1);
  });

  test('equivalent concurrent requests deduplicate but themes stay isolated', () async {
    final client = _CountingSvgClient();
    final first = SvgNetworkLoader(
      'https://example.com/logo.svg',
      headers: const <String, String>{'Accept': 'image/svg+xml'},
      httpClient: client,
    );
    final equivalent = SvgNetworkLoader(
      'https://example.com/logo.svg',
      headers: Map<String, String>.of(first.headers!),
      httpClient: client,
    );
    final differentTheme = SvgNetworkLoader(
      'https://example.com/logo.svg',
      headers: first.headers,
      theme: const SvgTheme(fontSize: 20),
      httpClient: client,
    );
    final Future<ByteData> pending = first.loadBytes(null);
    expect(identical(equivalent.loadBytes(null), pending), isTrue);
    await Future.wait(<Future<ByteData>>[pending, differentTheme.loadBytes(null)]);
    expect(client.requests, 2);
    expect(svg.cache.count, 2);
  });
}

class _CountingSvgClient extends http.BaseClient {
  int requests = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests++;
    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode('<svg width="10" height="10"></svg>')),
      200,
    );
  }
}
