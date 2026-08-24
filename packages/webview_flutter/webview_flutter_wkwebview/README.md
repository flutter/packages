# webview\_flutter\_wkwebview

The Apple WKWebView implementation of [`webview_flutter`][1].

## Usage

This package is [endorsed][2], which means you can simply use `webview_flutter`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

### Gesture blocking policy

By default the plugin lets the engine block the web view's gesture recognizers through Flutter's
gesture arena. If a web view stops responding to touches after the first interaction, deriving the
blocking decision from hit testing instead can work around it:

<?code-excerpt "example/lib/readme_excerpts.dart (gesture_blocking_policy_example)"?>
```dart
final params = WebKitWebViewWidgetCreationParams(
  controller: controller,
  gestureBlockingPolicy: .doNotBlockGesture,
);
```

Pass those parameters to `WebViewWidget.fromPlatformCreationParams`, using the `platform` of your
`WebViewController` as the `controller`.

This is a workaround for bugs in the underlying `WKWebView`, and it may cause the web view to
recognize a gesture that should have been blocked, so only opt in when a web view is affected.

### External Native API

The plugin also provides a native API accessible by the native code of iOS applications or packages.
This API follows the convention of breaking changes of the Dart API, which means that any changes to
the class that are not backwards compatible will only be made with a major version change of the
plugin. Native code other than this external API does not follow breaking change conventions, so
app or plugin clients should not use any other native APIs.

The API can be accessed by importing the native plugin `webview_flutter_wkwebview`:

Objective-C:

```objectivec
@import webview_flutter_wkwebview;
```

Then you will have access to the native class `FWFWebViewFlutterWKWebViewExternalAPI`.

## Contributing

For information on contributing to this plugin, see [`CONTRIBUTING.md`](CONTRIBUTING.md).

[1]: https://pub.dev/packages/webview_flutter
[2]: https://flutter.dev/to/endorsed-federated-plugin
