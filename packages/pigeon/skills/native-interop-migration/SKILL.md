# Skill: Migrating Flutter Plugins to Pigeon Native Interop (FFI & JNI)

## Overview
This skill guides AI agents and developers through migrating an existing Flutter plugin package (containing Swift for iOS/macOS and/or Kotlin for Android) from platform-channel-based Pigeon code to direct **Native Interop** (`useFfi: true` for Swift, `useJni: true` for Kotlin).

> [!IMPORTANT]
> **Golden Rule for Generated Code**: Generated code files (`.g.dart`, `.g.swift`, `.g.kt`, `.g.jni.dart`, `.g.ffi.dart`) should be produced automatically by Pigeon, FFIgen, or JNIgen without manual edits. If you encounter a code generation error or bug that prevents compilation and cannot be resolved through configuration options:
> 1. File a detailed bug report describing the generator issue.
> 2. **Do not modify generated files without explicit user permission**. You may ask the user if they want you to temporarily alter the generated code to unblock testing, but you must inform them that re-running code generation will overwrite these manual edits.

---

## 1. Add Dependencies

Add the required runtime dependencies to `dependencies` and code generators/config-script dependencies to `dev_dependencies` in the package where Pigeon runs (for a plugin package, add these to the **plugin's** `pubspec.yaml`, not `example/pubspec.yaml`, unless the example app runs Pigeon directly).

Because Pigeon generates helper scripts in `tool/pigeon/` (`*_ffigen_config.dart` and `*_jnigen_config.dart`), `dart pub publish --dry-run` (and `flutter_plugin_tools publish-check`) requires every package imported by `lib/` or `tool/` to be explicitly declared in `pubspec.yaml`:

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
**Only if a `.m` file is generated** in `<swift_output_dir>_objc_gen`, split the targets in `Package.swift` into an Objective-C bridging target (`<plugin_name>_objc_gen`) and the main Swift target (since SPM targets cannot mix Swift and Objective-C files in a single target):

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

> [!IMPORTANT]
> **Do NOT add `<plugin_name>_objc_gen` to `Package.swift` if no `.m` file is generated!**
> If your Pigeon schema only has synchronous `@HostApi()` methods, `ffigen` only generates a `.h` header (and a temporary `.o` file that should be deleted/ignored) in `<swift_output_dir>_objc_gen`, without a `.m` file. Because SwiftPM requires every `.target` to have at least one compilable source file (`.m`, `.c`, or `.swift`), declaring `<plugin_name>_objc_gen` without a `.m` file will cause `flutter build ios`/`macos` to fail with:
> `Error (Xcode): Build input file cannot be found: '.../<plugin_name>_objc_gen.o'`

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
1. **Registration Calls**: Replace platform channel setup with JNI registrars:
   ```kotlin
   // BEFORE: MyApi.setUp(messenger, this)
   // AFTER:  MyApiRegistrar().register(this)
   ```
2. **Async Method Signatures**: Replace callback interfaces with Kotlin Coroutine `suspend` functions:
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

### 4.4 Dart Plugin Client (`createWithNativeInteropApi` & `dartPluginClass`)
In your Dart plugin implementation class, instantiate the Pigeon Host API using `<MyApi>.createWithNativeInteropApi()` (passing `messageChannelSuffix` if multiple named instances are registered on the host).

> [!CAUTION]
> **Initialize `createWithNativeInteropApi()` Lazily (`late final`)**:
> If your plugin declares `dartPluginClass` in `pubspec.yaml`, Flutter calls `<PluginClass>.registerWith()` during Dart plugin registration **before `main()`** and before `JniPlugin` initializes `DartJNI` on Android (or before native host registration). Calling `createWithNativeInteropApi()` eagerly in the constructor initializer list will crash the app at startup on Android (`F DartJNI : JNI is not initialized`). Always initialize the API lazily using `late final`:

```dart
class MyPluginAndroid extends MyPluginPlatform {
  MyPluginAndroid({@visibleForTesting MyApi? api}) : _apiOverride = api;

  final MyApi? _apiOverride;

  @visibleForTesting
  late final MyApi api = _apiOverride ?? MyApi.createWithNativeInteropApi();
}
```

### 4.5 Android Release Builds (R8 Keep Rules)
<!-- TODO(tarrinneal): Remove this section once package:jni ships these keep rules: https://github.com/dart-lang/native/issues/3732 -->
Flutter enables R8 for Android release builds by default, and R8 removes or renames classes that JNI looks up by name. Pigeon adds `@Keep` to the generated Kotlin classes that JNI reaches, but `package:jni` and the generated Dart code also look up Kotlin standard library classes by name to call and implement `suspend` functions. Until `package:jni` includes rules for these classes, add them to the plugin:

1. Create `android/consumer-rules.pro` in the plugin:
   ```text
   # Kotlin classes that package:jni and the generated Dart code look up by name.
   -keep class kotlin.Unit { *; }
   -keep class kotlin.Result { *; }
   -keep class kotlin.Result$Failure { *; }
   -keep class kotlin.coroutines.Continuation { *; }
   -keep class kotlin.coroutines.intrinsics.CoroutineSingletons { *; }
   -keep class kotlin.coroutines.intrinsics.IntrinsicsKt { *; }
   ```
2. Reference it from `android.defaultConfig` in the plugin's `android/build.gradle` or `android/build.gradle.kts`, so that every app using the plugin applies the rules:
   ```gradle
   consumerProguardFiles("consumer-rules.pro")
   ```

Do not add a `-keep` rule for the plugin's own package to work around missing generated classes; regenerate with the latest Pigeon instead.

---

## 5. Code Generation, Formatting, and Validation

1. **Run Pigeon Generator** (this also runs JNIgen and FFIgen automatically):
   ```bash
   dart run pigeon --input pigeons/messages.dart
   ```
2. **Format Code**:
   ```bash
   dart run script/tool/bin/flutter_plugin_tools.dart format --packages <plugin_name>
   ```
3. **Run Analysis, Unit Tests, and Publish Check**:
   ```bash
   # Static Analysis & Unit Tests
   dart run script/tool/bin/flutter_plugin_tools.dart analyze --packages <plugin_name>
   dart run script/tool/bin/flutter_plugin_tools.dart dart-test --packages <plugin_name>

   # Verify pubspec.yaml dependencies (including tool/pigeon/*_config.dart imports)
   dart run script/tool/bin/flutter_plugin_tools.dart publish-check --packages <plugin_name>

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
- **`jnigen` 1.0.0 or later**: Earlier versions of JNIgen cannot parse metadata from newer Kotlin compilers and fail with `IllegalArgumentException: Provided Metadata instance has version ... while maximum supported version is ...`. `jnigen` 1.0.0 supports Kotlin metadata up to 2.4, and uses the JDK bundled with Flutter by default. Do not downgrade the project's Kotlin version to work around this error; upgrade `jnigen` instead.
- **LLVM / Xcode Command Line Tools**: Required by FFIgen to parse C/Objective-C headers (`xcode-select --install`).

### 6.6 Threading, Isolates & Platform UI Affinity
- **Dart Isolates**: Native Interop Host API calls can be made from any Dart worker isolate (`Isolate.run`) without needing `BackgroundIsolateBinaryMessenger` or `RootIsolateToken`. The native code executes synchronously on the OS thread backing that isolate. Callers must ensure the isolate stays alive while there are pending asynchronous calls, as attempting to execute a callback after the isolate has terminated will cause a crash.
- **Platform UI Thread Affinity**: If native code interacts with platform UI elements (such as UIKit views on iOS/macOS or `Activity`/view hierarchies on Android), that work must execute on the platform's main thread. If an interop call is initiated from a background isolate or dispatches work to a background queue, the native implementation must explicitly dispatch to the main thread (`DispatchQueue.main.async` in Swift, `Handler(Looper.getMainLooper()).post` in Kotlin) before interacting with UI APIs.
- **`FlutterApi` Synchronous Callbacks**: Synchronous callbacks into Dart are isolate-local and must be invoked on the isolate that registered them.

### 6.7 Failed to Load Objective-C Class (`<ffiModuleName>.<Api>Setup`)
If the application crashes at startup with `FailedToLoadClassException: Failed to load Objective-C class`:
- **Module Name Mismatch**: Ensure `ffiModuleName` matches the app's Swift module name. If iOS and macOS share the same generated Dart FFI file, ensure both platforms use the same module name (e.g., align macOS by setting `PRODUCT_MODULE_NAME` in `macos/Runner/Configs/AppInfo.xcconfig`).
- **Linker Dead-Code Stripping**: The Xcode linker (`-dead_strip`) strips native classes that are not directly referenced in compiled code. Ensure your host application instantiates and registers the native implementation (e.g. calling `MyApiSetup.register(api: api)` in `MainFlutterWindow.swift` on macOS or `AppDelegate.swift` on iOS).

### 6.8 Startup Crash on Android (`VmServiceDisappearedException` / `JNI is not initialized`)
If integration tests fail during test loading with `VmServiceDisappearedException` and `adb logcat` shows:
```text
F DartJNI : JNI is not initialized. Are you trying to invoke a Java API from Dart code too early, before 'main()' (such as during Dart plugin class registration)?
```
- **Cause**: Your plugin's `registerWith()` method (invoked by Flutter's `_PluginRegistrant.register()` before `main()`) constructed your Dart plugin class, and its constructor eagerly called `<MyApi>.createWithNativeInteropApi()` before `JniPlugin` initialized `DartJNI`.
- **Solution**: Initialize `<MyApi>.createWithNativeInteropApi()` lazily using `late final` (see [Section 4.4](#44-dart-plugin-client-createwithnativeinteropapi--dartpluginclass)).

### 6.9 Xcode Build Error: `Build input file cannot be found: '.../<plugin_name>_objc_gen.o'`
If an iOS or macOS SwiftPM build fails because `<plugin_name>_objc_gen.o` cannot be found:
- **Cause**: `Package.swift` defines a `<plugin_name>_objc_gen` target, but `ffigen` did not generate a `.m` implementation file in `Sources/<plugin_name>_objc_gen/` (because the Pigeon schema has no async callbacks, closures, or `@FlutterApi` methods requiring Objective-C trampolines). Without a `.m` source file, SwiftPM does not produce an object file for the target. (Note: any `.o` file produced inside `Sources/<plugin_name>_objc_gen/` during `ffigen` execution is a temporary `swiftc` artifact and must be deleted/ignored, never committed.)
- **Solution**: Remove the `<plugin_name>_objc_gen` target and its dependency entry from `Package.swift`.

### 6.10 `ClassNotFoundException` or `NoSuchMethodError` in Android Release Builds (JNI)
If native interop calls work in debug builds but fail in release builds with `java.lang.ClassNotFoundException` or `java.lang.NoSuchMethodError`:
- **Cause**: R8 removed or renamed a class or member that JNI looks up by name.
- **Solution**:
  - If the error names a class generated by Pigeon, regenerate with Pigeon 29.0.7 or later, which adds `@Keep` to every generated class that JNI reaches.
  - If the error names a class in the `kotlin` package (for example, `kotlin/coroutines/Continuation` in the signature of a `suspend` method), add the keep rules from [Section 4.5](#45-android-release-builds-r8-keep-rules). <!-- TODO(tarrinneal): Remove this bullet once package:jni ships these keep rules: https://github.com/dart-lang/native/issues/3732 -->
  - To see what R8 removed or renamed, check `build/app/outputs/mapping/release/mapping.txt` in the example app directory.
