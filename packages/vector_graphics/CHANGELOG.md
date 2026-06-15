## 1.3.0

* Adds support for SVG filters (`feGaussianBlur`, `feOffset`, `feMerge`, and `feMergeNode`).

## 1.2.7

* Fixes uncaught surface-creation throwables (such as bare JavaScript strings
  or engine errors) from `useHtmlRenderObject()` so `VectorGraphic` widgets
  reliably fall back to the HTML render object and cache the fallback instead
  of crashing repeatedly (flutter/flutter#189451).

## 1.2.6

* Fixes `<text>` not being drawn when the ambient text direction is RTL.

## 1.2.5

* Fixes a leak of the decoded picture when a `VectorGraphic` is removed before
  loading finishes.

## 1.2.4

* Fixes an unhandled exception reported for every asynchronous loading failure,
  such as an asset that fails to load, even when `errorBuilder` handles it.
* Updates minimum supported SDK version to Flutter 3.41/Dart 3.11.
* Removes unnecessary Material imports.
* Fixes deprecation lints.

## 1.2.3

* Updates minimum supported SDK version to Flutter 3.38/Dart 3.10.
* Fixes a crash when a `semanticsLabel` is provided without an ambient `Directionality` (flutter/flutter#175532).

## 1.2.2

* Fixes `text-anchor` on `<text>` with multiple `<tspan>` children. The
  anchor now applies to the entire anchored chunk as required by the SVG
  spec, instead of independently to each tspan.

## 1.2.1

* Fixes uncaught `StateError` and `NoSuchMethodError` from `useHtmlRenderObject()` on CanvasKit / iOS Safari so SVG widgets fall back to the HTML render object.

## 1.2.0

* Adds support for the `feDropShadow` element.

## 1.1.18

* Fixes line height for text spans when multiple spans have varying font size.

## 1.1.17

* Fixes unhandled `<pattern>` element causing a crash.

## 1.1.16

* Fixes a crash in `VectorGraphic` when the image has a width or height of zero.

## 1.1.15

* Fixes a crash in `VectorGraphic` when an asset path is invalid.

## 1.1.14

* Fixes a leak of text painter objects.

## 1.1.13

* Updates minimum supported SDK version to Flutter 3.32/Dart 3.8.

## 1.1.12

* Fixes SVG compiler parsing for text-anchor with multiple tspan elements.

## 1.1.11+1

* Internal code cleanup.

## 1.1.11

* Fixes support for custom fonts.

## 1.1.10

* Adds support for `useHtmlRenderObject` in `VectorGraphic`.

## 1.1.9+2

* Updates README.

## 1.1.9+1

* Updates README.

## 1.1.9

* Fixes an issue where `VectorGraphic` would throw an exception if the asset
  failed to load.

## 1.1.8

* Fixes an issue where `VectorGraphic` would not render if the asset was
  loaded asynchronously.

## 1.1.7

* Fixes an issue where `VectorGraphic` would not update when the asset name
  changed.

## 1.1.6

* Fixes an issue where `VectorGraphic` would not render if the asset was
  already cached.

## 1.1.5

* Updates `vector_graphics_codec` dependency.

## 1.1.4

* Fixes an issue where `VectorGraphic` would not render if the asset was
  loaded from the network.

## 1.1.3

* Fixes an issue where `VectorGraphic` would not render if the asset was
  loaded from a file.

## 1.1.2

* Fixes an issue where `VectorGraphic` would not render if the asset was
  loaded from memory.

## 1.1.1

* Fixes an issue where `VectorGraphic` would not render if the asset was
  loaded from a package.

## 1.1.0

* Adds `VectorGraphic` widget.

## 1.0.0

* Initial release.
