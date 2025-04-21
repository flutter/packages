A Flutter plugin for easily creating interactive links in text.

## Features

 * Convert URLs to well-formed links across all of Flutter's platforms.
 * Or customize the RegExp and callback for use cases other than opening a URL
   in the browser.
 * Works with strings or span trees.

## Getting started

Install and import the package and you're ready to start using the LinkedText
widget or the TextLinker class.

```dart
import 'package:linked_text/linked_text.dart';
```

## Usage

By default, LinkedText turns URLs into interactive links. Tapping on one will open the link in the device's default browser.

```dart
LinkedText(
  text: 'Check out https://www.flutter.dev, or maybe just flutter.dev or www.flutter.dev.',
),
```

See the full exameple in [linked_text.0.dart](https://github.com/flutter/packages/tree/main/packages/linked_text/example/linked_text.0.dart).

### Custom regular expressions

It's also easy to specify the regular expression and/or the tap callback for
more custom behavior. This example makes usernames tappable.

```dart
LinkedText(
  regExp: RegExp(r'@[a-zA-Z0-9]{4,15}'), // Usernames starting with @
  text: 'Please check out @FlutterDev on X for the latest.',
  onTap: (String handleString) =>
      _handleTapHandle(context, handleString),
),
```

See the full exameple in [linked_text.1.dart](https://github.com/flutter/packages/tree/main/packages/linked_text/example/linked_text.1.dart)).

### Span trees

It's possible to use LinkedText with a span tree instead of just a flat string.

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

```dart
LinkedText.textLinkers(
  text: '@FlutterDev is our X account, or find us at www.flutter.dev',
  textLinkers: <TextLinker>[
    TextLinker(
      regExp: LinkedText.defaultUriRegExp,
      linkBuilder: (String displayText, String linkText) {
        final TapGestureRecognizer recognizer = TapGestureRecognizer()
            ..onTap = () => widget.onTapUrl(linkText);
        _recognizers.add(recognizer);
        return TextSpan(
          text: displayText,
          style: LinkedText.defaultLinkStyle.copyWith(
            color: const Color(0xff0000ee),
          ),
          recognizer: recognizer,
        );
      },
    ),
    TextLinker(
      regExp: RegExp(r'@[a-zA-Z0-9]{4,15}'), // Usernames starting with @
      linkBuilder: (String displayText, String linkText) {
        final TapGestureRecognizer recognizer = TapGestureRecognizer()
            ..onTap = () => widget.onTapXHandle(linkText);
        _recognizers.add(recognizer);
        return TextSpan(
          text: displayText,
          style: LinkedText.defaultLinkStyle.copyWith(
            color: const Color(0xff00aaaa),
          ),
          recognizer: recognizer,
        );
      },
    ),
  ],
),
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
