## NEXT

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.

## 3.1.3

* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.
* Fixes handling of `file:` URLs that contain UTF-8 encoded paths.

## 3.1.2

* Updates to pigeon 21.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 3.1.1

* Updates `launchUrl` to return false instead of throwing when there is no handler.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 3.1.0

* Implements `supportsMode` and `supportsCloseForMode`.

## 3.0.8

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 3.0.7

* Updates pigeon dependency for url_launcher_windows to "^10.1.2".
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 3.0.6

* Sets a cmake_policy compatibility version to fix build warnings.

## 3.0.5

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 3.0.4

* Updates links for the merge of flutter/plugins into flutter/packages.

## 3.0.3

* Converts internal implentation to Pigeon.
* Updates minimum Flutter version to 3.0.

## 3.0.2

* Updates code for stricter lint checks.
* Updates minimum Flutter version to 2.10.

## 3.0.1

* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 3.0.0

* Changes the major version since, due to a typo in `default_package` in
  existing versions of `url_launcher`, requiring Dart registration in this
  package is in practice a breaking change.
  * Does not include any API changes; clients can allow both 2.x or 3.x.

## 2.0.3

**\[Retracted\]**

* Switches to an in-package method channel implementation.
* Adds unit tests.
* Updates code for new analysis options.

## 2.0.2

* Replaced reference to `shared_preferences` plugin with the `url_launcher` in the README.

## 2.0.1

* Updated installation instructions in README.

## 2.0.0

* Migrate to null-safety.
* Update the example app: remove the deprecated `RaisedButton` and `FlatButton` widgets.
* Set `implementation` in pubspec.yaml

## 0.0.2+1

* Update Flutter SDK constraint.

## 0.0.2

* Update integration test examples to use `testWidgets` instead of `test`.

## 0.0.1+3

* Update Dart SDK constraint in example.

## 0.0.1+2

* Check in windows/ directory for example/

## 0.0.1+1

* Update README to reflect endorsement.

## 0.0.1

* Initial Windows implementation of `url_launcher`.
