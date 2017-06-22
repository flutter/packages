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
  });
}
