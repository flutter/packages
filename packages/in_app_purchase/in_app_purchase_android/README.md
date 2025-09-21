# in\_app\_purchase\_android

The Android implementation of [`in_app_purchase`][1].

## Usage

This package is [endorsed][2], which means you can simply use `in_app_purchase`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should [add it to your `pubspec.yaml` as usual][3].

## Alternative/UserChoice Billing

Alternative and UserChoice billing from Google Play is exposed from this package.

Using the Alternative billing only feature requires Google Play app configuration, checking if the feature is available (`isAlternativeBillingOnlyAvailable`) and informing users that Google Play does not handle all aspects of purchase (`showAlternativeBillingOnlyInformationDialog`). After those calls then you can call `setBillingChoice` and respond when a user attempts a purchase.

[Google Play documentation for Alternative billing](https://developer.android.com/google/play/billing/alternative)

## Migrating to 0.3.0
To migrate to version 0.3.0 from 0.2.x, have a look at the [migration guide](migration_guide.md).

[1]: https://pub.dev/packages/in_app_purchase
[2]: https://flutter.dev/to/endorsed-federated-plugin
[3]: https://pub.dev/packages/in_app_purchase_android/install
