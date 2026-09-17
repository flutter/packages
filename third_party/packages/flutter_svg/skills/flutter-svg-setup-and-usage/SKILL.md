---
name: flutter-svg-setup-and-usage
description: Set up and use the flutter_svg package to render SVG vector images from assets, network URLs, files, or strings with custom color filters and ColorMapper support.
---

# Setting Up and Using flutter_svg

`flutter_svg` renders Scalable Vector Graphics (SVG) files directly in Flutter widgets using `SvgPicture`.

## 1. Installation and Asset Declaration

Add `flutter_svg` to your `pubspec.yaml` and declare your SVG asset directories:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_svg: ^2.1.0

flutter:
  assets:
    - assets/icons/
```

## 2. Basic SVG Rendering

### From an Asset (`SvgPicture.asset`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgAssetExample extends StatelessWidget {
  const SvgAssetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/logo.svg',
      width: 48,
      height: 48,
      semanticsLabel: 'App Logo',
    );
  }
}
```

### From Network or String

```dart
// From Network URL with placeholder:
SvgPicture.network(
  'https://example.com/vector.svg',
  placeholderBuilder: (BuildContext context) => const CircularProgressIndicator(),
);

// From raw SVG XML string:
SvgPicture.string('<svg viewBox="0 0 24 24">...</svg>');
```

## 3. Tinting and Color Manipulation

### Applying a Single Tint (`colorFilter`)

Use `colorFilter` with `BlendMode.srcIn` to tint monochrome SVG icons:

```dart
SvgPicture.asset(
  'assets/icons/bell.svg',
  colorFilter: const ColorFilter.mode(Colors.blueAccent, BlendMode.srcIn),
  semanticsLabel: 'Notification Bell',
)
```

### Dynamic Multi-Color Replacement (`ColorMapper`)

To selectively substitute colors within an SVG based on element or original color value, extend `ColorMapper`:

```dart
class ThemeColorMapper extends ColorMapper {
  const ThemeColorMapper({required this.primaryColor});
  final Color primaryColor;

  @override
  Color substitute(String? id, String elementName, String attributeName, Color color) {
    if (color == const Color(0xFF000000)) {
      return primaryColor;
    }
    return color;
  }
}

// Usage:
SvgPicture.asset(
  'assets/icons/illustration.svg',
  colorMapper: ThemeColorMapper(primaryColor: Theme.of(context).colorScheme.primary),
)
```
