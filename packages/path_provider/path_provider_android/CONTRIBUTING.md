# Contributing

## `jnigen`

This package uses [jnigen](https://pub.dev/packages/jnigen) to call Android
methods, rather than using the standard Flutter plugin structure. To add new
functionality to the JNI interface, update `tool/jnigen.dart`, then run:

```bash
dart run tool/jnigen.dart
```
