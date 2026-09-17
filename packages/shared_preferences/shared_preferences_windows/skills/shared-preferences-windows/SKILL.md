---
name: shared-preferences-windows
description: Set up and configure shared_preferences_windows, the Windows implementation of Flutter's shared_preferences plugin storing JSON files in the roaming AppData directory.
---

# Setting Up and Using shared_preferences_windows

`shared_preferences_windows` is the endorsed Windows platform implementation of the Flutter [`shared_preferences`](https://pub.dev/packages/shared_preferences) plugin.

## 1. Installation and Setup

Because `shared_preferences_windows` is endorsed by `shared_preferences`, adding `shared_preferences` to your `pubspec.yaml` automatically includes Windows support.

If you import `package:shared_preferences_windows/shared_preferences_windows.dart` directly (for example, to configure `SharedPreferencesWindowsOptions` with a custom file name), add it explicitly to your `pubspec.yaml`:

```yaml
dependencies:
  shared_preferences: ^2.5.0
  shared_preferences_windows: ^2.4.0
```

## 2. Platform-Specific Configuration

### Storage Location and Custom File Names

On Windows, preferences are persisted as JSON files in the application support directory resolved by `path_provider_windows` (typically inside the user's roaming `AppData` folder, e.g. `%APPDATA%\<Company>\<App>\shared_preferences.json`).

When using `SharedPreferencesAsync` or `SharedPreferencesWithCache`, you can specify a custom file name via `SharedPreferencesWindowsOptions`.

## 3. Usage and API Examples

### Using a Custom Preferences File Name on Windows

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_windows/shared_preferences_windows.dart';

Future<void> useCustomWindowsPreferencesFile() async {
  const SharedPreferencesWindowsOptions windowsOptions =
      SharedPreferencesWindowsOptions(
    fileName: 'app_window_state',
  );

  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync(
    options: windowsOptions,
  );

  await asyncPrefs.setDouble('window_width', 1280.0);
  await asyncPrefs.setDouble('window_height', 720.0);

  final double? width = await asyncPrefs.getDouble('window_width');
}
```

### Direct Registration (Testing)

For unit tests or custom desktop plugin initialization on Windows:

```dart
import 'package:shared_preferences_windows/shared_preferences_windows.dart';

void initializeWindowsPreferences() {
  SharedPreferencesWindows.registerWith();
}
```
