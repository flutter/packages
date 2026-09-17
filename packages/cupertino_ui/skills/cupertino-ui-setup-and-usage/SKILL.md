---
name: cupertino-ui-setup-and-usage
description: Set up, migrate to, and use the standalone cupertino_ui package for building iOS and macOS style user interfaces in Flutter following Apple's Human Interface Guidelines.
---

# Setting Up and Using cupertino_ui

The `cupertino_ui` package is Flutter's official Cupertino design library, implementing Apple's Human Interface Guidelines for iOS and macOS applications. It provides high-fidelity visual components, navigation scaffolds, pickers, dialogs, typography, dynamic colors, and theming tools.

## 1. Installation

Add `cupertino_ui` to your project's `pubspec.yaml`:

```bash
flutter pub add cupertino_ui
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  cupertino_ui: ^1.0.1
```

## 2. Migration and Compatibility Configuration

`cupertino_ui` was decoupled from `package:flutter/cupertino.dart` into a standalone package.

### Automated Migration
Run the Dart fix command to automatically migrate imports from `package:flutter/cupertino.dart` to `package:cupertino_ui/cupertino_ui.dart`:

```bash
dart fix --apply --code=migrate_design_widgets
```

### Localizations
Use `GlobalCupertinoLocalizations` from `package:cupertino_ui/cupertino_ui.dart` rather than from `flutter_localizations`.

### Bridging Legacy Packages (`CupertinoUiCompatibilityBridge`)
If your application includes third-party widgets or subtrees that still import `package:flutter/cupertino.dart`, wrap your app or subtree in `CupertinoUiCompatibilityBridge` so legacy widgets inherit `CupertinoThemeData` and `CupertinoLocalizations`:

```dart
import 'package:cupertino_ui/cupertino_ui.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
      ),
      builder: (BuildContext context, Widget? child) {
        return CupertinoUiCompatibilityBridge(child: child!);
      },
      home: const HomeScreen(),
    );
  }
}
```

## 3. Usage and API Examples

### Basic App Structure with Navigation and Lists

```dart
import 'package:cupertino_ui/cupertino_ui.dart';

void main() {
  runApp(const MyCupertinoApp());
}

class MyCupertinoApp extends StatelessWidget {
  const MyCupertinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Cupertino Demo',
      home: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  void _showConfirmationDialog(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              setState(() => _notificationsEnabled = false);
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: ListView(
          children: <Widget>[
            CupertinoListSection.insetGrouped(
              header: const Text('PREFERENCES'),
              children: <Widget>[
                CupertinoListTile(
                  title: const Text('Enable Notifications'),
                  trailing: CupertinoSwitch(
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                ),
                CupertinoListTile(
                  title: const Text('Account Details'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () {},
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CupertinoButton.filled(
                onPressed: () => _showConfirmationDialog(context),
                child: const Text('Reset Defaults'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```
