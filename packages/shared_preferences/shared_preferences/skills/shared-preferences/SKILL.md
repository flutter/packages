---
name: shared-preferences
description: Set up and use the shared_preferences plugin for reading and writing persistent key-value pairs across Flutter platforms using SharedPreferencesAsync, SharedPreferencesWithCache, or legacy SharedPreferences.
---

# Setting Up and Using shared_preferences

`shared_preferences` wraps platform-specific persistent storage for simple data (`NSUserDefaults` on iOS and macOS, DataStore Preferences or `SharedPreferences` on Android, `localStorage` on Web, and JSON files on Linux and Windows). Supported data types are `int`, `double`, `bool`, `String`, and `List<String>`.

## 1. Installation and Setup

Add `shared_preferences` to your `pubspec.yaml`:

```yaml
dependencies:
  shared_preferences: ^2.5.0
```

### Choosing an API

Starting with version 2.3.0, three APIs are available:
- **`SharedPreferencesAsync`** (Recommended): Does not use a local cache. All reads and writes are asynchronous calls directly to host platform storage. Safe for multi-isolate or multi-engine environments and background contexts.
- **`SharedPreferencesWithCache`** (Recommended): Uses a local cache for synchronous getters after an initial asynchronous setup call. Requires specifying an `allowList` or cache options.
- **`SharedPreferences`** (Legacy): Uses a local cache and prefixes keys with `flutter.` by default. Maintained for backward compatibility; new code should prefer `SharedPreferencesAsync` or `SharedPreferencesWithCache`.

## 2. Platform-Specific Configuration

By default, no special permissions or entitlements are required. However, platform-specific options classes allow customizing the underlying storage backend or file/suite name:

- **Android (`shared_preferences_android`)**: Uses Jetpack DataStore Preferences by default for `SharedPreferencesAsync` and `SharedPreferencesWithCache`. To use legacy Android `SharedPreferences` instead, pass `SharedPreferencesAsyncAndroidOptions`:
  ```dart
  import 'package:shared_preferences_android/shared_preferences_android.dart';

  const SharedPreferencesAsyncAndroidOptions androidOptions =
      SharedPreferencesAsyncAndroidOptions(
    backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
    originalSharedPreferencesOptions: AndroidSharedPreferencesStoreOptions(
      fileName: 'custom_prefs_file',
    ),
  );
  ```
- **iOS and macOS (`shared_preferences_foundation`)**: Uses standard `NSUserDefaults` by default. To use an App Group or custom suite name, pass `SharedPreferencesAsyncFoundationOptions` (note: on iOS, `suiteName` must begin with `"group."`):
  ```dart
  import 'package:shared_preferences_foundation/shared_preferences_foundation.dart';

  final SharedPreferencesAsyncFoundationOptions darwinOptions =
      SharedPreferencesAsyncFoundationOptions(
    suiteName: 'group.com.example.myapp',
  );
  ```
- **Linux (`shared_preferences_linux`)** and **Windows (`shared_preferences_windows`)**: Store preferences in JSON files inside the application support directory (`SharedPreferencesLinuxOptions(fileName: ...)` / `SharedPreferencesWindowsOptions(fileName: ...)`).

## 3. Usage and API Examples

### Using `SharedPreferencesAsync` (No Cache)

```dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> useAsyncPreferences() async {
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  // Write values
  await asyncPrefs.setBool('repeat', true);
  await asyncPrefs.setInt('counter', 42);
  await asyncPrefs.setDouble('decimal', 3.14);
  await asyncPrefs.setString('action', 'Start');
  await asyncPrefs.setStringList('items', <String>['Earth', 'Moon', 'Sun']);

  // Read values asynchronously
  final bool? repeat = await asyncPrefs.getBool('repeat');
  final int? counter = await asyncPrefs.getInt('counter');
  final String? action = await asyncPrefs.getString('action');

  // Remove a single key
  await asyncPrefs.remove('repeat');

  // Clear keys using an allowList to avoid deleting unrelated preferences
  await asyncPrefs.clear(allowList: <String>{'counter', 'decimal', 'action', 'items'});
}
```

### Using `SharedPreferencesWithCache` (Cached Synchronous Reads)

```dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> useCachedPreferences() async {
  final SharedPreferencesWithCache prefsWithCache =
      await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: <String>{'repeat', 'action', 'counter'},
    ),
  );

  // Asynchronous writes update both platform storage and local cache
  await prefsWithCache.setBool('repeat', true);
  await prefsWithCache.setString('action', 'Start');

  // Synchronous reads from cache
  final bool? repeat = prefsWithCache.getBool('repeat');
  final String? action = prefsWithCache.getString('action');

  // Reload cache from platform storage if modified externally
  await prefsWithCache.reload();
}
```

### Migrating from Legacy `SharedPreferences`

To migrate existing preferences from legacy `SharedPreferences` to `SharedPreferencesAsync` or `SharedPreferencesWithCache` without data loss:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';

Future<void> migratePreferences() async {
  final SharedPreferences legacyPrefs = await SharedPreferences.getInstance();
  await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
    legacySharedPreferencesInstance: legacyPrefs,
    sharedPreferencesAsyncOptions: const SharedPreferencesOptions(),
    migrationCompletedKey: 'migrationCompleted',
  );
}
```
