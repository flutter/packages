---
name: path-provider-platform-interface-setup-and-usage
description: Implement or mock PathProviderPlatform using path_provider_platform_interface. Covers extending PathProviderPlatform for new platform implementations, StorageDirectory enums, and writing unit test fakes and mocks.
---

# Setting Up and Using path_provider_platform_interface

`path_provider_platform_interface` defines the common platform interface (`PathProviderPlatform`) and shared types (`StorageDirectory`) for the [`path_provider`](https://pub.dev/packages/path_provider) federated plugin.

## 1. Installation and Setup

To implement a custom platform implementation of `path_provider` or mock the interface in unit tests, add `path_provider_platform_interface` to your `pubspec.yaml`:

```yaml
dependencies:
  path_provider_platform_interface: ^2.1.3
```

For unit tests that mock or fake `PathProviderPlatform`, also include `plugin_platform_interface`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  plugin_platform_interface: ^2.1.7
```

## 2. Architecture and Implementation Guidelines

- **Extend, Do Not Implement**: When creating a platform implementation, always use `extends PathProviderPlatform` rather than `implements PathProviderPlatform`. Adding new methods to `PathProviderPlatform` is considered a non-breaking change because base methods provide default `UnimplementedError` implementations.
- **Test Fakes / Mocks**: When writing test doubles using `implements PathProviderPlatform` (e.g., via `Fake` or `Mock`), always mix in `MockPlatformInterfaceMixin` so `PlatformInterface.verify` allows setting `PathProviderPlatform.instance`.

## 3. Usage and API Examples

### Implementing a Custom Platform Implementation

To create a platform-specific implementation of `path_provider`:

```dart
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class CustomPathProvider extends PathProviderPlatform {
  static void registerWith() {
    PathProviderPlatform.instance = CustomPathProvider();
  }

  @override
  Future<String?> getTemporaryPath() async => '/custom/tmp';

  @override
  Future<String?> getApplicationSupportPath() async => '/custom/app_support';

  @override
  Future<String?> getApplicationDocumentsPath() async => '/custom/documents';

  @override
  Future<String?> getApplicationCachePath() async => '/custom/cache';

  @override
  Future<String?> getDownloadsPath() async => '/custom/downloads';
}
```

### Mocking `PathProviderPlatform` in Unit Tests

Because modern `path_provider` implementations use FFI or JNI rather than a shared MethodChannel, unit tests for code that calls `getApplicationDocumentsDirectory()` or other `path_provider` functions must override `PathProviderPlatform.instance`:

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  FakePathProviderPlatform(this.rootDir);

  final String rootDir;

  @override
  Future<String?> getTemporaryPath() async => '$rootDir/temp';

  @override
  Future<String?> getApplicationSupportPath() async => '$rootDir/support';

  @override
  Future<String?> getApplicationDocumentsPath() async => '$rootDir/documents';

  @override
  Future<String?> getApplicationCachePath() async => '$rootDir/cache';

  @override
  Future<String?> getDownloadsPath() async => '$rootDir/downloads';
}

void main() {
  late Directory tempSandbox;

  setUp(() async {
    tempSandbox = await Directory.systemTemp.createTemp('path_provider_test_');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempSandbox.path);
  });

  tearDown(() async {
    if (tempSandbox.existsSync()) {
      await tempSandbox.delete(recursive: true);
    }
  });

  test('writes file into mocked application support directory', () async {
    final Directory dir = await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    final File testFile = File('${dir.path}/data.txt');
    await testFile.writeAsString('hello world');

    expect(testFile.existsSync(), isTrue);
    expect(await testFile.readAsString(), equals('hello world'));
  });
}
```
