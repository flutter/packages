// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:ci_info/ci_lib.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('cacheDir', () {
    test('uses CI_INFO_CACHE when set or system temp ci_info_cache otherwise', () {
      final String? envOverride = Platform.environment['CI_INFO_CACHE'];
      if (envOverride != null) {
        expect(cacheDir, envOverride);
      } else {
        expect(cacheDir, p.join(Directory.systemTemp.path, 'ci_info_cache'));
      }
    });
  });

  group('prpc', () {
    late Directory tempCache;
    late int requests;

    setUp(() {
      tempCache = Directory.systemTemp.createTempSync('ci_info_test_');
      cacheDirOverride = tempCache.path;
      requests = 0;
    });

    tearDown(() {
      cacheDirOverride = null;
      tempCache.deleteSync(recursive: true);
    });

    MockClient clientReturning(String body) {
      return MockClient((http.Request request) async {
        requests++;
        return http.Response(body, 200);
      });
    }

    List<File> cachedFiles() {
      final dir = Directory(p.join(tempCache.path, 'prpc'));
      return dir.existsSync() ? dir.listSync().whereType<File>().toList() : <File>[];
    }

    test('strips the XSSI guard and caches valid responses', () async {
      final Map<String, dynamic> first = await prpc(
        'SearchBuilds',
        <String, dynamic>{},
        client: clientReturning(")]}'\n{\"builds\": []}"),
      );
      final Map<String, dynamic> second = await prpc(
        'SearchBuilds',
        <String, dynamic>{},
        client: clientReturning('{"unexpected": true}'),
      );

      expect(first, <String, dynamic>{'builds': <dynamic>[]});
      expect(second, first, reason: 'second call should be served from the cache');
      expect(requests, 1);
    });

    test('treats a corrupt cache entry as a miss', () async {
      await prpc('SearchBuilds', <String, dynamic>{}, client: clientReturning('{"n": 1}'));
      for (final File file in cachedFiles()) {
        file.writeAsStringSync('{not json');
      }

      final Map<String, dynamic> result = await prpc(
        'SearchBuilds',
        <String, dynamic>{},
        client: clientReturning('{"n": 2}'),
      );

      expect(result, <String, dynamic>{'n': 2});
      expect(requests, 2);
    });

    test('does not cache a response that is not valid JSON', () async {
      await expectLater(
        prpc('SearchBuilds', <String, dynamic>{}, client: clientReturning('<html>{oops')),
        throwsA(
          isA<Exception>().having(
            (Exception e) => e.toString(),
            'message',
            contains('Unexpected Buildbucket response'),
          ),
        ),
      );
      expect(cachedFiles(), isEmpty);
    });

    test('does not cache a JSON response that is not an object', () async {
      await expectLater(
        prpc('SearchBuilds', <String, dynamic>{}, client: clientReturning(jsonEncode(<int>[1]))),
        throwsException,
      );
      expect(cachedFiles(), isEmpty);
    });
  });

  group('fetchLog', () {
    const url =
        'https://logs.chromium.org/logs/flutter/buildbucket/cr-buildbucket/1/+/u/step/stdout';
    late Directory tempCache;
    late int requests;

    setUp(() {
      tempCache = Directory.systemTemp.createTempSync('ci_info_test_');
      cacheDirOverride = tempCache.path;
      requests = 0;
    });

    tearDown(() {
      cacheDirOverride = null;
      tempCache.deleteSync(recursive: true);
    });

    MockClient clientReturning(String body, int statusCode) {
      return MockClient((http.Request request) async {
        requests++;
        expect(request.url.queryParameters['format'], 'raw');
        return http.Response(body, statusCode);
      });
    }

    test('returns and caches the log text', () async {
      expect(await fetchLog(url, client: clientReturning('log text', 200)), 'log text');
      expect(await fetchLog(url, client: clientReturning('other', 200)), 'log text');
      expect(requests, 1);
    });

    test('treats a purged stream as missing', () async {
      expect(
        await fetchLog(url, client: clientReturning('stream path not found', 200)),
        logMissing,
      );
    });

    test('treats a 404 as missing without caching it', () async {
      expect(await fetchLog(url, client: clientReturning('', 404)), logMissing);
      expect(await fetchLog(url, client: clientReturning('log text', 200)), 'log text');
      expect(requests, 2);
    });

    test('retries server errors', () async {
      var attempt = 0;
      final client = MockClient((http.Request request) async {
        attempt++;
        return attempt == 1 ? http.Response('busy', 503) : http.Response('log text', 200);
      });

      expect(await fetchLog(url, client: client), 'log text');
      expect(attempt, 2);
    });

    test('does not cache a 403', () async {
      expect(await fetchLog(url, client: clientReturning('', 403)), logInaccessible);
      expect(await fetchLog(url, client: clientReturning('log text', 200)), 'log text');
      expect(requests, 2);
    });
  });

  group('stepLogUrl', () {
    test('turns each step name part into a URL segment', () {
      expect(
        stepLogUrl('123', 'Run package tests|process logs (6)'),
        'https://logs.chromium.org/logs/flutter/buildbucket/cr-buildbucket/'
        '123/+/u/Run_package_tests/process_logs__6_/stdout?format=raw',
      );
    });
  });

  group('parseBuildTime', () {
    test('accepts nanosecond precision', () {
      expect(
        parseBuildTime('2026-09-15T01:02:03.123456789Z'),
        DateTime.utc(2026, 9, 15, 1, 2, 3, 123, 456),
      );
    });

    test('returns null for missing or invalid times', () {
      expect(parseBuildTime(null), isNull);
      expect(parseBuildTime('not a time'), isNull);
    });
  });

  group('truncate', () {
    test('returns text unchanged when within maxLength', () {
      expect(truncate('hello', 10), 'hello');
      expect(truncate('hello', 5), 'hello');
    });

    test('cuts text to maxLength when longer', () {
      expect(truncate('hello world', 5), 'hello');
    });
  });

  group('stringField', () {
    test('returns the value when the key is present', () {
      expect(stringField(<String, dynamic>{'status': 'FAILURE'}, 'status'), 'FAILURE');
    });

    test("returns '?' when the key is missing", () {
      expect(stringField(<String, dynamic>{}, 'status'), '?');
    });

    test('returns defaultValue when the key is missing', () {
      expect(stringField(<String, dynamic>{}, 'project', defaultValue: 'flutter'), 'flutter');
    });
  });

  group('miloBuildUrl', () {
    test('builds builder/number overview URL when build number is present', () {
      expect(
        miloBuildUrl(
          'flutter',
          'try',
          'Mac_arm64 ios_platform_tests_shard_5 master',
          32124,
          '8665950131386809281',
        ),
        'https://ci.chromium.org/ui/p/flutter/builders/try/'
        'Mac_arm64%20ios_platform_tests_shard_5%20master/32124/overview',
      );
    });

    test('falls back to build ID URL when build number is null', () {
      expect(
        miloBuildUrl('flutter', 'try', 'Linux analyze master', null, '8665950131386809281'),
        'https://ci.chromium.org/b/8665950131386809281',
      );
    });
  });

  group('commitBuildset', () {
    test('constructs gitiles buildset tag for flutter/packages by default', () {
      expect(
        commitBuildset('920c2eec29aab89b40e176b1a019fa29e933b4df'),
        'commit/gitiles/flutter.googlesource.com/mirrors/packages/+/'
        '920c2eec29aab89b40e176b1a019fa29e933b4df',
      );
    });

    test('supports flutter/cocoon mirror', () {
      expect(
        commitBuildset('0123456789abcdef0123456789abcdef01234567', repo: 'flutter/cocoon'),
        'commit/gitiles/flutter.googlesource.com/mirrors/cocoon/+/'
        '0123456789abcdef0123456789abcdef01234567',
      );
    });

    test('throws on unknown repository', () {
      expect(() => commitBuildset('abc', repo: 'unknown/repo'), throwsException);
    });
  });

  group('githubLink', () {
    test('constructs pull request URL for default and custom repos', () {
      expect(githubLink(13575), 'https://github.com/flutter/packages/pull/13575');
      expect(githubLink(42, repo: 'flutter/cocoon'), 'https://github.com/flutter/cocoon/pull/42');
    });
  });
}
