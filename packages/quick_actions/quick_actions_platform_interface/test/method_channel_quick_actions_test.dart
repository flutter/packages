// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_actions_platform_interface/method_channel/method_channel_quick_actions.dart';
import 'package:quick_actions_platform_interface/types/shortcut_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$MethodChannelQuickActions', () {
    final quickActions = MethodChannelQuickActions();

    final log = <MethodCall>[];

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(quickActions.channel, (
            MethodCall methodCall,
          ) async {
            log.add(methodCall);
            return '';
          });

      log.clear();
    });

    group('#initialize', () {
      test('passes getLaunchAction on launch method', () {
        quickActions.initialize((String type) {});

        expect(log, <Matcher>[
          isMethodCall('getLaunchAction', arguments: null),
        ]);
      });

      test('initialize', () async {
        final quickActionsHandler = Completer<bool>();
        await quickActions.initialize(
          (_) => quickActionsHandler.complete(true),
        );
        expect(log, <Matcher>[
          isMethodCall('getLaunchAction', arguments: null),
        ]);
        log.clear();

        expect(quickActionsHandler.future, completion(isTrue));
      });
    });

    group('#setShortCutItems', () {
      test('passes shortcutItem through channel', () {
        quickActions.initialize((String type) {});
        quickActions.setShortcutItems(<ShortcutItem>[
          const ShortcutItem(
            type: 'test',
            localizedTitle: 'title',
            localizedSubtitle: 'subtitle',
            icon: 'icon.svg',
          ),
        ]);

        expect(log, <Matcher>[
          isMethodCall('getLaunchAction', arguments: null),
          isMethodCall(
            'setShortcutItems',
            arguments: <Map<String, String>>[
              <String, String>{
                'type': 'test',
                'localizedTitle': 'title',
                'localizedSubtitle': 'subtitle',
                'icon': 'icon.svg',
              },
            ],
          ),
        ]);
      });

      test(
        'passes shortcutItem through channel with null localizedSubtitle',
        () {
          quickActions.initialize((String type) {});
          quickActions.setShortcutItems(<ShortcutItem>[
            const ShortcutItem(
              type: 'test',
              localizedTitle: 'title',
              icon: 'icon.svg',
            ),
          ]);

          expect(log, <Matcher>[
            isMethodCall('getLaunchAction', arguments: null),
            isMethodCall(
              'setShortcutItems',
              arguments: <Map<String, String>>[
                <String, String>{
                  'type': 'test',
                  'localizedTitle': 'title',
                  'icon': 'icon.svg',
                },
              ],
            ),
          ]);
        },
      );

      test('setShortcutItems with demo data', () async {
        const type = 'type';
        const localizedTitle = 'localizedTitle';
        const localizedSubtitle = 'localizedSubtitle';
        const icon = 'icon';
        await quickActions.setShortcutItems(const <ShortcutItem>[
          ShortcutItem(
            type: type,
            localizedTitle: localizedTitle,
            localizedSubtitle: localizedSubtitle,
            icon: icon,
          ),
        ]);
        expect(log, <Matcher>[
          isMethodCall(
            'setShortcutItems',
            arguments: <Map<String, String>>[
              <String, String>{
                'type': type,
                'localizedTitle': localizedTitle,
                'localizedSubtitle': localizedSubtitle,
                'icon': icon,
              },
            ],
          ),
        ]);
        log.clear();
      });
    });

    group('#clearShortCutItems', () {
      test('send clearShortcutItems through channel', () {
        quickActions.initialize((String type) {});
        quickActions.clearShortcutItems();

        expect(log, <Matcher>[
          isMethodCall('getLaunchAction', arguments: null),
          isMethodCall('clearShortcutItems', arguments: null),
        ]);
      });

      test('clearShortcutItems', () {
        quickActions.clearShortcutItems();
        expect(log, <Matcher>[
          isMethodCall('clearShortcutItems', arguments: null),
        ]);
        log.clear();
      });
    });
  });

  group('$ShortcutItem', () {
    test('Shortcut item can be constructed', () {
      const type = 'type';
      const localizedTitle = 'title';
      const localizedSubtitle = 'subtitle';
      const icon = 'foo';

      const item = ShortcutItem(
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
  });
}
