# camera\_android

The Android implementation of [`camera`][1].

*Note*: Unless any of the [missing features and limitations](TODO(camsim99)) of
`camera_android_camerax` may restrict you from using its implementation, please
see [the instructions](TODO(camsim99)) on how to use that platform implementation,
as support for `camera_android` will eventually stop. Additionally, if there are
any reasons you are unable to use `camera_android_camerax` besides those listed,
please report these by filing issues under [`flutter/flutter`][5] with `[camerax]` in
the title, which will be actively triaged.

## Usage

This package is [endorsed][2], which means you can simply use `camera`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

[1]: https://pub.dev/packages/camera
[2]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin
