# Pigeon Native Interop (FFI & JNI) Guide

This guide describes the new Native Interop feature in Pigeon, which allows for direct communication between Dart and native code using **FFI (Foreign Function Interface)** for Swift and **JNI (Java Native Interface)** for Kotlin/Java, bypassing the traditional MethodChannel communication.

---

## 1. Overview

Native Interop provides a way to make synchronous or asynchronous calls between Dart and platform code without the overhead of standard Message Channels. Instead of serializing data to binary format and sending it over a channel, Pigeon now generates bridging code that uses Dart's native interop capabilities.

### Key Difference in Concurrency

An important architectural difference in Native Interop is the shift in how asynchronous methods are handled:
-   **Old Pigeon (MethodChannels)**: Async methods relied on callbacks passed as completion handlers.
-   **New Pigeon (Native Interop)**: Async methods leverage modern concurrency models:
    -   **Kotlin**: Uses **Kotlin Coroutines**.
    -   **Swift**: Uses **async/await** syntax.

---

## 2. Benefits, Drawbacks, and Use Cases

### Benefits
-   **High Performance**: Direct memory sharing and function calls avoid serialization and message channel machinery overhead.
-   **Direct Interaction**: Interact with native types directly in supported scenarios.

### Drawbacks
-   **Complex Setup**: Requires external tools like `jnigen` or `ffigen` which have their own prerequisites.
-   **Dual-step Generation**: Generating code requires running Pigeon first, and then running generated config scripts to produce the final bindings.
-   **Current Performance Regression**: There is currently a known performance regression on some complex classes with many fields relative to MethodChannel Pigeon. Sending complex classes frequently will cause a significant slowdown until this is resolved soon.

### Use Cases
-   Plugins handling large arrays, typed data, or frequent small messages where overhead is critical.
-   *Avoid frequent complex class transfers for now due to the current performance regression.*

---

## 3. Prerequisites for External Tools

To use the Native Interop feature, both your environment and the external tools must be properly configured.

### JNIgen (for Kotlin)
-   **Java 17 is specifically required**. JNIgen and parts of the Android ecosystem now rely on this specific version.
-   **Maven (`mvn`)**: Required for resolving target Java dependencies.
-   **Android SDK**: Must be installed and reachable.
-   The app must be buildable to allow JNIgen to resolve classpaths correctly.
-   **Kotlin Version**: The newest version supported is **2.1.0**.

### FFIgen (for Swift)
-   **LLVM (version 9+)**: Required to parse C/Objective-C headers.
    -   On **macOS**, LLVM is included by default with Xcode Command Line Tools.
-   **`package:ffi`** and **`package:ffigen`** dependencies must be added to your project.

---

## 4. How to Use

### Step 1: Pigeon Configuration

To enable Native Interop, configure the `PigeonOptions` in your Pigeon file:

```dart
@ConfigurePigeon(
  PigeonOptions(
    dartOptions: DartOptions(),
    kotlinOptions: KotlinOptions(useJni: true),
    swiftOptions: SwiftOptions(useFfi: true, ffiModuleName: 'my_plugin'),
  ),
)
```

### Step 2: The "Chicken-and-Egg" Build Workaround for JNI

Generating code with `useJni` requires resolving classpaths from a built app, but applying the generated Pigeon code may cause build failures before the JNI bindings have been created. This chicken-and-egg problem is easiest to deal with currently via this workaround:

1.  Undo the generation of the Dart code (comment out or revert).
2.  **Build your app** (e.g., `flutter build apk`) once so Android dependencies and classpaths can be resolved.
3.  Comment/revert the clean state back to use generation.
4.  Run `jnigen` to generate the JNI bindings.
5.  Run Pigeon to regenerate the final files.

### Step 3: Run the Config Scripts

Running Pigeon with these options enabled creates standard code files as well as intermediate config scripts (e.g., `jnigen_config.dart` or `ffigen_config.dart`).
Run these generated files to output the actual `.jni.dart` and `.ffi.dart` bindings:

```bash
# Example for Android
dart run lib/pigeons/jnigen_config.dart

# Example for iOS
dart run lib/pigeons/ffigen_config.dart
```

---

## 5. Migration Guide

Moving from a traditional MethodChannel plugin to Native Interop involves shifting from a callback mindset to a direct call and newer concurrency paradigm.

### Async Methods Comparison

#### Before: Method Channel (Callback Style)

```swift
// Swift
func echoAsync(_ value: String, completion: @escaping (Result<String, Error>) -> Void) {
  completion(.success(value))
}
```

#### After: Native Interop (Concurrency Style)

```swift
// Swift
func echoAsync(_ value: String) async throws -> String {
  return value
}
```

```kotlin
// Kotlin
suspend fun echoAsync(value: String): String {
  return value
}
```

In Dart, you will await the result directly as before, but the interaction with the native layer bypasses serialization overhead.
