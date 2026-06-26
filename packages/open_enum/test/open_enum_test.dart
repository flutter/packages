// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: use_named_constants

import 'dart:convert';

import 'package:open_enum/open_enum.dart';
import 'package:test/test.dart';

// Test enum based on String
extension type const StringEnum._(String name) implements OpenEnum<String> {
  static const StringEnum one = StringEnum._('one');
  static const StringEnum two = StringEnum._('two');

  static const List<StringEnum> values = [one, two];
}

// Test enum based on int
extension type const IntEnum._(int index) implements OpenEnum<int> {
  static const IntEnum zero = IntEnum._(0);
  static const IntEnum one = IntEnum._(1);

  static const List<IntEnum> values = [zero, one];
}

// Test enum based on record (index + name)
extension type const RecordEnum._(({int index, String name}) data) implements OpenEnumRecord {
  static const RecordEnum zero = RecordEnum._((index: 0, name: 'zero'));
  static const RecordEnum one = RecordEnum._((index: 1, name: 'one'));

  static const List<RecordEnum> values = [zero, one];
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

  group('Record-based OpenEnumRecord', () {
    test('inherits index and name getters', () {
      expect(RecordEnum.zero.index, 0);
      expect(RecordEnum.zero.name, 'zero');
      expect(RecordEnum.one.index, 1);
      expect(RecordEnum.one.name, 'one');
    });

    test('byName returns correct element or throws', () {
      expect(RecordEnum.values.byName('zero'), RecordEnum.zero);
      expect(() => RecordEnum.values.byName('two'), throwsA(isA<ArgumentError>()));
    });

    test('byNameOrNull returns correct element or null', () {
      expect(RecordEnum.values.byNameOrNull('zero'), RecordEnum.zero);
      expect(RecordEnum.values.byNameOrNull('two'), isNull);
    });

    test('byIndex returns correct element or null', () {
      expect(RecordEnum.values.byIndex(0), RecordEnum.zero);
      expect(RecordEnum.values.byIndex(2), isNull);
    });
  });

  group('Evolution safety (non-exhaustiveness)', () {
    test('non-exhaustive switch compiles and behaves correctly with new values', () {
      // Simulate receiving a value that isn't in our current known set
      const newlyAddedValue = StringEnum._('three');

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

  group('Standard Enum-like Contracts', () {
    test('equality and hashCode contracts behave correctly', () {
      // String enums comparison
      expect(StringEnum.one == const StringEnum._('one'), isTrue);
      expect(StringEnum.one == StringEnum.two, isFalse);
      expect(StringEnum.one.hashCode == const StringEnum._('one').hashCode, isTrue);

      // Record enums comparison
      expect(RecordEnum.zero == const RecordEnum._((index: 0, name: 'zero')), isTrue);
      expect(RecordEnum.zero == RecordEnum.one, isFalse);
      expect(
        RecordEnum.zero.hashCode == const RecordEnum._((index: 0, name: 'zero')).hashCode,
        isTrue,
      );
    });

    test('identical works for constant instances', () {
      expect(identical(StringEnum.one, const StringEnum._('one')), isTrue);
      expect(identical(RecordEnum.zero, const RecordEnum._((index: 0, name: 'zero'))), isTrue);
    });

    test('behaves correctly in Sets and Maps', () {
      final set = <StringEnum>{StringEnum.one, StringEnum.two};
      expect(set.contains(const StringEnum._('one')), isTrue);
      expect(set.contains(const StringEnum._('three')), isFalse);

      final map = <RecordEnum, String>{RecordEnum.zero: 'Zero Value'};
      expect(map[const RecordEnum._((index: 0, name: 'zero'))], 'Zero Value');
      expect(map[RecordEnum.one], isNull);
    });
  });

  group('JSON Serialization and Deserialization', () {
    test('natively serializes to primitive JSON representations', () {
      expect(jsonEncode(StringEnum.one), '"one"');
      expect(jsonEncode(IntEnum.zero), '0');

      // Record open enums require calling .toJson() explicitly because Records
      // are erased at runtime and cannot invoke extension type getters via dynamic dispatch.
      expect(jsonEncode(RecordEnum.zero.toJson()), '{"index":0,"name":"zero"}');
    });

    test('deserializes safely and supports runtime lookups', () {
      const payload = '{"role": "one"}';
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final roleStr = data['role'] as String;

      final StringEnum? role = StringEnum.values.byNameOrNull(roleStr);
      expect(role, StringEnum.one);
    });
  });
}
