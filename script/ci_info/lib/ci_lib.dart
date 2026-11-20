// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

/// Host of the Buildbucket pRPC API.
const String buildbucketHost = 'cr-buildbucket.appspot.com';

/// Host of the LogDog log server.
const String logdogHost = 'logs.chromium.org';

/// Host of the Milo build UI.
const String miloHost = 'ci.chromium.org';

/// GitHub repo -> the gitiles mirror used in postsubmit `buildset` tags.
const Map<String, List<String>> gitilesMirrors = <String, List<String>>{
  'flutter/packages': <String>['flutter.googlesource.com', 'mirrors/packages'],
  'flutter/cocoon': <String>['flutter.googlesource.com', 'mirrors/cocoon'],
};

/// The repository analyzed when `--repo` is not given.
const String defaultRepo = 'flutter/packages';

/// Sentinel stored in place of a log that LogDog no longer has.
const String logMissing = '__LOG_PURGED__';

/// Sentinel returned (never cached) when LogDog refuses access to a log.
const String logInaccessible = '__LOG_INACCESSIBLE__';

/// Parses a Buildbucket timestamp, which can have nanosecond precision that
/// [DateTime.parse] doesn't accept. Returns null if [value] is missing or
/// invalid.
DateTime? parseBuildTime(String? value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(
    value.replaceAllMapped(RegExp(r'(\.\d{6})\d+'), (Match m) => m.group(1)!),
  );
}

/// Returns [text] cut to at most [maxLength] characters.
String truncate(String text, int maxLength) =>
    text.length <= maxLength ? text : text.substring(0, maxLength);

/// Returns the string at [key] in a Buildbucket JSON [map], or
/// [defaultValue] if it is missing.
String stringField(Map<String, dynamic> map, String key, {String defaultValue = '?'}) =>
    map[key] as String? ?? defaultValue;

/// Overrides [cacheDir] when set. Used by tests.
String? cacheDirOverride;

/// Directory holding cached network responses.
String get cacheDir {
  return cacheDirOverride ??
      Platform.environment['CI_INFO_CACHE'] ??
      p.join(Directory.systemTemp.path, 'ci_info_cache');
}

/// How long to wait for a single request.
const Duration _requestTimeout = Duration(seconds: 30);

String _cachePath(String kind, String key) {
  final String digest = sha256.convert(utf8.encode(key)).toString().substring(0, 24);
  final String directory = p.join(cacheDir, kind);
  Directory(directory).createSync(recursive: true);
  return p.join(directory, digest);
}

/// Returns the cached value, or null on a miss. A cache that can't be read
/// counts as a miss.
String? _readCache(String kind, String key, Duration? maxAge) {
  try {
    final file = File(_cachePath(kind, key));
    if (!file.existsSync()) {
      return null;
    }
    if (maxAge != null) {
      final Duration age = DateTime.now().difference(file.lastModifiedSync());
      if (age > maxAge) {
        return null;
      }
    }
    return file.readAsStringSync();
  } on FileSystemException {
    return null;
  }
}

/// Caches [value]. If the cache can't be written, the value isn't cached.
void _writeCache(String kind, String key, String value) {
  try {
    // Write-then-rename so that a concurrent run never reads a partial file.
    final String path = _cachePath(kind, key);
    final temp = File('$path.$pid.tmp');
    temp.writeAsStringSync(value);
    temp.renameSync(path);
  } on FileSystemException {
    // Caching is only an optimization.
  }
}

/// Sends a request with [send], retrying network errors, timeouts and 5xx
/// responses. Any other response is returned to the caller to handle.
Future<http.Response> _sendWithRetries(
  String description,
  Future<http.Response> Function() send,
) async {
  const maxAttempts = 3;
  Object? lastError;
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    if (attempt > 0) {
      await Future<void>.delayed(Duration(seconds: 1 + (attempt - 1) * 2));
    }
    try {
      final http.Response response = await send().timeout(_requestTimeout);
      if (response.statusCode < 500) {
        return response;
      }
      lastError = 'HTTP ${response.statusCode}: ${truncate(response.body, 200)}';
    } on Exception catch (e) {
      lastError = e;
    }
  }
  throw Exception('$description failed after $maxAttempts attempts: $lastError');
}

/// Calls the Buildbucket `buildbucket.v2.Builds/<method>` pRPC endpoint.
///
/// Network errors, timeouts and 5xx responses are retried; other failures are
/// not, since e.g. a misspelled builder name will never succeed. Only valid
/// JSON responses are cached.
///
/// [client] is used for requests if given, otherwise a default client is used.
Future<Map<String, dynamic>> prpc(
  String method,
  Map<String, dynamic> payload, {
  Duration? cacheAge = const Duration(minutes: 5),
  http.Client? client,
}) async {
  final String body = jsonEncode(payload);
  final cacheKey = '$method:$body';

  if (cacheAge != null) {
    final String? cached = _readCache('prpc', cacheKey, cacheAge);
    if (cached != null) {
      try {
        return jsonDecode(cached) as Map<String, dynamic>;
      } on FormatException {
        // A corrupt cache entry counts as a miss; refetch below.
      }
    }
  }

  final url = Uri.https(buildbucketHost, '/prpc/buildbucket.v2.Builds/$method');
  final http.Response response = await _sendWithRetries(
    'Buildbucket $method',
    () => (client?.post ?? http.post)(
      url,
      headers: const <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    ),
  );
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      'Buildbucket $method failed with status ${response.statusCode}: '
      '${response.body}',
    );
  }

  // pRPC prefixes JSON responses with the XSSI guard `)]}'`.
  final String raw = response.body;
  final int brace = raw.indexOf('{');
  if (brace == -1) {
    throw Exception('Unexpected Buildbucket response: ${truncate(raw, 200)}');
  }
  final Object? json;
  try {
    json = jsonDecode(raw.substring(brace));
  } on FormatException {
    throw Exception('Unexpected Buildbucket response: ${truncate(raw, 200)}');
  }
  if (json is! Map<String, dynamic>) {
    throw Exception('Unexpected Buildbucket response: ${truncate(raw, 200)}');
  }
  if (cacheAge != null) {
    _writeCache('prpc', cacheKey, jsonEncode(json));
  }
  return json;
}

/// Pages through `SearchBuilds` until [limit] builds have been collected.
Future<List<Map<String, dynamic>>> searchBuilds(
  Map<String, dynamic> predicate, {
  required String fields,
  int limit = 100,
  Duration? cacheAge = const Duration(minutes: 5),
}) async {
  final collected = <Map<String, dynamic>>[];
  String? pageToken;

  while (collected.length < limit) {
    final payload = <String, dynamic>{
      'predicate': predicate,
      'pageSize': (limit - collected.length).clamp(1, 300),
      'fields': fields,
      'pageToken': ?pageToken,
    };

    final Map<String, dynamic> response = await prpc('SearchBuilds', payload, cacheAge: cacheAge);
    final List<Map<String, dynamic>> builds =
        (response['builds'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        <Map<String, dynamic>>[];
    if (builds.isEmpty) {
      break;
    }

    collected.addAll(builds);
    pageToken = response['nextPageToken'] as String?;
    if (pageToken == null) {
      break;
    }
  }

  return collected.take(limit).toList();
}

/// Fetches a single build by Buildbucket ID.
Future<Map<String, dynamic>> getBuild(
  String buildId,
  String fields, {
  Duration? cacheAge = const Duration(hours: 1),
}) async {
  return prpc('GetBuild', <String, dynamic>{'id': buildId, 'fields': fields}, cacheAge: cacheAge);
}

/// Constructs the raw LogDog URL for [stepName]'s [logName] log.
String stepLogUrl(String buildId, String stepName, {String logName = 'stdout'}) {
  // LUCI derives URL segments from step names by splitting on `|` and replacing
  // every non-alphanumeric character with `_` (e.g. `process logs (6)` becomes
  // `process_logs__6_`).
  final String segments = stepName
      .split('|')
      .map((String part) => part.replaceAll(RegExp('[^A-Za-z0-9]'), '_'))
      .join('/');

  return 'https://$logdogHost/logs/flutter/buildbucket/cr-buildbucket/'
      '$buildId/+/u/$segments/$logName?format=raw';
}

String _normalizeLogUrl(String url) {
  if (url.endsWith('format=raw')) {
    return url;
  }
  return '$url${url.contains('?') ? '&' : '?'}format=raw';
}

/// Path at which the log for [url] is (or will be) cached.
String logCachePath(String url) {
  return _cachePath('log', _normalizeLogUrl(url));
}

/// Fetches a raw LogDog log, returning [logMissing] if it no longer exists
/// or [logInaccessible] if LogDog refuses access.
///
/// Network errors, timeouts and 5xx responses are retried. A 404 is not
/// cached, because a log can be requested before LogDog has finished
/// receiving it.
///
/// [client] is used for the request if given, otherwise a default client is
/// used.
Future<String> fetchLog(String url, {Duration? cacheAge, http.Client? client}) async {
  url = _normalizeLogUrl(url);
  final String? cached = _readCache('log', url, cacheAge);
  if (cached != null) {
    return cached;
  }

  final http.Response response = await _sendWithRetries(
    'Fetching $url',
    () => (client?.get ?? http.get)(Uri.parse(url)),
  );

  switch (response.statusCode) {
    case 200:
      String text = response.body;
      // LogDog keeps logs for roughly six months. Older streams come back as a
      // 200 whose body is an error message rather than as a 404.
      if (truncate(text, 400).contains('stream path not found') ||
          text.startsWith('ERROR: start fetch')) {
        text = logMissing;
      }
      _writeCache('log', url, text);
      return text;
    case 404:
      return logMissing;
    case 403:
      if (response.body.contains('not allowed by policy')) {
        stderr.writeln(
          'Warning: $logdogHost blocked by sandbox/proxy policy: ${response.body.trim()}',
        );
      }
      // Not cached: this can be a transient auth or rate-limit error.
      return logInaccessible;
    default:
      throw Exception('Failed to fetch $url: HTTP ${response.statusCode}');
  }
}

/// Milo URL for a single build.
String miloBuildUrl(String project, String bucket, String builder, int? number, String buildId) {
  if (number != null) {
    final String builderPath = Uri.encodeComponent(builder);
    return 'https://$miloHost/ui/p/$project/builders/$bucket/$builderPath/'
        '$number/overview';
  }
  return 'https://$miloHost/b/$buildId';
}

/// The `buildset` tag value that postsubmit builds of [sha] carry.
String commitBuildset(String sha, {String repo = defaultRepo}) {
  final List<String>? mirror = gitilesMirrors[repo];
  if (mirror == null) {
    throw Exception('Unknown repo $repo. Known: ${gitilesMirrors.keys.join(', ')}.');
  }
  return 'commit/gitiles/${mirror[0]}/${mirror[1]}/+/$sha';
}

/// The `github_link` tag value that presubmit builds of PR [pr] carry.
String githubLink(int pr, {String repo = defaultRepo}) {
  return 'https://github.com/$repo/pull/$pr';
}
