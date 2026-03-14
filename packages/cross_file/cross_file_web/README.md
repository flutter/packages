# cross\_file\_web

The web implementation of [`cross_file`][1].

## Usage

This package is [endorsed][2], which means you can simply use `cross_file`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Limitations

`XFile` on the web platform is backed by [Blob](https://api.dart.dev/be/180361/dart-html/Blob-class.html)
objects and their URLs.

It seems that Safari hangs when reading Blobs larger than 4GB (your app will stop without returning
any data, or throwing an exception).

This package will attempt to throw an `Exception` before a large file is accessed from Safari (if
its size is known beforehand), so that case can be handled programmatically.

### Browser compatibility

[![Data on Global support for Blob constructing](https://caniuse.bitsofco.de/image/blobbuilder.png)](https://caniuse.com/blobbuilder)

[![Data on Global support for Blob URLs](https://caniuse.bitsofco.de/image/bloburls.png)](https://caniuse.com/bloburls)

### Tests

Tests for the web platform can be run with `flutter test -d chrome`.

[1]: https://pub.dev/packages/cross_file
[2]: https://flutter.dev/to/endorsed-federated-plugin
