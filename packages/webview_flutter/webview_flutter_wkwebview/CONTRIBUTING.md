# Contributing to `webview_flutter_wkwebview`

Please start by taking a look at the general guide to contributing to the `flutter/packages` repo:
https://github.com/flutter/packages/blob/main/CONTRIBUTING.md

## Package Structure

This plugin serves as a platform implementation plugin as outlined in [federated plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages#federated-plugins).
The sections below will provide an overview of how this plugin implements this portion with iOS and
macOS.

For making changes to this package, please take a look at [changing federated plugins](https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#changing-federated-plugins).

### Quick Overview

This plugin implements the platform interface provided by `webview_flutter_platform_interface` using
the native WebKit APIs for WKWebView APIs.

#### SDK Wrappers

To access native APIS, this plugins uses Dart wrappers of the native library. The native library is
wrapped using using the `ProxyApi` feature from the `pigeon` package.

The wrappers for the native library can be updated and modified by changing `pigeons/web_kit.dart`.

The generated files are located:
* `lib/src/common/web_kit.g.dart`
* `darwin/webview_flutter_wkwebview/Sources/webview_flutter_wkwebview/WebKitLibrary.g.swift`

To update the wrapper, follow the steps below:

##### 1. Make changes to the respective pigeon file that matches the native SDK

* WebKit Dependency: https://developer.apple.com/documentation/webkit
* Pigeon file to update: `pigeons/web_kit.dart`

##### 2. Run the code generator from the terminal

Run: `dart run pigeon --input pigeons/web_kit.dart`

##### 3. Update the generated APIs in native code

Running the `flutter build` command from step 1 again should provide build errors and indicate what
needs to be done. Alternatively, it can be easier to update native code with the platform's specific
IDE:

Open `example/ios/` or `example/macos/` in Xcode.

##### 4. Write API tests

Assuming a non-static method or constructor was added to the native wrapper, a native test will need
to be added.

Tests location: `darwin/Tests`
