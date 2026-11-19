# Skill: Migrating from `@EventChannelApi` to `@HostApi` `Stream<T>` (Pigeon 31.0.0)

## Overview
Pigeon 31.0.0 removes `@EventChannelApi`, `KotlinEventChannelOptions`, and `SwiftEventChannelOptions` in favor of `Stream<T>` return types directly on `@HostApi` methods (supported on Dart, Kotlin, and Swift platform channels).

This skill guides AI agents and developers through migrating an existing Flutter plugin or app from legacy `@EventChannelApi` definitions to `@HostApi` `Stream<T>` methods.

> [!IMPORTANT]
> **Do not hand-edit generated files** (`.g.dart`, `.g.kt`, `.g.swift`). Update the Pigeon input schema, re-run `dart run pigeon --input <file>.dart`, and then update your Dart, Kotlin, and Swift call sites.

---

## 1. Choose the Native Streaming Style

Before editing the Pigeon schema, decide which native style fits each stream method:

| Style | Pigeon Annotation | Kotlin Signature | Swift Signature | Best For |
|---|---|---|---|---|
| **Structured Concurrency (default)** | *(none)* | `fun foo(...): Flow<T>` | `func foo(...) -> AsyncThrowingStream<T, Error>` | Coroutine/async producers, timers, `callbackFlow`, new code |
| **Callback Event Sink** | `@asyncCallback` | `fun foo(..., sink: <Prefix>PigeonEventSink<T>): AutoCloseable?` | `func foo(..., sink: <Prefix>PigeonEventSink<T>) -> (() -> Void)?` | Minimal-diff migration from existing listener/delegate `StreamHandler`s |

> [!TIP]
> If the existing native code is heavily callback- or delegate-driven (e.g., Android `SensorEventListener` or iOS `CLLocationManagerDelegate`), starting with `@asyncCallback` is usually a clean 1:1 migration from `onListen`/`onCancel` without needing `kotlinx-coroutines` on Android.

---

## 2. Update the Pigeon Schema (`pigeons/*.dart`)

1. Replace `@EventChannelApi()` with `@HostApi()` (or move the methods into an existing `@HostApi()` class).
2. Wrap each method's return type `T` in `Stream<T>`. Typed method parameters are now supported directly on stream methods.
3. Remove `KotlinEventChannelOptions` and `SwiftEventChannelOptions` from `@ConfigurePigeon(...)` (both classes were removed in 31.0.0).
4. Add `@asyncCallback` to any stream method where you want the callback sink signature.

**Before:**
```dart
@EventChannelApi()
abstract class MyEventChannelApi {
  int streamInts();
  PlatformEvent streamEvents();
}
```

**After:**
```dart
@HostApi()
abstract class MyStreamHostApi {
  Stream<int> streamInts({int count = 5});

  @asyncCallback
  Stream<PlatformEvent> streamEvents();
}
```

### Schema Constraints to Check
- **No `@async` or `@TaskQueue`** on `Stream<T>` methods (both cause a generation error).
- **No nullable `Stream<T>?` or `Stream<void>`** (nullable *element* types like `Stream<int?>` are supported).
- **No parameter named `sink`** on `@asyncCallback` stream methods (reserved for the generated sink parameter).
- **Kotlin/Swift/Dart only**: `Stream<T>` is supported on both platform channels and Native Interop (`useJni` / `useFfi`), and is rejected on `@FlutterApi`, `@ProxyApi`, Java, Objective-C, C++, and GObject.

---

## 3. Regenerate Pigeon Outputs

Run Pigeon for each updated input file:

```bash
dart run pigeon --input pigeons/<your_messages>.dart
```

---

## 4. Update Dart Call Sites

1. **Instantiate the `@HostApi` class** instead of calling top-level generated stream functions.
2. **Replace `instanceName` with `messageChannelSuffix`** on the `@HostApi` constructor.
3. **Check for multiple Dart listeners (Broadcast vs. Single-Subscription)**:
   - Legacy `@EventChannelApi` returned a **broadcast** `Stream`.
   - New `@HostApi` `Stream<T>` methods return a **single-subscription** `Stream` (each `.listen()` creates an independent multiplexed native subscription).
   - If multiple Dart widgets/listeners need to share a single native subscription, append `.asBroadcastStream()`.
4. **Test mocks**: The deprecated `HostApi.dartHostTestHandler` omits `Stream<T>` methods; test stream consumers by injecting a fake/mock `@HostApi` implementation or a fake `BinaryMessenger`.

**Before:**
```dart
final Stream<int> ints = streamInts(instanceName: 'sensorA');
```

**After:**
```dart
final api = MyStreamHostApi(messageChannelSuffix: 'sensorA');
final Stream<int> ints = api.streamInts(count: 5);
// If multiple Dart listeners must share one native subscription:
// final Stream<int> sharedInts = api.streamInts(count: 5).asBroadcastStream();
```

---

## 5. Update Kotlin Host Implementation (Android)

1. Remove `<Method>StreamHandler` subclasses and `<Method>StreamHandler.register(...)` / `EventChannel.setStreamHandler(null)` calls.
2. Implement the stream methods on your `MyStreamHostApi` class and register/unregister with standard `MyStreamHostApi.setUp(...)`:
   - Attach: `MyStreamHostApi.setUp(binding.binaryMessenger, api, messageChannelSuffix)`
   - Detach (`onDetachedFromEngine`): `MyStreamHostApi.setUp(binding.binaryMessenger, null, messageChannelSuffix)` (automatically cancels all active streams for that `(binaryMessenger, suffix)`).

### Option A: Default `Flow<T>`
```kotlin
override fun streamInts(count: Long): Flow<Long> = flow {
  for (i in 0L until count) {
    emit(i)
  }
}
```
- Cancellation from Dart or `setUp(..., null)` cancels the collecting coroutine (clean up in `finally` or `awaitClose`).
- Throw your generated `FlutterError` class to send a terminal `PlatformException` to Dart.

### Option B: `@asyncCallback` (`<FilePrefix>PigeonEventSink<T>`)
```kotlin
override fun streamEvents(
    sink: MessagesPigeonEventSink<PlatformEvent>,
): AutoCloseable {
  val listener = MyListener(
      onEvent = { sink.success(it) },
      onError = { sink.error("ERR_CODE", it.message, null) },
      onComplete = { sink.endOfStream() },
  )
  sdk.register(listener)
  return AutoCloseable { sdk.unregister(listener) }
}
```
- **File-prefixed sink name**: The sink type is `<FilePrefix>PigeonEventSink<T>` (using `fileSpecificClassNameComponent`, which defaults to the PascalCase output filename, e.g. `MessagesPigeonEventSink<T>`).
- **Renamed `error` parameters**: Kotlin's `sink.error(code, message, details)` replaces the old `(errorCode, errorMessage, errorDetails)` parameter names—update any named arguments.
- **Thread safety**: `success`, `error`, and `endOfStream` marshal to the main `Looper` automatically and ignore calls after termination/cancellation.
- **Cancellation handle**: The returned `AutoCloseable?` is invoked on Dart cancel or `setUp(..., null)` teardown—not on normal `endOfStream()` / `error(...)`.

---

## 6. Update Swift Host Implementation (iOS / macOS)

1. Remove `<Method>StreamHandler` subclasses and `<Method>StreamHandler.register(with:streamHandler:instanceName:)` / `setStreamHandler(nil)` calls.
2. Implement the stream methods on your `MyStreamHostApi` class and register/unregister with standard `MyStreamHostApiSetup.setUp(...)`:
   - Attach: `MyStreamHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: api, messageChannelSuffix: suffix)`
   - Detach: `MyStreamHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil, messageChannelSuffix: suffix)` (automatically cancels all active streams for that `(binaryMessenger, suffix)`).

### Option A: Default `AsyncThrowingStream<T, Error>`
```swift
func streamInts(count: Int64) -> AsyncThrowingStream<Int64, Error> {
  AsyncThrowingStream { continuation in
    let task = Task {
      for i in 0..<count {
        if Task.isCancelled { break }
        continuation.yield(i)
      }
      continuation.finish()
    }
    continuation.onTermination = { _ in
      task.cancel()
    }
  }
}
```
- Call `continuation.finish(throwing: PigeonError(code: ..., message: ..., details: ...))` to send a terminal `PlatformException` to Dart.

### Option B: `@asyncCallback` (`<FilePrefix>PigeonEventSink<T>`)
```swift
func streamEvents(
  sink: MessagesPigeonEventSink<PlatformEvent>
) -> (() -> Void)? {
  let token = sdk.observe(
    onEvent: { sink.success($0) },
    onError: { sink.error(code: "ERR_CODE", message: $0.localizedDescription, details: nil) },
    onComplete: { sink.endOfStream() }
  )
  return { [weak self] in
    self?.sdk.removeObserver(token)
  }
}
```
- **File-prefixed sink name**: `<FilePrefix>PigeonEventSink<T>` (defaulting to the PascalCase output filename).
- **Thread safety**: `success`, `error`, and `endOfStream` dispatch to `DispatchQueue.main` when called off-main and ignore calls after termination/cancellation.
- **Cancellation closure**: Runs on Dart cancel or `setUp(..., api: nil)` teardown—not on normal `endOfStream()` / `error(...)`.

---

## 7. Verification Checklist

- [ ] No remaining `@EventChannelApi`, `KotlinEventChannelOptions`, `SwiftEventChannelOptions`, `*StreamHandler.register`, or unprefixed `PigeonEventSink` references.
- [ ] All multi-listener Dart call sites either intentionally open independent subscriptions or use `.asBroadcastStream()`.
- [ ] Plugin detach calls `setUp(messenger, null)` / `setUp(binaryMessenger: ..., api: nil)` to cancel active streams.
- [ ] `dart analyze`, Dart unit tests, Android Gradle build/tests, and iOS/macOS Xcode build/tests pass.
