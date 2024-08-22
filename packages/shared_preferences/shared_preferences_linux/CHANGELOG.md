## 2.4.1

* Fixes `getStringList` returning immutable list.
* Fixes `getStringList` cast error.
* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.

## 2.4.0

* Adds `SharedPreferencesAsyncLinux` API.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 2.3.2

* Updates `package:file` version constraints.

## 2.3.1

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 2.3.0

* Adds `clearWithParameters` and `getAllWithParameters` methods.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 2.2.0

* Adds `getAllWithPrefix` and `clearWithPrefix` methods.

## 2.1.5

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 2.1.4

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 2.1.3

* Updates code for stricter lint checks.

## 2.1.2

* Updates code for stricter lint checks.
* Updates code for `no_leading_underscores_for_local_identifiers` lint.
* Updates minimum Flutter version to 2.10.

## 2.1.1

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 2.1.0

* Deprecated `SharedPreferencesWindows.instance` in favor of `SharedPreferencesStorePlatform.instance`.

## 2.0.4

* Removes dependency on `meta`.

## 2.0.3

* Removed obsolete `pluginClass: none` from pubpsec.
* Fixes newly enabled analyzer options.

## 2.0.2

* Updated installation instructions in README.

## 2.0.1

* Add `implements` to the pubspec.
* Add `registerWith` to the Dart main class.

## 2.0.0

* Migrate to null-safety.

## 0.0.3+1

* Update Flutter SDK constraint.

## 0.0.3

* Update integration test examples to use `testWidgets` instead of `test`.

## 0.0.2+4

* Remove unused `test` dependency.
* Update Dart SDK constraint in example.

## 0.0.2+3

* Check in linux/ directory for example/

## 0.0.2+2

* Bump the `file` package dependency to resolve dep conflicts with `flutter_driver`.

## 0.0.2+1
* Replace path_provider dependency with path_provider_linux.

## 0.0.2
* Add iOS stub.

## 0.0.1
* Initial release to support shared_preferences on Linux.
