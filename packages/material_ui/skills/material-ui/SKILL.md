---
name: material-ui
description: Set up, migrate to, and use the standalone material_ui package for building Google Material Design 3 user interfaces in Flutter.
---

# Setting Up and Using material_ui

The `material_ui` package is Flutter's official Material Design library (`package:material_ui/material_ui.dart`), implementing Google's Material Design 3 system. It provides a comprehensive suite of visual components, adaptive layouts, dynamic color schemes, typography, motion easing curves, and theming tools.

## 1. Installation

Add `material_ui` to your project's `pubspec.yaml`:

```bash
flutter pub add material_ui
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  material_ui: ^1.2.0
```

## 2. Migration and Compatibility Configuration

`material_ui` was decoupled from `package:flutter/material.dart` into a standalone package.

### Automated Migration
Run the Dart fix command to automatically migrate imports from `package:flutter/material.dart` to `package:material_ui/material_ui.dart`:

```bash
dart fix --apply --code=migrate_design_widgets
```

### Localizations
Use `GlobalMaterialLocalizations.delegates` from `package:material_ui/material_ui.dart`:

```dart
MaterialApp(
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: const HomeScreen(),
);
```

### Bridging Legacy Packages (`MaterialUiCompatibilityBridge`)
If your application uses third-party widgets that still import `package:flutter/material.dart`, wrap your app or subtree in `MaterialUiCompatibilityBridge` so legacy widgets properly resolve `ThemeData` and `MaterialLocalizations`:

```dart
import 'package:material_ui/material_ui.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      builder: (BuildContext context, Widget? child) {
        return MaterialUiCompatibilityBridge(child: child!);
      },
      home: const HomeScreen(),
    );
  }
}
```

## 3. Usage and API Examples

### Material 3 App Scaffold with NavigationBar and Cards

```dart
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MyMaterialApp());
}

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material 3 App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Welcome to Material UI',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8.0),
                  const Text('Build accessible, modern apps across all platforms.'),
                  const SizedBox(height: 16.0),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Action triggered!')),
                      );
                    },
                    icon: const Icon(Icons.explore),
                    label: const Text('Get Started'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Stats'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
```
