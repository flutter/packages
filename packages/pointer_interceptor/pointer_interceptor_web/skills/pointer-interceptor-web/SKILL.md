---
name: pointer-interceptor-web
description: Configure and use pointer_interceptor_web to prevent HtmlElementViews and iframes on Flutter Web from consuming mouse and pointer events.
---

# Setting Up and Using pointer_interceptor_web

`pointer_interceptor_web` is the endorsed Web implementation of the Flutter [`pointer_interceptor`](https://pub.dev/packages/pointer_interceptor) plugin. It inserts a transparent HTML DOM element behind overlaid Flutter widgets so mouse clicks and pointer gestures do not reach underlying `HtmlElementView` instances (such as embedded maps, videos, or iframes).

## 1. Installation and Setup

Because this package is endorsed, adding `pointer_interceptor` to your `pubspec.yaml` automatically includes `pointer_interceptor_web`. If you need to depend on it directly:

```yaml
dependencies:
  pointer_interceptor: ^0.10.1+3
  pointer_interceptor_web: ^0.10.3
```

## 2. Platform-Specific Configuration

No additional HTML or JavaScript configuration is required. Flutter's web plugin registrant automatically registers `PointerInterceptorWeb` when compiling for Web.

## 3. Usage and API Examples

### Protecting Overlaid Controls Over an `HtmlElementView`
Wrap Flutter UI controls positioned over an `HtmlElementView` with `PointerInterceptor`:

```dart
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class WebIframeOverlay extends StatelessWidget {
  const WebIframeOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Positioned.fill(
          child: HtmlElementView(viewType: 'embedded-iframe-view'),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: PointerInterceptor(
            debug: false,
            child: ElevatedButton.icon(
              onPressed: () {
                // Clicks are handled by Flutter instead of the underlying iframe
              },
              icon: const Icon(Icons.close),
              label: const Text('Close Overlay'),
            ),
          ),
        ),
      ],
    );
  }
}
```
