// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

import 'package:devtools_app_shared/ui.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_tool/src/async_state.dart';
import 'package:shared_preferences_tool/src/shared_preferences_state.dart';
import 'package:shared_preferences_tool/src/shared_preferences_state_provider.dart';
import 'package:shared_preferences_tool/src/ui/error_panel.dart';
import 'package:shared_preferences_tool/src/ui/keys_panel.dart';

import '../../test_helpers/notifier_mocking_helpers.dart';
import '../../test_helpers/notifier_mocking_helpers.mocks.dart';

void main() {
  group('KeysPanel', () {
    setupDummies();

    late MockSharedPreferencesStateNotifier notifierMock;

    setUp(() {
      notifierMock = MockSharedPreferencesStateNotifier();
    });

    Future<void> pumpKeysPanel(WidgetTester tester) {
      return tester.pumpWidget(
        DevToolsExtension(
          requiresRunningApplication: false,
          child: InnerSharedPreferencesStateProvider(
            notifier: notifierMock,
            child: const KeysPanel(),
          ),
        ),
      );
    }

    void stubAsyncState(AsyncState<SharedPreferencesState> state) {
      when(notifierMock.value).thenReturn(state);
    }

    void stubDataState({
      List<String> asyncKeys = const <String>[],
      List<String> legacyKeys = const <String>[],
      SelectedSharedPreferencesKey? selectedKey,
      bool editing = false,
    }) {
      stubAsyncState(
        AsyncState<SharedPreferencesState>.data(
          SharedPreferencesState(
            asyncKeys: asyncKeys,
            legacyKeys: legacyKeys,
            selectedKey: selectedKey,
            editing: editing,
          ),
        ),
      );
    }

    testWidgets('should show loading state', (WidgetTester tester) async {
      stubAsyncState(const AsyncState<SharedPreferencesState>.loading());
      await pumpKeysPanel(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error state', (WidgetTester tester) async {
      stubAsyncState(
        const AsyncState<SharedPreferencesState>.error(
          'error',
          StackTrace.empty,
        ),
      );
      await pumpKeysPanel(tester);

      expect(find.byType(ErrorPanel), findsOneWidget);
    });

    testWidgets('should show keys list with async and legacy keys',
        (WidgetTester tester) async {
      const List<String> asyncKeys = <String>['key1', 'key2'];
      const List<String> legacyKeys = <String>['key3', 'key4'];
      stubDataState(
        asyncKeys: asyncKeys,
        legacyKeys: legacyKeys,
      );

      await pumpKeysPanel(tester);

      for (final String key in asyncKeys) {
        expect(find.text(key), findsOneWidget);
      }

      for (final String key in legacyKeys) {
        expect(find.text('legacy - $key'), findsOneWidget);
      }
    });

    testWidgets(
      'only selected key should be highlighted',
      (WidgetTester tester) async {
        const String selectedKey = 'selectedKey';
        const List<String> keys = <String>['key1', selectedKey, 'key2'];
        stubDataState(
          asyncKeys: keys,
          selectedKey: const SelectedSharedPreferencesKey(
            key: selectedKey,
            value: AsyncState<SharedPreferencesData>.loading(),
            legacy: false,
          ),
        );

        await pumpKeysPanel(tester);

        final Element selectedKeyElement =
            tester.element(find.text(selectedKey));
        final ColorScheme colorScheme =
            Theme.of(selectedKeyElement).colorScheme;

        Color? bgColorFor(String key) {
          final Container? container = tester
              .element(find.text(key))
              .findAncestorWidgetOfExactType<Container>();
          return container?.color;
        }

        for (final String key in <String>[...keys]..remove(selectedKey)) {
          expect(
            bgColorFor(key),
            isNot(equals(colorScheme.selectedRowBackgroundColor)),
          );
        }
        expect(
          bgColorFor(selectedKey),
          equals(colorScheme.selectedRowBackgroundColor),
        );
      },
    );

    testWidgets(
      'only selected legacy key should be highlighted',
      (WidgetTester tester) async {
        const String selectedKey = 'selectedKey';
        const List<String> keys = <String>['key1', selectedKey, 'key2'];
        stubDataState(
          legacyKeys: keys,
          selectedKey: const SelectedSharedPreferencesKey(
            key: selectedKey,
            value: AsyncState<SharedPreferencesData>.loading(),
            legacy: true,
          ),
        );

        await pumpKeysPanel(tester);

        final Element selectedKeyElement =
            tester.element(find.text('legacy - $selectedKey'));
        final ColorScheme colorScheme =
            Theme.of(selectedKeyElement).colorScheme;

        Color? bgColorFor(String key) {
          final Container? container = tester
              .element(find.text('legacy - $key'))
              .findAncestorWidgetOfExactType<Container>();
          return container?.color;
        }

        for (final String key in <String>[...keys]..remove(selectedKey)) {
          expect(
            bgColorFor(key),
            isNot(equals(colorScheme.selectedRowBackgroundColor)),
          );
        }
        expect(
          bgColorFor(selectedKey),
          equals(colorScheme.selectedRowBackgroundColor),
        );
      },
    );

    testWidgets(
      'should start searching when clicking the search icon',
      (WidgetTester tester) async {
        stubDataState();
        await pumpKeysPanel(tester);

        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      'should stop searching when clicking the close icon',
      (WidgetTester tester) async {
        stubDataState();
        await pumpKeysPanel(tester);
        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsNothing);
      },
    );

    testWidgets(
      'should filter keys when searching',
      (WidgetTester tester) async {
        stubDataState();
        await pumpKeysPanel(tester);
        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'key2');

        verify(notifierMock.filter('key2')).called(1);
      },
    );

    testWidgets(
      'should refresh on refresh icon clicked',
      (WidgetTester tester) async {
        stubDataState();
        await pumpKeysPanel(tester);

        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pumpAndSettle();

        verify(notifierMock.fetchAllKeys()).called(1);
      },
    );

    testWidgets(
      'should select key on key clicked',
      (WidgetTester tester) async {
        const String keyToSelect = 'keyToSelect';
        stubDataState(asyncKeys: <String>[keyToSelect]);
        await pumpKeysPanel(tester);

        await tester.tap(find.text(keyToSelect));

        verify(notifierMock.selectKey(keyToSelect, false)).called(1);
      },
    );

    testWidgets(
      'should select legacy key on key clicked',
      (WidgetTester tester) async {
        const String keyToSelect = 'keyToSelect';
        stubDataState(legacyKeys: <String>[keyToSelect]);
        await pumpKeysPanel(tester);

        await tester.tap(find.text('legacy - $keyToSelect'));

        verify(notifierMock.selectKey(keyToSelect, true)).called(1);
      },
    );
  });
}
