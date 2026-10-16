// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'misc/errors.dart';
import 'route.dart';

final RegExp _parameterNameRegExp = RegExp(r':(\w+)');

/// A `:name` occurrence in a path pattern, with its optional constraint.
class _PathParameter {
  const _PathParameter({
    required this.start,
    required this.end,
    required this.name,
    this.constraint,
  });

  /// Index of the leading `:`.
  final int start;

  /// Exclusive end of the whole occurrence, constraint included.
  final int end;

  final String name;

  /// The parenthesised regular expression constraining this parameter, parens
  /// included (`(\d+)`), or null when the parameter is unconstrained.
  final String? constraint;
}

/// Scans [pattern] for `:name` occurrences, each optionally followed by a
/// `(...)` constraint.
List<_PathParameter> _pathParametersOf(String pattern) {
  final parameters = <_PathParameter>[];
  RegExpMatch? match = _parameterNameRegExp.firstMatch(pattern);
  while (match != null) {
    final int closingParen = _closingParenIndex(pattern, match.end);
    final int end = closingParen != -1 ? closingParen + 1 : match.end;
    final String? name = match[1];

    if (name != null) {
      parameters.add(
        _PathParameter(
          start: match.start,
          end: end,
          name: name,
          constraint: closingParen != -1 ? pattern.substring(match.end, end) : null,
        ),
      );
    }
    match = _parameterNameRegExp.allMatches(pattern, end).firstOrNull;
  }
  return parameters;
}

/// The index of the `)` that closes the `(` at [start], or -1 when [start] is
/// not a `(` or the group is never closed.
///
/// Escaped characters and character classes never open or close a group, so
/// `(\()` and `([()])` are both single groups.
int _closingParenIndex(String pattern, int start) {
  if (start >= pattern.length || pattern[start] != '(') {
    return -1;
  }

  var depth = 0;
  var inCharacterClass = false;
  for (var currentIndex = start; currentIndex < pattern.length; currentIndex++) {
    final String character = pattern[currentIndex];
    if (character == r'\') {
      // The next character is a literal: skip it together with the backslash.
      currentIndex++;
      continue;
    }
    if (inCharacterClass) {
      if (character == ']') {
        inCharacterClass = false;
      }
      continue;
    }
    switch (character) {
      case '[':
        inCharacterClass = true;
      case '(':
        depth++;
      case ')':
        depth--;
        if (depth == 0) {
          return currentIndex;
        }
    }
  }

  return -1;
}

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
RegExp patternToRegExp(String pattern, List<String> parameters, {required bool caseSensitive}) {
  final buffer = StringBuffer('^');
  var start = 0;
  for (final _PathParameter parameter in _pathParametersOf(pattern)) {
    if (parameter.start > start) {
      buffer.write(RegExp.escape(pattern.substring(start, parameter.start)));
    }

    buffer.write('(?<${parameter.name}>${parameter.constraint ?? '[^/]+'})');
    parameters.add(parameter.name);
    start = parameter.end;
  }

  if (start < pattern.length) {
    buffer.write(RegExp.escape(pattern.substring(start)));
  }

  if (!pattern.endsWith('/')) {
    buffer.write(r'(?=/|$)');
  }
  return RegExp(buffer.toString(), caseSensitive: caseSensitive);
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
  final buffer = StringBuffer();
  var start = 0;
  for (final _PathParameter parameter in _pathParametersOf(pattern)) {
    if (parameter.start > start) {
      buffer.write(pattern.substring(start, parameter.start));
    }
    buffer.write(pathParameters[parameter.name]);
    start = parameter.end;
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
Map<String, String> extractPathParameters(List<String> parameters, RegExpMatch match) {
  return <String, String>{
    for (int i = 0; i < parameters.length; ++i) parameters[i]: match.namedGroup(parameters[i])!,
  };
}

/// Concatenates two paths.
///
/// e.g: pathA = /a, pathB = /c/d, concatenatePaths(pathA, pathB) = /a/c/d.
/// or: pathA = a, pathB = c/d, concatenatePaths(pathA, pathB) = /a/c/d.
String concatenatePaths(String parentPath, String childPath) {
  final Iterable<String> segments = <String>[
    ...parentPath.split('/'),
    ...childPath.split('/'),
  ].where((String segment) => segment.isNotEmpty);
  return '/${segments.join('/')}';
}

/// Concatenates two Uri. It will [concatenatePaths] the parent's and the child's paths, and take only the child's parameters.
///
/// e.g: pathA = /a?fid=f1, pathB = c/d?pid=p2,  concatenatePaths(pathA, pathB) = /a/c/d?pid=2.
Uri concatenateUris(Uri parentUri, Uri childUri) {
  Uri newUri = childUri.replace(path: concatenatePaths(parentUri.path, childUri.path));

  // Parse the new normalized uri to remove unnecessary parts, like the trailing '?'.
  newUri = Uri.parse(canonicalUri(newUri.toString()));
  return newUri;
}

/// Normalizes the location string.
String canonicalUri(String loc) {
  if (loc.isEmpty) {
    throw GoException('Location cannot be empty.');
  }
  var canon = Uri.parse(loc).toString();
  canon = canon.endsWith('?') ? canon.substring(0, canon.length - 1) : canon;
  final Uri uri = Uri.parse(canon);

  // remove trailing slash except for when you shouldn't, e.g.
  // /profile/ => /profile
  // / => /
  // /login?from=/ => /login?from=/
  canon = uri.path.endsWith('/') && uri.path != '/' && !uri.hasQuery && !uri.hasFragment
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
String? fullPathForRoute(RouteBase targetRoute, String parentFullpath, List<RouteBase> routes) {
  for (final route in routes) {
    final String fullPath = (route is GoRoute)
        ? concatenatePaths(parentFullpath, route.path)
        : parentFullpath;

    if (route == targetRoute) {
      return fullPath;
    } else {
      final String? subRoutePath = fullPathForRoute(targetRoute, fullPath, route.routes);
      if (subRoutePath != null) {
        return subRoutePath;
      }
    }
  }
  return null;
}
