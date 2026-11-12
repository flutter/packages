<?code-excerpt path-base="example/native_interop_app"?>
# Pigeon Native Interop Migration Guide

This guide provides detailed information on migrating from the platform-channel-based Pigeon model to the direct **Native Interop (FFI & JNI)** model.

For a comprehensive walkthrough on setting up Native Interop from scratch, see the main [Native Interop Guide](./native_interop_guide.md).

---

## 1. Key Architectural Differences

| Feature | Platform Channels | Native Interop (FFI / JNI) |
| :--- | :--- | :--- |
| **Data Serialization** | Serialized to binary format (`StandardMessageCodec`) | Scalars, strings, enums and typed data cross directly; data classes, lists and maps are encoded into one buffer per call |
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

# For Android Kotlin JNI (jni 1.1.1+ required for Android R8 keep rules):
flutter pub add 'jni:^1.1.1' meta
# Code generator imported by tool/pigeon/*_jnigen_config.dart:
flutter pub add dev:jnigen
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

### 3.4 Splitting Unsupported Pigeon Features (`@EventChannelApi`, `@ProxyApi`)

`@EventChannelApi` and `@ProxyApi` are not supported with Native Interop (`useFfi` / `useJni`). If your existing Pigeon file declares event channels or proxy APIs alongside `@HostApi` / `@FlutterApi`, move the `@EventChannelApi` / `@ProxyApi` declarations into a separate Pigeon file that does not enable `useFfi` or `useJni`. In addition, Swift FFI requires `SwiftOptions.includeErrorClass: true` (if you have multiple Swift FFI files in the same module, give each file a distinct `errorClassName` instead of setting `includeErrorClass: false`).

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
- **Multi-Engine Plugin Deregistration (`unregister`)**: Unlike platform channels (where `MyApi.setUp(messenger, null)` clears a single engine's `BinaryMessenger`), Native Interop tracks registered `@HostApi` and `@FlutterApi` instances in process memory, with each native registration associated with an engine. Register and unregister on the platform main thread, as with platform channel `setUp`:
  - For `@HostApi` in `FlutterPlugin` implementations, `register` requires a non-null API instance and the engine it belongs to (and Swift FFI `@HostApi` protocols conform to `AnyObject`, requiring class implementations). Register with `MyApiRegistrar().register(this, binding)` on Android and `MyApiSetup.register(api: instance, registrar: registrar)` on iOS/macOS, and deregister on engine detach with `MyApiRegistrar().unregister(this, binding)` / `MyApiSetup.unregister(api: self, registrar: registrar)`, so detaching a secondary `FlutterEngine` does not clear registrations for other active engines. Apps that own a `FlutterEngine` can use `register(api, flutterEngine)` / `unregister(api, flutterEngine)`. *(If upgrading from Pigeon `29.x` Native Interop: `unregister` replaces `register(null)` / `register(api: nil)`, and the name-only native `@HostApi` `getInstance(name)` is removed.)* On iOS, `detachFromEngine(for:)` is only called for instances published with `registrar.publish(instance)`. macOS plugins get no detach callback, so macOS registrations currently outlive their engine.
  - For `@FlutterApi` in Dart, `MyFlutterApi.setUp(null)` deregisters that isolate's Native Interop callback in addition to clearing its `BasicMessageChannel` handler (or call `MyFlutterApiRegistrar().unregister(api)` when registering via `MyFlutterApiRegistrar().register(api)`), leaving other engines' `@FlutterApi` registrations intact. Native code replaces `MyFlutterApi(binaryMessenger:)` (or Pigeon `29.x`'s name-only `getInstance(name)`) with `MyFlutterApiRegistrar().getInstance(binding)` / `getInstance(flutterEngine)` in Kotlin or `MyFlutterApiRegistrar.getInstance(registrar: registrar)` in Swift. Because Dart has no isolate-shutdown hook, `@FlutterApi` registrations are only removed when Dart calls `setUp(null)` or `unregister`; if an isolate disappears without doing so (for example, after a hot restart or when its engine is destroyed), its stale registration stays in native memory and calls to it fail.
  - Lookups on an engine's root isolate are exact when native code knows the engine identifier (always for Kotlin `register(api, flutterEngine)`, and for plugin bindings/registrars on **Flutter 3.50.0 or higher**), and are otherwise best-effort (including on Flutter < 3.50.0 and in background isolates created with `Isolate.spawn` / `Isolate.run`, which have no `PlatformDispatcher.engineId`). **Using Flutter 3.50.0 or higher is strongly recommended** — if you run into multi-engine routing issues on an earlier Flutter version, upgrade to Flutter 3.50.0+. Plugins with per-engine state (such as `ActivityAware` or `TextureRegistry`) may not route to the right engine when routing is best-effort; see the routing limits in [Multi-Engine Routing](./native_interop_guide.md#multi-engine-routing). For macOS with multiple engines, or custom headless `FlutterEngine`s on Android without `GeneratedPluginRegistrant`, see [Multi-Engine Support in the Native Interop Guide](./native_interop_guide.md#step-5-plugin-registration-deregistration-and-multi-engine-support).
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
  - Depend on `FlutterFramework` (`dependencies: [.package(name: "FlutterFramework", path: "../FlutterFramework")]` and `.product(name: "FlutterFramework", package: "FlutterFramework")` on your Swift target) for all `useFfi: true` SwiftPM plugins so the generated `#if canImport(Flutter)` / `#if canImport(FlutterMacOS)` registration APIs compile.
  - **Only if a `.m` file is generated** in `<swift_output_dir>_objc_gen`: Add a separate Objective-C target for `<plugin_name>_objc_gen` in `Package.swift` and depend on it from your main Swift target.
  - **If no `.m` file is generated** (e.g., your schema only has synchronous `@HostApi()` methods and `<swift_output_dir>_objc_gen` only contains a `.h` header): Keep the `FlutterFramework` dependency, but **do not** add the `<plugin_name>_objc_gen` target to `Package.swift`. SwiftPM requires at least one compilable source file (`.m`, `.c`, or `.swift`) per target; an empty/header-only target causes Xcode builds to fail with `Build input file cannot be found: '.../<plugin_name>_objc_gen.o'`.
- **Application & Example App Targets**:
  - **Swift Module Name**: Set `ffiModuleName` in `SwiftOptions` to match your application's Swift module name (defaults to `'Runner'`). If iOS and macOS share the same generated Dart FFI file, both platforms must compile under that same module name. Since Flutter's default macOS template sets the module name to the app name rather than `Runner`, you can unify them by setting `PRODUCT_MODULE_NAME = Runner` in `macos/Runner/Configs/AppInfo.xcconfig` (or by matching whatever module name you configure). If iOS and macOS use separate Pigeon generation outputs or you only target one platform, unifying module names across platforms is not required.
  - **Native Registration (iOS/macOS)**: Register the native API implementation in native code (e.g., `MainFlutterWindow.swift` in `awakeFromNib()` on macOS, or `AppDelegate.swift` on iOS via `MyApiSetup.register(api: api, registrar: registrar)`, passing the registrar from `registrar(forPlugin:)`). This also ensures the setup class is referenced so the Xcode linker does not strip it (`-dead_strip`).

---

## 6. Environment Prerequisites & Tooling Versions

To use Native Interop and its external code generators:
- **Flutter 3.50.0 or higher (strongly recommended)**: Exposes engine identifiers on plugin bindings and registrars for exact multi-engine routing. Upgrade to Flutter 3.50.0+ if you encounter multi-engine issues on earlier versions.
- **Android SDK & JDK 17–21**: An Android SDK must be installed and configured (via Flutter, `android/local.properties`, or `ANDROID_HOME`). JNIgen uses the JDK configured for Flutter (`flutter config --machine` → `jdk-dir`, which defaults to Android Studio's bundled JBR or `JAVA_HOME`), so no separate JDK setup is needed if Android Studio is installed; otherwise install a JDK (17–21) and configure it via `flutter config --jdk-dir` or `JAVA_HOME`.
- **`jnigen` 1.0.0+ and `jni` 1.1.1+**: Pigeon's generated `*_jnigen_config.dart` uses the `JniGenerator` Dart config API introduced in `jnigen` 1.0.0 (which also supports Kotlin metadata up to 2.4), and requires `jni: ^1.1.1` so Android release builds include the required R8 keep rules.
- **LLVM / Xcode Command Line Tools**: Required by FFIgen to parse C/Objective-C headers (`xcode-select --install`).
