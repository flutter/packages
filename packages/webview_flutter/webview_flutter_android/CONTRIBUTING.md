# Contributing to `webview_flutter_android`

Please start by taking a look at the general guide to contributing to the `flutter/packages` repo:
https://github.com/flutter/packages/blob/main/CONTRIBUTING.md

## Package Structure

This plugin serves as a platform implementation plugin as outlined in [federated plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages#federated-plugins). 
The sections below will provide an overview of how this plugin implements this portion with Android.

For making changes to this package, please take a look at [changing federated plugins](https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#changing-federated-plugins).

### Quick Overview

This plugin implements the platform interface provided by `webview_flutter_platform_interface` using
the native WebKit APIs for Android.

#### SDK Wrappers

To access native APIS, this plugins uses Dart wrappers of the native library. The native library is
wrapped using using the `ProxyApi` feature from the `pigeon` package.

The wrappers for the native library can be updated and modified by changing `pigeons/android_webkit.dart`.

The generated files are located:
* `lib/src/android_webkit.g.dart`
* `android/src/main/java/io/flutter/plugins/webviewflutter/AndroidWebkitLibrary.g.kt`

To update the wrapper, follow the steps below:

##### 1. Ensure the project has been built at least once

Run `flutter build apk --debug` in `example/`.

##### 2. Make changes to the respective pigeon file that matches the native SDK

* Android Dependency: https://developer.android.com/reference/android/webkit/package-summary
* Pigeon file to update: `pigeons/android_webkit.dart`

##### 3. Run the code generator from the terminal

Run: `dart run pigeon --input pigeons/android_webkit.dart`

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
needs to be updated after the pigeon generator is run. Please add

```kotlin
val instance: Any? = getInstance(identifier)
if (instance is WebViewProxyApi.WebViewPlatformView) {
  instance.destroy()
}
```

to `AndroidWebkitLibraryPigeonInstanceManager.remove`. The current implementation of the native
code doesn't currently support handling when the Dart instance is garbage collected.
