## NEXT

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.

## 2.3.3

* Changes `launchUrl` so it always returns `true`, except for disallowed URL schemes.

## 2.3.2

* Adds support for `web: ^1.0.0`.

## 2.3.1

* Implements correct handling of keyboard events with Link.

## 2.3.0

* Updates web code to package `web: ^0.5.0`.
* Updates SDK version to Dart `^3.3.0`. Flutter `^3.19.0`.

## 2.2.3

* Fixes new lint warnings.

## 2.2.2

* Adds documentation that a launch in a new window/tab needs to be triggered by
  a user action.

## 2.2.1

* Supports Flutter Web + Wasm
* Updates minimum supported SDK version to Flutter 3.16.0/Dart 3.2.0.

## 2.2.0

* Implements `supportsMode` and `supportsCloseForMode`.

## 2.1.0

* Adds `launchUrl` implementation.
* Prevents _Tabnabbing_ and disallows `javascript:` URLs on `launch` and `launchUrl`.

## 2.0.20

* Migrates to `dart:ui_web` APIs.
* Updates minimum supported SDK version to Flutter 3.13.0/Dart 3.1.0.

## 2.0.19

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 2.0.18

* Removes nested third_party Safari check.

## 2.0.17

* Removes obsolete null checks on non-nullable values.
* Updates minimum Flutter version to 3.3.

## 2.0.16

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 2.0.15

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 2.0.14

* Updates code for stricter lint checks.
* Updates minimum Flutter version to 2.10.

## 2.0.13

* Updates `url_launcher_platform_interface` constraint to the correct minimum
  version.

## 2.0.12

* Fixes call to `setState` after dispose on the `Link` widget.
[Issue](https://github.com/flutter/flutter/issues/102741).
* Removes unused `BuildContext` from the `LinkViewController`.

## 2.0.11

* Minor fixes for new analysis options.

## 2.0.10

* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 2.0.9

- Fixes invalid routes when opening a `Link` in a new tab

## 2.0.8

* Updates the minimum Flutter version to 2.10, which is required by the change
  in 2.0.7.

## 2.0.7

* Marks the `Link` widget as invisible so it can be optimized by the engine.

## 2.0.6

* Removes dependency on `meta`.

## 2.0.5

* Updates code for new analysis options.

## 2.0.4

- Add `implements` to pubspec.

## 2.0.3

- Replaced reference to `shared_preferences` plugin with the `url_launcher` in the README.

## 2.0.2

- Updated installation instructions in README.

## 2.0.1

- Change sizing code of `Link` widget's `HtmlElementView` so it works well when slotted.

## 2.0.0

- Migrate to null safety.

## 0.1.5+3

- Fix Link misalignment [issue](https://github.com/flutter/flutter/issues/70053).

## 0.1.5+2

- Update Flutter SDK constraint.

## 0.1.5+1

- Substitute `undefined_prefixed_name: ignore` analyzer setting by a `dart:ui` shim with conditional exports. [Issue](https://github.com/flutter/flutter/issues/69309).

## 0.1.5

- Added the web implementation of the Link widget.

## 0.1.4+2

- Move `lib/third_party` to `lib/src/third_party`.

## 0.1.4+1

- Add a more correct attribution to `package:platform_detect` code.

## 0.1.4

- (Null safety) Remove dependency on `package:platform_detect`
- Port unit tests to run with `flutter drive`

## 0.1.3+2

- Fix a typo in a test name and fix some style inconsistencies.

## 0.1.3+1

- Depend explicitly on the `platform_interface` package that adds the `webOnlyWindowName` parameter.

## 0.1.3

- Added webOnlyWindowName parameter to launch()

## 0.1.2+1

- Update docs

## 0.1.2

- Adds "tel" and "sms" support

## 0.1.1+6

- Open "mailto" urls with target set as "\_top" on Safari browsers.
- Update lower bound of dart dependency to 2.2.0.

## 0.1.1+5

- Update lower bound of dart dependency to 2.1.0.

## 0.1.1+4

- Declare API stability and compatibility with `1.0.0` (more details at: https://github.com/flutter/flutter/wiki/Package-migration-to-1.0.0).

## 0.1.1+3

- Refactor tests to not rely on the underlying browser behavior.

## 0.1.1+2

- Open urls with target "\_top" on iOS PWAs.

## 0.1.1+1

- Make the pedantic dev_dependency explicit.

## 0.1.1

- Added support for mailto scheme

## 0.1.0+2

- Remove androidx references from the no-op android implemenation.

## 0.1.0+1

- Add an android/ folder with no-op implementation to workaround https://github.com/flutter/flutter/issues/46304.
- Bump the minimal required Flutter version to 1.10.0.

## 0.1.0

- Update docs and pubspec.

## 0.0.2

- Switch to using `url_launcher_platform_interface`.

## 0.0.1

- Initial open-source release.
