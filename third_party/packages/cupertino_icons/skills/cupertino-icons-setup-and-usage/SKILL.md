---
name: cupertino-icons-setup-and-usage
description: Set up and use the cupertino_icons asset package to render Apple iOS-styled CupertinoIcons in Flutter applications.
---

# Setting Up and Using cupertino_icons

`cupertino_icons` provides the default font icon assets used by Flutter's `CupertinoIcons` class for iOS-styled user interfaces.

## 1. Installation and Asset Setup

Include `cupertino_icons` under `dependencies` in your Flutter application's `pubspec.yaml` and ensure `uses-material-design: true` (or font asset inclusion) is enabled:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

flutter:
  uses-material-design: true
```

## 2. Rendering Cupertino Icons

Import `package:flutter/cupertino.dart` and pass `CupertinoIcons` constants to `Icon` widgets:

```dart
import 'package:flutter/cupertino.dart';

class CupertinoIconExample extends StatelessWidget {
  const CupertinoIconExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Icon(
          CupertinoIcons.share,
          color: CupertinoColors.activeBlue,
          size: 28.0,
        ),
        Icon(
          CupertinoIcons.heart_fill,
          color: CupertinoColors.systemRed,
          size: 28.0,
        ),
        Icon(
          CupertinoIcons.gear_alt_fill,
          color: CupertinoColors.systemGrey,
          size: 28.0,
        ),
      ],
    );
  }
}
```

## 3. Usage in Cupertino Navigation and Tab Bars

`CupertinoIcons` integrates directly with `CupertinoNavigationBar`, `CupertinoTabBar`, and `CupertinoButton`:

```dart
CupertinoTabBar(
  items: const <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.search),
      label: 'Search',
    ),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.person_crop_circle),
      label: 'Profile',
    ),
  ],
)
```
