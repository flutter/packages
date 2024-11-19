# Contributing to `webview_flutter_android`

Please start by taking a look at the general guide to contributing to the `flutter/packages` repo:
https://github.com/flutter/packages/blob/main/CONTRIBUTING.md

## Package Structure

This plugin serves as a platform implementation plugin as outlined in [federated plugin](https://docs.flutter.dev/packages-and-plugins/developing-packages#federated-plugins). 
The sections below will provide an overview of how this plugin implements this portion with Android.

For making changes to this package, please take a look at [changing federated plugins](https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#changing-federated-plugins).

### Quick Overview

This plugin implements the platform interface provided in `webview_flutter_platform_interface` using
the native WebKit APIs for Android.

#### SDK Wrappers

To access native APIS, this plugins uses Dart wrappers of the native library. The native library is
wrapped using using the `ProxyApi` feature from the `pigeon` package.

The wrappers for the native library can be updated and modified by changing `pigeons/android_webview.dart`.

The generated files are located:
* `lib/src/android_webkit.g.dart`
* `android/src/main/java/io/flutter/plugins/webviewflutter/AndroidWebkitLibrary.g.kt`

To update a wrapper for a platform, follow the steps:

##### 1. Ensure the project has been built at least once

Run `flutter build apk --debug` in `example/`.

##### 2. Make changes to the respective pigeon file that matches the native SDK

* Android Dependency: https://developer.android.com/reference/android/webkit/package-summary
* Pigeon file to update: `pigeons/android_webview.dart`

##### 3. Run the code generator from the terminal

Run: `dart run pigeon --input pigeons/interactive_media_ads_android.dart`

##### 4. Update the generated APIs in native code

Running the `flutter build` command from step 1 again should provide build errors and indicate what
needs to be done. Alternatively, it can be easier to update native code with the platform's specific
IDE:

Open `example/android/` in a separate Android Studio project.

##### 5. Write API tests

Assuming a non-static method or constructor was added to the native wrapper, a native test will need
to be added.

Tests location: `android/src/test/java/io/flutter/plugins/webviewflutter/`

## Important Notes

### Calling `WebView.destroy()` after Dart Instance is Garbage Collected

To avoid a potentially breaking change, the code in `android/src/main/java/io/flutter/plugins/webviewflutter/AndroidWebkitLibrary.g.kt`
needs to be updated after the pigeon generator is ran. Please add

```kotlin
val instance: Any? = getInstance(identifier)
if (instance is WebViewProxyApi.WebViewPlatformView) {
  instance.destroy()
}
```

to `AndroidWebkitLibraryPigeonInstanceManager.remove`. The current implementation of the native
doesn't currently support handling when the Dart instance is garbage collected.

## Recommended Process for Adding a New Feature

### 1. Create a new feature request issue in the `flutter/flutter` repo.

See https://github.com/flutter/flutter/issues/new?assignees=&labels=&projects=&template=3_feature_request.yml

### 2. In that issue add the specific native classes/methods that this feature requires for each platform:

Add a note if this feature only exist for a single platform.

### 3. Add a design where the feature can be added to the platform interface and app-facing interface.

If this is only supported on a single platform, add where it can be added in the platform
implementation.

### 4. Work can be started on the feature request or you can wait for feedback from a Flutter contributor.
