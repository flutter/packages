## NEXT

* Updates minimum supported SDK version to Flutter 3.38/Dart 3.10.

## 1.1.0

* Deprecates top-level utility functions `blendPoints` and `reflectedPoint` and
  some members in `PathSegmentData`.

## 1.0.3

* Updates README.md.

## 1.0.2

* Transfers the package source from https://github.com/dnfield/dart_path_parsing
  to https://github.com/flutter/packages.

## 1.0.1

* Fixes [bug in arc decomposition](https://github.com/dnfield/flutter_svg/issues/742).
* Minor code cleanup for analysis warnings.

## 1.0.0

* Stable release.

## 0.2.1

* Performance improvements to parsing.

## 0.2.0

* Stable nullsafe release.

## 0.2.0-nullsafety.0

* Nullsafety migration.

## 0.1.4

* Fixes implementation of `_PathOffset`'s `==` operator.

## 0.1.3

* Fixes a bug in decompose cubic curve - avoid trying to call `toInt()` on `double.infinity`.
* Bumps test dependency.

## 0.1.2

* Fixes bug with smooth curve commands.
* Adds deep testing.

## 0.1.1

* Fixes link to homepage in pubspec, add example.

## 0.1.0

* Initial release, based on the 0.2.4 release of path_drawing.
