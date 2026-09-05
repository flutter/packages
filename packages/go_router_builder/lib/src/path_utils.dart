// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:collection/collection.dart';

final RegExp _parameterNameRegExp = RegExp(r':(\w+)');

/// A `:name` occurrence in a path pattern, with its optional constraint.
class _PathParameter {
  const _PathParameter({required this.start, required this.end, required this.name});

  /// Index of the leading `:`.
  final int start;

  /// Exclusive end of the whole occurrence, constraint included.
  final int end;

  final String name;
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
      parameters.add(_PathParameter(start: match.start, end: end, name: name));
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

/// Extracts the path parameters from a [pattern] such as `/user/:id`.
///
/// The path parameters can be specified by prefixing them with `:`.
///
/// For example:
///
/// ```dart
/// final pattern = '/user/:id/book/:bookId';
/// final pathParameters = pathParametersFromPattern(pattern); // {'id', 'bookId'}
/// ```
Set<String> pathParametersFromPattern(String pattern) => <String>{
  for (final _PathParameter parameter in _pathParametersOf(pattern)) parameter.name,
};

/// Reconstructs the full path from a [pattern] and path parameters.
///
/// For example:
///
/// ```dart
/// final pattern = '/family/:id';
/// final path = patternToPath(pattern, {'id': 'family-id'}); // '/family/family-id'
/// ```
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
