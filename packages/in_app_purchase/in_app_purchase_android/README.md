# in\_app\_purchase\_android

The Android implementation of [`in_app_purchase`][1].

## Usage

This package is [endorsed][2], which means you can simply use `in_app_purchase`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should [add it to your `pubspec.yaml` as usual][3].

## Migrating to 0.3.0
To migrate to version 0.3.0 from 0.2.x, have a look at the [migration guide](migration_guide.md).

## Contributing

This plugin uses
[json_serializable](https://pub.dev/packages/json_serializable) for the
many data structs passed between the underlying platform layers and Dart. After
editing any of the serialized data structs, rebuild the serializers by running
`flutter packages pub run build_runner build --delete-conflicting-outputs`.
`flutter packages pub run build_runner watch --delete-conflicting-outputs` will
watch the filesystem for changes.

If you would like to contribute to the plugin, check out our
[contribution guide](https://github.com/flutter/packages/blob/main/CONTRIBUTING.md).


[1]: https://pub.dev/packages/in_app_purchase
[2]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin
[3]: https://pub.dev/packages/in_app_purchase_android/install
