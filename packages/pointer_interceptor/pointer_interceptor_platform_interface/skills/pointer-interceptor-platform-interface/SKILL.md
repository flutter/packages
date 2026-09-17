---
name: pointer-interceptor-platform-interface
description: Implement or extend the common platform interface for the Flutter pointer_interceptor plugin using PointerInterceptorPlatform.
---

# Setting Up and Using pointer_interceptor_platform_interface

`pointer_interceptor_platform_interface` defines the common platform interface (`PointerInterceptorPlatform`) for the [`pointer_interceptor`](https://pub.dev/packages/pointer_interceptor) plugin.

## 1. Installation and Setup

Add `pointer_interceptor_platform_interface` to your platform implementation package or test suite's `pubspec.yaml`:

```yaml
dependencies:
  pointer_interceptor_platform_interface: ^0.10.0+1
```

## 2. Platform-Specific Configuration

This package is a pure Dart interface package and requires no native platform configuration.

When modifying `PointerInterceptorPlatform`, prefer non-breaking changes over breaking changes.

## 3. Usage and API Examples

### Implementing a Custom `PointerInterceptorPlatform`
To create a custom platform implementation or a test double, extend `PointerInterceptorPlatform`, override `buildWidget`, and set `PointerInterceptorPlatform.instance`:

```dart
import 'package:flutter/widgets.dart';
import 'package:pointer_interceptor_platform_interface/pointer_interceptor_platform_interface.dart';

class CustomPointerInterceptorPlatform extends PointerInterceptorPlatform {
  static void registerWith() {
    PointerInterceptorPlatform.instance = CustomPointerInterceptorPlatform();
  }

  @override
  Widget buildWidget({
    required Widget child,
    bool debug = false,
    Key? key,
  }) {
    return Container(
      key: key,
      color: debug ? const Color(0x44FF0000) : null,
      child: child,
    );
  }
}
```
