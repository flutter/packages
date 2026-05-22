<?code-excerpt path-base="example/lib"?>

# image\_picker\_android

The Android implementation of [`image_picker`][1].

## Usage

This package is [endorsed][2], which means you can simply use `image_picker`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Photo Picker

On Android 16 (API level 36) and above, gallery image, video, and mixed-media
picks always use the Android Photo Picker.
cannot be set to false to use the legacy ACTION_GET_CONTENT flow on those
versions. See [flutter/flutter#182071][5].

On Android 15 and below this package has optional Android Photo Picker functionality.

To use this feature, add the following code to your app before calling any `image_picker` APIs:

<?code-excerpt "main.dart (photo-picker-example)"?>
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

In addition, `ImagePickerAndroid.useAndroidPhotoPicker` must be set to `true` to use the `limit` functionality. It is implemented based on [`ActivityResultContract`][3], so it can only be ensured to take effect on Android 13 or above. Otherwise, it depends on whether the corresponding system app supports it.

[1]: https://pub.dev/packages/image_picker
[2]: https://flutter.dev/to/endorsed-federated-plugin
[3]: https://developer.android.google.cn/reference/kotlin/androidx/activity/result/contract/ActivityResultContracts.PickMultipleVisualMedia
[4]: https://pub.dev/documentation/image_picker_android/latest/image_picker_android/ImagePickerAndroid/useAndroidPhotoPicker.htmlAdd a comment on  line R52Add diff commentMarkdown input:  edit mode selected.WritePreviewHeadingBoldItalicQuoteCodeLinkUnordered listNumbered listTask listMentionReferenceMore Formatting tools items 0Saved repliesAdd FilesPaste, drop, or click to add filesCancelCommentStart a review
[5]: https://github.com/flutter/flutter/issues/182071