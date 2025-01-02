# image\_picker\_linux

A Linux implementation of [`image_picker`][1].

## Limitations

`ImageSource.camera` is not supported unless a `cameraDelegate` is set.

### pickImage()
The arguments `maxWidth`, `maxHeight`, and `imageQuality` are not currently supported.

### pickVideo()
The argument `maxDuration` is not currently supported.

## Usage

### Import the package

This package is [endorsed][2], which means you can simply use `file_selector`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

[1]: https://pub.dev/packages/image_picker
[2]: https://flutter.dev/to/endorsed-federated-plugin
