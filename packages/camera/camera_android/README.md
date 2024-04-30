# camera\_android

An Android implementation of [`camera`][1] built with the [Camera2 library][4].

## Usage

As of `camera: ^0.11.0`, to use this plugin instead of [`camera_android_camerax`][3],
run

```sh
$ flutter pub add camera_android
```

If using `camera: <0.11.0` and wish to use this plugin instead of [`camera_android_camerax`][3],
you can simply use `camera` normally because it is [endorsed][2]. This package will automatically
be included in your app when you do so, so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package with a version lower than `0.11.0`, to use any of its APIs directly, you should add it to your `pubspec.yaml` as usual.

## Limitation of testing video recording on emulators
It's important to note that the `MediaRecorder` class is not working properly on emulators, as stated in the documentation: https://developer.android.com/reference/android/media/MediaRecorder. Specifically, when recording a video with sound enabled and trying to play it back, the duration won't be correct and you will only see the first frame.

[1]: https://pub.dev/packages/camera
[2]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin
[3]: https://pub.dev/packages/camera_android_camerax
[4]: https://developer.android.com/media/camera/camera2
