# camera\_android

The Android implementation of [`camera`][1].

*Note*: [`camera_android_camerax`][3] will become the default implementation of
`camera` on Android by May 2024, so **we strongly encourage you to opt into it**
by using [these instructions][4]. If any [limitations][5] of `camera_android_camerax`
prevent you from using it or if you run into any problems, please report these
issues under [`flutter/flutter`][5] with `[camerax]` in the title.

## Usage

This package is [endorsed][2], which means you can simply use `camera`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

[1]: https://pub.dev/packages/camera
[2]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin
[3]: https://pub.dev/packages/camera_android_camerax
[4]: https://pub.dev/packages/camera_android_camerax#usage
[5]: https://pub.dev/packages/camera_android_camerax#limitations
