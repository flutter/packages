# material_ui

The official Flutter Material Design library, implementing Google's [Material
Design](https://m3.material.io/) design system for Flutter applications.

`material_ui` provides a complete, modern suite of visual components, motion,
typography, color system, and theming tools to build beautiful and accessible
user interfaces on all screen sizes.

See also the
[`cupertino_ui`](https://github.com/flutter/packages/tree/main/packages/cupertino_ui)
package, which is Flutter's official iOS- and macOS-style design library.

## New to the package?

Install the package with the following command:

```dart
flutter add material_ui
```

See Flutter's main [getting started
guide](https://flutter.dev/getting-started/) for information about using Flutter
and `material_ui`.

## Migrating existing code to this package

The standalone `material_ui` package was previously built directly into the core
Flutter framework as `package:flutter/material.dart`. It has been decoupled from
the [flutter/flutter](https://github.com/flutter/flutter) repository into its
new home here in `flutter/packages`.

Follow the steps below to migrate:

### Step 1: Migrate imports

We've included a data driven Dart fix to help users migrate. Simply run the
following command:

```sh
dart fix --apply --code=migrate_design_widgets
```

This performs the equivalent of adding `material_ui` to your project and
changing imports of `package:flutter/material.dart` to
`package:material_ui/material_ui.dart`.

### Step 2: Migrate localizations (if needed)

If you are not currently using the `GlobalMaterialLocalizations` or
`GlobalCupertinoLocalizations` classes from flutter/flutter's
`flutter_localizations` package, then you are already good to go. For those that
do need to migrate off of these classes, simply use the new versions of these
classes from `material_ui` and `cupertino_ui`, respectively.

A typical app can use the following localization delegate from `material_ui` to
cover all of the localization strings in Flutter, Material, and Cupertino:

```dart
  localizationDelegates: GlobalMaterialLocalizations.delegates,
```

### Step 3: Bridge legacy dependencies (if needed)

If your app uses third-party packages or subtrees that still import and rely on
`package:flutter/material.dart`, use `MaterialUiCompatibilityBridge` to bridge
`ThemeData` and `MaterialLocalizations` so legacy widgets resolve correctly
within modern widget trees.

Wrap your app using `MaterialApp.builder`:

```dart
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (BuildContext context, Widget? child) {
        return MaterialUiCompatibilityBridge(child: child!);
      },
      home: const HomeScreen(),
    );
  }
}
```

You can also wrap individual subtrees that contain legacy package widgets:

```dart
Scaffold(
  appBar: AppBar(title: const Text('Modern Screen')),
  body: MaterialUiCompatibilityBridge(
    child: LegacyPackageWidget(),
  ),
)
```

---

## Features

The `material_ui` package contains everything you need to create a
fully-featured Material app, such as:

* **App Structure & Navigation**: `MaterialApp`, `Scaffold`, `AppBar`,
`NavigationBar`, `BottomSheet`, `TabBar`, `SearchAnchor`, `SearchBar`, `Dialog`
* **Buttons & Interaction**: `ElevatedButton`, `TextButton`, `IconButton`,
`FloatingActionButton`, `SegmentedButton`, `InkWell`, `MenuBar`
* **Inputs & Selection**: `TextField`, `Checkbox`, `Radio`, `Switch`, `Slider`,
`DropdownMenu`, `DatePicker`, `TimePicker`
* **Display & Feedback**: `Card`, `Chip`, `ListTile`, `Badge`, `Divider`,
`ProgressIndicator`, `SnackBar`, `Tooltip`, `CarouselView`, `VerticalDivider`
* **Theming & Color**: `ThemeData`, `ColorScheme`, `TextTheme`, dynamic color
generation, Material 3 design tokens, typography, and motion easing curves
* **Internationalization**: `MaterialLocalizations` and
`GlobalMaterialLocalizations` for multi-locale support

## Changelog
See the
[Changelog](https://github.com/flutter/packages/blob/main/packages/material_ui/CHANGELOG.md)
for a list of new features and breaking changes.

## Documentation & Resources

* [Material Design 3 Specification](https://m3.material.io/)
* [Flutter Material Widget Catalog](https://docs.flutter.dev/ui/widgets/material)
* [API Reference](https://pub.dev/documentation/material_ui/latest/)
* [Issue Tracker](https://github.com/flutter/flutter/issues?q=is%3Aissue%20is%3Aopen%20label%3A%22p%3A%20material_ui%22)
