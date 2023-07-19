// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The base type of all tokens produced by a path specification.
abstract class Token {
  /// The name of the parameter.
  String get name;

  /// Parses a [path] specification.
  static List<Token> parse(String path) => _parse(path);
}

/// Corresponds to a parameter of a path specification.
class ParameterToken implements Token {
  /// Creates a parameter token for [name].
  ParameterToken(this.name);

  /// The parameter name.
  @override
  final String name;
}

/// Corresponds to a non-parameterized section of a path specification.
class PathToken implements Token {
  /// Creates a path token with [name].
  PathToken(this.name);

  /// A substring of the path specification.
  @override
  final String name;
}

/// The regular expression used to extract parameters from a path specification.
///
/// Capture groups:
///   1. The parameter name.
///   2. An optional pattern.
final RegExp _parameterRegExp = RegExp(
  /* (1) */ r':(\w+)'
  /* (2) */ r'(\((?:\\.|[^\\()])+\))?',
);

/// Parses a [path] specification.
List<Token> _parse(String path) {
  final Iterable<RegExpMatch> matches = _parameterRegExp.allMatches(path);
  final List<Token> tokens = <Token>[];
  int start = 0;
  for (final RegExpMatch match in matches) {
    if (match.start > start) {
      tokens.add(PathToken(path.substring(start, match.start)));
    }
    final String name = match[1]!;
    tokens.add(ParameterToken(name));
    start = match.end;
  }
  if (start < path.length) {
    tokens.add(PathToken(path.substring(start)));
  }
  return tokens;
}
