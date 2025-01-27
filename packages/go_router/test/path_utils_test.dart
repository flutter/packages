// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/path_utils.dart';

void main() {
  test('patternToRegExp without path parameter', () async {
    const String pattern = '/settings/detail';
    final List<String> pathParameter = <String>[];
    final RegExp regex = patternToRegExp(pattern, pathParameter);
    expect(pathParameter.isEmpty, isTrue);
    expect(regex.hasMatch('/settings/detail'), isTrue);
    expect(regex.hasMatch('/settings/'), isFalse);
    expect(regex.hasMatch('/settings'), isFalse);
    expect(regex.hasMatch('/'), isFalse);
    expect(regex.hasMatch('/settings/details'), isFalse);
    expect(regex.hasMatch('/setting/detail'), isFalse);
  });

  test('patternToRegExp with path parameter', () async {
    const String pattern = '/user/:id/book/:bookId';
    final List<String> pathParameter = <String>[];
    final RegExp regex = patternToRegExp(pattern, pathParameter);
    expect(pathParameter.length, 2);
    expect(pathParameter[0], 'id');
    expect(pathParameter[1], 'bookId');

    final RegExpMatch? match = regex.firstMatch('/user/123/book/456/');
    expect(match, isNotNull);
    final Map<String, String> parameterValues =
        extractPathParameters(pathParameter, match!);
    expect(parameterValues.length, 2);
    expect(parameterValues[pathParameter[0]], '123');
    expect(parameterValues[pathParameter[1]], '456');

    expect(regex.hasMatch('/user/123/book/'), isFalse);
    expect(regex.hasMatch('/user/123'), isFalse);
    expect(regex.hasMatch('/user/'), isFalse);
    expect(regex.hasMatch('/'), isFalse);
  });

  test('patternToPath without path parameter', () async {
    const String pattern = '/settings/detail';
    final List<String> pathParameter = <String>[];
    final RegExp regex = patternToRegExp(pattern, pathParameter);

    const String url = '/settings/detail';
    final RegExpMatch? match = regex.firstMatch(url);
    expect(match, isNotNull);

    final Map<String, String> parameterValues =
        extractPathParameters(pathParameter, match!);
    final String restoredUrl = patternToPath(pattern, parameterValues);

    expect(url, restoredUrl);
  });

  test('patternToPath with path parameter', () async {
    const String pattern = '/user/:id/book/:bookId';
    final List<String> pathParameter = <String>[];
    final RegExp regex = patternToRegExp(pattern, pathParameter);

    const String url = '/user/123/book/456';
    final RegExpMatch? match = regex.firstMatch(url);
    expect(match, isNotNull);

    final Map<String, String> parameterValues =
        extractPathParameters(pathParameter, match!);
    final String restoredUrl = patternToPath(pattern, parameterValues);

    expect(url, restoredUrl);
  });

  test('concatenatePaths', () {
    void verify(String pathA, String pathB, String expected) {
      final String result = concatenatePaths(pathA, pathB);
      expect(result, expected);
    }

    verify('/a', 'b/c', '/a/b/c');
    verify('/', 'b', '/b');
    verify('/a', '/b/c/', '/a/b/c');
    verify('/a', 'b/c', '/a/b/c');
    verify('/', '/', '/');
    verify('', '', '/');
  });

  test('concatenateUris', () {
    void verify(String pathA, String pathB, String expected) {
      final String result =
          concatenateUris(Uri.parse(pathA), Uri.parse(pathB)).toString();
      expect(result, expected);
    }

    verify('/a', 'b/c', '/a/b/c');
    verify('/', 'b', '/b');

    // Test with parameters
    verify('/a?fid=f1', 'b/c?', '/a/b/c');
    verify('/a', 'b/c?pid=p2', '/a/b/c?pid=p2');
    verify('/a?fid=f1', 'b/c?pid=p2', '/a/b/c?pid=p2');

    // Test with fragment
    verify('/a#f', 'b/c#f2', '/a/b/c#f2');

    // Test with fragment and parameters
    verify('/a?fid=f1#f', 'b/c?pid=p2#', '/a/b/c?pid=p2#');
  });

  test('canonicalUri', () {
    void verify(String path, String expected) =>
        expect(canonicalUri(path), expected);
    verify('/a', '/a');
    verify('/a/', '/a');
    verify('/', '/');
    verify('/a/b/', '/a/b');
    verify('https://www.example.com/', 'https://www.example.com/');
    verify('https://www.example.com/a', 'https://www.example.com/a');
    verify('https://www.example.com/a/', 'https://www.example.com/a');
    verify('https://www.example.com/a/b/', 'https://www.example.com/a/b');
    verify('https://www.example.com/?', 'https://www.example.com/');
    verify('https://www.example.com/?a=b', 'https://www.example.com/?a=b');
    verify('https://www.example.com/?a=/', 'https://www.example.com/?a=/');
    verify('https://www.example.com/a/?b=c', 'https://www.example.com/a?b=c');
    verify('https://www.example.com/#a/', 'https://www.example.com/#a/');

    expect(() => canonicalUri('::::'), throwsA(isA<FormatException>()));
    expect(() => canonicalUri(''), throwsA(anything));
  });
}
