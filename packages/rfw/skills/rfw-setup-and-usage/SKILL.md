---
name: rfw-setup-and-usage
description: Set up and use Remote Flutter Widgets (rfw) to render declarative widget description files and dynamic data obtained at runtime.
---

# Setting Up and Using Remote Flutter Widgets (rfw)

The `rfw` (Remote Flutter Widgets) package enables rendering Flutter UI trees from declarative widget descriptions and dynamic data loaded at runtime (for example, over the network). It is ideal for dynamic server-driven UIs such as message-of-the-day banners, bespoke data editors, and custom search result cards.

## 1. Installation

Add `rfw` to your project's `pubspec.yaml`:

```bash
flutter pub add rfw
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  rfw: ^1.1.3
```

## 2. Formats and Architecture

- **Remote Widget Libraries**: Written in text format (`.rfwtxt`) during development and compiled into binary format (`.rfw`) for production transport.
  - Parse text format: `parseLibraryFile(String text)` (from `package:rfw/formats.dart`).
  - Encode to binary blob: `encodeLibraryBlob(RemoteWidgetLibrary library)`.
  - Decode binary blob at runtime: `decodeLibraryBlob(Uint8List bytes)`.
- **Dynamic Configuration Data**: Represented by `DynamicContent`. Can be updated in Dart via `_data.update(key, value)` or decoded from binary blobs using `decodeDataBlob(Uint8List bytes)`.
- **Local Widget Libraries**: Precompiled widget definitions that remote widgets bottom out into (e.g., `createCoreWidgets()`, `createMaterialWidgets()`, or custom `LocalWidgetLibrary`).

## 3. Usage and API Examples

### Rendering a Remote Widget with `Runtime` and `DynamicContent`

```dart
import 'package:flutter/material.dart';
import 'package:rfw/formats.dart' show parseLibraryFile;
import 'package:rfw/rfw.dart';

class RemoteBannerExample extends StatefulWidget {
  const RemoteBannerExample({super.key});

  @override
  State<RemoteBannerExample> createState() => _RemoteBannerExampleState();
}

class _RemoteBannerExampleState extends State<RemoteBannerExample> {
  final Runtime _runtime = Runtime();
  final DynamicContent _data = DynamicContent();

  static const LibraryName _coreName = LibraryName(<String>['core', 'widgets']);
  static const LibraryName _materialName = LibraryName(<String>['core', 'material']);
  static const LibraryName _mainName = LibraryName(<String>['main']);

  // In production, fetch binary .rfw bytes from your backend and use decodeLibraryBlob(bytes).
  static final RemoteWidgetLibrary _remoteLibrary = parseLibraryFile('''
    import core.widgets;
    import core.material;

    widget root = Card(
      child: Padding(
        padding: [16.0],
        child: Column(
          mainAxisSize: "min",
          crossAxisAlignment: "start",
          children: [
            Text(text: ["Welcome, ", data.user.name, "!"], textDirection: "ltr"),
            SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: event "dismiss_banner" { userId: data.user.id },
              child: Text(text: "Dismiss", textDirection: "ltr"),
            ),
          ],
        ),
      ),
    );
  ''');

  @override
  void initState() {
    super.initState();
    _runtime.update(_coreName, createCoreWidgets());
    _runtime.update(_materialName, createMaterialWidgets());
    _runtime.update(_mainName, _remoteLibrary);

    _data.update('user', <String, Object>{
      'name': 'Alex',
      'id': 1024,
    });
  }

  @override
  Widget build(BuildContext context) {
    return RemoteWidget(
      runtime: _runtime,
      data: _data,
      widget: const FullyQualifiedWidgetName(_mainName, 'root'),
      onEvent: (String eventName, DynamicMap eventArguments) {
        debugPrint('Triggered event "$eventName" with args: $eventArguments');
      },
    );
  }
}
```

### Creating Custom Local Widget Libraries

Expose your own Flutter widgets to remote widget libraries by registering a `LocalWidgetLibrary`. Use `DataSource` to read scalar values (`source.v<T>`), child widgets (`source.child`), and event handlers (`source.voidHandler`):

```dart
import 'package:flutter/widgets.dart';
import 'package:rfw/rfw.dart';

WidgetLibrary createCustomWidgets() {
  return LocalWidgetLibrary(<String, LocalWidgetBuilder>{
    'CustomBadge': (BuildContext context, DataSource source) {
      final String label = source.v<String>(<Object>['label']) ?? '';
      return GestureDetector(
        onTap: source.voidHandler(<Object>['onTap']),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          color: const Color(0xFF0055AA),
          child: Text(
            label,
            textDirection: TextDirection.ltr,
            style: const TextStyle(color: Color(0xFFFFFFFF)),
          ),
        ),
      );
    },
  });
}
```
