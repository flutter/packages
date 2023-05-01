# image\_picker\_macos

A macOS implementation of [`image_picker`][1].

### pickImage()
The arguments `source`, `maxWidth`, `maxHeight`, `imageQuality`, and `preferredCameraDevice` are not supported on macOS.

### pickVideo()
The arguments `source`, `preferredCameraDevice`, and `maxDuration` are not supported on macOS.

## Usage

### Import the package

This package is not yet [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you need to [add `image_picker_macos` as a dependency](https://pub.dev/packages/image_picker_macos/install)
in addition to `image_picker`.

Once you do, you can use the `image_picker` APIs as you normally would, other
than the limitations noted above.

[1]: https://pub.dev/packages/image_picker
