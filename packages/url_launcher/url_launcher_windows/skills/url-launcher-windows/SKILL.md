---
name: url-launcher-windows
description: Set up and configure url_launcher_windows, the Windows desktop implementation of Flutter's url_launcher plugin. Covers endorsed usage, ShellExecuteW URL and file launching on Windows 10+, and direct platform registration.
---

# Setting Up and Using url_launcher_windows

`url_launcher_windows` is the endorsed Windows desktop implementation of the Flutter [`url_launcher`](https://pub.dev/packages/url_launcher) plugin. It uses the Win32 `ShellExecuteW` API to launch web URLs, `mailto:` links, custom application schemes, and local files on Windows 10 and higher.

## 1. Installation and Setup

Because `url_launcher_windows` is an endorsed federated plugin implementation, adding `url_launcher` to your `pubspec.yaml` automatically includes it on Windows builds:

```yaml
dependencies:
  url_launcher: ^6.3.2
```

If you need to depend on `url_launcher_windows` directly in your `pubspec.yaml`:

```yaml
dependencies:
  url_launcher: ^6.3.2
  url_launcher_windows: ^3.1.6
```

## 2. Platform-Specific Configuration

### Windows Handler Associations

On Windows, URLs and files are dispatched through the Windows Shell (`ShellExecuteW`). `canLaunchUrl` checks whether an application is registered in the Windows Registry to handle the specified URI scheme.

Windows desktop supports `LaunchMode.platformDefault` and `LaunchMode.externalApplication`. Requesting `LaunchMode.inAppWebView` or `LaunchMode.inAppBrowserView` will automatically fall back to opening the URL in the user's default Windows web browser.

## 3. Usage and API Examples

### Endorsed Usage via `url_launcher`

Use `package:url_launcher/url_launcher.dart` to open web pages, trigger email clients, or open local files/folders in Windows Explorer:

```dart
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchBrowserOnWindows() async {
  final Uri url = Uri.parse('https://flutter.dev');
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url on Windows');
  }
}

Future<void> openFileInWindowsDefaultApp(String filePath) async {
  final File file = File(filePath);
  if (!file.existsSync()) {
    throw Exception('File does not exist: $filePath');
  }
  final Uri fileUri = Uri.file(file.absolute.path);
  if (!await launchUrl(fileUri)) {
    throw Exception('Could not launch file $fileUri');
  }
}
```

### Direct Platform Registration and Usage

To explicitly register `UrlLauncherWindows` or invoke the platform implementation directly:

```dart
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_windows/url_launcher_windows.dart';

void registerWindowsLauncher() {
  UrlLauncherWindows.registerWith();
}

Future<void> launchDirectlyOnWindows() async {
  final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;
  if (await launcher.canLaunch('https://flutter.dev')) {
    await launcher.launchUrl('https://flutter.dev', const LaunchOptions());
  }
}
```
