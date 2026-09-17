---
name: xdg-directories
description: Set up and use the xdg_directories package to read XDG Base Directory and user directory configuration on Linux systems.
---

# Setting Up and Using xdg_directories

`xdg_directories` is a pure Dart package for reading XDG Base Directory and user directory configuration information on Linux desktop environments (following the freedesktop.org specification).

## 1. Installation

Add `xdg_directories` to your `pubspec.yaml`:

```yaml
dependencies:
  xdg_directories: ^1.1.0
```

## 2. Accessing XDG Base Directories

Import `package:xdg_directories/xdg_directories.dart` to access standard XDG paths:

- `dataHome`: Base directory for user-specific data files (`$XDG_DATA_HOME`, defaults to `~/.local/share`).
- `configHome`: Base directory for user-specific configuration files (`$XDG_CONFIG_HOME`, defaults to `~/.config`).
- `cacheHome`: Base directory for user-specific non-essential cached data (`$XDG_CACHE_HOME`, defaults to `~/.cache`).
- `runtimeDir`: Base directory for user-specific runtime files (`$XDG_RUNTIME_DIR`, nullable).
- `dataDirs`: Preference-ordered list of base directories for searching data files (`$XDG_DATA_DIRS`).
- `configDirs`: Preference-ordered list of base directories for searching config files (`$XDG_CONFIG_DIRS`).

```dart
import 'dart:io';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

void printXdgPaths() {
  final Directory configDir = xdg.configHome;
  final Directory dataDir = xdg.dataHome;
  final Directory cacheDir = xdg.cacheHome;

  stdout.writeln('Config Home: ${configDir.path}');
  stdout.writeln('Data Home: ${dataDir.path}');
  stdout.writeln('Cache Home: ${cacheDir.path}');
}
```

## 3. Reading XDG User Directories

Query user-defined directories (such as `DESKTOP`, `DOCUMENTS`, `DOWNLOAD`, `MUSIC`, `PICTURES`, `VIDEOS`) configured in `user-dirs.dirs`:

```dart
import 'dart:io';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

void readUserDirectories() {
  // List all configured user directory names
  final Set<String> names = xdg.getUserDirectoryNames();
  stdout.writeln('Configured user dirs: $names');

  // Look up a specific user directory (case-insensitive)
  final Directory? downloads = xdg.getUserDirectory('DOWNLOAD');
  if (downloads != null) {
    stdout.writeln('Downloads folder: ${downloads.path}');
  }
}
```
