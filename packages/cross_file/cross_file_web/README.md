# cross\_file\_web

The web implementation of [`cross_file`][1].

## Usage

This package is [endorsed][2], which means you can simply use `cross_file`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Importing `cross_file_web`

Depending on your target platforms, this plugin offers two different entry points:

### 1. Safe Multiplatform Import (Recommended for Cross-Platform Code)
If your code runs on multiple platforms (iOS, Android, macOS, Linux, Windows, and Web) but needs to reference web-specific creation parameters or extensions safely, use the safe entry point:

```dart
import 'package:cross_file_web/cross_file_web_safe.dart';
```

This file uses conditional exports (`dart.library.js_interop`), ensuring your code compiles successfully across **all platforms** while providing web-specific features when running on the web.

### 2. Direct Web Import (Web-Only)
If your code targets **only the web** (or web-specific tests/implementations), you can import the direct implementation:

```dart
import 'package:cross_file_web/cross_file_web.dart';
```

> [!WARNING]
> Importing `cross_file_web.dart` directly on non-web platforms (such as Android or iOS) will cause compilation failures because it depends on web-only APIs and libraries.

### Browser compatibility

[![Data on Global support for Blob constructing](https://caniuse.bitsofco.de/image/blobbuilder.png)](https://caniuse.com/blobbuilder)

[![Data on Global support for Blob URLs](https://caniuse.bitsofco.de/image/bloburls.png)](https://caniuse.com/bloburls)

[1]: https://pub.dev/packages/cross_file
[2]: https://flutter.dev/to/endorsed-federated-plugin
