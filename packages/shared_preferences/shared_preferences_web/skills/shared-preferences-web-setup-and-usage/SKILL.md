---
name: shared-preferences-web-setup-and-usage
description: Set up and use shared_preferences_web, the Web implementation of Flutter's shared_preferences plugin backed by window.localStorage.
---

# Setting Up and Using shared_preferences_web

`shared_preferences_web` is the endorsed Web platform implementation of the Flutter [`shared_preferences`](https://pub.dev/packages/shared_preferences) plugin, storing key-value pairs in browser `window.localStorage`.

## 1. Installation and Setup

Because `shared_preferences_web` is endorsed by `shared_preferences`, adding `shared_preferences` to your `pubspec.yaml` automatically includes web support:

```yaml
dependencies:
  shared_preferences: ^2.5.0
```

If you need to import `package:shared_preferences_web/shared_preferences_web.dart` directly, add it to your `pubspec.yaml`:

```yaml
dependencies:
  shared_preferences: ^2.5.0
  shared_preferences_web: ^2.4.0
```

## 2. Platform-Specific Behavior on Web

- **Storage Mechanism**: Values are JSON-encoded and stored in `window.localStorage`.
- **Key Prefixing and Clearing**:
  - Legacy `SharedPreferences` only reads and clears keys prefixed with `flutter.` (or a custom prefix set via `SharedPreferences.setPrefix`).
  - `SharedPreferencesAsync` and `SharedPreferencesWithCache` read and write keys directly without automatic prefixing. To avoid clearing unrelated data stored in `window.localStorage` by other scripts or web libraries on the same origin, always provide an `allowList` when calling `clear()` or configuring `SharedPreferencesWithCacheOptions`.

## 3. Usage and API Examples

### Safe Usage on Web with `SharedPreferencesAsync`

```dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> manageWebPreferences() async {
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  await asyncPrefs.setString('auth_state', 'logged_in');
  final String? state = await asyncPrefs.getString('auth_state');

  // Always specify an allowList on Web so other window.localStorage keys are preserved
  await asyncPrefs.clear(allowList: <String>{'auth_state'});
}
```

### Safe Usage on Web with `SharedPreferencesWithCache`

```dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> manageCachedWebPreferences() async {
  final SharedPreferencesWithCache cachedPrefs =
      await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: <String>{'theme_mode', 'font_scale'},
    ),
  );

  await cachedPrefs.setString('theme_mode', 'dark');
  final String? theme = cachedPrefs.getString('theme_mode');

  // Clears only keys included in cacheOptions.allowList
  await cachedPrefs.clear();
}
```
