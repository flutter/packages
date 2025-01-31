// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_tool/src/async_state.dart';
import 'package:shared_preferences_tool/src/shared_preferences_state.dart';
import 'package:shared_preferences_tool/src/shared_preferences_state_provider.dart';
import 'package:shared_preferences_tool/src/ui/data_panel.dart';
import 'package:shared_preferences_tool/src/ui/error_panel.dart';

import '../../test_helpers/notifier_mocking_helpers.dart';
import '../../test_helpers/notifier_mocking_helpers.mocks.dart';

void main() {
  group('DataPanel', () {
    setupDummies();

    late MockSharedPreferencesStateNotifier notifierMock;

    setUp(() {
      notifierMock = MockSharedPreferencesStateNotifier();
    });

    Future<void> pumpDataPanel(WidgetTester tester) {
      return tester.pumpWidget(
        DevToolsExtension(
          requiresRunningApplication: false,
          child: InnerSharedPreferencesStateProvider(
            notifier: notifierMock,
            child: const DataPanel(),
          ),
        ),
      );
    }

    void stubAsyncState(
      AsyncState<SharedPreferencesData>? state, {
      bool editing = false,
    }) {
      const String selectedKey = 'selectedTestKey';
      when(notifierMock.value).thenReturn(
        SharedPreferencesState(
          allKeys: const AsyncState<List<String>>.data(<String>[selectedKey]),
          editing: editing,
          selectedKey: state == null
              ? null
              : SelectedSharedPreferencesKey(
                  key: selectedKey,
                  value: state,
                ),
        ),
      );
    }

    void stubDataState(SharedPreferencesData state, {bool editing = false}) {
      stubAsyncState(
        AsyncState<SharedPreferencesData>.data(state),
        editing: editing,
      );
    }

    testWidgets('should show select key state', (WidgetTester tester) async {
      stubAsyncState(null);
      await pumpDataPanel(tester);

      expect(find.text('Select a key to view its data.'), findsOneWidget);
    });

    testWidgets('should show loading state', (WidgetTester tester) async {
      stubAsyncState(const AsyncState<SharedPreferencesData>.loading());
      await pumpDataPanel(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error state', (WidgetTester tester) async {
      stubAsyncState(
        const AsyncState<SharedPreferencesData>.error(
          'error',
          StackTrace.empty,
        ),
      );
      await pumpDataPanel(tester);

      expect(find.byType(ErrorPanel), findsOneWidget);
    });

    testWidgets('should show string value', (WidgetTester tester) async {
      const String value = 'testValue';
      stubDataState(const SharedPreferencesData.string(value: value));
      await pumpDataPanel(tester);

      expect(find.text('Type: String'), findsOneWidget);
      expect(find.text('Value: $value'), findsOneWidget);
    });

    testWidgets('should show int value', (WidgetTester tester) async {
      const int value = 42;
      stubDataState(const SharedPreferencesData.int(value: value));
      await pumpDataPanel(tester);

      expect(find.text('Type: int'), findsOneWidget);
      expect(find.text('Value: $value'), findsOneWidget);
    });

    testWidgets('should show double value', (WidgetTester tester) async {
      const double value = 42.0;
      stubDataState(const SharedPreferencesData.double(value: value));
      await pumpDataPanel(tester);

      expect(find.text('Type: double'), findsOneWidget);
      expect(find.text('Value: $value'), findsOneWidget);
    });

    testWidgets('should show boolean value', (WidgetTester tester) async {
      const bool value = true;
      stubDataState(const SharedPreferencesData.bool(value: value));
      await pumpDataPanel(tester);

      expect(find.text('Type: bool'), findsOneWidget);
      expect(find.text('Value: $value'), findsOneWidget);
    });

    testWidgets('should show string list value', (WidgetTester tester) async {
      stubDataState(const SharedPreferencesData.stringList(
          value: <String>['value1', 'value2']));
      await pumpDataPanel(tester);

      expect(find.text('Type: List<String>'), findsOneWidget);
      expect(find.textContaining('0 -> value1'), findsOneWidget);
      expect(find.textContaining('1 -> value2'), findsOneWidget);
    });

    testWidgets('should show viewing state', (WidgetTester tester) async {
      stubDataState(const SharedPreferencesData.string(value: 'value'));
      await pumpDataPanel(tester);

      expect(find.text('Remove'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('on edit should start editing', (WidgetTester tester) async {
      stubDataState(const SharedPreferencesData.string(value: 'value'));
      await pumpDataPanel(tester);

      await tester.tap(find.text('Edit'));
      verify(notifierMock.startEditing()).called(1);
    });

    testWidgets(
      'on remove should show confirmation modal',
      (WidgetTester tester) async {
        stubDataState(const SharedPreferencesData.string(value: 'value'));
        await pumpDataPanel(tester);

        await tester.tap(find.text('Remove'));
        await tester.pumpAndSettle();

        expect(
          find.text('Are you sure you want to remove selectedTestKey?'),
          findsOneWidget,
        );
        expect(find.text('CANCEL'), findsOneWidget);
        expect(find.text('REMOVE'), findsOneWidget);
      },
    );

    testWidgets(
      'on removed confirmed should remove key',
      (WidgetTester tester) async {
        const SharedPreferencesData value = SharedPreferencesData.string(
          value: 'value',
        );
        stubDataState(value);
        await pumpDataPanel(tester);
        await tester.tap(find.text('Remove'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('REMOVE'));

        verify(
          notifierMock.deleteSelectedKey(),
        ).called(1);
      },
    );

    testWidgets(
      'on remove canceled should cancel remove',
      (WidgetTester tester) async {
        stubDataState(const SharedPreferencesData.string(value: 'value'));
        await pumpDataPanel(tester);
        await tester.tap(find.text('Remove'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('CANCEL'));
        await tester.pumpAndSettle();

        expect(
          find.text('Are you sure you want to remove selectedTestKey?'),
          findsNothing,
        );
      },
    );

    testWidgets('should show editing state', (WidgetTester tester) async {
      stubDataState(
        const SharedPreferencesData.string(value: 'value'),
        editing: true,
      );
      await pumpDataPanel(tester);

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets(
      'should show string editing state',
      (WidgetTester tester) async {
        const String value = 'value';
        stubDataState(
          const SharedPreferencesData.string(value: value),
          editing: true,
        );
        await pumpDataPanel(tester);

        expect(find.text('Type: String'), findsOneWidget);
        expect(find.text('Value:'), findsOneWidget);
        expect(find.text(value), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      'should show int editing state',
      (WidgetTester tester) async {
        const int value = 42;
        stubDataState(
          const SharedPreferencesData.int(value: value),
          editing: true,
        );
        await pumpDataPanel(tester);

        expect(find.text('Type: int'), findsOneWidget);
        expect(find.text('Value:'), findsOneWidget);
        expect(find.text('$value'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(
          tester.textInputFormatterPattern,
          equals(RegExp(r'^-?\d*').toString()),
        );
      },
    );

    testWidgets(
      'should show double editing state',
      (WidgetTester tester) async {
        const double value = 42.0;
        stubDataState(
          const SharedPreferencesData.double(value: value),
          editing: true,
        );
        await pumpDataPanel(tester);

        expect(find.text('Type: double'), findsOneWidget);
        expect(find.text('Value:'), findsOneWidget);
        expect(find.text('$value'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(
          tester.textInputFormatterPattern,
          equals(RegExp(r'^-?\d*\.?\d*').toString()),
        );
      },
    );

    testWidgets(
      'should show boolean editing state',
      (WidgetTester tester) async {
        const bool value = true;
        stubDataState(
          const SharedPreferencesData.bool(value: value),
          editing: true,
        );
        await pumpDataPanel(tester);

        expect(find.text('Type: bool'), findsOneWidget);
        expect(find.text('Value:'), findsOneWidget);
        expect(find.byType(DropdownMenu<bool>), findsOneWidget);
      },
    );

    testWidgets(
      'should show string list editing state',
      (WidgetTester tester) async {
        stubDataState(
          const SharedPreferencesData.stringList(
            value: <String>['value1', 'value2'],
          ),
          editing: true,
        );
        await pumpDataPanel(tester);

        expect(find.text('Type: List<String>'), findsOneWidget);
        expect(find.text('Value:'), findsOneWidget);
        expect(find.text('value1'), findsOneWidget);
        expect(find.text('value2'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(2));
        // Finds 3 add buttons:
        // +
        // value1
        // +
        // value2
        // +
        expect(find.byIcon(Icons.add), findsNWidgets(3));
      },
    );

    testWidgets(
      'should show apply changes button on value changed',
      (WidgetTester tester) async {
        stubDataState(
          const SharedPreferencesData.string(value: 'value'),
          editing: true,
        );
        await pumpDataPanel(tester);

        await tester.enterText(find.byType(TextField), 'newValue');
        await tester.pumpAndSettle();

        expect(find.text('Apply changes'), findsOneWidget);
      },
    );

    testWidgets(
      'pressing an add button on the string list editing state '
      'should add element in the right index',
      (WidgetTester tester) async {
        stubDataState(
          const SharedPreferencesData.stringList(
            value: <String>['value1', 'value2'],
          ),
          editing: true,
        );
        await pumpDataPanel(tester);

        for (int i = 0; i < 3; i++) {
          await tester.tap(find.byIcon(Icons.add).at(i));
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextField).at(i), '$i');
          await tester.pumpAndSettle();
          await tester.tap(find.text('Apply changes'));
          await tester.pumpAndSettle();
        }

        verifyInOrder(<Future<void>>[
          notifierMock.changeValue(
            const SharedPreferencesData.stringList(
              value: <String>['0', 'value1', 'value2'],
            ),
          ),
          notifierMock.changeValue(
            const SharedPreferencesData.stringList(
              value: <String>['0', '1', 'value1', 'value2'],
            ),
          ),
          notifierMock.changeValue(
            const SharedPreferencesData.stringList(
              value: <String>['0', '1', '2', 'value1', 'value2'],
            ),
          ),
        ]);
      },
    );
  });
}

extension on WidgetTester {
  Pattern get textInputFormatterPattern {
    final TextField textField = widget(find.byType(TextField));
    return (textField.inputFormatters!.first as FilteringTextInputFormatter)
        .filterPattern
        .toString();
  }
}
