# local\_auth\_android

The Android implementation of [`local_auth`][1].

## Usage

This package is [endorsed][2], which means you can simply use `local_auth`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Setup

### Activity Changes

`local_auth` requires the use of a `FragmentActivity` instead of an
`Activity`. To update your application:

* If you are using `FlutterActivity` directly, change it to
`FlutterFragmentActivity` in your `AndroidManifest.xml`.
* If you are using a custom activity, update your `MainActivity.kt` to
  inherit from `FlutterFragmentActivity`:

  ```kotlin
  import io.flutter.embedding.android.FlutterFragmentActivity

  class MainActivity: FlutterFragmentActivity() {
      // ...
  }
  ```

### Permissions

Update your project's `AndroidManifest.xml` file to include the
[`USE_BIOMETRIC` permission][3]:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          package="com.example.app">
  <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
</manifest>
```

### Android theme

Your `LaunchTheme`'s parent must be a valid `Theme.AppCompat` theme to prevent
crashes on Android 8 and below. For example, use `Theme.AppCompat.DayNight` to
enable light/dark modes for the biometric dialog. To do that go to
`android/app/src/main/res/values/styles.xml` and look for the style with name
`LaunchTheme`. Then change the parent for that style as follows:

```xml
...
<resources>
  <style name="LaunchTheme" parent="Theme.AppCompat.DayNight">
    ...
  </style>
  ...
</resources>
...
```

If you don't have a `styles.xml` file for your Android project you can set up
the Android theme directly in `android/app/src/main/AndroidManifest.xml`:

```xml
...
	<application
		...
		<activity
			...
			android:theme="@style/Theme.AppCompat.DayNight"
			...
		>
		</activity>
	</application>
...
```


[1]: https://pub.dev/packages/local_auth
[2]: https://flutter.dev/to/endorsed-federated-plugin
[3]: https://developer.android.com/reference/android/Manifest.permission#USE_BIOMETRIC
