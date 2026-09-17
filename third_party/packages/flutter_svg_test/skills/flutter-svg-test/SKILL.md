---
name: flutter-svg-test
description: Set up and use flutter_svg_test finders to verify SvgPicture widgets by BytesLoader, asset path, network URL, file, or SVG string in Flutter widget tests.
---

# Setting Up and Using flutter_svg_test

`flutter_svg_test` provides custom `Finder` extensions on `CommonFinders` (`find.svg`, `find.svgAssetWithPath`, `find.svgNetworkWithUrl`, `find.svgFileWithPath`, `find.svgMemoryWithBytes`, `find.svgStringWithCode`) to assert on `SvgPicture` widgets in Flutter widget tests.

## 1. Installation

Add `flutter_svg_test` to `dev_dependencies` in your `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_svg: ^2.1.0
  flutter_svg_test: ^1.0.0
```

## 2. Finding SVGs by Asset Path

Use `find.svgAssetWithPath` to assert that an `SvgPicture.asset` widget with a specific asset path is rendered:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_test/flutter_svg_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders logo SVG asset', (WidgetTester tester) async {
    const String svgPath = 'assets/logo.svg';
    await tester.pumpWidget(
      MaterialApp(
        home: SvgPicture.asset(svgPath),
      ),
    );

    expect(find.svgAssetWithPath(svgPath), findsOneWidget);
  });
}
```

## 3. Finding SVGs by `BytesLoader` or Other Sources

You can also match against exact `BytesLoader` instances or other source types:

```dart
testWidgets('matches SvgPicture by BytesLoader or string', (WidgetTester tester) async {
  const String rawSvg = '<svg viewBox="0 0 10 10"><circle cx="5" cy="5" r="4"/></svg>';
  final SvgPicture widget = SvgPicture.string(rawSvg);

  await tester.pumpWidget(MaterialApp(home: widget));

  // Match by exact BytesLoader:
  expect(find.svg(widget.bytesLoader), findsOneWidget);

  // Or match by raw SVG string content:
  expect(find.svgStringWithCode(rawSvg), findsOneWidget);
});
```
