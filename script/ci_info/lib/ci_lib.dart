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

/// Host of the Milo build UI.
const String miloHost = 'ci.chromium.org';

/// GitHub repo -> the gitiles mirror used in postsubmit `buildset` tags.
const Map<String, List<String>> gitilesMirrors = <String, List<String>>{
  'flutter/packages': <String>['flutter.googlesource.com', 'mirrors/packages'],
  'flutter/cocoon': <String>['flutter.googlesource.com', 'mirrors/cocoon'],
};

/// The repository analyzed when `--repo` is not given.
const String defaultRepo = 'flutter/packages';

/// Returns [text] cut to at most [maxLength] characters.
String truncate(String text, int maxLength) =>
    text.length <= maxLength ? text : text.substring(0, maxLength);

/// Returns the string at [key] in a Buildbucket JSON [map], or
/// [defaultValue] if it is missing.
String stringField(Map<String, dynamic> map, String key, {String defaultValue = '?'}) =>
    map[key] as String? ?? defaultValue;

/// Directory holding cached network responses.
String get cacheDir {
  return Platform.environment['CI_INFO_CACHE'] ??
      p.join(Directory.systemTemp.path, 'ci_info_cache');
}

String _cachePath(String kind, String key) {
  final String digest = sha256.convert(utf8.encode(key)).toString().substring(0, 24);
  final String directory = p.join(cacheDir, kind);
  Directory(directory).createSync(recursive: true);
  return p.join(directory, digest);
}

String? _readCache(String kind, String key, Duration? maxAge) {
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
}

void _writeCache(String kind, String key, String value) {
  // Write-then-rename so that a concurrent run never reads a partial file.
  final String path = _cachePath(kind, key);
  final temp = File('$path.$pid.tmp');
  temp.writeAsStringSync(value);
  temp.renameSync(path);
}

/// Calls the Buildbucket `buildbucket.v2.Builds/<method>` pRPC endpoint.
///
/// Network errors and 5xx responses are retried; other failures are not,
/// since e.g. a misspelled builder name will never succeed.
Future<Map<String, dynamic>> prpc(
  String method,
  Map<String, dynamic> payload, {
  Duration? cacheAge = const Duration(minutes: 5),
}) async {
  final String body = jsonEncode(payload);
  final cacheKey = '$method:$body';

  if (cacheAge != null) {
    final String? cached = _readCache('prpc', cacheKey, cacheAge);
    if (cached != null) {
      return jsonDecode(cached) as Map<String, dynamic>;
    }
  }

  final url = Uri.https(buildbucketHost, '/prpc/buildbucket.v2.Builds/$method');
  const maxAttempts = 3;
  Object? lastError;
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    if (attempt > 0) {
      await Future<void>.delayed(Duration(seconds: 1 + (attempt - 1) * 2));
    }

    final http.Response response;
    try {
      response = await http.post(
        url,
        headers: const <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );
    } on Exception catch (e) {
      lastError = e;
      continue;
    }

    if (response.statusCode >= 500) {
      lastError = 'HTTP ${response.statusCode}: ${response.body}';
      continue;
    }
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
    final String decoded = raw.substring(brace);
    if (cacheAge != null) {
      _writeCache('prpc', cacheKey, decoded);
    }
    return jsonDecode(decoded) as Map<String, dynamic>;
  }
  throw Exception('Buildbucket $method failed after $maxAttempts attempts: $lastError');
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
