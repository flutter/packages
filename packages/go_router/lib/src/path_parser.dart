// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

String _escapeGroup(String group, String name) {
  final String escapedGroup = group.replaceFirstMapped(
      RegExp(r'[:=!]'), (Match match) => '\\${match[0]}');
  return '(?<$name>$escapedGroup)';
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
  final StringBuffer buffer = StringBuffer('');
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
