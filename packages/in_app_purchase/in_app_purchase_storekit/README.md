# in\_app\_purchase\_storekit

The iOS and macOS implementation of [`in_app_purchase`][1].

## Usage

This package has been [endorsed][2], meaning that you only need to add `in_app_purchase`
as a dependency in your `pubspec.yaml`. This package will be automatically included in your app
when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should [add it to your `pubspec.yaml` as usual][3].

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


[1]: ../in_app_purchase
[2]: https://flutter.dev/to/endorsed-federated-plugin
[3]: https://pub.dev/packages/in_app_purchase_storekit/install
