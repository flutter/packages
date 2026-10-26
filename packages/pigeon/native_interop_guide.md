<?code-excerpt path-base="."?>
# Pigeon Native Interop (FFI & JNI) Guide

This guide describes Pigeon's Native Interop feature, which allows for direct, high-performance communication between Dart and native code using **FFI (Foreign Function Interface)** for Swift (iOS/macOS) and **JNI (Java Native Interface)** for Kotlin (Android).

---

## 1. Overview

Pigeon Native Interop allows Dart code to make direct function calls into native platform code, and vice versa, without the overhead of platform-channel-based message passing. Instead of serializing data into binary buffers, Native Interop establishes direct memory-bound bridges using native pointers and JVM references.
For a detailed comparison between platform-channel-based communication and Native Interop—including advantages, limitations, and recommended use cases—see the [Pigeon README](./README.md#communication-options-platform-channels-vs-native-interop).

### Threading & Isolates Model

Native Interop calls are direct in-process function calls across the C ABI (FFI) or JNI boundary rather than asynchronous messages queued through the Flutter engine:

* **Host APIs (Dart → Native)**:
  * **Execution Thread**: Host methods run directly on the OS thread of the calling Dart isolate. Calls from Flutter's root isolate run on the platform's main UI thread (unless the application developer has opted out of thread merging, which [is still possible on macOS](https://github.com/flutter/flutter/issues/181874)).
  * **Background Isolates**: Host APIs can be called directly from worker isolates (e.g., via `Isolate.run`) without requiring `BackgroundIsolateBinaryMessenger` or engine tokens. Callers must ensure the isolate stays alive while there are pending asynchronous calls, as attempting to execute a callback after the isolate has terminated will cause a crash.
  * **Synchronous Calls Block**: Synchronous methods block the calling isolate until native execution returns. Avoid long-running synchronous calls on the main UI isolate.
  * **Platform UI Affinity**: Native APIs that manipulate UI (such as UIKit views or Android `Activity`/views) must run on the platform's main thread. If invoked from a background isolate, native code must explicitly dispatch to the main thread (`DispatchQueue.main.async` in Swift, `Handler(Looper.getMainLooper()).post` in Kotlin) before interacting with UI APIs.
* **Flutter APIs (Native → Dart)**:
  * Synchronous callbacks into Dart are isolate-local and must be invoked from the isolate that registered them.
* **`@TaskQueue` Not Supported**:
  * Platform channels queue work onto engine background threads; Native Interop executes directly on the caller thread. Specifying `@TaskQueue` results in a code generation error.
  * To run host operations on background threads, annotate the method with `@async` in the Pigeon file and implement it using Swift `async` or Kotlin `suspend` functions (with `DispatchQueue.global` or `Dispatchers.IO`).

---

## 2. End-to-End Workflow

Using Native Interop in pigeon follows the standard pigeon workflow, with a few additional configuration and compilation steps. The complete end-to-end process is:

1. **Add Dependencies**: Add required interop packages to your `pubspec.yaml` (see [Step 1: Add Dependencies](#step-1-add-dependencies) below).
2. **Define the Interface**: Create a Dart definition file outlining your `HostApi` and `FlutterApi` declarations (refer to the [Pigeon README](./README.md#rules-for-defining-your-communication-interface) for syntax and rules).
3. **Configure Options**: Configure `kotlinOptions.useJni` or `swiftOptions.useFfi` in your `PigeonOptions` (see [Step 2: Configure Pigeon Options](#step-2-configure-pigeon-options) below).
4. **Prerequisites**: Ensure your local environment meets the toolchain prerequisites for `jnigen` and `ffigen` (see [Section 3: Prerequisites](#3-prerequisites) below).
5. **Run Code Generation**: Run the `pigeon` tool to generate the native bridge code and interop bindings (see [Step 3: Run Code Generation](#step-3-run-code-generation) below).
6. **Configure Build Systems**: For Swift FFI, configure CocoaPods or Swift Package Manager (SwiftPM) to compile the intermediate Objective-C bridge files (see [Step 4: iOS/macOS Build System Configuration (FFI)](#step-4-iosmacos-build-system-configuration-ffi) below). For Kotlin JNI, add keep rules so that Android release builds work (see [Step 5: Android Release Build Configuration (JNI)](#step-5-android-release-build-configuration-jni) below). <!-- TODO(tarrinneal): Remove this JNI sentence once package:jni ships these keep rules: https://github.com/dart-lang/native/issues/3732 -->
7. **Implement and Call**: Implement the generated protocol/class interface in your native codebase and call the generated Dart methods from your Flutter application.

---

## 3. Prerequisites

To use Native Interop, your development environment and the corresponding external tools must be configured:

### Android (JNI / JNIgen)
- **Android SDK**: Must be installed and configured in your path. JNIgen uses the JDK bundled with Flutter by default, so a separate JDK installation is not required.
- **`jnigen` 1.0.0 or later**: Earlier versions of JNIgen cannot parse metadata from newer Kotlin compilers and fail with `IllegalArgumentException: Provided Metadata instance has version ... while maximum supported version is ...`. `jnigen` 1.0.0 supports Kotlin metadata up to 2.4.

### iOS/macOS (FFI / FFIgen)
- **LLVM (version 9+) / Xcode Command Line Tools**: Required by FFIgen to parse C/Objective-C headers (`xcode-select --install`).

---

## 4. Implementation Steps

### Step 1: Add Dependencies

Add the required runtime dependencies to `dependencies` and code generators/config-script dependencies to `dev_dependencies` in the package where Pigeon runs (for a plugin package, add these to the **plugin's** `pubspec.yaml`, not `example/pubspec.yaml`, unless the example app runs Pigeon directly).

Because Pigeon generates helper scripts in `tool/pigeon/` (`*_ffigen_config.dart` and `*_jnigen_config.dart`), `dart pub publish --dry-run` requires every package imported by `lib/` or `tool/` to be explicitly declared in `pubspec.yaml`:

```bash
# Add Pigeon:
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
      // Optional: Paths to search for compiled local classes (primarily needed for standalone apps)
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
  1. Generates the JNI-compatible Kotlin bridge and the `<input_name>_jnigen_config.dart` script in `tool/pigeon/`.
  2. Runs `jnigen` via the config script to parse the Kotlin bridge and produce Dart JNI bindings.
  3. Generates the final pigeon Dart output that wraps and imports those JNI bindings.
- **iOS/macOS (FFI)**: When `swiftOptions.useFfi` is enabled:
  1. Generates the Objective-C compatible Swift bridge and the `<input_name>_ffigen_config.dart` script in `tool/pigeon/`.
  2. Runs `ffigen` via the config script to parse the Objective-C bridge and produce Dart FFI bindings.
  3. Generates the final pigeon Dart output that wraps and imports those FFI bindings.

### Step 4: iOS/macOS Build System Configuration (FFI)

Because Dart FFI cannot directly call Swift symbols, the FFI toolchain generates intermediate Objective-C bridging files in a subdirectory named `<swift_output_dir>_objc_gen`:
- **`.h` (Headers)**: Always generated to declare module interfaces and types.
- **`.m` (Bridging Implementation)**: Generated when the schema contains callbacks, closures, Flutter APIs, or Objective-C blocks requiring trampoline implementations.
- **`.o` (Temporary Object Files)**: Intermediate binary files generated during `ffigen`/`swiftgen` AST extraction. These are **not** needed after code generation and must **not** be committed to version control.

To compile the generated Objective-C files alongside your Swift code, you must configure your iOS/macOS build systems:

#### CocoaPods Configuration
Ensure your `.podspec` file matches Swift, Objective-C implementations (`.m`), and headers (`.h`):
```ruby
s.source_files = 'Sources/**/*.{swift,m,h}'
```
This allows CocoaPods to automatically compile the generated Objective-C bridging files into the framework.

#### Swift Package Manager (SwiftPM) Configuration
**Only if a `.m` file is generated** in `<swift_output_dir>_objc_gen`, you must configure a separate Objective-C target in your `Package.swift` file. Because Swift and Objective-C files cannot reside within the same SwiftPM target, define two separate targets:
1. An Objective-C target for the generated bridge files (e.g., `my_plugin_objc_gen`).
2. The main Swift target that depends on the Objective-C target.

> **Important:** If your Pigeon schema only uses synchronous `@HostApi()` methods (and does not generate a `.m` file in `<swift_output_dir>_objc_gen`), **do not** add the `<plugin_name>_objc_gen` target to `Package.swift`. SwiftPM requires every `.target` to contain at least one compilable source file (`.m`, `.c`, or `.swift`). Declaring a `<plugin_name>_objc_gen` target when the directory only contains a `.h` header (or temporary `.o` file) will cause Xcode builds to fail with:
> `Build input file cannot be found: '.../<plugin_name>_objc_gen.o'`

Example configuration (when `<plugin_name>_objc_gen` contains a generated `.m` file):
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

#### Standalone Applications & Example Apps

When implementing Native Interop host APIs directly in an application target rather than a plugin package:

* **Swift Module Name Configuration (`ffiModuleName`)**:
  Swift namespaces `@objc` classes with the module name (`<module>.<class>`). Set `ffiModuleName` in `SwiftOptions` to match your application's Swift module name (which defaults to `'Runner'`).

  If iOS and macOS share the same generated Dart FFI file, both platforms must compile under that same module name. Because Flutter's macOS template defaults to using the app name instead of `Runner`, you can unify them by setting `PRODUCT_MODULE_NAME` in `macos/Runner/Configs/AppInfo.xcconfig` to match `ffiModuleName`:
  ```xcconfig
  PRODUCT_MODULE_NAME = Runner // or your custom ffiModuleName
  ```
  *(Note: If iOS and macOS use separate Pigeon generation outputs or you only target one platform, unifying module names between platforms is not required.)*

* **Native Registration in macOS (`MainFlutterWindow.swift`)**:
  While iOS registers the host implementation in `AppDelegate.swift` within `didInitializeImplicitFlutterEngine`, macOS applications should register it in `MainFlutterWindow.swift` within `awakeFromNib()`:
  ```swift
  RegisterGeneratedPlugins(registry: flutterViewController)

  let api = PigeonApiImplementation()
  MyApiSetup.register(api: api)
  ```
  Calling `register(api:)` in native code also prevents the Xcode linker (`-dead_strip`) from stripping the setup class from the compiled binary.

### Step 5: Android Release Build Configuration (JNI)

<!-- TODO(tarrinneal): Remove this section once package:jni ships these keep rules: https://github.com/dart-lang/native/issues/3732 -->

Flutter enables R8 for Android release builds by default. R8 removes, renames, and merges classes and members that it doesn't see being used. JNI looks up classes and members by name at runtime, so everything that JNI reaches must keep its original name.

Pigeon adds `@Keep` to every generated Kotlin class that the generated Dart code reaches through JNI, so the generated code needs no extra rules. However, `package:jni` and the generated Dart code also look up several Kotlin standard library classes by name to call Kotlin `suspend` functions (`@async` methods) and to implement them from Dart. Library classes can't be annotated, so until `package:jni` includes rules for these classes, you must add them yourself:

```text
# Kotlin classes that package:jni and the generated Dart code look up by name.
-keep class kotlin.Unit { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep class kotlin.coroutines.Continuation { *; }
-keep class kotlin.coroutines.intrinsics.CoroutineSingletons { *; }
-keep class kotlin.coroutines.intrinsics.IntrinsicsKt { *; }
```

* **Plugins**: Add the rules to a file in the plugin's `android/` directory, such as `consumer-rules.pro`, and list it in `consumerProguardFiles` in the plugin's `android/build.gradle` or `android/build.gradle.kts`. R8 then applies the rules to every application that uses the plugin:
  ```gradle
  android {
      defaultConfig {
          consumerProguardFiles("consumer-rules.pro")
      }
  }
  ```
* **Applications**: Add the rules to `android/app/proguard-rules.pro`. Flutter applies this file to release builds when it exists.

Debug and profile builds are not minified, so test a release build (for example, with `flutter run --release`) to verify the configuration.

---

## 5. Troubleshooting Automated Generation

If `dart run pigeon` or your platform build encounters errors, review the following troubleshooting steps:

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

Pigeon writes the interop configuration scripts to `tool/pigeon/<input_name>_jnigen_config.dart` and `tool/pigeon/<input_name>_ffigen_config.dart`.

- **Solution**: Run the generated config scripts directly to view verbose stderr logs and diagnose toolchain errors:
  ```bash
  # Debug JNIgen (Android):
  dart run tool/pigeon/<input_name>_jnigen_config.dart

  # Debug FFIgen (iOS/macOS):
  dart run tool/pigeon/<input_name>_ffigen_config.dart
  ```

### 5.4 Failed to Load Objective-C Class (`<ffiModuleName>.<Api>Setup`)

If your app crashes at startup with `FailedToLoadClassException: Failed to load Objective-C class`:
- **Module Name Mismatch**: Ensure `ffiModuleName` matches your app's Swift module name. If iOS and macOS share the same generated Dart FFI file, ensure both platforms use the same module name (e.g., align macOS by setting `PRODUCT_MODULE_NAME` in `macos/Runner/Configs/AppInfo.xcconfig`).
- **Linker Dead-Code Stripping**: Ensure your native host code instantiates and registers the implementation (e.g. `MyApiSetup.register(api: api)` in `MainFlutterWindow.swift` on macOS or `AppDelegate.swift` on iOS) so the linker does not strip the class.

### 5.5 Startup Crash on Android (`VmServiceDisappearedException` / `JNI is not initialized`)

If your app or integration test crashes at startup on Android with `adb logcat` showing:
```text
F DartJNI : JNI is not initialized. Are you trying to invoke a Java API from Dart code too early, before 'main()' (such as during Dart plugin class registration)?
```
- **Cause**: Your plugin's `registerWith()` method (invoked by Flutter's `_PluginRegistrant.register()` before `main()`) constructed your Dart plugin class, and its constructor eagerly called `<MyApi>.createWithNativeInteropApi()` before `JniPlugin` initialized `DartJNI`.
- **Solution**: Initialize `<MyApi>.createWithNativeInteropApi()` lazily using `late final` rather than eagerly in the constructor initializer list (see [Section 4 of the Migration Guide](./native_interop_migration_guide.md#4-dart-client-adaptation)).

### 5.6 Xcode Error: `Build input file cannot be found: '.../<plugin_name>_objc_gen.o'`

If an iOS or macOS SwiftPM build fails because `<plugin_name>_objc_gen.o` cannot be found:
- **Cause**: `Package.swift` defines a `<plugin_name>_objc_gen` target, but `ffigen` did not generate a `.m` implementation file in `Sources/<plugin_name>_objc_gen/` (because the Pigeon schema has no async callbacks, closures, or `@FlutterApi` methods requiring Objective-C trampolines). Without a `.m` source file, SwiftPM does not produce an object file for the target. (Note: any `.o` file produced inside `Sources/<plugin_name>_objc_gen/` during `ffigen` execution is a temporary `swiftc` artifact and must not be committed or used.)
- **Solution**: Remove the `<plugin_name>_objc_gen` target and its dependency entry from `Package.swift`.

### 5.7 `ClassNotFoundException` or `NoSuchMethodError` in Android Release Builds (JNI)

If native interop calls work in debug builds but fail in release builds with `java.lang.ClassNotFoundException` or `java.lang.NoSuchMethodError`:
- **Cause**: R8 removed or renamed a class or member that JNI looks up by name.
- **Solution**:
  - If the error names a class generated by Pigeon, regenerate your Pigeon output with Pigeon 29.0.7 or later, which adds `@Keep` to every generated class that JNI reaches.
  - If the error names a class in the `kotlin` package (for example, `kotlin/coroutines/Continuation` in the signature of a `suspend` method), add the keep rules from [Step 5](#step-5-android-release-build-configuration-jni). <!-- TODO(tarrinneal): Remove this bullet once package:jni ships these keep rules: https://github.com/dart-lang/native/issues/3732 -->
  - To see what R8 removed or renamed, check `build/app/outputs/mapping/release/mapping.txt` in the application directory.

---

## 6. Migration from Platform Channels

If you are migrating an existing Pigeon plugin from the platform-channel-based model to the Native Interop model, see the [Native Interop Migration Guide](./native_interop_migration_guide.md) for a complete comparison of the API models and transition examples.
