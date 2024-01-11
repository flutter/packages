// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router_builder/src/path_utils.dart';
import 'package:test/test.dart';

void main() {
  group('pathParametersFromPattern', () {
    test('It should return the parameters of the path', () {
      expect(pathParametersFromPattern('/'), const <String>{});
      expect(pathParametersFromPattern('/user'), const <String>{});
      expect(pathParametersFromPattern('/user/:id'), const <String>{'id'});
      expect(pathParametersFromPattern('/user/:id/book'), const <String>{'id'});
      expect(
        pathParametersFromPattern('/user/:id/book/:bookId'),
        const <String>{'id', 'bookId'},
      );
    });
  });

  group('patternToPath', () {
    test('It should replace the path parameters with their values', () {
      expect(patternToPath('/', const <String, String>{}), '/');
      expect(patternToPath('/user', const <String, String>{}), '/user');
      expect(
          patternToPath('/user/:id', const <String, String>{'id': 'user-id'}),
          '/user/user-id');
      expect(
          patternToPath(
              '/user/:id/book', const <String, String>{'id': 'user-id'}),
          '/user/user-id/book');
      expect(
        patternToPath('/user/:id/book/:bookId',
            const <String, String>{'id': 'user-id', 'bookId': 'book-id'}),
        '/user/user-id/book/book-id',
      );
    });
  });
}
