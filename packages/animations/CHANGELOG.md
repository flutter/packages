## NEXT

* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.

## 2.0.11

* Fixes new lint warnings.

## 2.0.10

* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 2.0.9

* Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.
* Migrate motion curves to use `Easing` class.

## 2.0.8

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.
* Aligns Dart and Flutter SDK constraints.

## 2.0.7
* Updates screenshots to use webp compressed animations

## 2.0.6
* Adds screenshots to pubspec.yaml

## 2.0.5
* Update `OpenContainer` to use `Visibility` widget internally instead of `Opacity`.
* Update `OpenContainer` to use `FadeTransition` instead of animating an `Opacity`
  widget internally.

## 2.0.4

* Updates text theme parameters to avoid deprecation issues.
* Fixes lint warnings.

## 2.0.3
* Updates for non-nullable bindings.

## 2.0.2
* Fixed documentation for `OpenContainer` class; replaced `openBuilder` with `closedBuilder`.

## 2.0.1
* Add links to the spec and codelab.

## 2.0.0

* Migrates to null safety.
* Add `routeSettings` and `filter` option to `showModal`.

## 1.1.2

* Fixes for upcoming changes to the flutter framework.

## 1.1.1

* Hide implementation of `DualTransitionBuilder` as the widget has been implemented in the Flutter framework.

## 1.1.0

* Introduce usage of `DualTransitionBuilder` for all transition widgets, preventing ongoing animations at the start of the transition animation from resetting at the end of the transition animations.
* Fix `FadeScaleTransition` example's `FloatingActionButton` being accessible
and tappable when it is supposed to be hidden.
* `showModal` now defaults to using `FadeScaleTransitionConfiguration` instead of `null`.
* Added const constructors for `FadeScaleTransitionConfiguration` and `ModalConfiguration`.
* Add custom fillColor property to `SharedAxisTransition` and `SharedAxisPageTransitionsBuilder`.
* Fix prefer_const_constructors lint in test and example.
* Add option `useRootNavigator` to `OpenContainer`.
* Add `OpenContainer.onClosed`, which is called with a returned value when the container was popped and has returned to the closed state.
* Fixes a bug with OpenContainer where a crash occurs when the container is dismissed after the container widget itself is removed.


## 1.0.0+5

* Fix override analyzer ignore placement.


## 1.0.0+4

* Fix a typo in the changelog dates
* Revert use of modern Material text style nomenclature in the example app
  to be compatible with Flutter's `stable` branch for the time being.
* Add override analyzer ignore in modal.dart for reverseTransitionDuration
  until Flutter's stable branch contains
  https://github.com/flutter/flutter/pull/48274.


## 1.0.0+3

* Update README.md to better describe Material motion


## 1.0.0+2

* Fixes to pubspec.yaml


## 1.0.0+1

* Fixes to pubspec.yaml


## 1.0.0

* Initial release
