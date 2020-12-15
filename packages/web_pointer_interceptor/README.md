# web_pointer_interceptor

A small Flutter widget to prevent clicks (in web) from being intercepted by underlying HtmlElement views.

## How to use

Wrap your button element in a `PointerInterceptor` widget, like so:

```dart
PointerInterceptor(
  child: RaisedButton(...),
)
```

It can also be used as a "layout" element to wrap a bunch of other elements; for example, as the parent of a `Drawer`:

```dart
Scaffold(
  ...
  drawer: PointerInterceptor(
    child: Drawer(
      child: ...
    ),
  ),
  ...
)
```

The `PointerInterceptor` widget has a `debug` property, that will render it visibly on the screen. This is useful to see what the widget is actually covering when used as a layout element.
