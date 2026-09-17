---
name: path-parsing-setup-and-usage
description: Set up and use the path_parsing pure Dart package to parse SVG path data strings into structured path segments and commands without requiring the Flutter runtime.
---

# Setting Up and Using path_parsing

`path_parsing` is a pure Dart library for parsing SVG path definition strings (`d="M 10 10 L 20 20 ..."`) and emitting path commands via a visitor interface (`PathProxy`). Because it has no dependency on `dart:ui` or the Flutter runtime, it can be used in CLI tools, code generators, and server-side Dart applications as well as Flutter apps.

## 1. Installation

Add `path_parsing` to your `pubspec.yaml`:

```yaml
dependencies:
  path_parsing: ^1.1.0
```

## 2. Implementing a `PathProxy` Receiver

To process parsed SVG path commands, implement `PathProxy` and pass it to `writeSvgPathDataToPath`:

```dart
import 'dart:io';
import 'package:path_parsing/path_parsing.dart';

class LoggingPathProxy extends PathProxy {
  @override
  void moveTo(double x, double y) {
    stdout.writeln('moveTo($x, $y)');
  }

  @override
  void lineTo(double x, double y) {
    stdout.writeln('lineTo($x, $y)');
  }

  @override
  void cubicTo(double x1, double y1, double x2, double y2, double x3, double y3) {
    stdout.writeln('cubicTo($x1, $y1, $x2, $y2, $x3, $y3)');
  }

  @override
  void close() {
    stdout.writeln('close()');
  }
}

void main() {
  const String svgPath = 'M10 10 H 90 V 90 H 10 Z';
  final LoggingPathProxy proxy = LoggingPathProxy();
  writeSvgPathDataToPath(svgPath, proxy);
}
```

## 3. Inspecting Segments with `SvgPathStringSource`

For lower-level inspection of individual SVG path segments (`PathSegmentData`), use `SvgPathStringSource`:

```dart
import 'package:path_parsing/path_parsing.dart';

void parseSegments(String svgPathData) {
  final SvgPathStringSource parser = SvgPathStringSource(svgPathData);
  while (parser.hasMoreData) {
    final PathSegmentData segment = parser.parseSegment();
    // Inspect segment.command, segment.targetPoint, segment.point1, segment.point2
  }
}
```
