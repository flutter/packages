// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_tool/src/shared_preferences_state.dart';
import 'package:shared_preferences_tool/src/shared_preferences_state_provider.dart';
import 'package:shared_preferences_tool/src/ui/data_panel.dart';
import 'package:shared_preferences_tool/src/ui/keys_panel.dart';
import 'package:shared_preferences_tool/src/ui/shared_preferences_body.dart';

import '../../test_helpers/notifier_mocking_helpers.dart';
import '../../test_helpers/notifier_mocking_helpers.mocks.dart';

void main() {
  group('group name', () {
    setupDummies();

    testWidgets(
      'should show keys and data panels',
      (WidgetTester tester) async {
        final MockSharedPreferencesStateNotifier notifier =
            MockSharedPreferencesStateNotifier();
        when(notifier.value).thenReturn(const SharedPreferencesState());

        await tester.pumpWidget(
          DevToolsExtension(
            requiresRunningApplication: false,
            child: InnerSharedPreferencesStateProvider(
              notifier: notifier,
              child: const SharedPreferencesBody(),
            ),
          ),
        );

        expect(find.byType(KeysPanel), findsOneWidget);
        expect(find.byType(DataPanel), findsOneWidget);
      },
    );
  });
}
