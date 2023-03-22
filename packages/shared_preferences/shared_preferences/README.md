# Shared preferences plugin
<?code-excerpt path-base="excerpts/packages/shared_preferences_example"?>

[![pub package](https://img.shields.io/pub/v/shared_preferences.svg)](https://pub.dev/packages/shared_preferences)

Wraps platform-specific persistent storage for simple data
(NSUserDefaults on iOS and macOS, SharedPreferences on Android, etc.).
Data may be persisted to disk asynchronously,
and there is no guarantee that writes will be persisted to disk after
returning, so this plugin must not be used for storing critical data.

Supported data types are `int`, `double`, `bool`, `String` and `List<String>`.

|             | Android | iOS  | Linux | macOS  | Web | Windows     |
|-------------|---------|------|-------|--------|-----|-------------|
| **Support** | SDK 16+ | 9.0+ | Any   | 10.11+ | Any | Any         |

## Usage
To use this plugin, add `shared_preferences` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/platform-integration/platform-channels).

### Examples
Here are small examples that show you how to use the API.

#### Write data
<?code-excerpt "readme_excerpts.dart (Write)"?>
```dart
// Obtain shared preferences.
final SharedPreferences prefs = await SharedPreferences.getInstance();

// Save an integer value to 'counter' key.
await prefs.setInt('counter', 10);
// Save an boolean value to 'repeat' key.
await prefs.setBool('repeat', true);
// Save an double value to 'decimal' key.
await prefs.setDouble('decimal', 1.5);
// Save an String value to 'action' key.
await prefs.setString('action', 'Start');
// Save an list of strings to 'items' key.
await prefs.setStringList('items', <String>['Earth', 'Moon', 'Sun']);
```

#### Read data
<?code-excerpt "readme_excerpts.dart (Read)"?>
```dart
// Try reading data from the 'counter' key. If it doesn't exist, returns null.
final int? counter = prefs.getInt('counter');
// Try reading data from the 'repeat' key. If it doesn't exist, returns null.
final bool? repeat = prefs.getBool('repeat');
// Try reading data from the 'decimal' key. If it doesn't exist, returns null.
final double? decimal = prefs.getDouble('decimal');
// Try reading data from the 'action' key. If it doesn't exist, returns null.
final String? action = prefs.getString('action');
// Try reading data from the 'items' key. If it doesn't exist, returns null.
final List<String>? items = prefs.getStringList('items');
```

#### Remove an entry
<?code-excerpt "readme_excerpts.dart (Clear)"?>
```dart
// Remove data for the 'counter' key.
await prefs.remove('counter');
```

### Multiple instances

In order to make preference lookup via the `get*` methods synchronous,
`shared_preferences` uses a cache on the Dart side, which is normally only
updated by the `set*` methods. Usually this is an implementation detail that
does not affect callers, but it can cause issues in a few cases:
- If you are using `shared_preferences` from multiple isolates, since each
  isolate has its own `SharedPreferences` singleton and cache.
- If you are using `shared_preferences` in multiple engine instances (including
  those created by plugins that create background contexts on mobile devices,
  such as `firebase_messaging`).
- If you are modifying the underlying system preference store through something
  other than the `shared_preferences` plugin, such as native code.

If you need to read a preference value that may have been changed by anything
other than the `SharedPreferences` instance you are reading it from, you should
call `reload()` on the instance before reading from it to update its cache with
any external changes.

If this is problematic for your use case, you can thumbs up
[this issue](https://github.com/flutter/flutter/issues/123078) to express
interest in APIs that provide direct (asynchronous) access to the underlying
preference store, and/or subscribe to it for updates.

### Testing

In tests, you can replace the standard `SharedPreferences` implementation with
a mock implementation with initial values. This implementation is in-memory
only, and will not persist values to the usual preference store.

<?code-excerpt "readme_excerpts.dart (Tests)"?>
```dart
final Map<String, Object> values = <String, Object>{'counter': 1};
SharedPreferences.setMockInitialValues(values);
```

### Storage location by platform

| Platform | Location |
| :--- | :--- |
| Android | SharedPreferences |
| iOS | NSUserDefaults |
| Linux | In the XDG_DATA_HOME directory |
| macOS | NSUserDefaults |
| Web | LocalStorage |
| Windows | In the roaming AppData directory |
