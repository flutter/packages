# Contributing

## `ffigen`

This package uses [ffigen](https://pub.dev/packages/ffigen) to call Foundation
methods, rather than using the standard Flutter plugin structure. To add new
functionality to the FFI interface, update `tool/ffigen.dart`, then run:

```bash
dart run tool/ffigen.dart
```

### Configuration philosophy

This package intentionally uses very strict filtering rules to include only the
necessary methods and functions. This is partially to keep the package small,
but mostly to avoid unnecessarily generating anything that requires native code
helpers, which would require setting up a native compilation step.
