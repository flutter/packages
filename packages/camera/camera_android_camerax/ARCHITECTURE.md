# Camera Android CameraX - Codebase Context

This document provides a high-level overview of the `camera_android_camerax` package, its architecture, domain vocabulary, and module map.

## 🗺️ Codebase Map & Modules

The core logic resides in the `lib/src` directory. Here is a map of the key modules:

### 1. Core Implementation
*   **[android_camera_camerax.dart](lib/src/android_camera_camerax.dart)**: This is the heart of the package. It contains the class `AndroidCameraCameraX`, which extends `CameraPlatform` from the `camera_platform_interface`. It implements all the standard camera operations (initialize, take picture, record video, etc.) by calling down to the Android native side using the CameraX wrappers.

### 2. CameraX Wrappers & Platform Channels
*   **[camerax_library.dart](lib/src/camerax_library.dart)**: This file acts as a bridge, likely containing or exposing the wrappers for the CameraX classes used in Dart. It heavily relies on generated code.
*   **`camerax_library.g.dart`**: This is the generated file (by Pigeon) that contains the specific platform channel messaging logic between Dart and Java.

### 3. Feature Specific Modules
*   **`image_reader_rotated_preview.dart`**, **`rotated_preview_delegate.dart`**, **`rotated_preview_utils.dart`**, **`surface_texture_rotated_preview.dart`**: These files handle a specific, complex problem on Android regarding camera preview rotation correction when the hardware doesn't automatically handle it.

---

## 📚 Domain Glossary

To understand how these modules interact, here is the vocabulary used across the project, heavily borrowed from the Android CameraX API:

*   **`CameraPlatform`**: The base interface from `camera_platform_interface` that this package implements to provide Android support.
*   **`ProcessCameraProvider`**: A singleton object used to bind the lifecycle of cameras to lifecycle owners (like an Activity). It manages camera instances.
*   **`UseCase`**: An abstraction representing a specific camera feature. You bind `UseCase`s to a camera. Key instances include:
    *   **`Preview`**: Provides a surface for viewing live camera frames.
    *   **`ImageCapture`**: Used for taking still photos.
    *   **`ImageAnalysis`**: Provides access to camera frames for processing (e.g., computer vision or image streaming).
    *   **`VideoCapture`**: Used for recording video.
*   **`Camera`** & **`CameraInfo`**: Represent the camera device and provide metadata about it (e.g., sensor rotation, physical location).
*   **`CameraControl`**: Used to modify camera settings actively (e.g., zoom, focus, exposure).
*   **`Pigeon`**: The code generation tool used to create type-safe platform channels.

---

## 📞 Callers

Who uses this package?

1.  **The `camera` plugin**: This is the most common caller. In a typical Flutter app, a user simply depends on the `camera` package. On Android, the `camera` package will automatically delegate work to this package if it's selected as the endorsed implementation.
2.  **Direct Imports**: Developers *can* directly import this package to access CameraX-specific APIs that may not be exposed by the generic `camera_platform_interface`.
