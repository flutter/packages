---
name: shared-preferences-linux
description: Set up and configure shared_preferences_linux, the Linux implementation of Flutter's shared_preferences plugin storing JSON preferences in XDG_DATA_HOME.
---

# Setting Up and Using shared_preferences_linux

`shared_preferences_linux` is the endorsed Linux platform implementation of the Flutter [`shared_preferences`](https://pub.dev/packages/shared_preferences) plugin.

## 1. Installation and Setup

Because `shared_preferences_linux` is endorsed by `shared_preferences`, adding `shared_preferences` to your `pubspec.yaml` automatically includes it on Linux.

If you import `package:shared_preferences_linux/shared_preferences_linux.dart` directly (for example, to pass `SharedPreferencesLinuxOptions` with a custom file name), add it explicitly to your `pubspec.yaml`:

```yaml
dependencies:
  shared_preferences: ^2.5.0
  shared_preferences_linux: ^2.4.0
```

## 2. Platform-Specific Configuration

### Storage Location and Custom File Names

On Linux, preferences are stored as JSON files inside the application support directory provided by `path_provider_linux` (typically under `XDG_DATA_HOME` or `~/.local/share/<app_id>/`).

By default, preferences are stored in `shared_preferences.json`. When using `SharedPreferencesAsync` or `SharedPreferencesWithCache`, you can customize the JSON file name using `SharedPreferencesLinuxOptions`.

## 3. Usage and API Examples

### Specifying a Custom Preferences File Name on Linux

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_linux/shared_preferences_linux.dart';

Future<void> useCustomLinuxPreferencesFile() async {
  const SharedPreferencesLinuxOptions linuxOptions =
      SharedPreferencesLinuxOptions(
    fileName: 'user_settings',
  );

  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync(
    options: linuxOptions,
  );

  await asyncPrefs.setBool('dark_mode', true);
  final bool? isDarkMode = await asyncPrefs.getBool('dark_mode');
}
```

### Direct Registration (Testing)

For unit tests or custom platform initialization on Linux:

```dart
import 'package:shared_preferences_linux/shared_preferences_linux.dart';

void initializeLinuxPreferences() {
  SharedPreferencesLinux.registerWith();
}
```
