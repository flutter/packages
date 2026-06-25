// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:open_enum/open_enum.dart';
import 'package:test/test.dart';

// Test enum based on String
extension type const StringEnum(String name) implements OpenEnum<String> {
  static const StringEnum one = StringEnum('one');
  static const StringEnum two = StringEnum('two');

  static const List<StringEnum> values = [one, two];
}

// Test enum based on int
extension type const IntEnum(int index) implements OpenEnum<int> {
  static const IntEnum zero = IntEnum(0);
  static const IntEnum one = IntEnum(1);

  static const List<IntEnum> values = [zero, one];
}

void main() {
  group('String-based OpenEnum', () {
    test('inherits value getter', () {
      expect(StringEnum.one.value, 'one');
      expect(StringEnum.two.value, 'two');
    });

    test('byValue returns correct element or null', () {
      expect(StringEnum.values.byValue('one'), StringEnum.one);
      expect(StringEnum.values.byValue('three'), isNull);
    });

    test('byName returns correct element or throws', () {
      expect(StringEnum.values.byName('one'), StringEnum.one);
      expect(() => StringEnum.values.byName('three'), throwsA(isA<ArgumentError>()));
    });

    test('byNameOrNull returns correct element or null', () {
      expect(StringEnum.values.byNameOrNull('one'), StringEnum.one);
      expect(StringEnum.values.byNameOrNull('three'), isNull);
    });
  });

  group('Int-based OpenEnum', () {
    test('inherits value getter', () {
      expect(IntEnum.zero.value, 0);
      expect(IntEnum.one.value, 1);
    });

    test('byValue returns correct element or null', () {
      expect(IntEnum.values.byValue(0), IntEnum.zero);
      expect(IntEnum.values.byValue(2), isNull);
    });
  });

  group('Evolution safety (non-exhaustiveness)', () {
    test('non-exhaustive switch compiles and behaves correctly with new values', () {
      // Simulate receiving a value that isn't in our current known set
      const newlyAddedValue = StringEnum('three');

      String handle(StringEnum value) {
        // This switch does not cover all possible values (it omits any newly
        // added values), but it compiles cleanly because it is an extension type.
        switch (value) {
          case StringEnum.one:
            return 'matched one';
          case StringEnum.two:
            return 'matched two';
        }
        return 'matched fallback';
      }

      expect(handle(StringEnum.one), 'matched one');
      expect(handle(newlyAddedValue), 'matched fallback');
    });
  });
}
