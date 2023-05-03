# camera\_android\_camerax

An Android implementation of [`camera`][1] that uses the [CameraX library][2].

*Note*: This package is under development.
See [missing implementations and limitations](#missing-features-and-limitations).

## Usage

This package is [unendorsed][3]; the endorsed Android implementation of `camera`
is [`camera_android`][4]. To use this implementation of the plugin, you will need
to specify it in your `pubsepc.yaml` file as a dependency in addition to `camera`:

```yaml
dependencies:
  # ...along with your other dependencies
  camera: ^0.10.4
  camera_android_camerax: ^0.5.0
```

## Contributing

The `camera` implementation is located at `./lib/src/android_camera_camerax.dart`, and
it is implemented using Dart classes that act as wrapped versions of the Android
classes that the implementation needs access to.

To understand how this works, consider the example of [`Camera`][11], the interface
provided by CameraX used to control the flow of data to use cases, control the camera,
and publish the state of the camera via CameraInfo. The Dart-wrapped version of this
class is located at `./lib/src/camera.dart`. You'll notice its implementation as
`Camera`, but also two additional classes: `CameraHostApiImpl`, an extension
of the Host API used by [`pigeon`][12] to communicate with native code, and
`CameraFlutterApiImpl`, the implementation of the Flutter API used by `pigeon` to
communicate with native code. The file that `pigeon` uses to generate the Host
and Flutter APIs used by these classes is located at `pigeons/camerax_library.dart`.

Both `CameraHostApiImpl` and `CameraFlutterApiImpl` utilize `BinaryMessenger`
instances to communicate with native code using `pigeon`; for more information on
`pigeon`, see its [documentation][12]. Both of these classes additionally utilize
an `InstanceManager` instance that is used to manage Dart objects that represent
their Android counterparts. For example, the `InstanceManager` instance is used
to manage any instances of `Camera` we create in Dart and in native, and any other
instances that `Camera` methods may create.

On the native side, you'll find two Java classes that mirror these two Dart classes
discussed: in `./android/src/main/java/io/flutter/plugins/camerax/`. you will find
`CameraHostApiImpl.java` and `CameraFlutterApiImpl.java`, which implement the Host
API and extend the Flutter API used by `pigeon`, respectfully.

WHAT IF INSTEAD I JUST DID A MAP OF THE STRUCTURE VERSUS A LENGTHY EXAMPLE.


Thus, if you want to implement any new functionality in the implementation or fix any
bugs, you will want to search in `./lib/src/` for any wrapped classes you may need. If
any classes you need are not wrapped or you need to implement any additional methods,
you will need to take additional steps to wrap them.

## Missing features and limitations

### Resolution configuration \[[Issue #120462][5]\]

Any specified `ResolutionPreset` is unused in favor of CameraX defaults and
`onCameraResolutionChanged` is unimplemented.

### Locking/Unlocking capture orientation \[[Issue #125915][6]\]

`lockCaptureOrientation` & `unLockCaptureOrientation` are unimplemented.

### Flash mode configuration \[[Issue #120715][7]\]

`setFlashMode` is unimplemented.

### Exposure mode, point, & offset configuration \[[Issue #120468][8]\]

`setExposureMode`, `setExposurePoint`, & `setExposureOffset` are unimplemented.

### Focus mode & point configuration \[[Issue #120467][9]\]

`setFocusMode` & `setFocusPoint` are unimplemented.

### Zoom configuration \[[Issue #125371][9]\]

`setZoomLevel` is unimplemented.

<!-- Links -->

[1]: https://pub.dev/packages/camera
[2]: https://developer.android.com/training/camerax
[3]: https://docs.flutter.dev/packages-and-plugins/developing-packages#non-endorsed-federated-plugin
[4]: https://pub.dev/packages/camera_android
[5]: https://github.com/flutter/flutter/issues/120462
[6]: https://github.com/flutter/flutter/issues/125915
[7]: https://github.com/flutter/flutter/issues/120715
[8]: https://github.com/flutter/flutter/issues/120468
[9]: https://github.com/flutter/flutter/issues/120467
[10]: https://github.com/flutter/flutter/issues/125371
[11]: https://developer.android.com/reference/androidx/camera/core/Camera
[12]: 