// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

final _parameterRegExp = RegExp(r':(\w+)(\((?:\\.|[^\\()])+\))?');

/// Creates a [RegExp] that matches a [pattern] specification.
///
/// The path parameter names are stored into [parameters.
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
  final String escapedGroup =  group.replaceFirstMapped(RegExp(r'[:=!]'), (Match match) => '\\${match[0]}');
  return '(?<$name>$escapedGroup)';
}

/// Reconstruct the full path from a [pattern] specification.
String patternToPath(String pattern, Map<String, String> args) {
  final StringBuffer buffer = StringBuffer('');
  int start = 0;
  for (final RegExpMatch match in _parameterRegExp.allMatches(pattern)) {
    if (match.start > start) {
      buffer.write(pattern.substring(start, match.start));
    }
    final String name = match[1]!;
    buffer.write(args[name]);
    start = match.end;
  }

  if (start < pattern.length) {
    buffer.write(pattern.substring(start));
  }
  return buffer.toString();
}

/// Extracts arguments from [match] and maps them by parameter name.
///
/// The [parameters] should originate from the same path specification used to
/// create the [RegExp] that produced the [match].
Map<String, String> extract(List<String> parameters, RegExpMatch match) {
  return <String, String>{
    for (var i = 0; i < parameters.length; ++i) parameters[i]: match.namedGroup(parameters[i])!
  };
}
