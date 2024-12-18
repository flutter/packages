# shared\_preferences\_android

The Android implementation of [`shared_preferences`][1].

## Usage

This package is [endorsed][2], which means you can simply use `shared_preferences`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Options

The [SharedPreferencesAsync] and [SharedPreferencesWithCache] APIs can use [DataStore Preferences](https://developer.android.com/topic/libraries/architecture/datastore) or [Android SharedPreferences](https://developer.android.com/reference/android/content/SharedPreferences) to store data.

To use the `Android SharedPreferences` backend, use the `SharedPreferencesAsyncAndroidOptions` when using [SharedPreferencesAsync].

<?code-excerpt "example/lib/main.dart (Android_Options)"?>
```dart
const SharedPreferencesAsyncAndroidOptions options =
    SharedPreferencesAsyncAndroidOptions(
        backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
        originalSharedPreferencesOptions: AndroidSharedPreferencesStoreOptions(
            fileName: 'the_name_of_a_file'));
```

The [SharedPreferences] API uses the native [Android SharedPreferences](https://developer.android.com/reference/android/content/SharedPreferences) tool to store data.

[1]: https://pub.dev/packages/shared_preferences
[2]: https://flutter.dev/to/endorsed-federated-plugin
