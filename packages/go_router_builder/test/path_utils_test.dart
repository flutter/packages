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

    test('It should support a nested group in the parameter pattern', () {
      expect(
        pathParametersFromPattern(r'/user/:id((?!(?:0|1)(?:/|$))[^/]+)/book/:bookId'),
        const <String>{'id', 'bookId'},
      );
    });

    test('It should support group constructs in the parameter pattern', () {
      expect(pathParametersFromPattern(r'/user/:id((?:0x)?\d+)'), const <String>{'id'});
    });

    test('It should support parentheses in a character class', () {
      expect(pathParametersFromPattern(r'/a/:x([()])/:y'), const <String>{'x', 'y'});
    });

    test('It should support a nested group containing an alternation', () {
      expect(pathParametersFromPattern(r'/details/:id((FOO|BAR)[0-9a-zA-Z]{10})'), const <String>{
        'id',
      });
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

    test('It should support a nested group in the parameter pattern', () {
      expect(
        patternToPath(r'/tags/:slug((?!(?:admin|new)(?:/|$))[^/]+)', const <String, String>{
          'slug': 'flutter',
        }),
        '/tags/flutter',
      );
    });

    test('It should support group constructs in the parameter pattern', () {
      expect(
        patternToPath(r'/user/:id((?:0x)?\d+)/book', const <String, String>{'id': '0x42'}),
        '/user/0x42/book',
      );
    });

    test('It should support parentheses in a character class', () {
      expect(patternToPath(r'/a/:x([()])', const <String, String>{'x': '('}), '/a/(');
    });

    test('It should support a nested group containing an alternation', () {
      expect(
        patternToPath(r'/details/:id((FOO|BAR)[0-9a-zA-Z]{10})', const <String, String>{
          'id': 'FOO0123456789',
        }),
        '/details/FOO0123456789',
      );
    });
  });
}
