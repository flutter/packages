// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:quick_actions/quick_actions.dart';

/// Initializes the plugin and handles quick action launches.
void initializeSnippet() {
  // #docregion Initialize
  const quickActions = QuickActions();
  quickActions.initialize((String shortcutType) {
    if (shortcutType == 'action_main') {
      debugPrint('The user tapped on the "Main view" action.');
    }
    // More handling code...
  });
  // #enddocregion Initialize
}

/// Sets the shortcut items shown on the device's home screen.
Future<void> setShortcutItemsSnippet() async {
  const quickActions = QuickActions();
  // #docregion SetShortcutItems
  await quickActions.setShortcutItems(<ShortcutItem>[
    const ShortcutItem(type: 'action_main', localizedTitle: 'Main view', icon: 'icon_main'),
    const ShortcutItem(
      type: 'action_help',
      localizedTitle: 'Help',
      localizedSubtitle: 'Tap to get help',
      icon: 'icon_help',
    ),
  ]);
  // #enddocregion SetShortcutItems
}
