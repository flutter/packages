<?code-excerpt path-base="example"?>

A Flutter plugin for easily creating interactive links in text.

## Features

 * Convert URLs to well-formed links across all of Flutter's platforms.
 * Or customize the RegExp and callback for use cases other than opening a URL
   in the browser.
 * Works with strings or span trees.

## Getting started

Install and import the package and you're ready to start using the LinkedText
widget or the TextLinker class.

## Usage

By default, LinkedText turns URLs into interactive links. Tapping on one will open the link in the device's default browser.

<?code-excerpt "linked_text.0.dart (linked_text)"?>
```dart
LinkedText(
text: 'Check out https://www.flutter.dev, or maybe just flutter.dev or www.flutter.dev.',
),
```

See the full exameple in [linked_text.0.dart](https://github.com/flutter/packages/tree/main/packages/linked_text/example/linked_text.0.dart).

### Custom regular expressions

It's also easy to specify the regular expression and/or the tap callback for
more custom behavior. This example makes usernames tappable.

<?code-excerpt "linked_text.1.dart (linked_text_reg_exp)"?>
```dart
LinkedText.regExp(
    text: _text,
    regExp: _xHandleRegExp,
    onTap: (String xHandleString) =>
        _handleTapXHandle(context, xHandleString),
),
```

See the full exameple in [linked_text.1.dart](https://github.com/flutter/packages/tree/main/packages/linked_text/example/linked_text.1.dart)).

### Span trees

It's possible to use LinkedText with a span tree instead of just a flat string.

<?code-excerpt "linked_text.2.dart (linked_text_spans)"?>
```dart
LinkedText(
spans: <InlineSpan>[
  TextSpan(
    text: 'Check out https://www.',
    style: DefaultTextStyle.of(context).style,
    children: const <InlineSpan>[
      TextSpan(
        style: TextStyle(
          fontWeight: FontWeight.w800,
        ),
        text: 'flutter',
      ),
    ],
  ),
  TextSpan(
    text: '.dev!',
    style: DefaultTextStyle.of(context).style,
  ),
],
),
```

See the full exameple in [linked_text.2.dart](https://github.com/flutter/packages/tree/main/packages/linked_text/example/linked_text.2.dart)).

### Multiple matchers and styles

For the same text or span tree, it's possible to create links of different types
matching different content with `LinkedText.textLinkers`.

<?code-excerpt "linked_text.3.dart (linked_text_text_linkers)"?>
```dart
return LinkedText.textLinkers(
  text: widget.text,
  textLinkers: _textLinkers,
);
```

See the full exameple in
[linked_text.3.dart](https://github.com/flutter/packages/tree/main/packages/linked_text/example/linked_text.3.dart)).

### Direct access

It's also possible to directly manipulate a string or span tree without relying
on the LinkedText widget by using the `TextLinker` class directly. See the full
examples in
[text_linkers.0.dart](https://github.com/flutter/packages/tree/main/packages/linked_text/example/text_linkers.0.dart))
and
[text_linkers.1.dart](https://github.com/flutter/packages/tree/main/packages/linked_text/example/text_linkers.1.dart)).

## Additional information

Please file issues in [flutter/flutter](https://github.com/flutter/flutter) with
"[linked_text]" at the start of the title.
