// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/path_parser.dart';

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
}
