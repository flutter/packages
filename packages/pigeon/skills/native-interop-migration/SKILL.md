# Skill: Migrating Flutter Plugins to Pigeon Native Interop (FFI & JNI)

## Overview
This skill guides AI agents and developers through migrating an existing Flutter plugin package (containing Swift for iOS/macOS and/or Kotlin for Android) from platform-channel-based Pigeon code to direct **Native Interop** (`useFfi: true` for Swift, `useJni: true` for Kotlin).

> [!IMPORTANT]
> **Golden Rule for Generated Code**: Generated code files (`.g.dart`, `.g.swift`, `.g.kt`, `.g.jni.dart`, `.g.ffi.dart`) should be produced automatically by Pigeon, FFIgen, or JNIgen without manual edits. If you encounter a code generation error or bug that prevents compilation and cannot be resolved through configuration options:
> 1. File a detailed bug report describing the generator issue.
> 2. **Do not modify generated files without explicit user permission**. You may ask the user if they want you to temporarily alter the generated code to unblock testing, but you must inform them that re-running code generation will overwrite these manual edits.

---

## 1. Add Dependencies

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
flutter pub add dev:jnigen@1.0.0
```

---

## 2. Configure `@ConfigurePigeon` Options

In your Pigeon Dart definition file (`pigeons/<messages_file>.dart`), update `@ConfigurePigeon` to enable native interop for Swift and Kotlin. 

> [!NOTE]
> Keep your package's existing file paths and options (`input`, `dartOut`, `swiftOut`, `kotlinOut`, `package`, `fileSpecificClassNameComponent`, `copyrightHeader`) unchanged. You only need to enable `useFfi: true`, `useJni: true`, and configure `appDirectory`.

```dart
// Example configuration (keep existing paths and options, add native interop settings):
@ConfigurePigeon(
  PigeonOptions(
    input: 'pigeons/messages.dart', // Your existing input path
    dartOut: 'lib/src/messages.g.dart', // Your existing Dart output path
    swiftOut: 'darwin/my_plugin/Sources/my_plugin/messages.g.swift', // Your existing Swift output path
    swiftOptions: SwiftOptions(
      useFfi: true, // <-- ADD/UPDATE: Enables Swift FFI
    ),
    fileSpecificClassNameComponent: 'Messages', // Your existing fileSpecificClassNameComponent (if present)
    kotlinOut: 'android/src/main/kotlin/com/example/my_plugin/Messages.g.kt', // Your existing Kotlin output path
    kotlinOptions: KotlinOptions(
      package: 'com.example.my_plugin', // Your existing Kotlin package
      useJni: true, // <-- ADD/UPDATE: Enables Kotlin JNI
      appDirectory: 'example/', // <-- ADD/UPDATE: Application directory (e.g. 'example/' for plugins, './' for apps)
    ),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
```

### Key Option Breakdown:
- **`swiftOptions: SwiftOptions(useFfi: true)`**: Enables Swift FFI code generation.
- **`kotlinOptions: KotlinOptions(useJni: true)`**: Enables Kotlin JNI code generation.
- **`appDirectory`**: Root path of the compiled Flutter **application** context required by `ffigen` and `jnigen` (use `'example/'` for plugins with an example app, or `'./'` for standalone Flutter apps).

> [!WARNING]
> **Threading, Isolates & TaskQueue**: Native Interop calls execute directly on the calling isolate's OS thread (the main UI thread when called from the root isolate, unless the application developer has opted out of thread merging, which [is still possible on macOS](https://github.com/flutter/flutter/issues/181874)).
> - **`@TaskQueue` is unsupported**: Because calls do not use Flutter Engine message queues, `@TaskQueue` annotations must be removed from the Pigeon file.
> - **Migrating background work**:
>   - *Option A (Native Concurrency)*: Replace `@TaskQueue` with `@async` in the Pigeon definition file, and implement the generated Swift `async` or Kotlin `suspend` function on a background queue or coroutine dispatcher.
>   - *Option B (Dart Isolates)*: Keep the method synchronous and call it from a worker isolate using `await Isolate.run(() => api.doSomething())`. Unlike platform channels, Native Interop Host API calls work out of the box in background isolates without `BackgroundIsolateBinaryMessenger`. Callers must ensure the isolate stays alive while there are pending asynchronous calls, as attempting to execute a callback after the isolate has terminated will cause a crash.

---

## 3. iOS/macOS Build System Configurations (Swift FFI)

Swift FFI generates Objective-C bridging files under `<swift_output_dir>_objc_gen`:
- **`.h` (Headers)**: Always generated to declare module interfaces and types.
- **`.m` (Bridging Implementation)**: Generated when the schema includes callbacks, closures, Flutter APIs, or Objective-C blocks requiring trampoline implementations.
- **`.o` (Temporary Object Files)**: Intermediate binary files generated during `ffigen`/`swiftgen` AST parsing. These are **not** needed after code generation and must **not** be committed to version control (they can be deleted or added to `.gitignore`).

Both CocoaPods and Swift Package Manager (SPM) must be configured to compile these Objective-C sources:

### 3.1 CocoaPods (`<plugin_name>.podspec`)
Ensure `s.source_files` includes `.m` and `.h` files alongside `.swift`:

```ruby
s.source_files = 'my_plugin/Sources/**/*.{swift,m,h}'
```

### 3.2 Swift Package Manager (`Package.swift`)
Because SPM targets cannot mix Swift and Objective-C files in a single target, split the targets into an Objective-C bridging target (`<plugin_name>_objc_gen`) and the main Swift target:

```swift
targets: [
  .target(
    name: "my_plugin_objc_gen",
    dependencies: [],
    publicHeadersPath: "."
  ),
  .target(
    name: "my_plugin",
    dependencies: ["my_plugin_objc_gen"],
    resources: [
      .process("Resources")
    ]
  ),
]
```

### 3.3 Application & Example App Targets
When implementing Native Interop host APIs directly in an application target (such as a plugin's `example/` app or a standalone app) rather than a plugin package:

1. **Swift Module Name Configuration (`ffiModuleName`)**:
   Swift namespaces `@objc` classes with the module name (`<module>.<class>`). Set `ffiModuleName` in `SwiftOptions` to match the application's Swift module name (defaults to `'Runner'`).

   If iOS and macOS share the same generated Dart FFI output, both platforms must compile under the same Swift module name. Because Flutter's macOS template defaults to using the app name instead of `Runner`, unify them by setting `PRODUCT_MODULE_NAME` in `macos/Runner/Configs/AppInfo.xcconfig` to match `ffiModuleName`:
   ```xcconfig
   PRODUCT_MODULE_NAME = Runner // or your custom ffiModuleName
   ```
   *(Note: If iOS and macOS have separate generated outputs or you only target one platform, aligning module names between platforms is not required.)*
2. **Native Host Registration Location**:
   - **iOS**: Register in `AppDelegate.swift` inside `didInitializeImplicitFlutterEngine`:
     ```swift
     let api = PigeonApiImplementation()
     MyApiSetup.register(api: api)
     ```
   - **macOS**: Register in `MainFlutterWindow.swift` inside `awakeFromNib()`:
     ```swift
     let api = PigeonApiImplementation()
     MyApiSetup.register(api: api)
     ```
   *Note: Calling `MyApiSetup.register(api: api)` in native code also prevents the Xcode linker (`-dead_strip`) from stripping the setup class from the compiled binary.*


---

## 4. Update Native Plugin Implementations

### 4.1 Swift Implementation (`<PluginName>.swift`)
1. **Registration Calls**: Replace platform channel setup calls with FFI registration:
   ```swift
   // BEFORE (platform channels):
   // LegacyUserDefaultsApiSetup.setUp(binaryMessenger: messenger, api: instance)

   // AFTER (Native Interop FFI):
   LegacyUserDefaultsApiSetup.register(api: instance)
   ```

2. **Async Method Signatures**: Replace completion-handler callbacks with Swift `async/await`:
   ```swift
   // BEFORE (Callback style):
   func fetchData(id: String, completion: @escaping (Result<Data, Error>) -> Void) {
     completion(.success(data))
   }

   // AFTER (Native Interop async/await style):
   func fetchData(id: String) async throws -> Data {
     return data
   }
   ```

### 4.2 Kotlin Implementation (`<PluginName>.kt`)
1. **Abstract Class Constructors**: Add `()` to parent Pigeon class instantiations:
   ```kotlin
   // BEFORE: class MyPlugin : FlutterPlugin, MyApi
   // AFTER:  class MyPlugin : FlutterPlugin, MyApi()
   ```
2. **Registration Calls**: Replace platform channel setup with JNI registrars:
   ```kotlin
   // BEFORE: MyApi.setUp(messenger, this)
   // AFTER:  MyApiRegistrar().register(this)
   ```
3. **Async Method Signatures**: Replace callback interfaces with Kotlin Coroutine `suspend` functions:
   ```kotlin
   // BEFORE (Callback style):
   fun fetchData(id: String, callback: (Result<Data>) -> Unit) {
     callback(Result.success(data))
   }

   // AFTER (Native Interop suspend style):
   suspend fun fetchData(id: String): Data {
     return data
   }
   ```
4. **Kotlin Version Constraint**: Ensure Kotlin version in `example/android/settings.gradle.kts` is set to `<= 2.1.0` for JNIgen metadata compatibility:
   ```kotlin
   id("org.jetbrains.kotlin.android") version "2.1.0" apply false
   ```

### 4.3 FlutterApi (Host-to-Dart Calls)
For `@FlutterApi()` interfaces (where host native code calls into Dart):

- **Dart side**: Register your Dart implementation using `MyFlutterApi.setUp(MyFlutterApiImpl())`.
- **Swift (FFI)**: Instantiate `MyFlutterApi()` directly without passing a `BinaryMessenger`:
  ```swift
  // BEFORE (platform channels):
  // let flutterApi = MyFlutterApi(binaryMessenger: messenger)
  // flutterApi.onEvent(data) { result in ... }

  // AFTER (Native Interop FFI):
  let flutterApi = MyFlutterApi()
  try await flutterApi.onEvent(data)
  ```
- **Kotlin (JNI)**: Instantiate `MyFlutterApi()` directly without passing a `BinaryMessenger`:
  ```kotlin
  // BEFORE (platform channels):
  // val flutterApi = MyFlutterApi(messenger)
  // flutterApi.onEvent(data) { ... }

  // AFTER (Native Interop JNI):
  val flutterApi = MyFlutterApi()
  flutterApi.onEvent(data)
  ```

---

## 5. Code Generation, Formatting, and Validation

1. **Run Pigeon Generator**:
   ```bash
   dart run pigeon --input pigeons/messages.dart
   ```
2. **Run JNIgen Config Script** (if JNI is enabled):
   ```bash
   dart run example/tool/pigeon/jnigen_config.dart
   ```
3. **Format Code**:
   ```bash
   dart run script/tool/bin/flutter_plugin_tools.dart format --packages <plugin_name>
   ```
4. **Run Tests**:
   ```bash
   # Static Analysis & Unit Tests
   dart run script/tool/bin/flutter_plugin_tools.dart analyze --packages <plugin_name>
   dart run script/tool/bin/flutter_plugin_tools.dart dart-test --packages <plugin_name>

   # Integration Tests
   dart run script/tool/bin/flutter_plugin_tools.dart drive-examples --macos --packages <plugin_name>
   dart run script/tool/bin/flutter_plugin_tools.dart drive-examples --android --packages <plugin_name>
   ```

---

## 6. Troubleshooting & Common Edge Cases

### 6.1 Synchronous Host API Execution
Host API methods executed via FFI/JNI run directly on the calling thread without message loop scheduling. Ensure native operations intended to be synchronous are thread-safe and do not perform long-running blocking I/O on the main UI thread.

### 6.2 Unupdated Native Code or Uncompiled Bytecode (JNI)
JNIgen parses compiled `.class` bytecode files. If you change a Pigeon schema and run Pigeon before updating or compiling your native Kotlin/Java implementation, JNIgen will fail to parse class signatures.
- **Solution**: Compile your native code first to produce up-to-date `.class` files:
  ```bash
  cd android && ./gradlew compileReleaseKotlin
  ```
  Then re-run `dart run pigeon --input pigeons/<messages_file>.dart`.

### 6.3 Missing Class Files or Non-Standard Build Directory (JNI)
For standalone Flutter applications, JNIgen defaults to searching `build/app/tmp/kotlin-classes/release`. If your build configuration uses a different output path (or hasn't been built yet), JNIgen will fail.
- **Solution**: Ensure the project has been built at least once, or specify custom class paths via `jniClassPaths` under `KotlinOptions`:
  ```dart
  kotlinOptions: KotlinOptions(
    useJni: true,
    jniClassPaths: <String>['build/app/tmp/kotlin-classes/debug'],
  )
  ```

### 6.4 Direct Interop Config Script Execution (Debugging)
Pigeon automatically generates input-specific config scripts under `tool/pigeon/` named `<input_name>_jnigen_config.dart` and `<input_name>_ffigen_config.dart` (for example, `messages_jnigen_config.dart` for `pigeons/messages.dart`). If `dart run pigeon` fails during automated JNIgen or FFIgen execution, you can execute these generated configuration scripts directly to view full verbose log output:
```bash
# Debug JNIgen (Android):
dart run tool/pigeon/<input_name>_jnigen_config.dart

# Debug FFIgen (iOS/macOS):
dart run tool/pigeon/<input_name>_ffigen_config.dart
```

### 6.5 Environment Prerequisites & Tooling Versions
- **Java 17**: Required specifically by Android build tools and JNIgen.
- **Kotlin Version (`<= 2.1.0`)**: JNIgen uses `kotlinx-metadata-jvm` to parse Kotlin class metadata. It currently supports Kotlin metadata versions up to **2.1.0**. If the Android Gradle project uses a higher Kotlin plugin version (e.g. Kotlin 2.4.0), JNIgen will throw `IllegalArgumentException: Provided Metadata instance has version ... while maximum supported version is ...`. Ensure `settings.gradle.kts` sets Kotlin to `2.1.0`:
  ```kotlin
  id("org.jetbrains.kotlin.android") version "2.1.0" apply false
  ```
- **LLVM / Xcode Command Line Tools**: Required by FFIgen to parse C/Objective-C headers (`xcode-select --install`).

### 6.6 Threading, Isolates & Platform UI Affinity
- **Dart Isolates**: Native Interop Host API calls can be made from any Dart worker isolate (`Isolate.run`) without needing `BackgroundIsolateBinaryMessenger` or `RootIsolateToken`. The native code executes synchronously on the OS thread backing that isolate. Callers must ensure the isolate stays alive while there are pending asynchronous calls, as attempting to execute a callback after the isolate has terminated will cause a crash.
- **Platform UI Thread Affinity**: If native code interacts with platform UI elements (such as UIKit views on iOS/macOS or `Activity`/view hierarchies on Android), that work must execute on the platform's main thread. If an interop call is initiated from a background isolate or dispatches work to a background queue, the native implementation must explicitly dispatch to the main thread (`DispatchQueue.main.async` in Swift, `Handler(Looper.getMainLooper()).post` in Kotlin) before interacting with UI APIs.
- **`FlutterApi` Synchronous Callbacks**: Synchronous callbacks into Dart are isolate-local and must be invoked on the isolate that registered them.

### 6.7 Failed to Load Objective-C Class (`<ffiModuleName>.<Api>Setup`)
If the application crashes at startup with `FailedToLoadClassException: Failed to load Objective-C class`:
- **Module Name Mismatch**: Ensure `ffiModuleName` matches the app's Swift module name. If iOS and macOS share the same generated Dart FFI file, ensure both platforms use the same module name (e.g., align macOS by setting `PRODUCT_MODULE_NAME` in `macos/Runner/Configs/AppInfo.xcconfig`).
- **Linker Dead-Code Stripping**: The Xcode linker (`-dead_strip`) strips native classes that are not directly referenced in compiled code. Ensure your host application instantiates and registers the native implementation (e.g. calling `MyApiSetup.register(api: api)` in `MainFlutterWindow.swift` on macOS or `AppDelegate.swift` on iOS).

