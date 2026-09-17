---
name: pointer-interceptor-ios-setup-and-usage
description: Configure and use pointer_interceptor_ios to prevent native UiKitViews on iOS from capturing touches intended for overlaying Flutter widgets.
---

# Setting Up and Using pointer_interceptor_ios

`pointer_interceptor_ios` is the endorsed iOS implementation of the Flutter [`pointer_interceptor`](https://pub.dev/packages/pointer_interceptor) plugin. It inserts a transparent `UIView` platform view behind Flutter overlay widgets so touches are handled by Flutter rather than underlying native `UiKitView` instances.

## 1. Installation and Setup

Because this package is endorsed, adding `pointer_interceptor` to your `pubspec.yaml` automatically includes `pointer_interceptor_ios`. If you need to depend on it directly:

```yaml
dependencies:
  pointer_interceptor: ^0.10.1+3
  pointer_interceptor_ios: ^0.10.1+1
```

## 2. Platform-Specific Configuration

- **Minimum iOS Version**: iOS 13.0+.
- **Performance Considerations**: Each `PointerInterceptor` on iOS creates an underlying native `UIView` platform view. Avoid wrapping dozens of individual small widgets on a single screen; instead, wrap their common parent container (such as a toolbar, card, or `Drawer`) with a single `PointerInterceptor` to minimize platform view composition overhead.

## 3. Usage and API Examples

Use `PointerInterceptor` from `package:pointer_interceptor/pointer_interceptor.dart` to protect Flutter controls placed over iOS platform views:

```dart
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class IosVideoOverlay extends StatelessWidget {
  const IosVideoOverlay({super.key, required this.nativeVideoView});

  final Widget nativeVideoView;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: nativeVideoView),
        Align(
          alignment: Alignment.bottomCenter,
          child: PointerInterceptor(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  // Touch is intercepted before reaching native UiKitView
                },
                child: const Text('Play / Pause'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```
