// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:quick_actions_ios/messages.g.dart';
import 'package:quick_actions_ios/quick_actions_ios.dart';
import 'package:quick_actions_platform_interface/quick_actions_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final _FakeQuickActionsApi api = _FakeQuickActionsApi();
  final QuickActionsIos quickActions = QuickActionsIos(api: api);

  test('registerWith() registers correct instance', () {
    QuickActionsIos.registerWith();
    expect(QuickActionsPlatform.instance, isA<QuickActionsIos>());
  });

  group('#initialize', () {
    test('initialize', () {
      expect(quickActions.initialize((_) {}), completes);
    });
  });

  test('setShortcutItems', () async {
    await quickActions.initialize((String type) {});
    const ShortcutItem item = ShortcutItem(
      type: 'test',
      localizedTitle: 'title',
      localizedSubtitle: 'subtitle',
      icon: 'icon.svg',
    );
    await quickActions.setShortcutItems(<ShortcutItem>[item]);

    expect(api.items.first.type, item.type);
    expect(api.items.first.localizedTitle, item.localizedTitle);
    expect(api.items.first.localizedSubtitle, item.localizedSubtitle);
    expect(api.items.first.icon, item.icon);
  });

  test('clearShortCutItems', () {
    quickActions.initialize((String type) {});
    const ShortcutItem item = ShortcutItem(
      type: 'test',
      localizedTitle: 'title',
      localizedSubtitle: 'subtitle',
      icon: 'icon.svg',
    );
    quickActions.setShortcutItems(<ShortcutItem>[item]);
    quickActions.clearShortcutItems();

    expect(api.items.isEmpty, true);
  });

  test('Shortcut item can be constructed', () {
    const String type = 'type';
    const String localizedTitle = 'title';
    const String localizedSubtitle = 'subtitle';
    const String icon = 'foo';

    const ShortcutItem item = ShortcutItem(
      type: type,
      localizedTitle: localizedTitle,
      localizedSubtitle: localizedSubtitle,
      icon: icon,
    );

    expect(item.type, type);
    expect(item.localizedTitle, localizedTitle);
    expect(item.localizedSubtitle, localizedSubtitle);
    expect(item.icon, icon);
  });
}

class _FakeQuickActionsApi implements IOSQuickActionsApi {
  List<ShortcutItem> items = <ShortcutItem>[];
  bool getLaunchActionCalled = false;

  @override
  Future<void> clearShortcutItems() async {
    items = <ShortcutItem>[];
    return;
  }

  @override
  Future<void> setShortcutItems(List<ShortcutItemMessage?> itemsList) async {
    await clearShortcutItems();
    for (final ShortcutItemMessage? element in itemsList) {
      items.add(shortcutItemMessageToShortcutItem(element!));
    }
  }
}

/// Conversion tool to change [ShortcutItemMessage] back to [ShortcutItem]
ShortcutItem shortcutItemMessageToShortcutItem(ShortcutItemMessage item) {
  return ShortcutItem(
    type: item.type,
    localizedTitle: item.localizedTitle,
    localizedSubtitle: item.localizedSubtitle,
    icon: item.icon,
  );
}
