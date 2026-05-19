<?code-excerpt path-base="."?>
# Pigeon Native Interop (FFI & JNI) Guide

This guide describes Pigeon's Native Interop feature, which allows for direct, high-performance communication between Dart and native code using **FFI (Foreign Function Interface)** for Swift (iOS/macOS) and **JNI (Java Native Interface)** for Kotlin/Java (Android).

---

## 1. Overview

Pigeon Native Interop allows Dart code to make direct function calls into native platform code, and vice versa, without the overhead of MethodChannel-based message passing. Instead of serializing data into binary buffers, Native Interop establishes direct memory-bound bridges using native pointers and JVM references.
For a detailed comparison between MethodChannel-based communication and Native Interop—including advantages, limitations, and recommended use cases—see the [Pigeon README](file:///Users/tarrinneal/work/packages/packages/pigeon/README.md#communication-options-methodchannels-vs-native-interop).

---

## 2. End-to-End Workflow

Using Native Interop in pigeon follows the standard pigeon workflow, with a few additional configuration and compilation steps. The complete end-to-end process is:

1. **Define the Interface**: Create a Dart definition file outlining your `HostApi` and `FlutterApi` declarations (refer to the [Pigeon README](file:///Users/tarrinneal/work/packages/packages/pigeon/README.md#rules-for-defining-your-communication-interface) for syntax and rules).
2. **Configure Options**: Configure `kotlinOptions.useJni` or `swiftOptions.useFfi` in your `PigeonOptions` (see [Step 1: Configure Pigeon Options](#step-1-configure-pigeon-options) below).
3. **Prerequisites**: Ensure your local environment meets the toolchain prerequisites for `jnigen` and `ffigen` (see [Section 3: Prerequisites](#section-3-prerequisites) below).
4. **Run Code Generation**: Run the `pigeon` tool to generate the native bridge code, Dart wrapper, and config scripts, then run the generated config scripts to produce the underlying interop bindings (see [Step 2: Automated Interop Generation](#step-2-automated-interop-generation) below).
5. **Configure Build Systems**: For Swift FFI, configure CocoaPods or Swift Package Manager to compile the intermediate Objective-C bridge files (see [Step 3: iOS/macOS Build System Configuration (FFI)](#step-3-iosmacos-build-system-configuration-ffi) below).
6. **Implement and Call**: Implement the generated protocol/class interface in your native codebase and call the generated Dart methods from your Flutter application.

---

## 3. Prerequisites

To use Native Interop, your development environment and the corresponding external tools must be configured:

### Android (JNI / JNIgen)
- **Java 17**: Required by the Android build tools and JNIgen.
- **Maven (`mvn`)**: Required to resolve dependencies during generation.
- **Android SDK**: Must be installed and configured in your path.
- **Kotlin Version**: The maximum supported version is **2.1.0**.

### iOS/macOS (FFI / FFIgen)
- **LLVM (version 9+)**: Required to parse header files. 
  - On macOS, this is included with Xcode Command Line Tools.
- **Dart Dependencies**: The `package:ffi` and `package:ffigen` packages must be added to your pubspec.

---

## 4. Implementation Steps

### Step 1: Configure Pigeon Options

Enable Native Interop for your target platforms by setting the configuration options in your Pigeon file:

<?code-excerpt "example/native_interop_app/pigeons/native_interop_example.dart (config)"?>
```dart
@ConfigurePigeon(
  PigeonOptions(
    dartOptions: DartOptions(),
    kotlinOptions: KotlinOptions(
      useJni: true,
      // Optional: Paths to search for compiled local classes (primarily needed for standalone Apps)
      jniClassPaths: <String>['build/app/tmp/kotlin-classes/release'],
    ),
    swiftOptions: SwiftOptions(useFfi: true, ffiModuleName: 'my_plugin'),
  ),
)
```

#### Kotlin Options for JNI
* **`useJni`**: Set to `true` to enable Kotlin JNI code generation and automated JNIgen orchestration.
* **`jniClassPaths`**: (Optional) A list of paths to directories or `.jar` files containing compiled Kotlin/Java classes. This is primarily required for standalone Flutter Applications, as their own local compiled classes are not automatically resolved by JNIgen's default dependency scanner. If omitted, it defaults to the standard Flutter release build output directory (`build/app/tmp/kotlin-classes/release`).
  - *Note*: If you are building a Flutter Plugin, this option is generally not needed because JNIgen automatically resolves classes defined inside plugin packages via standard Gradle dependency classpaths.
  - *CLI Equivalent*: `--kotlin_jni_classpaths <path>` (can be specified multiple times).

### Step 2: Automated Interop Generation

Pigeon automatically orchestrates running `jnigen` and `ffigen` as part of the generation process.

- **Android (JNI)**: When `kotlinOptions.useJni` is enabled and `kotlinOut` is specified:
  1. Generate the JNI-compatible Kotlin bridge and the `jnigen_config.dart` configuration.
  2. Run `jnigen` (via the config script) to parse the generated Kotlin bridge and produce Dart JNI bindings.
  3. Generate the final pigeon Dart output that wraps and imports those JNI bindings.
- **iOS/macOS (FFI)**: When `swiftOptions.useFfi` is enabled and `swiftOptions.appDirectory` is specified:
  1. Generate the Objective-C compatible Swift bridge and the `ffigen_config.dart` configuration.
  2. Run `ffigen` (via the config script) to parse the generated Objective-C bridge and produce Dart FFI bindings.
  3. Generate the final pigeon Dart output that wraps and imports those FFI bindings.

### Step 3: iOS/macOS Build System Configuration (FFI)

Because Dart FFI cannot directly call Swift symbols, the FFI toolchain generates an intermediate Objective-C bridging file (`.m` file) in a subdirectory named `<swift_output_dir>_objc_gen`. 

To compile the generated Objective-C files alongside your Swift code, you must configure your iOS/macOS build system:

#### Option A: CocoaPods (Standard Flutter Plugins)
If you are developing a standard Flutter plugin using CocoaPods, ensure your `.podspec` file matches both Swift and Objective-C source files:
```ruby
s.source_files = 'Sources/**/*.{swift,m}'
```
This allows CocoaPods to automatically compile the generated Objective-C bridging files into the framework.

#### Option B: Swift Package Manager (SPM)
If your plugin uses SPM, note that Swift and Objective-C files cannot reside within the same SPM target. You must define two separate targets in your `Package.swift` file:
1. An Objective-C target for the generated bridge files (e.g., `my_plugin_objc_gen`).
2. The main Swift target that depends on the Objective-C target.

Example configuration:
<?code-excerpt "platform_tests/test_plugin/darwin/test_plugin/Package.swift (spm-targets)"?>
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

## 5. Migration from Method Channels

If you are migrating an existing Pigeon plugin from the `MethodChannel`-based model to the Native Interop model, see the [Native Interop Migration Guide](file:///Users/tarrinneal/work/packages/packages/pigeon/native_interop_migration_guide.md) for a complete comparison of the API models and transition examples.
