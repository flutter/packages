# cross\_file\_darwin

The Darwin implementation of [`cross_file`][1].

This plugin provides support for traditional file systems and Apple's app sandbox, security
scoped resources, and PhotoKit assets.

When using the `FileSystem` implementations on iOS or macOS, this implementation returns the
implementation created by `CrossFileIO`.

For the `ScopedStorage` implementation, this implementation uses `dart:io` for typical file
interactions while providing access to security scoped resource features. See
https://developer.apple.com/documentation/uikit/uidocumentpickerviewcontroller#Work-with-external-documents.

## Usage

This package is [endorsed][2], which means you can simply use `cross_file`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

[1]: https://pub.dev/packages/cross_file
[2]: https://flutter.dev/to/endorsed-federated-plugin
