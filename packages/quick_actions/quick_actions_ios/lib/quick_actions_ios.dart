// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:quick_actions_platform_interface/quick_actions_platform_interface.dart';

import 'messages.g.dart';

export 'package:quick_actions_platform_interface/types/types.dart';

late QuickActionHandler _handler;

/// An implementation of [QuickActionsPlatform] for iOS.
class QuickActionsIos extends QuickActionsPlatform {
  /// Creates a new plugin implementation instance.
  QuickActionsIos({
    @visibleForTesting IOSQuickActionsApi? api,
  }) : _hostApi = api ?? IOSQuickActionsApi();

  final IOSQuickActionsApi _hostApi;

  /// Registers this class as the default instance of [QuickActionsPlatform].
  static void registerWith() {
    QuickActionsPlatform.instance = QuickActionsIos();
  }

  @override
  Future<void> initialize(QuickActionHandler handler) async {
    final _QuickActionHandlerApi quickActionsHandlerApi =
        _QuickActionHandlerApi();
    IOSQuickActionsFlutterApi.setUp(quickActionsHandlerApi);
    _handler = handler;
  }

  @override
  Future<void> setShortcutItems(List<ShortcutItem> items) async {
    await _hostApi.setShortcutItems(
      items.map(_shortcutItemToShortcutItemMessage).toList(),
    );
  }

  @override
  Future<void> clearShortcutItems() => _hostApi.clearShortcutItems();

  ShortcutItemMessage _shortcutItemToShortcutItemMessage(ShortcutItem item) {
    return ShortcutItemMessage(
      type: item.type,
      localizedTitle: item.localizedTitle,
      localizedSubtitle: item.localizedSubtitle,
      icon: item.icon,
    );
  }
}

class _QuickActionHandlerApi extends IOSQuickActionsFlutterApi {
  @override
  void launchAction(String action) {
    _handler(action);
  }
}
