// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Represents a route pattern such as '/books/:bookId'
class RoutePath {
  /// Constructs a [RoutePath] given a pattern such as '/books/:bookId'
  RoutePath(this._pattern) {
    final ({RegExp regExp, List<String> parameters}) result =
        _buildRegExp(_pattern);
    _patternRegExp = result.regExp;
    parameters = result.parameters;
  }

  static final RegExp _parameterRegExp =
      RegExp(r':(\w+)(\((?:\\.|[^\\()])+\))?');

  /// route pattern such as '/books/:bookId'
  final String _pattern;
  late final RegExp _patternRegExp;

  /// The parameters presents in the pattern,
  /// such that RoutePath('/users/:userId/books/:bookId')
  /// will have as parameters ['userId', 'bookId']
  late final List<String> parameters;

  /// matches a location against this route path
  RegExpMatch? match(String location) {
    return _patternRegExp.matchAsPrefix(location) as RegExpMatch?;
  }

  /// Constructs the full location by providing the path paramters
  ///
  /// Example:
  ///
  /// RoutePath('/books/:bookgId').toLocation({'bookId': 3}) => /books/3
  String toLocation(Map<String, String> pathParameters) {
    final StringBuffer buffer = StringBuffer();
    int start = 0;
    for (final RegExpMatch match in _parameterRegExp.allMatches(_pattern)) {
      if (match.start > start) {
        buffer.write(_pattern.substring(start, match.start));
      }
      final String name = match[1]!;
      buffer.write(pathParameters[name]);
      start = match.end;
    }

    if (start < _pattern.length) {
      buffer.write(_pattern.substring(start));
    }
    return buffer.toString();
  }

  /// Extracts the path parameters from the `match` and maps them by parameter name.
  Map<String, String> extractPathParameters(RegExpMatch match) {
    return <String, String>{
      for (int i = 0; i < parameters.length; ++i)
        parameters[i]: match.namedGroup(parameters[i])!
    };
  }

  /// Concatenates two patterns.
  ///
  /// e.g: pathA = /a, pathB = /c/d, concatenatePaths(pathA, pathB) = /a/c/d.
  /// or: pathA = a, pathB = c/d, concatenatePaths(pathA, pathB) = /a/c/d.
  RoutePath concatenate(RoutePath next) {
    final Iterable<String> segments = <String>[
      ..._pattern.split('/'),
      ...next._pattern.split('/')
    ].where((String segment) => segment.isNotEmpty);
    return RoutePath('/${segments.join('/')}');
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
  /// [RegExpMatch] into [_buildRegExp] with the `parameters` that are
  /// used for generating the [RegExp].
  static ({RegExp regExp, List<String> parameters}) _buildRegExp(
      String pattern) {
    final List<String> parameters = <String>[];
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
    final RegExp regExp = RegExp(buffer.toString(), caseSensitive: false);
    return (regExp: regExp, parameters: parameters);
  }

  static String _escapeGroup(String group, [String? name]) {
    final String escapedGroup = group.replaceFirstMapped(
        RegExp(r'[:=!]'), (Match match) => '\\${match[0]}');
    if (name != null) {
      return '(?<$name>$escapedGroup)';
    }
    return escapedGroup;
  }

  @override
  String toString() => _pattern;
}
