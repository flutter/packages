---
name: url-launcher-platform-interface
description: Implement or mock UrlLauncherPlatform using url_launcher_platform_interface. Covers extending UrlLauncherPlatform for new platform implementations, LaunchOptions, PreferredLaunchMode, and writing unit test mocks.
---

# Setting Up and Using url_launcher_platform_interface

`url_launcher_platform_interface` defines the common platform interface (`UrlLauncherPlatform`) for the [`url_launcher`](https://pub.dev/packages/url_launcher) federated plugin. All platform-specific implementations (`url_launcher_android`, `url_launcher_ios`, etc.) extend this interface.

## 1. Installation and Setup

To implement a custom platform plugin for `url_launcher` or mock the platform interface in tests, add `url_launcher_platform_interface` to your `pubspec.yaml`:

```yaml
dependencies:
  url_launcher_platform_interface: ^2.3.2
```

For unit testing your app or plugin, add `plugin_platform_interface`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  plugin_platform_interface: ^2.1.7
```

## 2. Platform Interface Architecture and Guidelines

When creating a platform implementation or mock:
- **Always `extends UrlLauncherPlatform`** rather than `implements UrlLauncherPlatform`. New methods added to `UrlLauncherPlatform` provide default implementations so existing subclasses do not break.
- If creating a test mock that uses `implements`, mix in `MockPlatformInterfaceMixin` from `package:plugin_platform_interface/plugin_platform_interface.dart` so `PlatformInterface.verify` succeeds when setting `UrlLauncherPlatform.instance`.

## 3. Usage and API Examples

### Implementing a Custom Platform Implementation

To create a new platform-specific implementation of `url_launcher`, extend `UrlLauncherPlatform` and register it via `UrlLauncherPlatform.instance`:

```dart
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class CustomPlatformUrlLauncher extends UrlLauncherPlatform {
  static void registerWith() {
    UrlLauncherPlatform.instance = CustomPlatformUrlLauncher();
  }

  @override
  final LinkDelegate? linkDelegate = null;

  @override
  Future<bool> canLaunch(String url) async {
    return url.startsWith('https://') || url.startsWith('http://');
  }

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    // Perform custom platform-specific launch logic here.
    return true;
  }

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async {
    return mode == PreferredLaunchMode.platformDefault ||
        mode == PreferredLaunchMode.externalApplication;
  }
}
```

### Mocking `UrlLauncherPlatform` in Unit Tests

When testing widgets or services that call `launchUrl` or `canLaunchUrl`, replace `UrlLauncherPlatform.instance` with a fake or mock implementation:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class FakeUrlLauncherPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  final List<String> launchedUrls = <String>[];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrls.add(url);
    return true;
  }

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async => true;
}

void main() {
  late FakeUrlLauncherPlatform fakePlatform;

  setUp(() {
    fakePlatform = FakeUrlLauncherPlatform();
    UrlLauncherPlatform.instance = fakePlatform;
  });

  test('launches expected URL', () async {
    final Uri target = Uri.parse('https://flutter.dev');
    final bool result = await launchUrl(target);

    expect(result, isTrue);
    expect(fakePlatform.launchedUrls, contains('https://flutter.dev'));
  });
}
```
