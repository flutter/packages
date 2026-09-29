# cupertino_ui

The official Flutter Cupertino library, implementing Apple's [Human Interface
Guidelines](https://developer.apple.com/design/human-interface-guidelines/) for
Flutter applications.

`cupertino_ui` provides a complete, high-fidelity suite of visual components,
motion, typography, color system, and theming tools to build authentic
iOS- and macOS-style user interfaces on all screen sizes.

See also the
[`material_ui`](https://github.com/flutter/packages/tree/main/packages/material_ui)
package, which is Flutter's official Material Design library.

## New to the package?

Install the package with the following command:

```dart
flutter add cupertino_ui
```

See Flutter's main [getting started
guide](https://flutter.dev/getting-started/) for information about using Flutter
and `cupertino_ui`.

## Migrating existing code to this package

The standalone `cupertino_ui` package was previously built directly into the
core Flutter framework as `package:flutter/cupertino.dart`. It has been
decoupled from the [flutter/flutter](https://github.com/flutter/flutter)
repository into its new home here in `flutter/packages`.

Follow the steps below to migrate:

### Step 1: Migrate imports

We've included a data driven Dart fix to help users migrate. Simply run the
following command:

```sh
dart fix --apply --code=migrate_design_widgets
```

This performs the equivalent of adding `cupertino_ui` to your project and
changing imports of `package:flutter/cupertino.dart` to
`package:cupertino_ui/cupertino_ui.dart`.

### Step 2: Migrate localizations (if needed)

Don't use the `GlobalMaterialLocalizations` or `GlobalCupertinoLocalizations`
classes from flutter/flutter's `flutter_localizations` package. Instead, use the
new versions of these classes from `material_ui` and `cupertino_ui`,
respectively.

### Step 3: Bridge legacy dependencies (if needed)

If your app uses third-party packages or subtrees that still import and rely on
`package:flutter/cupertino.dart`, use `CupertinoUiCompatibilityBridge` to bridge
`CupertinoThemeData` and `CupertinoLocalizations` so legacy widgets resolve
correctly within modern widget trees.

Wrap your app using `CupertinoApp.builder`:

```dart
import 'package:cupertino_ui/cupertino_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      builder: (BuildContext context, Widget? child) {
        return CupertinoUiCompatibilityBridge(child: child!);
      },
      home: const HomeScreen(),
    );
  }
}
```

You can also wrap individual subtrees that contain legacy package widgets:

```dart
CupertinoPageScaffold(
  navigationBar: const CupertinoNavigationBar(
    middle: Text('Modern Screen'),
  ),
  child: CupertinoUiCompatibilityBridge(
    child: LegacyPackageWidget(),
  ),
)
```

---

## Features

The `cupertino_ui` package contains everything you need to create a
fully-featured iOS app, such as:

* **App Structure & Navigation**: `CupertinoApp`, `CupertinoPageScaffold`,
`CupertinoTabScaffold`, `CupertinoTabView`, `CupertinoNavigationBar`,
`CupertinoSliverNavigationBar`, `CupertinoTabBar`, `CupertinoPageRoute`
* **Buttons & Controls**: `CupertinoButton`, `CupertinoSegmentedControl`,
`CupertinoSlidingSegmentedControl`, `CupertinoContextMenu`,
`CupertinoContextMenuAction`, `CupertinoScrollbar`
* **Inputs & Selection**: `CupertinoTextField`, `CupertinoTextFormFieldRow`,
`CupertinoFormSection`, `CupertinoFormRow`, `CupertinoSwitch`,
`CupertinoSlider`, `CupertinoCheckbox`, `CupertinoRadio`,
`CupertinoSearchTextField`
* **Pickers & Dialogs**: `CupertinoPicker`, `CupertinoDatePicker`,
`CupertinoTimerPicker`, `CupertinoAlertDialog`, `CupertinoActionSheet`,
`CupertinoActionSheetAction`, `CupertinoPopupSurface`
* **Display & Feedback**: `CupertinoListSection`, `CupertinoListTile`,
`CupertinoActivityIndicator`, `CupertinoIcons`, `CupertinoFocusHalo`
* **Theming & Typography**: `CupertinoTheme`, `CupertinoThemeData`,
`CupertinoTextThemeData`, `CupertinoColors`, `CupertinoDynamicColor`
* **Internationalization**: `CupertinoLocalizations` and
`GlobalCupertinoLocalizations` for multi-locale support

## Changelog

See the
[Changelog](https://github.com/flutter/packages/blob/main/packages/cupertino_ui/CHANGELOG.md)
for a list of new features and breaking changes.

## Documentation & Resources

* [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
* [Flutter Cupertino Widget Catalog](https://docs.flutter.dev/ui/widgets/cupertino)
* [API Reference](https://pub.dev/documentation/cupertino_ui/latest/)
* [Issue Tracker](https://github.com/flutter/flutter/issues?q=is%3Aissue%20is%3Aopen%20label%3A%22p%3A%20cupertino_ui%22)
