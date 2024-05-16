// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/messages.g.dart',
  swiftOut: 'ios/quick_actions_ios/Sources/quick_actions_ios/messages.g.swift',
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Home screen quick-action shortcut item.
class ShortcutItemMessage {
  ShortcutItemMessage(
    this.type,
    this.localizedTitle,
    this.icon,
  );

  /// The identifier of this item; should be unique within the app.
  String type;

  /// Localized title of the item.
  String localizedTitle;

  /// Name of native resource to be displayed as the icon for this item.
  String? icon;
}

@HostApi()
abstract class IOSQuickActionsApi {
  /// Sets the dynamic shortcuts for the app.
  void setShortcutItems(List<ShortcutItemMessage> itemsList);

  /// Removes all dynamic shortcuts.
  void clearShortcutItems();
}

@FlutterApi()
abstract class IOSQuickActionsFlutterApi {
  /// Sends a string representing a shortcut from the native platform to the app.
  void launchAction(String action);
}
