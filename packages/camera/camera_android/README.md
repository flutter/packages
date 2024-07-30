# camera\_android

An Android implementation of [`camera`][1] built with the [Camera2 library][4].

## Usage

As of `camera: ^0.11.0`, to use this plugin instead of [`camera_android_camerax`][3],
run

```sh
$ flutter pub add camera_android
```

## Limitation of testing video recording on emulators
`MediaRecorder` does not work properly on emulators, as stated in [the documentation][5]. Specifically,
when recording a video with sound enabled and trying to play it back, the duration won't be correct and
you will only see the first frame.

[1]: https://pub.dev/packages/camera
[2]: https://flutter.dev/to/endorsed-federated-plugin
[3]: https://pub.dev/packages/camera_android_camerax
[4]: https://developer.android.com/media/camera/camera2
[5]: https://developer.android.com/reference/android/media/MediaRecorder
