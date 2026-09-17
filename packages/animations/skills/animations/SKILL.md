---
name: animations
description: Set up and use the animations package to add Material motion transitions (Container transform, Shared axis, Fade through, and Fade) to Flutter applications.
---

# Setting Up and Using animations

The `animations` package provides high-quality, pre-built Material motion transition patterns for Flutter applications:
- **Container transform**: Transitions between UI elements that include a container (e.g., a card or FAB expanding into a details page).
- **Shared axis**: Transitions between UI elements with a spatial or navigational relationship along the X, Y, or Z axis.
- **Fade through**: Transitions between UI elements that do not have a strong relationship (e.g., bottom navigation bar destinations).
- **Fade**: Transitions for UI elements entering or exiting within the screen bounds (e.g., dialogs, menus, snackbars).

## 1. Installation

Add `animations` to your project's `pubspec.yaml`:

```bash
flutter pub add animations
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  animations: ^3.0.0
```

## 2. Usage and API Examples

Import the package in your Dart code:

```dart
import 'package:animations/animations.dart';
```

### Container Transform (`OpenContainer`)

Use `OpenContainer` to seamlessly transition a small container widget (like a card, list tile, or Floating Action Button) into a full-screen details page when tapped:

```dart
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class ContainerTransformExample extends StatelessWidget {
  const ContainerTransformExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Container Transform')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: OpenContainer<bool>(
              transitionType: ContainerTransitionType.fade,
              transitionDuration: const Duration(milliseconds: 500),
              closedElevation: 2.0,
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              closedColor: Theme.of(context).colorScheme.surface,
              closedBuilder: (BuildContext context, VoidCallback openContainer) {
                return ListTile(
                  title: Text('Item $index'),
                  subtitle: const Text('Tap to expand'),
                  onTap: openContainer,
                );
              },
              openBuilder: (BuildContext context, VoidCallback closeContainer) {
                return DetailsPage(index: index, onClose: closeContainer);
              },
            ),
          );
        },
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key, required this.index, required this.onClose});

  final int index;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for Item $index'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
      ),
      body: Center(
        child: Text('Full details view for item $index'),
      ),
    );
  }
}
```

### Shared Axis (`PageTransitionSwitcher` & `SharedAxisTransition`)

Use `SharedAxisTransition` inside a `PageTransitionSwitcher` to animate between widgets that share a spatial or navigational relationship (e.g., onboarding steps along the X-axis, steppers along the Y-axis, or parent-child flows along the Z-axis):

```dart
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class SharedAxisExample extends StatefulWidget {
  const SharedAxisExample({super.key});

  @override
  State<SharedAxisExample> createState() => _SharedAxisExampleState();
}

class _SharedAxisExampleState extends State<SharedAxisExample> {
  int _currentStep = 0;
  bool _reverse = false;

  void _goToStep(int newStep) {
    setState(() {
      _reverse = newStep < _currentStep;
      _currentStep = newStep;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        reverse: _reverse,
        transitionBuilder: (
          Widget child,
          Animation<double> primaryAnimation,
          Animation<double> secondaryAnimation,
        ) {
          return SharedAxisTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentStep),
          child: Center(
            child: Text('Step $_currentStep'),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(
              onPressed: _currentStep > 0 ? () => _goToStep(_currentStep - 1) : null,
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: _currentStep < 2 ? () => _goToStep(_currentStep + 1) : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Fade Through (`FadeThroughTransition`)

Use `FadeThroughTransition` when switching between destinations without a strong spatial relationship, such as tabs in a `NavigationBar` or `BottomNavigationBar`:

```dart
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class FadeThroughTabsExample extends StatefulWidget {
  const FadeThroughTabsExample({super.key});

  @override
  State<FadeThroughTabsExample> createState() => _FadeThroughTabsExampleState();
}

class _FadeThroughTabsExampleState extends State<FadeThroughTabsExample> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    Center(key: ValueKey<int>(0), child: Text('Home Tab')),
    Center(key: ValueKey<int>(1), child: Text('Search Tab')),
    Center(key: ValueKey<int>(2), child: Text('Profile Tab')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> primaryAnimation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

### Fade Scale Modal (`showModal` & `FadeScaleTransitionConfiguration`)

Use `showModal` with `FadeScaleTransitionConfiguration` to display dialogs or modals that smoothly fade and scale into view:

```dart
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

Future<void> showCustomFadeDialog(BuildContext context) {
  return showModal<void>(
    context: context,
    configuration: const FadeScaleTransitionConfiguration(
      transitionDuration: Duration(milliseconds: 250),
      reverseTransitionDuration: Duration(milliseconds: 150),
    ),
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Fade Scale Dialog'),
        content: const Text('This dialog enters and exits using Material Fade motion.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
```

### Configuring Global Route Transitions in `ThemeData`

You can configure app-wide route transitions by setting `pageTransitionsTheme` in your app's `ThemeData`:

```dart
MaterialApp(
  theme: ThemeData(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
        TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
      },
    ),
  ),
  home: const HomeScreen(),
);
```
