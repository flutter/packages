# web_mouse_click_boundary

A small Flutter widget to prevent clicks (in web) from being intercepted by underlying HtmlElement views.

## How to use

Wrap your button element in a `MouseClickBoundary` widget, like so:

```dart
MouseClickBoundary(
  child: RaisedButton(...),
)
```

It can also be used as a "layout" element to wrap a bunch of other elements; for example, as the parent of a `Drawer`:

```dart
Scaffold(
  ...
  drawer: MouseClickBoundary(
    child: Drawer(
      child: ...
    ),
  ),
  ...
)
```

The `MouseClickBoundary` widget has a `debug` property, that will render it visibly on the screen. This is useful to see what the widget is actually covering when used as a layout element.
