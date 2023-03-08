# image\_picker\_android

The Android implementation of [`image_picker`][1].

## Usage

This package is [endorsed][2], which means you can simply use `image_picker`
normally. This package will be automatically included in your app when you do.

## Photo Picker

This package has optional Android Photo Picker functionality.

To use this feature, add these lines to your Flutter app:

```
  final ImagePickerPlatform platform = ImagePickerPlatform.instance;
  (platform as ImagePickerAndroid).useAndroidPhotoPicker = true;
```

[1]: https://pub.dev/packages/image_picker
[2]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin
