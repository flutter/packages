// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'misc/errors.dart';
import 'route.dart';

final RegExp _parameterRegExp = RegExp(r':(\w+)(\((?:\\.|[^\\()])+\))?');

/// Converts a [pattern] such as `/user/:id` into [RegExp].
///
/// The path parameters can be specified by prefixing them with `:`. The
/// `parameters` are used for storing path parameter names.
///
///
/// For example:
///
///  `pattern` = `/user/:id/book/:bookId`
///
///  The `parameters` would contain `['id', 'bookId']` as a result of calling
///  this method.
///
/// To extract the path parameter values from a [RegExpMatch], pass the
/// [RegExpMatch] into [extractPathParameters] with the `parameters` that are
/// used for generating the [RegExp].
RegExp patternToRegExp(String pattern, List<String> parameters) {
  final StringBuffer buffer = StringBuffer('^');
  int start = 0;
  for (final RegExpMatch match in _parameterRegExp.allMatches(pattern)) {
    if (match.start > start) {
      buffer.write(RegExp.escape(pattern.substring(start, match.start)));
    }
    final String name = match[1]!;
    final String? optionalPattern = match[2];
    final String regex = optionalPattern != null
        ? _escapeGroup(optionalPattern, name)
        : '(?<$name>[^/]+)';
    buffer.write(regex);
    parameters.add(name);
    start = match.end;
  }

  if (start < pattern.length) {
    buffer.write(RegExp.escape(pattern.substring(start)));
  }

  if (!pattern.endsWith('/')) {
    buffer.write(r'(?=/|$)');
  }
  return RegExp(buffer.toString(), caseSensitive: false);
}

String _escapeGroup(String group, [String? name]) {
  final String escapedGroup = group.replaceFirstMapped(
      RegExp(r'[:=!]'), (Match match) => '\\${match[0]}');
  if (name != null) {
    return '(?<$name>$escapedGroup)';
  }
  return escapedGroup;
}

/// Reconstructs the full path from a [pattern] and path parameters.
///
/// This is useful for restoring the original path from a [RegExpMatch].
///
/// For example, A path matched a [RegExp] returned from [patternToRegExp] and
/// produced a [RegExpMatch]. To reconstruct the path from the match, one
/// can follow these steps:
///
/// 1. Get the `pathParameters` by calling [extractPathParameters] with the
///    [RegExpMatch] and the parameters used for generating the [RegExp].
/// 2. Call [patternToPath] with the `pathParameters` from the first step and
///    the original `pattern` used for generating the [RegExp].
String patternToPath(String pattern, Map<String, String> pathParameters) {
  final StringBuffer buffer = StringBuffer();
  int start = 0;
  for (final RegExpMatch match in _parameterRegExp.allMatches(pattern)) {
    if (match.start > start) {
      buffer.write(pattern.substring(start, match.start));
    }
    final String name = match[1]!;
    buffer.write(pathParameters[name]);
    start = match.end;
  }

  if (start < pattern.length) {
    buffer.write(pattern.substring(start));
  }
  return buffer.toString();
}

/// Extracts arguments from the `match` and maps them by parameter name.
///
/// The [parameters] should originate from the call to [patternToRegExp] that
/// creates the [RegExp].
Map<String, String> extractPathParameters(
    List<String> parameters, RegExpMatch match) {
  return <String, String>{
    for (int i = 0; i < parameters.length; ++i)
      parameters[i]: match.namedGroup(parameters[i])!
  };
}

/// Concatenates two paths.
///
/// e.g: pathA = /a, pathB = /c/d, concatenatePaths(pathA, pathB) = /a/c/d.
/// or: pathA = a, pathB = c/d, concatenatePaths(pathA, pathB) = /a/c/d.
String concatenatePaths(String parentPath, String childPath) {
  final Iterable<String> segments = <String>[
    ...parentPath.split('/'),
    ...childPath.split('/')
  ].where((String segment) => segment.isNotEmpty);
  return '/${segments.join('/')}';
}

/// Concatenates two Uri. It will [concatenatePaths] the parent's and the child's paths, and take only the child's parameters.
///
/// e.g: pathA = /a?fid=f1, pathB = c/d?pid=p2,  concatenatePaths(pathA, pathB) = /a/c/d?pid=2.
Uri concatenateUris(Uri parentUri, Uri childUri) {
  Uri newUri = childUri.replace(
    path: concatenatePaths(parentUri.path, childUri.path),
  );

  // Parse the new normalized uri to remove unnecessary parts, like the trailing '?'.
  newUri = Uri.parse(canonicalUri(newUri.toString()));
  return newUri;
}

/// Normalizes the location string.
String canonicalUri(String loc) {
  if (loc.isEmpty) {
    throw GoException('Location cannot be empty.');
  }
  String canon = Uri.parse(loc).toString();
  canon = canon.endsWith('?') ? canon.substring(0, canon.length - 1) : canon;
  final Uri uri = Uri.parse(canon);

  // remove trailing slash except for when you shouldn't, e.g.
  // /profile/ => /profile
  // / => /
  // /login?from=/ => /login?from=/
  canon = uri.path.endsWith('/') &&
          uri.path != '/' &&
          !uri.hasQuery &&
          !uri.hasFragment
      ? canon.substring(0, canon.length - 1)
      : canon;

  // replace '/?', except for first occurrence, from path only
  // /login/?from=/ => /login?from=/
  // /?from=/ => /?from=/
  final int pathStartIndex = uri.host.isNotEmpty
      ? uri.toString().indexOf(uri.host) + uri.host.length
      : uri.hasScheme
          ? uri.toString().indexOf(uri.scheme) + uri.scheme.length
          : 0;
  if (pathStartIndex < canon.length) {
    canon = canon.replaceFirst('/?', '?', pathStartIndex + 1);
  }

  return canon;
}

/// Builds an absolute path for the provided route.
String? fullPathForRoute(
    RouteBase targetRoute, String parentFullpath, List<RouteBase> routes) {
  for (final RouteBase route in routes) {
    final String fullPath = (route is GoRoute)
        ? concatenatePaths(parentFullpath, route.path)
        : parentFullpath;

    if (route == targetRoute) {
      return fullPath;
    } else {
      final String? subRoutePath =
          fullPathForRoute(targetRoute, fullPath, route.routes);
      if (subRoutePath != null) {
        return subRoutePath;
      }
    }
  }
  return null;
}
