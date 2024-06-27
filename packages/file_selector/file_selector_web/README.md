# file\_selector\_web

The web implementation of [`file_selector`][1].

## Usage

This package is [endorsed][2], which means you can simply use `file_selector`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

[1]: https://pub.dev/packages/file_selector
[2]: https://flutter.dev/to/endorsed-federated-plugin

## Limitations on the Web platform

### `cancel` event

The `cancel` event used by the web plugin to detect when users close the file
selector without picking a file is relatively new, and will only work in
recent browsers.

See:

* https://caniuse.com/mdn-api_htmlinputelement_cancel_event
