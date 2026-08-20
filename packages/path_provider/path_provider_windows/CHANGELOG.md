## NEXT

* Updates minimum supported SDK version to Flutter 3.38/Dart 3.10.

## 2.3.0

* Replaces `win32` dependency with direct FFI usage.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 2.2.1

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 2.2.0

* Adds getApplicationCachePath() for storing app-specific cache files.

## 2.1.7

* Adds compatibility with `win32` 5.x.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 2.1.6

* Adds compatibility with `win32` 4.x.

## 2.1.5

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 2.1.4

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 2.1.3

* Updates minimum Flutter version to 2.10.
* Adds compatibility with `package:win32` 3.x.

## 2.1.2

* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 2.1.1

* Updates dependency version of `package:win32` to 2.1.0.

## 2.1.0

* Upgrades `package:ffi` dependency to 2.0.0.
* Adds support for unicode encoded VERSIONINFO.
* Minor fixes for new analysis options.

## 2.0.6

* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 2.0.5

* Removes dependency on `meta`.

## 2.0.4

* Removes obsolete `pluginClass: none` from pubpsec.

## 2.0.3

* Updates installation instructions in README.

## 2.0.2

* Adds `implements` to pubspec.yaml.
* Adds `registerWith()` to the Dart main class.

## 2.0.1

* Fixes a crash when a known folder can't be located.

## 2.0.0

* Migrates to null safety.

## 0.0.4+4

* Updates Flutter SDK constraint.

## 0.0.4+3

* Removes unused `test` dependency.
* Updates Dart SDK constraint in example.

## 0.0.4+2

* Check in windows/ directory for example/.

## 0.0.4+1

* Adds getPath to the stub, so that the analyzer won't complain about
  fakes that override it.
* export 'folders.dart' rather than importing it, since it's intended to be
  public.

## 0.0.4

* Moves the actual implementation behind a conditional import, exporting
  a stub for platforms that don't support FFI. Fixes web builds in
  projects with transitive dependencies on path_provider.

## 0.0.3

* Adds missing `pluginClass: none` for compatibilty with stable channel.

## 0.0.2

* README update for endorsement.
* Changes getApplicationSupportPath location.
* Removes getLibraryPath.

## 0.0.1+2

* The initial implementation of path_provider for Windows.
  * Implements getTemporaryPath, getApplicationSupportPath, getLibraryPath,
    getApplicationDocumentsPath and getDownloadsPath.
