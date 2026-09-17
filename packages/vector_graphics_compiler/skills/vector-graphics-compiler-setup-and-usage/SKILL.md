---
name: vector-graphics-compiler-setup-and-usage
description: Set up and use vector_graphics_compiler via CLI or Dart API to compile and optimize SVG files into binary .vec assets for Flutter.
---

# Setting Up and Using vector_graphics_compiler

The `vector_graphics_compiler` package parses SVG files, applies geometry and paint optimizations (mask/clip elimination, overdraw reduction, group collapsing, and transformation inlining), and compiles them into the binary `.vec` format rendered by `package:vector_graphics` and `package:flutter_svg`.

## 1. Installation

Add `vector_graphics_compiler` as a `dev_dependency` in your project's `pubspec.yaml`:

```bash
flutter pub add dev:vector_graphics_compiler
```

Or activate it globally on your machine:

```bash
dart pub global activate vector_graphics_compiler
```

## 2. Command-Line Asset Compilation

### Basic Compilation
Compile an input SVG file (`-i`) into an output `.vec` binary file (`-o`):

```bash
dart run vector_graphics_compiler -i assets/logo.svg -o assets/logo.svg.vec
```

### Optimizer Flags and Options
By default, masking, clipping, and overdraw optimizers are enabled. You can customize or disable specific passes when troubleshooting complex SVGs:

```bash
# Disable specific optimization passes
dart run vector_graphics_compiler \
  -i assets/complex.svg \
  -o assets/complex.svg.vec \
  --no-optimize-masks \
  --no-optimize-clips \
  --no-optimize-overdraw

# Enable half-precision floating point control points to reduce binary file size
dart run vector_graphics_compiler \
  -i assets/icon.svg \
  -o assets/icon.svg.vec \
  --use-half-precision-control-points
```

## 3. Programmatic Dart API Usage

You can also use `vector_graphics_compiler` as a library in build scripts or server tools to compile SVG strings directly into `Uint8List` bytes.

Import the package:

```dart
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';
```

### Compiling an SVG String to Binary Bytes (`encodeSvg`)

```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

Future<void> compileSvgFile(String inputPath, String outputPath) async {
  final String svgXml = await File(inputPath).readAsString();

  final Uint8List compiledBytes = encodeSvg(
    xml: svgXml,
    debugName: inputPath,
    enableMaskingOptimizer: true,
    enableClippingOptimizer: true,
    enableOverdrawOptimizer: true,
    useHalfPrecisionControlPoints: false,
  );

  await File(outputPath).writeAsBytes(compiledBytes);
}
```

### Inspecting Parsed Instructions (`parse`)

Use `parse` to obtain the intermediate `VectorInstructions` representation without immediately encoding to bytes:

```dart
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void inspectSvgInstructions(String svgXml) {
  final VectorInstructions instructions = parse(svgXml);
  print('Width: ${instructions.width}, Height: ${instructions.height}');
  print('Paths count: ${instructions.paths.length}');
  print('Paints count: ${instructions.paints.length}');
}
```
