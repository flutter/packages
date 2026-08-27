# Skill: Migrating Flutter Plugins to Pigeon Native Interop (FFI & JNI)

## Overview
This skill guides AI agents and developers through migrating an existing Flutter plugin package (containing Swift for iOS/macOS and/or Kotlin for Android) from platform-channel-based Pigeon code to direct **Native Interop** (`useFfi: true` for Swift, `useJni: true` for Kotlin).

> [!IMPORTANT]
> **Golden Rule for Generated Code**: Generated code files (`.g.dart`, `.g.swift`, `.g.kt`, `.g.jni.dart`, `.g.ffi.dart`) should be produced automatically by Pigeon, FFIgen, or JNIgen without manual edits. If you encounter a code generation error or bug that prevents compilation and cannot be resolved through configuration options:
> 1. File a detailed bug report describing the generator issue.
> 2. **Do not modify generated files without explicit user permission**. You may ask the user if they want you to temporarily alter the generated code to unblock testing, but you must inform them that re-running code generation will overwrite these manual edits.

---

## 1. Update `pubspec.yaml` Dependencies

Add the required runtime and dev dependencies to the plugin's `pubspec.yaml` and its `example/pubspec.yaml` (if applicable):

```yaml
dependencies:
  flutter:
    sdk: flutter
  # For iOS/macOS Swift FFI:
  ffi: ^2.1.4
  objective_c: ^9.2.1
  # For Android Kotlin JNI:
  jni: ^1.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  pigeon: ^27.3.0
  # For iOS/macOS Swift FFI:
  ffigen: ^16.0.0
  # For Android Kotlin JNI:
  jnigen: ^0.17.0
```

*Run `dart pub get` (and `dart pub get` in `example/`) after updating `pubspec.yaml`.*

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
> **Threading & TaskQueue**: Native Interop (FFI/JNI) calls execute directly in-process and always run on the main UI thread. `@TaskQueue` annotations are not supported with Native Interop and must be removed from your Pigeon file before generating code.

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

---

## 4. Update Native Plugin Implementations

### 4.1 Swift Implementation (`<PluginName>.swift`)
1. **Registration Calls**: Replace platform channel setup calls with FFI registration:
   ```swift
   // BEFORE (Platform Channels):
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
  // BEFORE (Platform Channels):
  // let flutterApi = MyFlutterApi(binaryMessenger: messenger)
  // flutterApi.onEvent(data) { result in ... }

  // AFTER (Native Interop FFI):
  let flutterApi = MyFlutterApi()
  try await flutterApi.onEvent(data)
  ```
- **Kotlin (JNI)**: Instantiate `MyFlutterApi()` directly without passing a `BinaryMessenger`:
  ```kotlin
  // BEFORE (Platform Channels):
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
