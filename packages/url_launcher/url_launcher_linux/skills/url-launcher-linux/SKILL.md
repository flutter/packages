---
name: url-launcher-linux
description: Set up and configure url_launcher_linux, the Linux desktop implementation of Flutter's url_launcher plugin. Covers endorsed usage, desktop environment URL/file handling via GTK/xdg-open, and direct platform registration.
---

# Setting Up and Using url_launcher_linux

`url_launcher_linux` is the endorsed Linux desktop implementation of the Flutter [`url_launcher`](https://pub.dev/packages/url_launcher) plugin. It delegates URL and file launching to the host Linux desktop environment using GTK (`gtk_show_uri_on_window`).

## 1. Installation and Setup

Because `url_launcher_linux` is an endorsed federated plugin implementation, adding `url_launcher` to your `pubspec.yaml` automatically includes it on Linux builds:

```yaml
dependencies:
  url_launcher: ^6.3.2
```

If you need to depend on `url_launcher_linux` directly in your `pubspec.yaml`:

```yaml
dependencies:
  url_launcher: ^6.3.2
  url_launcher_linux: ^3.2.3
```

## 2. Platform-Specific Configuration

### Linux Desktop Environment Requirements

`url_launcher_linux` relies on GTK and standard desktop MIME/scheme associations (such as `xdg-utils` / `xdg-open` and registered desktop `.desktop` handlers) to open web URLs (`http:`, `https:`), emails (`mailto:`), and local files (`file:`).

Ensure the target Linux environment has a default web browser or handler configured for the schemes your app launches. In containerized or headless Linux environments without a desktop session or browser installed, `canLaunchUrl` and `launchUrl` will return `false`.

## 3. Usage and API Examples

### Endorsed Usage via `url_launcher`

Use `package:url_launcher/url_launcher.dart` for launching web links and local files on Linux. Note that Linux desktop only supports external application launching (`LaunchMode.externalApplication` / `LaunchMode.platformDefault`); in-app web view launch modes automatically fall back to opening the default external browser.

```dart
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

Future<void> openWebUrlOnLinux() async {
  final Uri url = Uri.parse('https://flutter.dev');
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

Future<void> openLocalLinuxDirectory(String dirPath) async {
  final Directory dir = Directory(dirPath);
  if (!dir.existsSync()) {
    throw Exception('Directory does not exist: $dirPath');
  }
  final Uri dirUri = Uri.directory(dir.absolute.path);
  if (!await launchUrl(dirUri)) {
    throw Exception('Could not open directory $dirUri');
  }
}
```

### Direct Platform Registration and Usage

To register `UrlLauncherLinux` explicitly or invoke the platform implementation directly:

```dart
import 'package:url_launcher_linux/url_launcher_linux.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void registerLinuxLauncher() {
  UrlLauncherLinux.registerWith();
}

Future<void> checkAndLaunchLinuxUrl() async {
  final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;
  if (await launcher.canLaunch('https://flutter.dev')) {
    await launcher.launchUrl('https://flutter.dev', const LaunchOptions());
  }
}
```
