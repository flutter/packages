# Shared preferences plugin
<?code-excerpt path-base="example/lib"?>

[![pub package](https://img.shields.io/pub/v/shared_preferences.svg)](https://pub.dev/packages/shared_preferences)

Wraps platform-specific persistent storage for simple data
(NSUserDefaults on iOS and macOS, SharedPreferences on Android, etc.).
Data may be persisted to disk asynchronously,
and there is no guarantee that writes will be persisted to disk after
returning, so this plugin must not be used for storing critical data.

Supported data types are `int`, `double`, `bool`, `String` and `List<String>`.

|             | Android | iOS   | Linux | macOS  | Web | Windows     |
|-------------|---------|-------|-------|--------|-----|-------------|
| **Support** | SDK 21+ | 12.0+ | Any   | 10.14+ | Any | Any         |

## Usage

## SharedPreferences vs SharedPreferencesAsync vs SharedPreferencesWithCache

Starting with version 2.3.0 there are three available APIs that can be used in this package.
[SharedPreferences] is a legacy API that will be deprecated in the future. We highly encourage
any new users of the plugin to use the newer [SharedPreferencesAsync] or [SharedPreferencesWithCache] 
APIs instead.

Consider migrating existing code to one of the new APIs. See [below](#migrating-from-sharedpreferences-to-sharedpreferencesasyncwithcache) 
for more information. 

### Cache and async or sync getters

[SharedPreferences] and [SharedPreferencesWithCache] both use a local cache to store preferences.
This allows for synchronous get calls after the initial setup call fetches the preferences from the platform.
However, The cache can present issues as well:

- If you are using `shared_preferences` from multiple isolates, since each
  isolate has its own singleton and cache.
- If you are using `shared_preferences` in multiple engine instances (including
  those created by plugins that create background contexts on mobile devices,
  such as `firebase_messaging`).
- If you are modifying the underlying system preference store through something
  other than the `shared_preferences` plugin, such as native code.

This can be remedied by calling the `reload` method before using a getter as needed. 
If most get calls need a reload, consider using [SharedPreferencesAsync] instead.

[SharedPreferencesAsync] does not utilize a local cache which causes all calls to be asynchronous
calls to the host platforms storage solution. This can be less performant, but should always provide the
latest data stored on the native platform regardless of what process was used to store it.

### Android platform storage

The [SharedPreferencesAsync] and [SharedPreferencesWithCache] APIs can use [DataStore Preferences](https://developer.android.com/topic/libraries/architecture/datastore) or [Android SharedPreferences](https://developer.android.com/reference/android/content/SharedPreferences) to store data.
In most cases you should use the default option of DataStore Preferences, as it is the platform-recommended preferences storage system. 
However, in some cases you may need to interact with preferences that were written to SharedPreferences by code you don't control.

To use the `Android SharedPreferences` backend, use the `SharedPreferencesAsyncAndroidOptions` when using [SharedPreferencesAsync] on Android.
<?code-excerpt "readme_excerpts.dart (Android_Options1)"?>
```dart
import 'package:shared_preferences_android/shared_preferences_android.dart';
```
<?code-excerpt "readme_excerpts.dart (Android_Options2)"?>
```dart
const SharedPreferencesAsyncAndroidOptions options =
    SharedPreferencesAsyncAndroidOptions(
        backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
        originalSharedPreferencesOptions: AndroidSharedPreferencesStoreOptions(
            fileName: 'the_name_of_a_file'));
```

The [SharedPreferences] API uses the native [Android SharedPreferences](https://developer.android.com/reference/android/content/SharedPreferences) tool to store data.

## Examples
Here are small examples that show you how to use the API.

### SharedPreferences

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

### SharedPreferencesAsync
<?code-excerpt "readme_excerpts.dart (Async)"?>
```dart
final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

await asyncPrefs.setBool('repeat', true);
await asyncPrefs.setString('action', 'Start');

final bool? repeat = await asyncPrefs.getBool('repeat');
final String? action = await asyncPrefs.getString('action');

await asyncPrefs.remove('repeat');

// Any time a filter option is included as a method parameter, strongly consider
// using it to avoid potentially unwanted side effects.
await asyncPrefs.clear(allowList: <String>{'action', 'repeat'});
```

### SharedPreferencesWithCache
<?code-excerpt "readme_excerpts.dart (WithCache)"?>
```dart
final SharedPreferencesWithCache prefsWithCache =
    await SharedPreferencesWithCache.create(
  cacheOptions: const SharedPreferencesWithCacheOptions(
    // When an allowlist is included, any keys that aren't included cannot be used.
    allowList: <String>{'repeat', 'action'},
  ),
);

await prefsWithCache.setBool('repeat', true);
await prefsWithCache.setString('action', 'Start');

final bool? repeat = prefsWithCache.getBool('repeat');
final String? action = prefsWithCache.getString('action');

await prefsWithCache.remove('repeat');

// Since the filter options are set at creation, they aren't needed during clear.
await prefsWithCache.clear();
```


### Migration and Prefixes

#### Migrating from SharedPreferences to SharedPreferencesAsync/WithCache

To migrate to the newer `SharedPreferencesAsync` or `SharedPreferencesWithCache` APIs, 
import the migration utility and provide it with the `SharedPreferences` instance that 
was being used previously, as well as the options for the desired new API options.

This can be run on every launch without data loss as long as the `migrationCompletedKey` is not altered or deleted.

<?code-excerpt "main.dart (migrate)"?>
```dart
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';
// ···
    const SharedPreferencesOptions sharedPreferencesOptions =
        SharedPreferencesOptions();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
      legacySharedPreferencesInstance: prefs,
      sharedPreferencesAsyncOptions: sharedPreferencesOptions,
      migrationCompletedKey: 'migrationCompleted',
    );
```

#### Adding, Removing, or changing prefixes on SharedPreferences

By default, the `SharedPreferences` class will only read (and write) preferences
that begin with the prefix `flutter.`. This is all handled internally by the plugin
and does not require manually adding this prefix.

Alternatively, `SharedPreferences` can be configured to use any prefix by adding 
a call to `setPrefix` before any instances of `SharedPreferences` are instantiated.
Calling `setPrefix` after an instance of `SharedPreferences` is  created will fail.
Setting the prefix to an empty string `''` will allow access to all preferences created
by any non-flutter versions of the app (for migrating from a native app to flutter).

If the prefix is set to a value such as `''` that causes it to read values that were 
not originally stored by the `SharedPreferences`, initializing `SharedPreferences` 
may fail if any of the values are of types that are not supported by `SharedPreferences`.
In this case, you can set an `allowList` that contains only preferences of supported types.

If you decide to remove the prefix entirely, you can still access previously created
preferences by manually adding the previous prefix `flutter.` to the beginning of 
the preference key.

If you have been using `SharedPreferences` with the default prefix but wish to change
to a new prefix, you will need to transform your current preferences manually to add 
the new prefix otherwise the old preferences will be inaccessible.

### Storage location by platform

| Platform | SharedPreferences | SharedPreferencesAsync/WithCache |
| :--- | :--- | :--- |
| Android | SharedPreferences | DataStore Preferences or SharedPreferences |
| iOS | NSUserDefaults | NSUserDefaults |
| Linux | In the XDG_DATA_HOME directory | In the XDG_DATA_HOME directory |
| macOS | NSUserDefaults | NSUserDefaults |
| Web | LocalStorage | LocalStorage |
| Windows | In the roaming AppData directory | In the roaming AppData directory |
