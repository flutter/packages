---
name: vector-graphics-setup-and-usage
description: Set up and use the vector_graphics package to render precompiled binary vector graphic (.vec) assets with high performance in Flutter.
---

# Setting Up and Using vector_graphics

The `vector_graphics` package is a high-performance vector graphics rendering runtime for Flutter. It renders binary `.vec` assets compiled ahead of time by [`vector_graphics_compiler`](https://pub.dev/packages/vector_graphics_compiler), eliminating runtime XML parsing overhead and reducing clipping/overdraw.

## 1. Installation

Add `vector_graphics` to your project's `pubspec.yaml`:

```bash
flutter pub add vector_graphics
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  vector_graphics: ^1.2.3
```

## 2. Asset Compilation and Configuration

1. Precompile your SVG files into `.vec` binary assets using `vector_graphics_compiler`:

```bash
dart run vector_graphics_compiler -i assets/images/logo.svg -o assets/images/logo.svg.vec
```

2. Declare the compiled `.vec` files under `flutter: assets:` in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/logo.svg.vec
```

## 3. Usage and API Examples

Import the package in your Dart code:

```dart
import 'package:vector_graphics/vector_graphics.dart';
```

### Rendering a Precompiled Asset (`VectorGraphic` & `AssetBytesLoader`)

```dart
import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

class VectorLogoWidget extends StatelessWidget {
  const VectorLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const VectorGraphic(
      loader: AssetBytesLoader('assets/images/logo.svg.vec'),
      width: 120,
      height: 120,
      fit: BoxFit.contain,
      semanticsLabel: 'Application Logo',
    );
  }
}
```

### Applying Color Filters and Rendering Strategies

Use `colorFilter` to tint the vector graphic, and choose between `RenderingStrategy.picture` (lossless scaling at any transform, best for icons) and `RenderingStrategy.raster` (caches a rasterized image across frames, best for complex static backdrops):

```dart
VectorGraphic(
  loader: const AssetBytesLoader('assets/images/illustration.svg.vec'),
  width: 300,
  height: 200,
  colorFilter: const ColorFilter.mode(Colors.indigo, BlendMode.srcIn),
  strategy: RenderingStrategy.raster,
  placeholderBuilder: (BuildContext context) => const Center(
    child: CircularProgressIndicator(),
  ),
);
```

### Loading Binary Vector Graphics over HTTP (`NetworkBytesLoader`)

```dart
VectorGraphic(
  loader: NetworkBytesLoader(
    Uri.parse('https://example.com/assets/banner.svg.vec'),
  ),
  width: 400,
  height: 150,
);
```
