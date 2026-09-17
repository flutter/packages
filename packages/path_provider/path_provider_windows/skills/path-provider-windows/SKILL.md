---
name: path-provider-windows
description: Set up and configure path_provider_windows, the Windows desktop implementation of Flutter's path_provider plugin. Covers endorsed usage, Windows Known Folders (SHGetKnownFolderPath), VERSIONINFO subdirectory naming, and querying arbitrary WindowsKnownFolder GUIDs.
---

# Setting Up and Using path_provider_windows

`path_provider_windows` is the endorsed Windows desktop implementation of the Flutter [`path_provider`](https://pub.dev/packages/path_provider) plugin. It uses Dart FFI to call Win32 Shell APIs (`SHGetKnownFolderPath` and `GetTempPath`) directly.

## 1. Installation and Setup

Because `path_provider_windows` is an endorsed federated plugin implementation, adding `path_provider` to your `pubspec.yaml` automatically includes it on Windows:

```yaml
dependencies:
  path_provider: ^2.1.6
```

If you want to query Windows-specific Known Folders directly via `WindowsKnownFolder`, add `path_provider_windows` to your `pubspec.yaml`:

```yaml
dependencies:
  path_provider: ^2.1.6
  path_provider_windows: ^2.3.0
```

## 2. Windows Known Folder Mappings and Subdirectory Rules

### Directory Mappings

| Flutter Function | Win32 API / Known Folder ID |
| :--- | :--- |
| `getTemporaryDirectory()` | `GetTempPath()` (typically `%TEMP%`) |
| `getApplicationSupportDirectory()` | `FOLDERID_RoamingAppData\<Company>\<Product>` (`%APPDATA%\...`) |
| `getApplicationCacheDirectory()` | `FOLDERID_LocalAppData\<Company>\<Product>` (`%LOCALAPPDATA%\...`) |
| `getApplicationDocumentsDirectory()` | `FOLDERID_Documents` (`%USERPROFILE%\Documents`) |
| `getDownloadsDirectory()` | `FOLDERID_Downloads` (`%USERPROFILE%\Downloads`) |

### Application Subdirectory Naming (`VERSIONINFO`)

For `getApplicationSupportDirectory()` and `getApplicationCacheDirectory()`, `path_provider_windows` automatically appends an application-specific subdirectory (`<CompanyName>\<ProductName>`) to prevent collisions in `%APPDATA%` and `%LOCALAPPDATA%`.

These values are read from your Windows executable's `VERSIONINFO` resource defined in `windows/runner/Runner.rc`:
- If `CompanyName` is present, it is used as the parent folder; otherwise it is omitted.
- If `ProductName` is present, it is used as the subfolder; otherwise the executable's filename (without `.exe`) is used.

## 3. Usage and API Examples

### Endorsed Usage via `path_provider`

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> getWindowsRoamingConfigFile() async {
  // Resolves to %APPDATA%\<CompanyName>\<ProductName>\config.json
  final Directory supportDir = await getApplicationSupportDirectory();
  return File('${supportDir.path}/config.json');
}
```

### Direct Usage: Querying Arbitrary Windows Known Folders

By importing `package:path_provider_windows/path_provider_windows.dart`, you can call `getPath(String folderID)` with any GUID constant defined in `WindowsKnownFolder` (such as `Pictures`, `Music`, `Videos`, `Public`, `ProgramData`, or `Desktop`):

```dart
import 'package:path_provider_windows/path_provider_windows.dart';

Future<void> printWindowsSpecialFolders() async {
  final PathProviderWindows provider = PathProviderWindows();

  final String? picturesPath = await provider.getPath(
    WindowsKnownFolder.Pictures,
  );
  final String? desktopPath = await provider.getPath(
    WindowsKnownFolder.Desktop,
  );

  print('Pictures folder: $picturesPath');
  print('Desktop folder: $desktopPath');
}
```
