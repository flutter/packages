# image\_picker\_macos

A macOS implementation of [`image_picker`][1].

## PHPicker

macOS 13.0 and newer versions supports native image picking via [PHPickerViewController][5].

To use this feature, add the following code to your app before calling any `image_picker` APIs:

<?code-excerpt "main.dart (phpicker-example)"?>
```dart
import 'package:image_picker_macos/image_picker_macos.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
// ···
  final ImagePickerPlatform imagePickerImplementation =
      ImagePickerPlatform.instance;
  if (imagePickerImplementation is ImagePickerMacOS) {
    imagePickerImplementation.useMacOSPHPicker = true;
  }
```

This implementation depends on the photos in the [Photos for macOS App][6],
if the user didn't open the app or import any photos to the app,
they will see: `No photos` or `No Photos or Videos` message even if they
have them as files on their desktop. The macOS Photos app supports importing images from an iOS device.

> [!NOTE]
> This feature is only supported on **macOS 13.0 and newer versions**, on older versions it will fallback to using [`file_selector`][3] if enabled.
> By defaults it's disabled on all versions.

## Limitations

`ImageSource.camera` is not supported unless a `cameraDelegate` is set.

### pickImage()
The arguments `maxWidth`, `maxHeight`, `imageQuality`, and `limit` are only supported when using the [PHPicker](#phpicker) implementation; they are not available in the default [file_selector][5] implementation.

The argument `requestFullMetadata` is unsupported on macOS.

### pickVideo()
The argument `maxDuration` is not supported even when using the [PHPicker](#phpicker) implementation.

## Usage

### Import the package

This package is [endorsed][2], which means you can simply use `file_selector`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

### Entitlements

This package’s default implementation relies on [file_selector][3],
which requires the following read-only file access entitlement:
```xml
    <key>com.apple.security.files.user-selected.read-only</key>
    <true/>
```

If you're using the [PHPicker](#phpicker) and require at **least macOS 13** to run the app, this entitlement is not required.

[1]: https://pub.dev/packages/image_picker
[2]: https://flutter.dev/to/endorsed-federated-plugin
[3]: https://pub.dev/packages/file_selector
[4]: https://flutter.dev/to/macos-entitlements
[5]: https://developer.apple.com/documentation/photokit/phpickerviewcontroller
[6]: https://www.apple.com/in/macos/photos/
