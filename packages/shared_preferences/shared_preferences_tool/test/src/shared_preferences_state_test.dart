// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_tool/src/async_state.dart';
import 'package:shared_preferences_tool/src/shared_preferences_state.dart';

void main() {
  group('SharedPreferencesState', () {
    test('should be possible to set selected key to null', () {
      const SharedPreferencesState state = SharedPreferencesState(
        selectedKey: SelectedSharedPreferencesKey(
          key: 'key',
          value: AsyncState<SharedPreferencesData>.loading(),
        ),
      );

      expect(
        state.copyWith(selectedKey: null),
        equals(const SharedPreferencesState()),
      );
    });
  });

  group('SharedPreferencesData', () {
    test('value as string should return formatted value', () {
      const SharedPreferencesData stringData =
          SharedPreferencesData.string(value: 'value');
      expect(stringData.valueAsString, 'value');

      const SharedPreferencesData intData = SharedPreferencesData.int(value: 1);
      expect(intData.valueAsString, '1');

      const SharedPreferencesData doubleData =
          SharedPreferencesData.double(value: 1.1);
      expect(doubleData.valueAsString, '1.1');

      const SharedPreferencesData boolData =
          SharedPreferencesData.bool(value: true);
      expect(boolData.valueAsString, 'true');

      const SharedPreferencesData stringListData =
          SharedPreferencesData.stringList(value: <String>['value1', 'value2']);
      expect(stringListData.valueAsString, '\n0 -> value1\n1 -> value2');
    });
  });

  test('should return pretty type', () {
    const SharedPreferencesData stringData =
        SharedPreferencesData.string(value: 'value');
    expect(stringData.kind, 'String');

    const SharedPreferencesData intData = SharedPreferencesData.int(value: 1);
    expect(intData.kind, 'int');

    const SharedPreferencesData doubleData =
        SharedPreferencesData.double(value: 1.0);
    expect(doubleData.kind, 'double');

    const SharedPreferencesData boolData =
        SharedPreferencesData.bool(value: true);
    expect(boolData.kind, 'bool');

    const SharedPreferencesData stringListData =
        SharedPreferencesData.stringList(value: <String>['value1', 'value2']);
    expect(stringListData.kind, 'List<String>');
  });

  test('should change value', () {
    const SharedPreferencesData stringData =
        SharedPreferencesData.string(value: 'value');
    const String newStringValue = 'newValue';
    expect(
      stringData.changeValue(newStringValue),
      isA<SharedPreferencesDataString>().having(
        (SharedPreferencesDataString data) => data.value,
        'value',
        equals(newStringValue),
      ),
    );

    const SharedPreferencesData intData = SharedPreferencesData.int(value: 1);
    const String newIntValue = '2';
    expect(
      intData.changeValue(newIntValue),
      isA<SharedPreferencesDataInt>().having(
        (SharedPreferencesDataInt data) => data.value,
        'value',
        equals(int.parse(newIntValue)),
      ),
    );

    const SharedPreferencesData doubleData =
        SharedPreferencesData.double(value: 1.0);
    const String newDoubleValue = '2.0';
    expect(
      doubleData.changeValue(newDoubleValue),
      isA<SharedPreferencesDataDouble>().having(
        (SharedPreferencesDataDouble data) => data.value,
        'value',
        equals(double.parse(newDoubleValue)),
      ),
    );

    const SharedPreferencesData boolData =
        SharedPreferencesData.bool(value: true);
    const String newBoolValue = 'false';
    expect(
      boolData.changeValue(newBoolValue),
      isA<SharedPreferencesDataBool>().having(
        (SharedPreferencesDataBool data) => data.value,
        'value',
        equals(false),
      ),
    );

    const SharedPreferencesData stringListData =
        SharedPreferencesData.stringList(value: <String>['value1', 'value2']);
    const String newStringListValue = '["newValue1", "newValue2"]';
    expect(
      stringListData.changeValue(newStringListValue),
      isA<SharedPreferencesDataStringList>().having(
        (SharedPreferencesDataStringList data) => data.value,
        'value',
        equals(<String>['newValue1', 'newValue2']),
      ),
    );
  });
}
