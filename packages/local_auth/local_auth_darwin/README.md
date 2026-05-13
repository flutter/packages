# local_auth_darwin

The iOS and macOS implementation of [`local_auth`][1].

## Usage

This package is [endorsed][2], which means you can simply use `local_auth`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Setup

To support Face ID on iOS devices, you must add an
[`NSFaceIDUsageDescription`][3] entry to your `Info.plist` file:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Explain why your app needs Face ID access here.</string>
```

[1]: https://pub.dev/packages/local_auth
[2]: https://flutter.dev/to/endorsed-federated-plugin
[3]: https://developer.apple.com/documentation/bundleresources/information-property-list/nsfaceidusagedescription
