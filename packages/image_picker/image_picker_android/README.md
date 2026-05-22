## Photo Picker

On Android 16+ (API level 36 and above), this package always uses the Android
Photo Picker regardless of the value of
`ImagePickerAndroid.useAndroidPhotoPicker`.

On earlier Android versions, Android Photo Picker support is optional and can
be enabled with `ImagePickerAndroid.useAndroidPhotoPicker`.

To enable this feature, add the following code to your app before calling any
`image_picker` APIs:

```dart
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

// ···
final ImagePickerPlatform imagePickerImplementation =
    ImagePickerPlatform.instance;

if (imagePickerImplementation is ImagePickerAndroid) {
  imagePickerImplementation.useAndroidPhotoPicker = true;
}
```

In addition, `ImagePickerAndroid.useAndroidPhotoPicker` must be set to `true`
to use the `limit` functionality. It is implemented using
[`ActivityResultContract`][3], so support for that functionality depends on the
Android version and available system components.
