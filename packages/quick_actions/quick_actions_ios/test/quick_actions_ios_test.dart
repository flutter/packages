// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_actions_ios/quick_actions_ios.dart';
import 'package:quick_actions_platform_interface/quick_actions_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$QuickActionsIos', () {
    late List<MethodCall> log;

    setUp(() {
      log = <MethodCall>[];
    });

    QuickActionsIos buildQuickActionsPlugin() {
      final QuickActionsIos quickActions = QuickActionsIos();
      _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
          .defaultBinaryMessenger
          .setMockMethodCallHandler(quickActions.channel,
              (MethodCall methodCall) async {
        log.add(methodCall);
        return '';
      });

      return quickActions;
    }

    test('registerWith() registers correct instance', () {
      QuickActionsIos.registerWith();
      expect(QuickActionsPlatform.instance, isA<QuickActionsIos>());
    });

    group('#initialize', () {
      test('passes getLaunchAction on launch method', () {
        final QuickActionsIos quickActions = buildQuickActionsPlugin();
        quickActions.initialize((String type) {});

        expect(
          log,
          <Matcher>[
            isMethodCall('getLaunchAction', arguments: null),
          ],
        );
      });

      test('initialize', () async {
        final QuickActionsIos quickActions = buildQuickActionsPlugin();
        final Completer<bool> quickActionsHandler = Completer<bool>();
        await quickActions
            .initialize((_) => quickActionsHandler.complete(true));
        expect(
          log,
          <Matcher>[
            isMethodCall('getLaunchAction', arguments: null),
          ],
        );
        log.clear();

        expect(quickActionsHandler.future, completion(isTrue));
      });
    });

    group('#setShortCutItems', () {
      test('passes shortcutItem through channel', () {
        final QuickActionsIos quickActions = buildQuickActionsPlugin();
        quickActions.initialize((String type) {});
        quickActions.setShortcutItems(<ShortcutItem>[
          const ShortcutItem(
              type: 'test', localizedTitle: 'title', icon: 'icon.svg')
        ]);

        expect(
          log,
          <Matcher>[
            isMethodCall('getLaunchAction', arguments: null),
            isMethodCall('setShortcutItems', arguments: <Map<String, String>>[
              <String, String>{
                'type': 'test',
                'localizedTitle': 'title',
                'icon': 'icon.svg',
              }
            ]),
          ],
        );
      });

      test('setShortcutItems with demo data', () async {
        const String type = 'type';
        const String localizedTitle = 'localizedTitle';
        const String icon = 'icon';
        final QuickActionsIos quickActions = buildQuickActionsPlugin();
        await quickActions.setShortcutItems(
          const <ShortcutItem>[
            ShortcutItem(type: type, localizedTitle: localizedTitle, icon: icon)
          ],
        );
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'setShortcutItems',
              arguments: <Map<String, String>>[
                <String, String>{
                  'type': type,
                  'localizedTitle': localizedTitle,
                  'icon': icon,
                }
              ],
            ),
          ],
        );
        log.clear();
      });
    });

    group('#clearShortCutItems', () {
      test('send clearShortcutItems through channel', () {
        final QuickActionsIos quickActions = buildQuickActionsPlugin();
        quickActions.initialize((String type) {});
        quickActions.clearShortcutItems();

        expect(
          log,
          <Matcher>[
            isMethodCall('getLaunchAction', arguments: null),
            isMethodCall('clearShortcutItems', arguments: null),
          ],
        );
      });

      test('clearShortcutItems', () {
        final QuickActionsIos quickActions = buildQuickActionsPlugin();
        quickActions.clearShortcutItems();
        expect(
          log,
          <Matcher>[
            isMethodCall('clearShortcutItems', arguments: null),
          ],
        );
        log.clear();
      });
    });
  });

  group('$ShortcutItem', () {
    test('Shortcut item can be constructed', () {
      const String type = 'type';
      const String localizedTitle = 'title';
      const String icon = 'foo';

      const ShortcutItem item =
          ShortcutItem(type: type, localizedTitle: localizedTitle, icon: icon);

      expect(item.type, type);
      expect(item.localizedTitle, localizedTitle);
      expect(item.icon, icon);
    });
  });
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
T? _ambiguate<T>(T? value) => value;
