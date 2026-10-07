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

Add the required runtime dependencies to `dependencies` and code generators/config-script dependencies to `dev_dependencies` in the package where Pigeon runs (for a plugin package, add these to the **plugin's** `pubspec.yaml`, not `example/pubspec.yaml`, unless the example app runs Pigeon directly).

Because Pigeon generates helper scripts in `tool/pigeon/` (`*_ffigen_config.dart` and `*_jnigen_config.dart`), `dart pub publish --dry-run` requires every package imported by `lib/` or `tool/` to be explicitly declared in `pubspec.yaml`:

```bash
# Add Pigeon (if not already added):
flutter pub add dev:pigeon

# For iOS/macOS Swift FFI:
flutter pub add ffi objective_c meta
# Code generators and packages imported by tool/pigeon/*_ffigen_config.dart:
flutter pub add dev:ffigen dev:swift2objc dev:swiftgen dev:path dev:pub_semver

# For Android Kotlin JNI:
flutter pub add jni
# Code generator and packages imported by tool/pigeon/*_jnigen_config.dart:
flutter pub add dev:jnigen dev:logging dev:path
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
   - In **Swift**: Implement the generated `async` method and perform background execution (e.g., using `Task` or `DispatchQueue.global(qos: .userInitiated)`).
   - In **Kotlin**: Implement the generated `suspend` function and perform background execution (e.g., using `withContext(Dispatchers.IO)`).

#### Option B: Offload via Dart Isolates

Keep the method synchronous in the Pigeon file and native code, and invoke it from a worker isolate on the Dart side:
```dart
final String result = await Isolate.run(() => api.doSomething(value));
```
*Note: Callers must ensure the isolate stays alive while there are pending asynchronous calls, as attempting to execute a callback after the isolate has terminated will cause a crash.*

---

## 4. Dart Client Adaptation

From the Dart side, instantiate your generated Host API using `<MyApi>.createWithNativeInteropApi()` (passing `messageChannelSuffix` if multiple named instances are registered on the host).

- **Lazy Initialization for `dartPluginClass` (`late final`)**: If your plugin declares `dartPluginClass` in `pubspec.yaml`, Flutter calls `<PluginClass>.registerWith()` during Dart plugin registration **before `main()`** and before `JniPlugin` initializes `DartJNI` on Android (or before native host registration). Calling `createWithNativeInteropApi()` eagerly in the constructor initializer list will crash the app at startup on Android (`F DartJNI : JNI is not initialized`). Always initialize the API lazily using `late final`:
  ```dart
  class MyPluginAndroid extends MyPluginPlatform {
    MyPluginAndroid({@visibleForTesting MyApi? api}) : _apiOverride = api;

    final MyApi? _apiOverride;

    @visibleForTesting
    late final MyApi api = _apiOverride ?? MyApi.createWithNativeInteropApi();
  }
  ```
- **Synchronous execution**: Host API methods that are synchronous now block the calling thread until completion, bypassing any message loop scheduling latency.
- **Dart Isolates**: Host API calls can be made directly from any background Dart isolate without initializing `BackgroundIsolateBinaryMessenger` or passing a `RootIsolateToken`. Callers must ensure the isolate stays alive while there are pending asynchronous calls, as attempting to execute a callback after the isolate has terminated will cause a crash.
- **Platform UI Thread Affinity**: If native code interacts with platform UI elements (such as UIKit views on iOS/macOS or `Activity`/view hierarchies on Android), that work must execute on the platform's main thread. If an interop call is initiated from a background isolate or dispatches work to a background queue, the native implementation must explicitly dispatch to the main thread (`DispatchQueue.main.async` in Swift, `Handler(Looper.getMainLooper()).post` in Kotlin) before interacting with UI APIs.
- **`FlutterApi` Synchronous Callbacks**: Synchronous callbacks into Dart are isolate-local and must be invoked on the isolate that registered them.
- **Type changes**: Some complex data types or generic collections may have stricter typing requirements at the FFI/JNI boundary compared to the platform channel message codec. Refer to the [Native Interop Guide](./native_interop_guide.md) for handling specific data types.

---

## 5. iOS/macOS Build System Configuration (FFI)

For Swift FFI, the toolchain generates an Objective-C bridging directory under `<swift_output_dir>_objc_gen`:
- **`.h` (Headers)**: Always generated to declare module interfaces and types for `ffigen`.
- **`.m` (Bridging Implementation)**: Only generated when the schema contains async callbacks, closures, `@FlutterApi`, or Objective-C blocks requiring trampoline implementations.
- **`.o` (Temporary Object Files)**: Intermediate binary files generated during `ffigen`/`swiftgen` AST parsing. These are **not** needed after code generation and must **not** be committed to version control.

Ensure your build system is configured appropriately:

- **CocoaPods**: Ensure `s.source_files = 'Sources/**/*.{swift,m,h}'` in your `.podspec`.
- **SwiftPM (`Package.swift`)**:
  - **Only if a `.m` file is generated** in `<swift_output_dir>_objc_gen`: Add a separate Objective-C target for `<plugin_name>_objc_gen` in `Package.swift` and depend on it from your main Swift target.
  - **If no `.m` file is generated** (e.g., your schema only has synchronous `@HostApi()` methods and `<swift_output_dir>_objc_gen` only contains a `.h` header): **Do not** add the `<plugin_name>_objc_gen` target to `Package.swift`. SwiftPM requires at least one compilable source file (`.m`, `.c`, or `.swift`) per target; an empty/header-only target causes Xcode builds to fail with `Build input file cannot be found: '.../<plugin_name>_objc_gen.o'`.
- **Application & Example App Targets**:
  - **Swift Module Name**: Set `ffiModuleName` in `SwiftOptions` to match your application's Swift module name (defaults to `'Runner'`). If iOS and macOS share the same generated Dart FFI file, both platforms must compile under that same module name. Since Flutter's default macOS template sets the module name to the app name rather than `Runner`, you can unify them by setting `PRODUCT_MODULE_NAME = Runner` in `macos/Runner/Configs/AppInfo.xcconfig` (or by matching whatever module name you configure). If iOS and macOS use separate Pigeon generation outputs or you only target one platform, unifying module names across platforms is not required.
  - **Native Registration**: Register the native API implementation in native code (e.g., `MainFlutterWindow.swift` in `awakeFromNib()` on macOS, or `AppDelegate.swift` on iOS via `MyApiSetup.register(api: api)`). This also ensures the setup class is referenced so the Xcode linker does not strip it (`-dead_strip`).

---

## 6. Android Release Build Configuration (JNI)

<!-- TODO(tarrinneal): Remove this section, and renumber the next one, once package:jni ships these keep rules: https://github.com/dart-lang/native/issues/3732 -->

Flutter enables R8 for Android release builds by default, and R8 removes or renames classes that JNI looks up by name. Pigeon adds `@Keep` to the generated Kotlin classes that JNI reaches, but `package:jni` and the generated Dart code also look up Kotlin standard library classes by name to call and implement `suspend` functions. Until `package:jni` includes rules for these classes, add them to a `consumer-rules.pro` file in your plugin's `android/` directory:

```text
# Kotlin classes that package:jni and the generated Dart code look up by name.
-keep class kotlin.Unit { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep class kotlin.coroutines.Continuation { *; }
-keep class kotlin.coroutines.intrinsics.CoroutineSingletons { *; }
-keep class kotlin.coroutines.intrinsics.IntrinsicsKt { *; }
```

Then add `consumerProguardFiles("consumer-rules.pro")` to `android.defaultConfig` in the plugin's `android/build.gradle` or `android/build.gradle.kts`, so that every app using the plugin applies the rules. For a standalone application, add the rules to `android/app/proguard-rules.pro` instead.

Debug builds are not minified, so test a release build (for example, by running the example app with `flutter run --release`) after migrating. See [Step 5 of the Native Interop Guide](./native_interop_guide.md#step-5-android-release-build-configuration-jni) for details.

---

## 7. Environment Prerequisites & Tooling Versions

To use Native Interop and its external code generators:
- **`jnigen` 1.0.0 or later**: Earlier versions of JNIgen cannot parse metadata from newer Kotlin compilers and fail with `IllegalArgumentException: Provided Metadata instance has version ... while maximum supported version is ...`. `jnigen` 1.0.0 supports Kotlin metadata up to 2.4, and uses the JDK bundled with Flutter by default.
- **LLVM / Xcode Command Line Tools**: Required by FFIgen to parse C/Objective-C headers (`xcode-select --install`).
