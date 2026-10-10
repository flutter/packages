## 1.6.0

- Documents that `TextField.decoration` is merged with the ambient
  `InputDecorationTheme` rather than replacing it.
- Fixes unresolved doc comment references.
- Fixes `NavigationIndicator` not repainting when the selected destination changes without pointer interaction.
- Removes the unconditional `dart:io` import from `AboutDialog`, so that `material_ui` is correctly detected as supporting the web platform and `showAboutDialog` no longer throws on the web when no application name is available.
- Fix DropdownButtonFormField underline alignment at bottom.
- Fixes floating-point rounding errors when calculating values for discrete `Slider` and `RangeSlider`.
- Added `fontFeatures` and `fontVariations` parameters to `TextTheme.apply()`.

## 1.5.0

- Adds Material 3 Expressive support for IconButton.
- Exposes `selected` state on `Autocomplete` option semantics.
- Wraps `DrawerHeader` in `Semantics(header: true)`.
- Adds `ignorePointer` to `TooltipThemeData` for WCAG 1.4.13 Hoverable support.
- Fixes decorations on `MenuItemButton.leadingIcon`, such as `Badge`, being clipped to the icon's bounds in vertically expanding menus.
- Introduces labelTextDirection property to InputDecoration.
- Adds support for standard, medium, and high contrast Material 3 color scheme baselines.
- Fixes LocalHistoryEntry leak when double tapping Drawer scrim
- Fixes the installation command in README.md

## 1.4.0

- Updates minimum supported SDK version to Flutter 3.47/Dart 3.13.
- Adds sortIconBuilder parameter to DataTable, PaginatedDataTable, and DataTableThemeData for custom sorting indicators.
- Fix `PopupMenuButton` not announcing button semantics (enabled state, expanded state) when built with a `child` instead of the default icon.
- Fixes `DatePickerThemeData.todayBorder` color being overridden by `todayForegroundColor` in the year selector.
- Adds an alternative keyboard input method for RangeSlider in NavigationMode.directional.

## 1.3.0

- Adds `@awaitNotRequired` annotations to asynchronous functions that do not need to be awaited.
- Adds an option for `MaterialPageRoute` and `MaterialPage` to opt out of introducing a semantics route scope.
- Fixes SliverGeometry maxPaintExtent assertion in CarouselView.weighted
- Corrects the Material 3 default style documentation for FilledButton to match its implementation.
- Adds support for customizing date input formatters via
  `CalendarDelegate.keyboardInputFormatters`, allowing custom date input
  behavior in the Material date picker.
- Adds a semanticLabel to MenuAnchor for the expanded menu overlay.

## 1.2.0

- Adds the `StyleVariant` enum defining the Material 3 and Material 3 Expressive style variants.

## 1.1.1

- Constrains Slider and RangeSlider value indicator labels to the screen width, truncating with an ellipsis instead of clipping.
- Prevents stale asynchronous suggestions from replacing newer `SearchAnchor` results.
- Fix RangeSlider thumb overlay remaining visible after touch interaction

## 1.1.0

- Add missing Widget of the Week videos to widget API docs.
- Exposes ink_sparkle shader asset in pubspec.yaml and removes stretch_effect shader.
- Fix Typo in Readme
- Fixes typos in library code and tests.
- SearchAnchor overlay expands to full-screen on viewport size change (e.g., on device rotation).
- Fixes https://github.com/flutter/flutter/issues/186154.

## 1.0.1

- Updates cupertino_ui dependency constraint to ^1.0.0.

## 1.0.0

- README updated for the full release of material_ui.
- Promotes the pre-release to 1.0.0.

## 0.0.3+1

- Replace unresolvable doc imports
- Added a main.dart example for the Pub "Example" tab that reference a curated
list of existing examples.

## 0.0.3

- Fix API doc by clearing unsupported directives introduced by macros.
- Fix API doc references.
- Adds MaterialUiCompatibilityBridge for legacy flutter/material.dart compatibility.

## 0.0.2

- Copies over all Material code from flutter/flutter.
- Copies over Material localizations from flutter/flutter's
  flutter_localizations package.
- Unpins material_color_utilities.
- Migrates API doc samples and formatting.
- Updates minimum supported SDK version to Flutter 3.44/Dart 3.12.

## 0.0.1

* Initial setup of the `material_ui` package, preparing for decoupling Material widgets from the Flutter framework.
