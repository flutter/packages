## 0.2.2+5

* Migrates to `package:web`
* Updates `HttpRequestFactory.request` to use `package:http` `BrowserClient`
* Updates `ìndex.html` in the example to use `flutter_bootstrap.js`
* Updates minimum dart sdk to `^3.3.0`
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 0.2.2+4

* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Fixes new lint warnings.

## 0.2.2+3

* Migrates to `dart:ui_web` APIs.
* Updates minimum supported SDK version to Flutter 3.13.0/Dart 3.1.0.

## 0.2.2+2

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.
* Removes obsolete null checks on non-nullable values.
* Updates minimum Flutter version to 3.3.
* Aligns Dart and Flutter SDK constraints.

## 0.2.2+1

* Updates links for the merge of flutter/plugins into flutter/packages.

## 0.2.2

* Updates `WebWebViewController.loadRequest` to only set the src of the iFrame
  when `LoadRequestParams.headers` and `LoadRequestParams.body` are empty and is
  using the HTTP GET request method. [#118573](https://github.com/flutter/flutter/issues/118573).
* Parses the `content-type` header of XHR responses to extract the correct
  MIME-type and charset. [#118090](https://github.com/flutter/flutter/issues/118090).
* Sets `width` and `height` of widget the way the Engine wants, to remove distracting
  warnings from the development console.
* Updates minimum Flutter version to 3.0.

## 0.2.1

* Adds auto registration of the `WebViewPlatform` implementation.

## 0.2.0

* **BREAKING CHANGE** Updates platform implementation to `2.0.0` release of
  `webview_flutter_platform_interface`. See README for updated usage.
* Updates minimum Flutter version to 2.10.

## 0.1.0+4

* Fixes incorrect escaping of some characters when setting the HTML to the iframe element.

## 0.1.0+3

* Minor fixes for new analysis options.

## 0.1.0+2

* Removes unnecessary imports.
* Fixes unit tests to run on latest `master` version of Flutter.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.1.0+1

* Adds an explanation of registering the implementation in the README.

## 0.1.0

* First web implementation for webview_flutter
