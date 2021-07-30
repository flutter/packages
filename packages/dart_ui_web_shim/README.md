`dart_ui_web_shim` is a package that helps use `dart:ui` in Flutter Web apps,
without triggering failures in dart analyzer.

## What is the problem?

Some Flutter Web-only APIs are currently exposed through a slightly modified version
of `dart:ui` for web.

flutter analyzer doesn't like that those APIs exist in some versions of `dart:ui`
and not others (because of type safety), so some methods in dart:ui are flagged
as non-existent by the analyzer, like `ui.platformViewRegistry.registerViewFactory`.

Unfortunately some of the methods exposed in that fashion are essential for web
apps (to access Asset URLs, or to register Platform Views).

## How does this work?

This package works by offering a "shim" version of `dart:ui` that contains the web
methods, and with conditional exports, exposes them to your app:

* In mobile: it exposes noop versions of the methods (see `dart_ui_fake.dart`)
* In web: it exposes the actual version of the methods (see `dart_ui_real.dart`)

> **Note that similarly to `dart:html`, this package can only be used in source files for the web platform!**

In your app, when you normally did something like:

```dart
import 'dart:ui' as ui;

...

// ignore: undefined_prefixed_name
ui.platformViewRegistry.registerViewFactory('foo', (int viewId) {
    return html.DivElement();
});

// or

// ignore: undefined_prefixed_name
final String assetUrl = ui.webOnlyAssetManager.getAssetUrl('some-asset.png');

```

Now you can do:

```dart
import 'package:dart_ui_web_shim/ui.dart' as ui;

...

ui.platformViewRegistry.registerViewFactory('foo', (int viewId) {
    return html.DivElement();
});

// or

final String assetUrl = ui.webOnlyAssetManager.getAssetUrl('some-asset.png');
```

Without the need to `ignore: undefined_prefixed_name`.

## I need method `ui.xxx.yyy` added to the shim

Please, [file an issue](https://github.com/flutter/flutter/issues/new/choose), or
send a Pull Request!

In any case, make sure to add `[dart_ui_web_shim]` in the title or description,
so it can be appropriately handled.

## Cleanup

Monitor this issue: [flutter/flutter#55000](https://github.com/flutter/flutter/issues/55000).
Once it's resolved, this package will be marked as "Discontinued".
