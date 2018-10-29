// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';

import 'package:sentry/src/utils.dart';

void main() {
  group('mergeAttributes', () {
    test('merges attributes', () {
      final Map<String, dynamic> target = <String, dynamic>{
        'overwritten': 1,
        'unchanged': 2,
        'recursed': <String, dynamic>{
          'overwritten_child': [1, 2, 3],
          'unchanged_child': 'qwerty',
        },
      };

      final Map<String, dynamic> attributes = <String, dynamic>{
        'overwritten': 2,
        'recursed': <String, dynamic>{
          'overwritten_child': [4, 5, 6],
        },
      };

      mergeAttributes(attributes, into: target);
      expect(target, <String, dynamic>{
        'overwritten': 2,
        'unchanged': 2,
        'recursed': <String, dynamic>{
          'overwritten_child': [4, 5, 6],
          'unchanged_child': 'qwerty',
        },
      });
    });

    test('does not allow overriding original maps', () {
      final environment = <String, dynamic>{
        'extra': {
          'device': 'Pixel 2',
        },
      };

      final event = <String, dynamic>{
        'extra': {
          'widget': 'Scaffold',
        },
      };

      final target = <String, dynamic>{};
      mergeAttributes(environment, into: target);
      mergeAttributes(event, into: target);
      expect(environment['extra'], {'device': 'Pixel 2'});
    });
  });

  group('formatDateAsIso8601WithSecondPrecision', () {
    test('strips sub-millisecond parts', () {
      final DateTime testDate =
          new DateTime.fromMillisecondsSinceEpoch(1502467721598, isUtc: true);
      expect(testDate.toIso8601String(), '2017-08-11T16:08:41.598Z');
      expect(formatDateAsIso8601WithSecondPrecision(testDate),
          '2017-08-11T16:08:41');
    });
  });
}
