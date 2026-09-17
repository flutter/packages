---
name: quick-actions-android-setup-and-usage
description: Configure and use quick_actions_android for Android App Shortcuts, including launchMode configuration for launcher activities and drawable icon resource retention.
---

# Setting Up and Using quick_actions_android

`quick_actions_android` is the endorsed Android implementation of the Flutter [`quick_actions`](https://pub.dev/packages/quick_actions) plugin using Android's `ShortcutManager` API.

## 1. Installation and Setup

Because this package is endorsed, adding `quick_actions` to your `pubspec.yaml` automatically includes it. If you need to depend on `quick_actions_android` directly:

```yaml
dependencies:
  quick_actions: ^1.1.1
  quick_actions_android: ^1.0.33
```

## 2. Platform-Specific Configuration

### Launcher Activity Launch Mode (`singleInstance`)
If your app uses a separate launcher `Activity` that starts your `FlutterActivity` (or in multi-activity / add-to-app scenarios), using the default `singleTop` launch mode can cause Android to ignore a second shortcut tap when the app is already running in the background.

To ensure Android delivers new shortcut intents when resuming from the background, configure `android:launchMode="singleInstance"` on your activity in `android/app/src/main/AndroidManifest.xml`:

```xml
<activity
    android:name=".MainActivity"
    android:launchMode="singleInstance"
    android:exported="true">
</activity>
```

If you forward intents from a custom `LauncherActivity` to `MainActivity`, forward the extras from `getIntent()`:

```java
Intent mainActivityIntent = new Intent(this, MainActivity.class);
mainActivityIntent.putExtras(getIntent());
startActivity(mainActivityIntent);
finish();
```

### Retaining Drawable Icons in Release Builds
Shortcut icons on Android reference native drawables in `android/app/src/main/res/drawable/`. To prevent code shrinking from removing unreferenced drawables in release builds, create `android/app/src/main/res/raw/keep.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools"
    tools:keep="@drawable/ic_shortcut_*" />
```

## 3. Usage and API Examples

Interact with Android App Shortcuts through the `QuickActions` API:

```dart
import 'package:quick_actions/quick_actions.dart';

Future<void> configureAndroidShortcuts() async {
  const QuickActions quickActions = QuickActions();

  await quickActions.initialize((String shortcutType) {
    // Handle shortcut invocation by type
  });

  await quickActions.setShortcutItems(<ShortcutItem>[
    const ShortcutItem(
      type: 'open_cart',
      localizedTitle: 'View Cart',
      icon: 'ic_shortcut_cart',
    ),
  ]);
}
```
