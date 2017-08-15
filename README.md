# Sentry.io client for Dart

[![Build Status](https://travis-ci.org/flutter/sentry.svg?branch=master)](https://travis-ci.org/flutter/sentry)

**WARNING: experimental code**

Use this library in your Dart programs (Flutter, command-line and (TBD) AngularDart) to report errors thrown by your
program to https://sentry.io error tracking service.

## Usage

Sign up for a Sentry.io account and get a DSN at http://sentry.io.

Add `sentry` dependency to your `pubspec.yaml`:

```yaml
dependencies:
  sentry: any
```

In your Dart code, import `package:sentry/sentry.dart` and create a `SentryClient` using the DSN issued by Sentry.io:

```dart
import 'package:sentry/sentry.dart';

final SentryClient sentry = new SentryClient(dsn: YOUR_DSN);
```

In an exception handler, call `captureException()`:

```dart
main() async {
  try {
    doSomethingThatMightThrowAnError();
  } catch(error, stackTrace) {
    await sentry.captureException(
      exception: error,
      stackTrace: stackTrace,
    );
  }
}
```

## Tips for catching errors

- use a `try/catch` block
- create a `Zone` with an error handler, e.g. using [runZoned][run_zoned]
- in Flutter, use [FlutterError.onError][flutter_error]
- use `Isolate.current.addErrorListener` to capture uncaught errors in the root zone

[run_zoned]: https://api.dartlang.org/stable/1.24.1/dart-async/runZoned.html
[flutter_error]: https://docs.flutter.io/flutter/foundation/FlutterError/onError.html
