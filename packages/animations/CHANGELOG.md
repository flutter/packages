# Changelog

All notable changes to this project will be documented in this file.

## [1.1.2] - July 28, 2020

* Fixes for upcoming changes to the flutter framework.

## [1.1.1] - June 19, 2020

* Hide implementation of `DualTransitionBuilder` as the widget has been implemented in the Flutter framework.

## [1.1.0] - June 2, 2020

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


## [1.0.0+5] - February 21, 2020

* Fix override analyzer ignore placement.


## [1.0.0+4] - February 21, 2020

* Fix a typo in the changelog dates
* Revert use of modern Material text style nomenclature in the example app
  to be compatible with Flutter's `stable` branch for the time being.
* Add override analyzer ignore in modal.dart for reverseTransitionDuration
  until Flutter's stable branch contains
  https://github.com/flutter/flutter/pull/48274.


## [1.0.0+3] - February 18, 2020

* Update README.md to better describe Material motion


## [1.0.0+2] - February 18, 2020

* Fixes to pubspec.yaml


## [1.0.0+1] - February 18, 2020

* Fixes to pubspec.yaml


## [1.0.0] - February 18, 2020

* Initial release
