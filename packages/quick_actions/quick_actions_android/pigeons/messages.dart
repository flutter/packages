// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  javaOut:
      'android/src/main/java/io/flutter/plugins/quickactions/Messages.java',
  javaOptions: JavaOptions(
    package: 'io.flutter.plugins.quickactions',
  ),
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

  /// Name of native resource (xcassets etc; NOT a Flutter asset) to be
  /// displayed as the icon for this item.
  String? icon;
}

@HostApi()
abstract class AndroidQuickActionsApi {
  @async
  String? getLaunchAction();

  @async
  void setShortcutItems(List<ShortcutItemMessage> itemsList);

  @async
  void clearShortcutItems();
}

@FlutterApi()
abstract class AndroidQuickActionsFlutterApi {
  void handleCall(String action);
}
