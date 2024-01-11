# image\_picker\_macos

A macOS implementation of [`image_picker`][1].

## Limitations

`ImageSource.camera` is not supported unless a `cameraDelegate` is set.

### pickImage()
The arguments `maxWidth`, `maxHeight`, and `imageQuality` are not currently supported.

### pickVideo()
The argument `maxDuration` is not currently supported.

## Usage

### Import the package

This package is [endorsed][2], which means you can simply use `file_selector`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

### Entitlements

This package is currently implemented using [`file_selector`][3], so you will
need to add a read-only file acces [entitlement][4]:
```xml
    <key>com.apple.security.files.user-selected.read-only</key>
    <true/>
```

[1]: https://pub.dev/packages/image_picker
[2]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin
[3]: https://pub.dev/packages/file_selector
[4]: https://docs.flutter.dev/platform-integration/macos/building#entitlements-and-the-app-sandbox
