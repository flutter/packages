---
name: pointer-interceptor
description: Set up and use the pointer_interceptor widget to prevent clicks and pointer events from being swallowed by underlying HtmlElementViews on Web or PlatformViews on iOS.
---

# Setting Up and Using pointer_interceptor

`pointer_interceptor` provides a `PointerInterceptor` widget that prevents pointer events (clicks, taps, drags) from being swallowed by underlying native views (`HtmlElementView` on Flutter Web or `UiKitView` / `PlatformView` on iOS).

## 1. Installation and Setup

Add `pointer_interceptor` to your `pubspec.yaml`:

```yaml
dependencies:
  pointer_interceptor: ^0.10.1+3
```

## 2. Platform-Specific Configuration

- **Web**: Supported out of the box across all modern browsers. Renders a transparent HTML element behind the wrapped Flutter widget to block DOM click propagation to underlying iframes or HTML elements.
- **iOS (iOS 13+)**: Renders a transparent `UIView` behind the wrapped widget. Note that instantiating many `PointerInterceptor` widgets simultaneously on iOS can add memory and rendering overhead due to platform view composition; prefer wrapping a single container (such as a `Drawer` or overlay bar) rather than dozens of individual small icons when possible.
- **Other Platforms**: On platforms where platform view event swallowing does not occur, `PointerInterceptor` simply returns its `child` with zero overhead.

## 3. Usage and API Examples

### Wrapping Interactive Widgets Over a Platform View
Wrap buttons, floating action buttons, drawers, or dialogs rendered on top of a map, video player, or iframe with `PointerInterceptor`:

```dart
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class MapOverlayScreen extends StatelessWidget {
  const MapOverlayScreen({super.key, required this.mapPlatformView});

  final Widget mapPlatformView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: PointerInterceptor(
        child: Drawer(
          child: ListView(
            children: const <Widget>[
              DrawerHeader(child: Text('Navigation')),
              ListTile(title: Text('Saved Places')),
            ],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: mapPlatformView),
          Positioned(
            bottom: 24,
            right: 24,
            child: PointerInterceptor(
              child: FloatingActionButton.extended(
                onPressed: () {
                  // Reliably receives click events without the map consuming them
                },
                label: const Text('Recenter'),
                icon: const Icon(Icons.my_location),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Conditional Interception and Visual Debugging
Use `intercepting` to toggle interception dynamically without changing the widget tree structure, and `debug: true` to tint the interceptor area during development:

```dart
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

Widget buildConditionalOverlay({
  required bool isPanelOpen,
  required Widget child,
}) {
  return PointerInterceptor(
    intercepting: isPanelOpen,
    debug: false, // Set true to render a visible overlay box for debugging
    child: child,
  );
}
```
