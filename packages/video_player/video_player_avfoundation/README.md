# video\_player\_avfoundation

The iOS and macOS implementation of [`video_player`][1].

## Usage

This package is [endorsed][2], which means you can simply use `video_player`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

[1]: https://pub.dev/packages/video_player
[2]: https://flutter.dev/to/endorsed-federated-plugin

## Platform limitations

On macOS, the plugin does not currently support platform views. Instead, a texture view is always used to display the video player, even if `VideoViewType.platformView` is specified as a parameter.