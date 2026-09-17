---
name: url-launcher-macos-setup-and-usage
description: Set up and configure url_launcher_macos, the macOS implementation of Flutter's url_launcher plugin. Covers endorsed usage, macOS App Sandbox entitlements for file access, NSWorkspace URL launching, and direct registration.
---

# Setting Up and Using url_launcher_macos

`url_launcher_macos` is the endorsed macOS desktop implementation of the Flutter [`url_launcher`](https://pub.dev/packages/url_launcher) plugin. It uses `NSWorkspace.shared.open` and `NSWorkspace.shared.urlForApplication` to open web URLs, emails, and files on macOS.

## 1. Installation and Setup

Because `url_launcher_macos` is an endorsed federated plugin implementation, adding `url_launcher` to your `pubspec.yaml` automatically includes it on macOS:

```yaml
dependencies:
  url_launcher: ^6.3.2
```

If you need to depend on `url_launcher_macos` directly in your `pubspec.yaml`:

```yaml
dependencies:
  url_launcher: ^6.3.2
  url_launcher_macos: ^3.2.6
```

## 2. Platform-Specific Configuration

### macOS Sandbox Entitlements (`macos/Runner/*.entitlements`)

macOS applications are sandboxed by default. Opening standard web URLs (`http:`, `https:`) or `mailto:` links in external applications via `NSWorkspace` works out of the box without additional entitlements.

However, if your macOS app uses `launchUrl` with `file:` URLs to open files or directories located outside of the application's sandbox container, you must configure appropriate file access entitlements in `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<!-- For read-only access to user-selected files -->
<key>com.apple.security.files.user-selected.read-only</key>
<true/>

<!-- Or for read-write access to user-selected files -->
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

## 3. Usage and API Examples

### Endorsed Usage via `url_launcher`

Use `package:url_launcher/url_launcher.dart` in your application code. On macOS, URLs are opened in the default external application (such as Safari for web links or Finder/Preview for local files):

```dart
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchWebUrlOnMacOS() async {
  final Uri url = Uri.parse('https://flutter.dev');
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url on macOS');
  }
}

Future<void> revealFileOnMacOS(String path) async {
  final File file = File(path);
  if (!file.existsSync()) {
    throw Exception('File not found: $path');
  }
  final Uri fileUri = Uri.file(file.absolute.path);
  if (!await launchUrl(fileUri)) {
    throw Exception('Could not open file $fileUri');
  }
}
```

### Direct Platform Registration and Usage

To explicitly register `UrlLauncherMacOS` or call methods on the platform implementation directly:

```dart
import 'package:url_launcher_macos/url_launcher_macos.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void registerMacOSLauncher() {
  UrlLauncherMacOS.registerWith();
}

Future<void> launchViaPlatformInterface() async {
  final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;
  if (await launcher.canLaunch('https://flutter.dev')) {
    await launcher.launchUrl('https://flutter.dev', const LaunchOptions());
  }
}
```
