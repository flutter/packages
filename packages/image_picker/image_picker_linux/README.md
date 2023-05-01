# image\_picker\_linux

A Linux implementation of [`image_picker`][1].

### pickImage()
The arguments `source`, `maxWidth`, `maxHeight`, `imageQuality`, and `preferredCameraDevice` are not supported on Linux.

### pickVideo()
The arguments `source`, `preferredCameraDevice`, and `maxDuration` are not supported on Linux.

## Usage

### Import the package

This package is not yet [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you need to [add `image_picker_linux` as a dependency](https://pub.dev/packages/image_picker_linux/install)
in addition to `image_picker`.

Once you do, you can use the `image_picker` APIs as you normally would, other
than the limitations noted above.

[1]: https://pub.dev/packages/image_picker
