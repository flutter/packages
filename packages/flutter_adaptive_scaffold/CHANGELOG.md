## 0.1.10+1

* Removes a broken design document link from the README.

## 0.1.10

* FIX : Assertion added when tried with less than 2 destinations - [flutter/flutter#110902](https://github.com/flutter/flutter/issues/110902)

## 0.1.9

* FIX : Drawer stays open even on destination tap - [flutter/flutter#141938](https://github.com/flutter/flutter/issues/141938)
* Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.

## 0.1.8

* Adds `transitionDuration` parameter for specifying how long the animation should be.

## 0.1.7+2

* Fixes new lint warnings.

## 0.1.7+1

* Adds pub topics to package metadata.

## 0.1.7

* Fix top padding for NavigationBar.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.1.6

* Added support for displaying an AppBar on any Breakpoint by introducing appBarBreakpoint

## 0.1.5

* Added support for Right-to-left (RTL) directionality.
* Fixes stale ignore: prefer_const_constructors.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 0.1.4

* Use Material 3 NavigationBar instead of BottomNavigationBar

## 0.1.3

* Fixes `groupAlignment` property not available in `standardNavigationRail` - [flutter/flutter#121994](https://github.com/flutter/flutter/issues/121994)

## 0.1.2

* Fixes `NavigationRail` items not considering `NavigationRailTheme` values - [flutter/flutter#121135](https://github.com/flutter/flutter/issues/121135)
* When `NavigationRailTheme` is provided, it will use the theme for values that the user has not given explicit theme-related values for.

## 0.1.1

* Fixes flutter/flutter#121135) `selectedIcon` parameter not displayed even if it is provided.

## 0.1.0+1

* Aligns Dart and Flutter SDK constraints.

## 0.1.0

* Change the `selectedIndex` parameter on `standardNavigationRail` to allow null values to indicate "no destination".
* An explicitly null `currentIndex` parameter passed to `standardBottomNavigationBar` will also default to 0, just like implicitly null missing parameters.

## 0.0.9

* Fix passthrough of `leadingExtendedNavRail`, `leadingUnextendedNavRail` and `trailingNavRail`

## 0.0.8

Make fuchsia a mobile platform.

## 0.0.7

* Patch duplicate key error in SlotLayout.

## 0.0.6

* Change type of `appBar` parameter from `AppBar?` to `PreferredSizeWidget?`

## 0.0.5

* Calls onDestinationChanged callback in bottom nav bar.

## 0.0.4

* Fix static analyzer warnings using `core` lint.

## 0.0.3

* First published version.

## 0.0.2

* Adds some more examples.

## 0.0.1+1

* Updates text theme parameters to avoid deprecation issues.

## 0.0.1

* Initial release
