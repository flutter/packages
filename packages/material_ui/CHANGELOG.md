## 1.8.1

- Fixes `showModalBottomSheet(useSafeArea: true)` incorrectly applying opposite sub-screen safe area padding on display-feature sub-screens.

## 1.8.0

- Adds `RoundedPolygon` and `CornerRounding` for creating rounded polygonal shapes.
- Adds `MaterialShapes`, the catalog of predefined Material Design shapes.
- Adds `MaterialShapeBorder` for drawing a `RoundedPolygon` as an `OutlinedBorder`, which morphs between shapes when lerped.
- Adds an example that morphs through the shapes in `MaterialShapes.all`.
- Adds `enableInlinePrediction` to `TextFormField`.
- Adds the `supportingTextPadding` property to `InputDecoration` and `InputDecorationThemeData`.
- Adds an `enabled` parameter to `DropdownButtonFormField` and makes its
  `onChanged` parameter optional. When `enabled` is true, the field is
  interactive without an `onChanged` callback.
- Adds a Material 3 Expressive IconButton example.
- Fix `GridTile` crash when the incoming constraints are unbounded (e.g. inside a horizontally scrolling `ListView`).
- Adds `onTertiaryTapDown`, `onTertiaryTapUp` and `onTertiaryTapCancel` to `InkResponse` and `InkWell`, so a tertiary (middle) button click can be handled directly.
- Clarifies how `Slider.label` can be displayed for continuous sliders.
- The FadeForwards page transition on Android now takes 20-40% less time to render thanks to snapshotting.
- Fixes the installation command in README.md
- Fixes `Theme.of` returning a fallback `ThemeData` whose `platform` was frozen to the first `defaultTargetPlatform` seen by the process. A subtree without a `Theme` ancestor now adapts when `defaultTargetPlatform` changes, for example under a `TargetPlatformVariant` or the platform override.

## 1.7.0

- Accounts for `MediaQuery`'s `TextScaler` when calculating `SnackBar` action overflow and removes unnecessary blank right spacing in multi-line layout.
- Allows `TabBar.indicatorWeight` of 0 when the indicator is supplied by `TabBarThemeData`.
- Fixes showTimePicker input mode rejecting or misreading hours in locales that use a 24-hour format.
- Adds the `scrollPadding` property to `DropdownMenuFormField`, forwarding it to the underlying `DropdownMenu`.
- Fixes an Android semantics assertion when an `ExpansionTile` is embedded in a `WidgetSpan`.

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
