---
name: shared-preferences-foundation
description: Set up and configure shared_preferences_foundation, the iOS and macOS implementation of Flutter's shared_preferences plugin built on NSUserDefaults with support for App Groups and custom suite names.
---

# Setting Up and Using shared_preferences_foundation

`shared_preferences_foundation` is the endorsed iOS and macOS platform implementation of the Flutter [`shared_preferences`](https://pub.dev/packages/shared_preferences) plugin, backed by Apple's `NSUserDefaults`.

## 1. Installation and Setup

Because `shared_preferences_foundation` is endorsed by `shared_preferences`, adding `shared_preferences` to your `pubspec.yaml` automatically includes it.

If you import `package:shared_preferences_foundation/shared_preferences_foundation.dart` directly to configure iOS/macOS-specific options such as custom `NSUserDefaults` suite names or App Groups, add it to your `pubspec.yaml`:

```yaml
dependencies:
  shared_preferences: ^2.5.0
  shared_preferences_foundation: ^2.5.0
```

## 2. Platform-Specific Configuration

### App Groups and Custom Suite Names (`suiteName`)

By default, `shared_preferences_foundation` stores data in `NSUserDefaults.standardUserDefaults`. To share preferences between your main app and app extensions (such as widgets or share extensions) on iOS or macOS, configure an App Group entitlement in Xcode and specify `suiteName` via `SharedPreferencesAsyncFoundationOptions`.

- **iOS Requirement**: To comply with Apple's privacy manifest requirements (Required Reason API category `1C8F.1`), any `suiteName` provided on iOS **must** begin with `"group."` (for example, `"group.com.example.myapp"`). Passing a suite name on iOS that does not start with `"group."` throws an `ArgumentError`.
- **macOS**: Supports App Group suite names as well as custom reverse-DNS suite names.

## 3. Usage and API Examples

### Using an App Group Suite Name with `SharedPreferencesAsync`

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_foundation/shared_preferences_foundation.dart';

Future<void> shareDataWithAppExtension() async {
  final SharedPreferencesAsyncFoundationOptions foundationOptions =
      SharedPreferencesAsyncFoundationOptions(
    suiteName: 'group.com.example.myflutterapp',
  );

  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync(
    options: foundationOptions,
  );

  await asyncPrefs.setString('widget_title', 'Updated from Flutter');
  final String? title = await asyncPrefs.getString('widget_title');
}
```

### Using an App Group Suite Name with `SharedPreferencesWithCache`

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_foundation/shared_preferences_foundation.dart';

Future<void> useCachedGroupPreferences() async {
  final SharedPreferencesAsyncFoundationOptions foundationOptions =
      SharedPreferencesAsyncFoundationOptions(
    suiteName: 'group.com.example.myflutterapp',
  );

  final SharedPreferencesWithCache cachedPrefs =
      await SharedPreferencesWithCache.create(
    sharedPreferencesOptions: foundationOptions,
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: <String>{'widget_title', 'counter'},
    ),
  );

  await cachedPrefs.setInt('counter', 5);
  final int? count = cachedPrefs.getInt('counter');
}
```
