---
name: shared-preferences-platform-interface-setup-and-usage
description: Implement or mock platform interfaces for Flutter's shared_preferences plugin using SharedPreferencesAsyncPlatform and SharedPreferencesStorePlatform.
---

# Setting Up and Using shared_preferences_platform_interface

`shared_preferences_platform_interface` defines the common platform interfaces (`SharedPreferencesAsyncPlatform` and `SharedPreferencesStorePlatform`) and option/filter types for the [`shared_preferences`](https://pub.dev/packages/shared_preferences) federated plugin family.

## 1. Installation and Setup

Plugin authors implementing a new platform backend or developers writing custom platform mocks should add `shared_preferences_platform_interface` to `pubspec.yaml`:

```yaml
dependencies:
  shared_preferences_platform_interface: ^2.4.0
```

## 2. Platform Interface Architecture

The package provides two primary platform interfaces:
- **`SharedPreferencesAsyncPlatform`**: The modern async interface backing both `SharedPreferencesAsync` and `SharedPreferencesWithCache`. Supports `SharedPreferencesOptions`, `GetPreferencesParameters`, and `ClearPreferencesParameters`.
- **`SharedPreferencesStorePlatform`**: The legacy store interface backing `SharedPreferences.getInstance()`. Includes `InMemorySharedPreferencesStore.empty()` for testing.

When registering a platform plugin implementation, set both `SharedPreferencesAsyncPlatform.instance` and `SharedPreferencesStorePlatform.instance` if supporting both APIs.

## 3. Usage and API Examples

### Implementing `SharedPreferencesAsyncPlatform`

```dart
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

base class CustomSharedPreferencesAsyncPlatform
    extends SharedPreferencesAsyncPlatform {
  final Map<String, Object> _storage = <String, Object>{};

  static void registerWith() {
    SharedPreferencesAsyncPlatform.instance =
        CustomSharedPreferencesAsyncPlatform();
  }

  @override
  Future<void> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) async {
    _storage[key] = value;
  }

  @override
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _storage[key] as String?;
  }

  @override
  Future<void> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) async {
    _storage[key] = value;
  }

  @override
  Future<bool?> getBool(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _storage[key] as bool?;
  }

  @override
  Future<void> setDouble(
    String key,
    double value,
    SharedPreferencesOptions options,
  ) async {
    _storage[key] = value;
  }

  @override
  Future<double?> getDouble(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _storage[key] as double?;
  }

  @override
  Future<void> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) async {
    _storage[key] = value;
  }

  @override
  Future<int?> getInt(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _storage[key] as int?;
  }

  @override
  Future<void> setStringList(
    String key,
    List<String> value,
    SharedPreferencesOptions options,
  ) async {
    _storage[key] = value;
  }

  @override
  Future<List<String>?> getStringList(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return (_storage[key] as List<Object?>?)?.cast<String>().toList();
  }

  @override
  Future<void> clear(
    ClearPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final Set<String>? allowList = parameters.filter.allowList;
    if (allowList == null) {
      _storage.clear();
    } else {
      _storage.removeWhere((String k, _) => allowList.contains(k));
    }
  }

  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final Set<String>? allowList = parameters.filter.allowList;
    final Map<String, Object> result = Map<String, Object>.from(_storage);
    if (allowList != null) {
      result.removeWhere((String k, _) => !allowList.contains(k));
    }
    return result;
  }

  @override
  Future<Set<String>> getKeys(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    return (await getPreferences(parameters, options)).keys.toSet();
  }
}
```
