// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _MenuButtonThemeDataWithExpressiveVariant extends MenuButtonThemeData {
  const _MenuButtonThemeDataWithExpressiveVariant();

  @override
  StyleVariant? get variant => .material3Expressive;
}

Matcher get _throwsUnsupportedStyleVariantAssertion {
  return isA<AssertionError>().having(
    (AssertionError error) => error.message,
    'message',
    kUnsupportedStyleVariantAssertionMessage,
  );
}

void main() {
  test('MenuButtonThemeData lerp special cases', () {
    expect(MenuButtonThemeData.lerp(null, null, 0), null);
    const data = MenuButtonThemeData();
    expect(identical(MenuButtonThemeData.lerp(data, data, 0.5), data), true);
  });

  testWidgets('MenuItemButton asserts on unsupported style variants', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MenuButtonTheme(
          data: const _MenuButtonThemeDataWithExpressiveVariant(),
          child: MenuItemButton(onPressed: () {}, child: const Text('Item')),
        ),
      ),
    );

    expect(tester.takeException(), _throwsUnsupportedStyleVariantAssertion);
  });

  testWidgets('SubmenuButton asserts on unsupported style variants', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MenuButtonTheme(
          data: const _MenuButtonThemeDataWithExpressiveVariant(),
          child: SubmenuButton(
            menuChildren: <Widget>[MenuItemButton(onPressed: () {}, child: const Text('Item'))],
            child: const Text('Submenu'),
          ),
        ),
      ),
    );

    expect(tester.takeException(), _throwsUnsupportedStyleVariantAssertion);
  });
}
