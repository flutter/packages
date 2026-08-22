<?code-excerpt path-base="."?>
# Pigeon Native Interop (FFI & JNI) Guide

This guide describes Pigeon's Native Interop feature, which allows for direct, high-performance communication between Dart and native code using **FFI (Foreign Function Interface)** for Swift (iOS/macOS) and **JNI (Java Native Interface)** for Kotlin (Android).

---

## 1. Overview

Pigeon Native Interop allows Dart code to make direct function calls into native platform code, and vice versa, without the overhead of MethodChannel-based message passing. Instead of serializing data into binary buffers, Native Interop establishes direct memory-bound bridges using native pointers and JVM references.
For a detailed comparison between MethodChannel-based communication and Native Interop—including advantages, limitations, and recommended use cases—see the [Pigeon README](./README.md#communication-options-method-channels-vs-native-interop).

### Threading Model (Main Thread Execution)

Native Interop calls are direct in-process function calls executed synchronously on the calling thread, which in Flutter is the main UI thread.

* **Main Thread Only**: All FFI and JNI Pigeon host API calls must be invoked and handled on the main thread.
* **`TaskQueue` Not Supported**: The `@TaskQueue` annotation (which dispatches calls to background queues on platform channels) is **not supported** with Native Interop. Specifying `@TaskQueue` when `useFfi: true` or `useJni: true` is enabled will result in a Pigeon code generation error. If your use case requires offloading work to background threads via platform channels, use standard Method Channels instead.

---

## 2. End-to-End Workflow

Using Native Interop in pigeon follows the standard pigeon workflow, with a few additional configuration and compilation steps. The complete end-to-end process is:

1. **Add Dependencies**: Add required interop packages to your `pubspec.yaml` (see [Step 1: Add Dependencies](#step-1-add-dependencies) below).
2. **Define the Interface**: Create a Dart definition file outlining your `HostApi` and `FlutterApi` declarations (refer to the [Pigeon README](./README.md#rules-for-defining-your-communication-interface) for syntax and rules).
3. **Configure Options**: Configure `kotlinOptions.useJni` or `swiftOptions.useFfi` in your `PigeonOptions` (see [Step 2: Configure Pigeon Options](#step-2-configure-pigeon-options) below).
4. **Prerequisites**: Ensure your local environment meets the toolchain prerequisites for `jnigen` and `ffigen` (see [Section 3: Prerequisites](#3-prerequisites) below).
5. **Run Code Generation**: Run the `pigeon` tool to generate the native bridge code and interop bindings (see [Step 3: Run Code Generation](#step-3-run-code-generation) below).
6. **Configure Build Systems**: For Swift FFI, configure CocoaPods or Swift Package Manager (SwiftPM) to compile the intermediate Objective-C bridge files (see [Step 4: iOS/macOS Build System Configuration (FFI)](#step-4-iosmacos-build-system-configuration-ffi) below).
7. **Implement and Call**: Implement the generated protocol/class interface in your native codebase and call the generated Dart methods from your Flutter application.

---

## 3. Prerequisites

To use Native Interop, your development environment and the corresponding external tools must be configured:

### Android (JNI / JNIgen)
- **Java 17**: Required specifically by the Android build tools and JNIgen.
- **Android SDK**: Must be installed and configured in your path.
- **Kotlin Version**: The maximum supported version is **2.1.0**.

### iOS/macOS (FFI / FFIgen)
- **LLVM (version 9+)**: Required to parse header files. 
  - On macOS, this is included with Xcode Command Line Tools.

---

## 4. Implementation Steps

### Step 1: Add Dependencies

Add the required runtime dependencies (`ffi`, `objective_c` for Swift FFI, or `jni` for Kotlin JNI) to `dependencies`, and code generators (`ffigen` or `jnigen`) to `dev_dependencies` in your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # For iOS/macOS Swift FFI:
  ffi: ^2.1.0
  objective_c: ^9.0.0
  # For Android Kotlin JNI:
  jni: ^0.14.0

dev_dependencies:
  pigeon: ^26.0.0
  # For iOS/macOS Swift FFI:
  ffigen: ^16.0.0
  # For Android Kotlin JNI:
  jnigen: ^0.14.0
```

### Step 2: Configure Pigeon Options

Enable Native Interop for your target platforms by setting the configuration options in your Pigeon file:

<?code-excerpt "example/native_interop_app/pigeons/native_interop_example.dart (config)"?>
```dart
@ConfigurePigeon(
  PigeonOptions(
    // (Recommended) Path to the compiled application directory (where pubspec.yaml resides)
    appDirectory: './',
    dartOptions: DartOptions(),
    kotlinOptions: KotlinOptions(
      useJni: true,
      // Optional: Paths to search for compiled local classes (primarily needed for standalone Apps)
      jniClassPaths: <String>['build/app/tmp/kotlin-classes/release'],
    ),
    swiftOptions: SwiftOptions(useFfi: true, ffiModuleName: 'Runner'),
  ),
)
```

#### General Options
* **`appDirectory`**: The path to the compiled Flutter **application** directory (e.g., `example/` when developing a plugin, or `./` for a standalone application). FFIgen and JNIgen require a compiled application context to locate class files and build outputs. If omitted when running Pigeon from an app root, it defaults to `./`.
  - *CLI Equivalent*: `--app_directory <path>`.

#### Kotlin Options for JNI
* **`useJni`**: Set to `true` to enable Kotlin JNI code generation and automated JNIgen orchestration.
* **`jniClassPaths`**: (Optional) A list of paths to directories or `.jar` files containing compiled Kotlin/Java classes. This is primarily required for standalone Flutter Applications, as their own local compiled classes are not automatically resolved by JNIgen's default dependency scanner. If omitted, it defaults to the standard Flutter release build output directory (`build/app/tmp/kotlin-classes/release`).
  - *Note*: If you are building a Flutter Plugin, this option is generally not needed because JNIgen automatically resolves classes defined inside plugin packages via standard Gradle dependency classpaths.
  - *CLI Equivalent*: `--kotlin_jni_classpaths <path>` (can be specified multiple times).
* **`appDirectory`**: (Optional) Overrides the target application directory specifically for Kotlin and JNIgen.
  - *CLI Equivalent*: `--kotlin_app_directory <path>`.

#### Swift Options for FFI
* **`useFfi`**: Set to `true` to enable Swift FFI code generation and automated FFIgen orchestration.
* **`ffiModuleName`**: The module name that generated Swift FFI classes and Objective-C bridge files will use.
  - *CLI Equivalent*: `--swift_use_ffi`, `--swift_ffi_module_name <name>`.
* **`appDirectory`**: (Optional) Overrides the target application directory specifically for Swift and FFIgen.
  - *CLI Equivalent*: `--swift_app_directory <path>`.

### Step 3: Run Code Generation

Run the `pigeon` tool to generate the native bridge code and interop bindings:

```bash
dart run pigeon --input <path/to/pigeon_file.dart>
```

#### How Automated Interop Generation Works

When Native Interop options (`useJni` or `useFfi`) are enabled, Pigeon automatically orchestrates running `jnigen` and `ffigen` as part of the generation process:

- **Android (JNI)**: When `kotlinOptions.useJni` is enabled:
  1. Generates the JNI-compatible Kotlin bridge and the `jnigen_config.dart` script in `tool/pigeon/`.
  2. Runs `jnigen` via the config script to parse the Kotlin bridge and produce Dart JNI bindings.
  3. Generates the final pigeon Dart output that wraps and imports those JNI bindings.
- **iOS/macOS (FFI)**: When `swiftOptions.useFfi` is enabled:
  1. Generates the Objective-C compatible Swift bridge and the `ffigen_config.dart` script in `tool/pigeon/`.
  2. Runs `ffigen` via the config script to parse the Objective-C bridge and produce Dart FFI bindings.
  3. Generates the final pigeon Dart output that wraps and imports those FFI bindings.

### Step 4: iOS/macOS Build System Configuration (FFI)

Because Dart FFI cannot directly call Swift symbols, the FFI toolchain generates intermediate Objective-C bridging files in a subdirectory named `<swift_output_dir>_objc_gen`:
- **`.h` (Headers)**: Always generated to declare module interfaces and types.
- **`.m` (Bridging Implementation)**: Generated when the schema contains callbacks, closures, Flutter APIs, or Objective-C blocks requiring trampoline implementations.
- **`.o` (Temporary Object Files)**: Intermediate binary files generated during `ffigen`/`swiftgen` AST extraction. These are **not** needed after code generation and must **not** be committed to version control.

To compile the generated Objective-C files alongside your Swift code, you must configure your iOS/macOS build systems (both CocoaPods and Swift Package Manager (SwiftPM) are expected to be supported by Flutter plugins):

#### CocoaPods Configuration
Ensure your `.podspec` file matches Swift, Objective-C implementations (`.m`), and headers (`.h`):
```ruby
s.source_files = 'Sources/**/*.{swift,m,h}'
```
This allows CocoaPods to automatically compile the generated Objective-C bridging files into the framework.

#### Swift Package Manager (SwiftPM) Configuration
Because Swift and Objective-C files cannot reside within the same SwiftPM target, you must define two separate targets in your `Package.swift` file:
1. An Objective-C target for the generated bridge files (e.g., `my_plugin_objc_gen`).
2. The main Swift target that depends on the Objective-C target.

Example configuration:
<?code-excerpt "platform_tests/test_plugin/darwin/test_plugin/Package.swift (swiftpm-targets)"?>
```swift
targets: [
  .target(
    name: "test_plugin_objc_gen",
    dependencies: [],
    publicHeadersPath: "."
  ),
  .target(
    name: "test_plugin",
    dependencies: ["test_plugin_objc_gen"]
  ),
]
```

---

## 5. Troubleshooting Automated Generation

If `dart run pigeon` encounters errors while running `jnigen` or `ffigen`, review the following troubleshooting steps:

### 5.1 Unupdated Native Implementation or Uncompiled Code (JNI)

JNIgen parses compiled bytecode (`.class` files). If you changed your Pigeon schema and haven't yet updated or compiled your native Kotlin/Java code, JNIgen will fail.

- **Solution**: Build/compile your native code first so that the compiled class files are up-to-date:
  ```bash
  cd android && ./gradlew compileReleaseKotlin
  ```
  Then re-run `dart run pigeon --input <path/to/pigeon_file.dart>`.

### 5.2 Missing Class Files or Non-Standard Build Directory (JNI)

For standalone Flutter Applications, JNIgen defaults to searching `build/app/tmp/kotlin-classes/release`. If your build output directory is different or the project has not been built, JNIgen will fail to find class definitions.

- **Solution**: Ensure the project has been built at least once, or specify custom class paths via `jniClassPaths`:
  ```dart
  kotlinOptions: KotlinOptions(
    useJni: true,
    jniClassPaths: <String>['build/app/tmp/kotlin-classes/debug'],
  )
  ```

### 5.3 Manual Configuration Script Execution

Pigeon writes the interop configuration scripts to `tool/pigeon/jnigen_config.dart` and `tool/pigeon/ffigen_config.dart`.

- **Solution**: Run the generated config scripts directly to view verbose stderr logs and diagnose toolchain errors:
  ```bash
  # Debug JNIgen (Android):
  dart run tool/pigeon/jnigen_config.dart

  # Debug FFIgen (iOS/macOS):
  dart run tool/pigeon/ffigen_config.dart
  ```

---

## 6. Migration from Method Channels

If you are migrating an existing Pigeon plugin from the `MethodChannel`-based model to the Native Interop model, see the [Native Interop Migration Guide](./native_interop_migration_guide.md) for a complete comparison of the API models and transition examples.
