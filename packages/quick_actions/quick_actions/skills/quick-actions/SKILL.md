---
name: quick-actions
description: Set up and use the quick_actions plugin to manage home screen shortcuts on iOS (Quick Actions) and Android (App Shortcuts).
---

# Setting Up and Using quick_actions

`quick_actions` enables Flutter apps to create, manage, and respond to home screen shortcuts, known as Quick Actions on iOS and App Shortcuts on Android.

## 1. Installation and Setup

Add `quick_actions` to your `pubspec.yaml`:

```yaml
dependencies:
  quick_actions: ^1.1.1
```

## 2. Platform-Specific Configuration

### Android
- **Minimum SDK**: Compiles on SDK 24+, active on SDK 25+ (Android 7.1+). Below SDK 25, calls are safe no-ops.
- **Icon Resources**: Shortcut icons must be native drawable resources located in `android/app/src/main/res/drawable/` (for example, `icon_search.png` referenced as `'icon_search'`).
- **Resource Shrinking**: If drawable icons are only referenced by name in Dart code, add a `res/raw/keep.xml` file so R8/ProGuard does not strip them in release builds:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <resources xmlns:tools="http://schemas.android.com/tools"
      tools:keep="@drawable/icon_*" />
  ```

### iOS
- **Minimum OS**: iOS 13.0+.
- **Icon Resources**: Shortcut icons should be added to your Xcode Asset Catalog (`ios/Runner/Assets.xcassets`) and referenced by their asset name in Dart.

## 3. Usage and API Examples

### Initializing and Registering Home Screen Shortcuts
Initialize `QuickActions` early in your app's lifecycle (such as in `initState` of your root widget) to handle shortcut launches, then call `setShortcutItems` to register your shortcuts:

```dart
import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuickActions _quickActions = const QuickActions();
  String _selectedShortcut = 'None';

  @override
  void initState() {
    super.initState();
    _quickActions.initialize((String shortcutType) {
      setState(() {
        _selectedShortcut = shortcutType;
      });
      if (shortcutType == 'action_search') {
        // Navigate to search screen
      } else if (shortcutType == 'action_new_message') {
        // Navigate to compose screen
      }
    });

    _quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'action_search',
        localizedTitle: 'Search',
        localizedSubtitle: 'Find items quickly',
        icon: 'icon_search',
      ),
      const ShortcutItem(
        type: 'action_new_message',
        localizedTitle: 'New Message',
        icon: 'icon_compose',
      ),
    ]);
  }

  Future<void> _clearShortcuts() async {
    await _quickActions.clearShortcutItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Actions Demo')),
      body: Center(
        child: Text('Last triggered shortcut: $_selectedShortcut'),
      ),
    );
  }
}
```
