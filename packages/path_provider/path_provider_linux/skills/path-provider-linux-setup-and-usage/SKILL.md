---
name: path-provider-linux-setup-and-usage
description: Set up and configure path_provider_linux, the Linux desktop implementation of Flutter's path_provider plugin. Covers endorsed usage, XDG Base Directory environment variables, application ID resolution, and direct registration.
---

# Setting Up and Using path_provider_linux

`path_provider_linux` is the endorsed Linux desktop implementation of the Flutter [`path_provider`](https://pub.dev/packages/path_provider) plugin. It resolves filesystem paths according to the Freedesktop.org XDG Base Directory Specification.

## 1. Installation and Setup

Because `path_provider_linux` is an endorsed federated plugin implementation, adding `path_provider` to your `pubspec.yaml` automatically includes it on Linux:

```yaml
dependencies:
  path_provider: ^2.1.6
```

If you need to depend on `path_provider_linux` directly in your `pubspec.yaml`:

```yaml
dependencies:
  path_provider: ^2.1.6
  path_provider_linux: ^2.2.2
```

## 2. Linux XDG Directory Mappings and Configuration

`path_provider_linux` resolves paths using standard environment variables and XDG user directories:

| Flutter Function | Linux Path Resolution |
| :--- | :--- |
| `getTemporaryDirectory()` | `$TMPDIR` environment variable, falling back to `/tmp` |
| `getApplicationCacheDirectory()` | `$XDG_CACHE_HOME/<app_id>` (defaults to `~/.cache/<app_id>`) |
| `getApplicationSupportDirectory()` | `$XDG_DATA_HOME/<app_id>` (defaults to `~/.local/share/<app_id>`) |
| `getApplicationDocumentsDirectory()` | `xdg-user-dir DOCUMENTS` (defaults to `~/Documents`) |
| `getDownloadsDirectory()` | `xdg-user-dir DOWNLOAD` (defaults to `~/Downloads`) |

### Application ID Resolution (`<app_id>`)

For application-scoped directories (`getApplicationSupportDirectory` and `getApplicationCacheDirectory`), `<app_id>` is determined from your GTK `GApplication` application ID (configured in `linux/my_application.cc` via `g_application_set_application_id`). If no application ID is set on the GTK application, the executable binary name is used as a fallback.

### External and Library Directories

`getLibraryDirectory()`, `getExternalStorageDirectory()`, `getExternalCacheDirectories()`, and `getExternalStorageDirectories()` are not supported on Linux and throw an `UnsupportedError`.

## 3. Usage and API Examples

### Endorsed Usage via `path_provider`

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> getLinuxAppConfigFile() async {
  // Resolves to ~/.local/share/<application_id>/config.yaml
  final Directory supportDir = await getApplicationSupportDirectory();
  return File('${supportDir.path}/config.yaml');
}
```

### Direct Platform Registration and Usage

To explicitly register `PathProviderLinux` or invoke the Linux platform implementation directly:

```dart
import 'package:path_provider_linux/path_provider_linux.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

void registerLinuxPathProvider() {
  PathProviderLinux.registerWith();
}

Future<String?> queryLinuxSupportPathDirectly() async {
  final PathProviderPlatform platform = PathProviderPlatform.instance;
  return platform.getApplicationSupportPath();
}
```
