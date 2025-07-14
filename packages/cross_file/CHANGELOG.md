## NEXT

* Updates minimum supported SDK version to Flutter 3.27/Dart 3.6.

## 0.3.4+2

* Adds support for `web: ^1.0.0`.

## 0.3.4+1

* Removes a few deprecated API usages.

## 0.3.4

* Updates to web code to package `web: ^0.5.0`.
* Updates SDK version to Dart `^3.3.0`.

## 0.3.3+8

* Now supports `dart2wasm` compilation.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 0.3.3+7

* Updates README to improve example of instantiating an XFile.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 0.3.3+6

* Improves documentation about ignored parameters in IO implementation.

## 0.3.3+5

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.3.3+4

* Reverts an accidental change in a constructor argument's nullability.

## 0.3.3+3

* **RETRACTED**
* Updates code to fix strict-cast violations.
* Updates minimum SDK version to Flutter 3.0.

## 0.3.3+2

* Fixes lint warnings in tests.
* Dartdoc correction for `readAsBytes` and `readAsString`.

## 0.3.3+1

* Fixes `lastModified` unimplemented error description.

## 0.3.3

* Removes unused Flutter dependencies.

## 0.3.2

* Improve web implementation so it can stream larger files.

## 0.3.1+5

* Unify XFile interface for web and mobile platforms

## 0.3.1+4

* The `dart:io` implementation of `saveTo` now does a file copy for path-based
  `XFile` instances, rather than reading the contents into memory.

## 0.3.1+3

* Fix example in README

## 0.3.1+2

* Fix package import in README
* Remove 'Get Started' boilerplate in README

## 0.3.1+1

* Rehomed to `flutter/packages` repository.

## 0.3.1

* Fix nullability of `XFileBase`'s `path` and `name` to match the
  implementations to avoid potential analyzer issues.

## 0.3.0

* Migrated package to null-safety.
* **breaking change** According to our unit tests, the API should be backwards-compatible. Some relevant changes were made, however:
  * Web: `lastModified` returns the epoch time as a default value, to maintain the `Future<DateTime>` return type (and not `null`)

## 0.2.1

* Prepare for breaking `package:http` change.

## 0.2.0

* **breaking change** Make sure the `saveTo` method returns a `Future` so it can be awaited and users are sure the file has been written to disk.

## 0.1.0+2

* Fix outdated links across a number of markdown files ([#3276](https://github.com/flutter/plugins/pull/3276))

## 0.1.0+1

* Update Flutter SDK constraint.

## 0.1.0

* Initial open-source release.
