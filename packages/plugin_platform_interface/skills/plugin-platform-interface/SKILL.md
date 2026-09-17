---
name: plugin-platform-interface
description: Set up and use plugin_platform_interface to create base platform interface classes for federated Flutter plugins and mock them in tests.
---

# Setting Up and Using plugin_platform_interface

The `plugin_platform_interface` package provides the `PlatformInterface` base class for federated Flutter plugins. It enforces that platform-specific implementations `extend` the platform interface class rather than `implement` it, ensuring that adding new methods with default implementations to a platform interface does not break existing platform implementations.

## 1. Installation

Add `plugin_platform_interface` to your platform interface package's `pubspec.yaml`:

```bash
flutter pub add plugin_platform_interface
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  plugin_platform_interface: ^2.1.8
```

## 2. Usage and API Examples

### Defining a Federated Plugin Platform Interface

Create an abstract class that extends `PlatformInterface`. Pass a private static `Object _token` to the super constructor and call `PlatformInterface.verify(instance, _token)` inside the static `instance` setter:

```dart
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class BatteryPluginPlatform extends PlatformInterface {
  /// Constructs a BatteryPluginPlatform.
  BatteryPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static BatteryPluginPlatform _instance = MethodChannelBatteryPlugin();

  /// The default instance of [BatteryPluginPlatform] to use.
  static BatteryPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BatteryPluginPlatform] when
  /// they register themselves.
  static set instance(BatteryPluginPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Returns the current battery level as a percentage (0 to 100).
  Future<int> getBatteryLevel() {
    throw UnimplementedError('getBatteryLevel() has not been implemented.');
  }
}

/// Default implementation using a MethodChannel.
class MethodChannelBatteryPlugin extends BatteryPluginPlatform {
  @override
  Future<int> getBatteryLevel() async {
    return 100;
  }
}
```

### Mocking or Faking Platform Interfaces in Unit Tests

Because `PlatformInterface.verify` rejects classes that use `implements`, test mocks created with `mockito` or `test`'s `Fake` must mix in `MockPlatformInterfaceMixin` to bypass the `extends` check during testing:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBatteryPluginPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements BatteryPluginPlatform {
  @override
  Future<int> getBatteryLevel() => Future<int>.value(85);
}

void main() {
  test('Can set mock instance with MockPlatformInterfaceMixin', () async {
    final MockBatteryPluginPlatform mockPlatform = MockBatteryPluginPlatform();
    BatteryPluginPlatform.instance = mockPlatform;

    expect(await BatteryPluginPlatform.instance.getBatteryLevel(), 85);
  });
}
```
