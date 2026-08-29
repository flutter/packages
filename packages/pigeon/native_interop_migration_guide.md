<?code-excerpt path-base="example/native_interop_app"?>
# Pigeon Native Interop Migration Guide

This guide provides detailed information on migrating from the platform-channel-based Pigeon model to the direct **Native Interop (FFI & JNI)** model.

For a comprehensive walkthrough on setting up Native Interop from scratch, see the main [Native Interop Guide](./native_interop_guide.md).

---

## 1. Key Architectural Differences

| Feature | Platform Channels | Native Interop (FFI / JNI) |
| :--- | :--- | :--- |
| **Data Serialization** | Serialized to binary format (`StandardMessageCodec`) | Direct memory mapping or native references |
| **Threading Model** | Main UI thread or custom background `TaskQueue` | Direct execution on caller thread (`TaskQueue` is not supported) |
| **Isolate Support** | Requires `BackgroundIsolateBinaryMessenger` | Supported for Host APIs |
| **Synchronous Calls** | Asynchronous only | Supports both synchronous and asynchronous calls |

---

## 2. Enabling Native Interop

To migrate an existing Pigeon plugin or app to Native Interop, follow these initial steps:

### 2.1 Add Dependencies

Add the required runtime dependencies to `dependencies` and code generators to `dev_dependencies` (in both the plugin and its `example/` app, if applicable). Using `flutter pub add` ensures runtime packages resolve to the latest compatible versions:

```bash
# Add Pigeon (if not already added):
flutter pub add dev:pigeon

# For iOS/macOS Swift FFI:
flutter pub add ffi
flutter pub add objective_c
# Pigeon requires this specific version for compatibility with its generated FFIgen configuration:
flutter pub add dev:ffigen@21.0.0

# For Android Kotlin JNI:
flutter pub add jni
# Pigeon requires this specific version for compatibility with its generated JNIgen configuration:
flutter pub add dev:jnigen@0.17.0
```

### 2.2 Update Pigeon Configuration Options

In your Pigeon Dart definition file, update `@ConfigurePigeon` to enable `useJni: true` for Kotlin and/or `useFfi: true` for Swift:

```dart
@ConfigurePigeon(
  PigeonOptions(
    // (Recommended) Path to the compiled application directory (e.g., 'example/' for plugins, or './' for standalone apps)
    appDirectory: './',
    dartOptions: DartOptions(),
    kotlinOptions: KotlinOptions(
      useJni: true,
    ),
    swiftOptions: SwiftOptions(
      useFfi: true,
      ffiModuleName: 'my_plugin',
    ),
  ),
)
```

*Note: `appDirectory` specifies the root of the compiled Flutter **application** (e.g., `example/` when developing a plugin, or `./` for a standalone app). This is required for `ffigen` and `jnigen` to locate the compiled native outputs and create `tool/pigeon/` config scripts.*

### 2.3 Re-run Code Generation

Re-run the Pigeon CLI tool to generate the interop bridge files and automatically run `ffigen` and `jnigen`:

```bash
dart run pigeon --input <path/to/pigeon_file.dart>
```

---

## 3. Migrating Native Code Signatures

If your existing native implementation uses the callback-based completion-handler model, you will need to migrate to modern native concurrency (Kotlin Coroutines or Swift async/await) as part of adopting the Native Interop model.

### 3.1 Swift Async Methods

#### Platform Channels (Callback Style)
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

### 3.2 Kotlin Async Methods

#### Platform Channels (Callback Style)
<?code-excerpt "android/app/src/main/kotlin/dev/flutter/pigeonnativeinteropapp/NativeInteropExample.kt (callback-style)"?>
```kotlin
fun echoAsync(value: String, callback: (Result<String>) -> Unit) {
  callback(Result.success(value))
}
```

#### Native Interop (suspend Style)
<?code-excerpt "android/app/src/main/kotlin/dev/flutter/pigeonnativeinteropapp/NativeInteropExample.kt (concurrency-style)"?>
```kotlin
suspend fun echoAsync(value: String): String {
  return value
}
```

### 3.3 Migrating from `@TaskQueue`

If your existing Pigeon interface uses `@TaskQueue` to process method calls off the main thread, you have two options:

#### Option A: Adopt Native Concurrency (Recommended)

1. **Update the Pigeon Definition**: Replace `@TaskQueue(...)` with `@async` in your Pigeon file:
   ```dart
   @HostApi()
   abstract class ExampleHostApi {
     @async
     String doSomething(String value);
   }
   ```
2. **Implement Using Native Concurrency**: In your native implementation, implement the generated asynchronous signature:
   - In **Swift**: Implement the generated `async throws` method and perform background execution (e.g., using `Task` or `DispatchQueue.global(qos: .userInitiated)`).
   - In **Kotlin**: Implement the generated `suspend` function and perform background execution (e.g., using `withContext(Dispatchers.IO)`).

#### Option B: Offload via Dart Isolates

Keep the method synchronous in the Pigeon file and native code, and invoke it from a worker isolate on the Dart side:
```dart
final String result = await Isolate.run(() => api.doSomething(value));
```

---

## 4. Dart Client Adaptation

From the Dart side, the API surface remains largely identical because both models return standard Dart `Future`s for asynchronous calls. However:
- **Synchronous execution**: Host API methods that are synchronous now block the calling thread until completion, bypassing any message loop scheduling latency.
- **Dart Isolates**: Host API calls can be made directly from any background Dart isolate without initializing `BackgroundIsolateBinaryMessenger` or passing a `RootIsolateToken`.
- **Type changes**: Some complex data types or generic collections may have stricter typing requirements at the FFI/JNI boundary compared to the platform channel message codec. Refer to the [Native Interop Guide](./native_interop_guide.md) for handling specific data types.

---

## 5. iOS/macOS Build System Configuration (FFI)

For Swift FFI, the toolchain generates an Objective-C bridging target under `<swift_output_dir>_objc_gen`. Ensure your build system includes these Objective-C files:

- **CocoaPods**: Ensure `s.source_files = 'Sources/**/*.{swift,m}'` in your `.podspec`.
- **SwiftPM**: Add a separate Objective-C target for `my_plugin_objc_gen` in `Package.swift` and depend on it from your main Swift target.
