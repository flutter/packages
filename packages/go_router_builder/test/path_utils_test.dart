// Copyright 2013 The Flutter Authors
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
      expect(pathParametersFromPattern('/user/:id/book/:bookId'), const <String>{'id', 'bookId'});
    });
  });

  group('normalizePathParameters', () {
    test('It should leave a pattern without parameters alone', () {
      expect(normalizePathParameters('/'), '/');
      expect(normalizePathParameters('/user/book'), '/user/book');
    });

    test('It should make patterns differing only in parameter name equal', () {
      expect(normalizePathParameters('/user/:id'), normalizePathParameters('/user/:userId'));
      expect(
        normalizePathParameters('/user/:id/book/:bookId'),
        normalizePathParameters('/user/:a/book/:b'),
      );
    });

    test('It should keep patterns with different literal segments distinct', () {
      expect(normalizePathParameters('/user/:id'), isNot(normalizePathParameters('/book/:id')));
      expect(
        normalizePathParameters('/user/:id'),
        isNot(normalizePathParameters('/user/:id/book')),
      );
    });

    test('It should keep a parameter constraint, which changes what matches', () {
      expect(normalizePathParameters(r'/user/:id(\d+)'), r'/user/:_(\d+)');
      expect(
        normalizePathParameters(r'/user/:id(\d+)'),
        isNot(normalizePathParameters(r'/user/:id(\w+)')),
      );
      // A colon inside a constraint is part of the constraint, not a second
      // parameter, so these two must stay distinct.
      expect(
        normalizePathParameters('/user/:id(mon:tue)'),
        isNot(normalizePathParameters('/user/:id(mon:wed)')),
      );
    });
  });

  group('patternToPath', () {
    test('It should replace the path parameters with their values', () {
      expect(patternToPath('/', const <String, String>{}), '/');
      expect(patternToPath('/user', const <String, String>{}), '/user');
      expect(patternToPath('/user/:id', const <String, String>{'id': 'user-id'}), '/user/user-id');
      expect(
        patternToPath('/user/:id/book', const <String, String>{'id': 'user-id'}),
        '/user/user-id/book',
      );
      expect(
        patternToPath('/user/:id/book/:bookId', const <String, String>{
          'id': 'user-id',
          'bookId': 'book-id',
        }),
        '/user/user-id/book/book-id',
      );
    });
  });
}
