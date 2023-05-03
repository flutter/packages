# camera\_android\_camerax

An Android implementation of [`camera`][1] that uses the [CameraX library][2].

*Note*: This package is under development.
See [missing features and limitations](#missing-features-and-limitations).

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

In `lib/src/` you will find all of the Dart-wrapped native classes that the plugin
currently uses to implement `camera`. Each of these classes uses an `InstanceManager`
(implementation in `instance_manager.dart`) to manage the creation/garbage collection
of objects created by the plugin on the Dart side and their corresponding Java object
on the native side. This plugin uses [`pigeon`][12] to communicate with native code,
so each of these Dart-wrapped classes have Host API and Flutter API implementations,
as needed.

Similarly, on the native side in `android/src/main/java/io/flutter/plugins/camerax/`,
you'll find the Host API and Flutter API implementations of the same classes wrapped
with Dart in `lib/src/`. These implementations call directly to the classes that are
wrapped in the CameraX library or otherwise. The objects created in this native code
are also managed by an `InstanceManager` (implementation in `InstanceManager.java`).

Thus, if you want to implement any new functionality in the implementation or fix any
bugs, you will want to search in `./lib/src/` for any wrapped classes you may need. If
any classes you need are not wrapped or you need to implement any additional methods,
you will need to take additional steps to wrap them.

For more information on the approach of wrapping native libraries For plugins, please
see the [design document][13].

## Missing features and limitations

### Resolution configuration \[[Issue #120462][5]\]

Any specified `ResolutionPreset` wll go unused in favor of CameraX defaults and
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
[12]: https://pub.dev/packages/pigeon
[13]: https://docs.google.com/document/d/1wXB1zNzYhd2SxCu1_BK3qmNWRhonTB6qdv4erdtBQqo/edit?usp=sharing&resourcekey=0-WOBqqOKiO9SARnziBg28pg