---
name: quick-actions-ios
description: Configure and use quick_actions_ios for iOS Home Screen Quick Actions, including Xcode Asset Catalog icon setup and dynamic shortcut management.
---

# Setting Up and Using quick_actions_ios

`quick_actions_ios` is the endorsed iOS implementation of the Flutter [`quick_actions`](https://pub.dev/packages/quick_actions) plugin using `UIApplicationShortcutItem`.

## 1. Installation and Setup

Because this package is endorsed, adding `quick_actions` to your `pubspec.yaml` automatically includes it. If you need to depend on `quick_actions_ios` directly:

```yaml
dependencies:
  quick_actions: ^1.1.1
  quick_actions_ios: ^1.2.5
```

## 2. Platform-Specific Configuration

- **Minimum OS**: iOS 13.0+.
- **Shortcut Icons**: Add custom icon images to your iOS project's Asset Catalog (`ios/Runner/Assets.xcassets`). Pass the asset's name to the `icon` parameter of `ShortcutItem`.

## 3. Usage and API Examples

### Registering Dynamic Quick Actions on iOS
Use `QuickActions` to listen for shortcut launches and set dynamic shortcuts with titles, subtitles, and asset catalog icons:

```dart
import 'package:quick_actions/quick_actions.dart';

Future<void> setupIosQuickActions() async {
  const QuickActions quickActions = QuickActions();

  await quickActions.initialize((String shortcutType) {
    if (shortcutType == 'action_favorites') {
      // Navigate to Favorites tab
    }
  });

  await quickActions.setShortcutItems(<ShortcutItem>[
    const ShortcutItem(
      type: 'action_favorites',
      localizedTitle: 'Favorites',
      localizedSubtitle: 'View saved items',
      icon: 'AppIconFavorites',
    ),
  ]);
}
```
