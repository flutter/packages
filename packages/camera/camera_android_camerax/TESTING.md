# Testing Best Practices

This document outlines testing rules and best practices for the `camera_android_camerax` package. All contributors MUST follow these guidelines to prevent CI flakiness and maintain code quality.

## General Guidelines

- **No Magic Numbers in Assertions**: Avoid unexplained numeric literals in `expect()` (e.g., `equals(5.0)`). Use variables derived from test inputs (e.g., `final expectedOffset = index * stepSize;`) or add a brief comment explaining the calculation.

## Integration Tests

- **Video Recording Delay**: You MUST add a delay of at least 4 seconds (e.g., `await Future<void>.delayed(const Duration(seconds: 4));`) before stopping a video recording. 
  - *Why*: Both physical Android devices and emulators require time for the CameraX encoder to initialize and capture actual video frames. Stopping immediately will result in an empty or corrupted file, causing CI flakes.
  - *Example*: See the `video recording state is cleared after camera is disposed` test in [`example/integration_test/integration_test.dart`](example/integration_test/integration_test.dart).
