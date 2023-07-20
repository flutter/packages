// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

final RegExp _parameterRegExp = RegExp(r':(\w+)(\((?:\\.|[^\\()])+\))?');

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
      for (final RegExpMatch match in _parameterRegExp.allMatches(pattern))
        match[1]!,
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
