<?code-excerpt path-base="example/native_interop_app"?>
# Pigeon Native Interop Migration Guide

This guide provides detailed information on migrating from the `MethodChannel`-based Pigeon model to the direct **Native Interop (FFI & JNI)** model.

For a comprehensive walkthrough on setting up Native Interop from scratch, see the main [Native Interop Guide](file:///Users/tarrinneal/work/packages/packages/pigeon/native_interop_guide.md).

---

## 1. Key Architectural Differences

| Feature | MethodChannels | Native Interop (FFI / JNI) |
| :--- | :--- | :--- |
| **Communication Layer** | Binary message passing over platform channels | Direct memory-bound function calls via `dart:ffi` / `package:jni` |
| **Data Serialization** | Serialized to binary format (`StandardMessageCodec`) | Direct memory mapping or native references |
| **Synchronous Calls** | Asynchronous only | Supports both true synchronous and asynchronous calls |
| **Swift Concurrency** | Callback-based completion handlers | Modern `async/await` syntax |
| **Kotlin Concurrency** | Callback-based interfaces | Kotlin Coroutines (`suspend` functions) |

---

## 2. Migrating Native Code signatures

If your existing native implementation uses the callback-based completion-handler model, you will need to migrate to modern native concurrency (such as Kotlin Coroutines or Swift async/await) as part of adopting the Native Interop model.

### 2.1 Swift Async Methods

#### MethodChannels (Callback Style)
<?code-excerpt "ios/Runner/NativeInteropExample.swift (callback-style)"?>
```swift
func echoAsync(_ value: String, completion: @escaping (Result<String, Error>) -> Void) {
  completion(.success(value))
}
```

#### Native Interop (async/await Style)
<?code-excerpt "ios/Runner/NativeInteropExample.swift (concurrency-style)"?>
```swift
func echoAsync(_ value: String) async throws -> String {
  return value
}
```

### 2.2 Kotlin Async Methods

#### MethodChannels (Callback Style)
<?code-excerpt "android/app/src/main/kotlin/dev/flutter/pigeon_example_app/NativeInteropExample.kt (callback-style)"?>
```kotlin
fun echoAsync(value: String, callback: (Result<String>) -> Unit) {
  callback(Result.success(value))
}
```

#### Native Interop (suspend Style)
<?code-excerpt "android/app/src/main/kotlin/dev/flutter/pigeon_example_app/NativeInteropExample.kt (concurrency-style)"?>
```kotlin
suspend fun echoAsync(value: String): String {
  return value
}
```

---

## 3. Dart Client Adaptation

From the Dart side, the API surface remains largely identical because both models return standard Dart `Future`s for asynchronous calls. However:
- **Synchronous execution**: Host API methods that are synchronous now block the calling thread until completion, bypassing any message loop scheduling latency.
- **Type changes**: Some complex data types or generic collections may have stricter typing requirements at the FFI/JNI boundary compared to the MethodChannel message codec. Refer to the [Native Interop Guide](file:///Users/tarrinneal/work/packages/packages/pigeon/native_interop_guide.md) for handling specific data types.
