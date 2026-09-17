---
name: shared-preferences-android-setup-and-usage
description: Set up and configure shared_preferences_android, the Android implementation of Flutter's shared_preferences plugin supporting Jetpack DataStore and Android SharedPreferences backends.
---

# Setting Up and Using shared_preferences_android

`shared_preferences_android` is the endorsed Android platform implementation of the Flutter [`shared_preferences`](https://pub.dev/packages/shared_preferences) plugin.

## 1. Installation and Setup

Because `shared_preferences_android` is an endorsed federated plugin implementation, adding `shared_preferences` to your `pubspec.yaml` automatically includes it.

However, if you import `package:shared_preferences_android/shared_preferences_android.dart` directly to configure Android-specific options (such as selecting the storage backend or custom file names), add it explicitly to your `pubspec.yaml`:

```yaml
dependencies:
  shared_preferences: ^2.5.0
  shared_preferences_android: ^2.4.0
```

## 2. Platform-Specific Configuration

### Storage Backends on Android

When using `SharedPreferencesAsync` or `SharedPreferencesWithCache`, the Android implementation supports two storage backends:
1. **`SharedPreferencesAndroidBackendLibrary.DataStore`** (Default): Uses Android Jetpack DataStore Preferences. This is the recommended backend for new apps and modern Android storage.
2. **`SharedPreferencesAndroidBackendLibrary.SharedPreferences`**: Uses native Android `android.content.SharedPreferences`. Use this backend when you need to read or write preferences shared with native Android code or third-party SDKs that use standard `SharedPreferences`, or to specify a custom preferences file name.

Note that the legacy `SharedPreferences.getInstance()` API always uses the native `android.content.SharedPreferences` backend with the default `FlutterSharedPreferences` file.

## 3. Usage and API Examples

### Configuring Android SharedPreferences Backend and File Name

Pass `SharedPreferencesAsyncAndroidOptions` when instantiating `SharedPreferencesAsync` or `SharedPreferencesWithCache`:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

Future<void> useCustomAndroidPreferencesFile() async {
  const SharedPreferencesAsyncAndroidOptions androidOptions =
      SharedPreferencesAsyncAndroidOptions(
    backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
    originalSharedPreferencesOptions: AndroidSharedPreferencesStoreOptions(
      fileName: 'my_custom_native_prefs',
    ),
  );

  // Using SharedPreferencesAsync with custom Android options
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync(
    options: androidOptions,
  );

  await asyncPrefs.setString('native_key', 'example_value');
  final String? value = await asyncPrefs.getString('native_key');

  // Or using SharedPreferencesWithCache with custom Android options
  final SharedPreferencesWithCache cachedPrefs =
      await SharedPreferencesWithCache.create(
    sharedPreferencesOptions: androidOptions,
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: <String>{'native_key'},
    ),
  );

  final String? cachedValue = cachedPrefs.getString('native_key');
}
```

### Direct Platform Registration (Testing / Custom Integration)

If you need to register the Android platform implementation manually (for example, in custom test harnesses):

```dart
import 'package:shared_preferences_android/shared_preferences_android.dart';

void registerAndroidPlugin() {
  SharedPreferencesAndroid.registerWith();
}
```
