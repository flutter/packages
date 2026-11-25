## 1.0.1

* Adds removal of `Finalizer` callback when security scoped implementations are disposed manually.
  This prevents a race condition where access to an entity could be loss from the garbage collection
  of another entity with the same URI.
* Updates minimum supported SDK version to Flutter 3.44/Dart 3.12.

## 1.0.0

* Initial release.
