# image\_picker\_windows

A Windows implementation of [`image_picker`][1].

### pickImage()
The arguments `source`, `maxWidth`, `maxHeight`, `imageQuality`, and `preferredCameraDevice` are not supported on Windows.

### pickVideo()
The arguments `source`, `preferredCameraDevice`, and `maxDuration` are not supported on Windows.

## Usage

### Import the package

This package is not yet [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you need to [add `image_picker_windows` as a dependency](https://pub.dev/packages/image_picker_windows/install)
in addition to `image_picker`.

Once you do, you can use the `image_picker` APIs as you normally would, other
than the limitations noted above.
