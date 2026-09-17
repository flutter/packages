---
name: quick-actions-platform-interface
description: Implement or mock the common platform interface for the Flutter quick_actions plugin using QuickActionsPlatform and ShortcutItem.
---

# Setting Up and Using quick_actions_platform_interface

`quick_actions_platform_interface` defines the common platform interface (`QuickActionsPlatform`) and data models (`ShortcutItem`, `QuickActionHandler`) for the [`quick_actions`](https://pub.dev/packages/quick_actions) plugin.

## 1. Installation and Setup

Add `quick_actions_platform_interface` to your platform implementation package or test suite's `pubspec.yaml`:

```yaml
dependencies:
  quick_actions_platform_interface: ^1.1.0
```

## 2. Platform-Specific Configuration

This package contains pure Dart abstractions and requires no native platform configuration.

When modifying `QuickActionsPlatform`, extend the class rather than implementing it, and prefer non-breaking additions over breaking changes.

## 3. Usage and API Examples

### Extending `QuickActionsPlatform`
To create a custom platform implementation or a mock for testing, extend `QuickActionsPlatform` and set `QuickActionsPlatform.instance`:

```dart
import 'package:quick_actions_platform_interface/quick_actions_platform_interface.dart';

class MockQuickActionsPlatform extends QuickActionsPlatform {
  QuickActionHandler? _handler;
  List<ShortcutItem> storedItems = <ShortcutItem>[];

  static void registerWith() {
    QuickActionsPlatform.instance = MockQuickActionsPlatform();
  }

  @override
  Future<void> initialize(QuickActionHandler handler) async {
    _handler = handler;
  }

  @override
  Future<void> setShortcutItems(List<ShortcutItem> items) async {
    storedItems = List<ShortcutItem>.from(items);
  }

  @override
  Future<void> clearShortcutItems() async {
    storedItems.clear();
  }

  void simulateShortcutTap(String type) {
    _handler?.call(type);
  }
}
```
