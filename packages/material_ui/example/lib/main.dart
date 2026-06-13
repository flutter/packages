// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MaterialExampleApp());
}

/// A small showcase app for the material_ui package.
class MaterialExampleApp extends StatefulWidget {
  const MaterialExampleApp({super.key});

  @override
  State<MaterialExampleApp> createState() => _MaterialExampleAppState();
}

class _MaterialExampleAppState extends State<MaterialExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'material_ui example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      home: _HomeScreen(
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen({
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  int _counter = 0;
  bool _notificationsEnabled = true;
  double _volume = 0.5;
  final Set<String> _selectedTopics = <String>{'Flutter'};

  static const List<String> _topics = <String>['Flutter', 'Material', 'Dart'];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? sectionStyle = theme.textTheme.titleMedium;

    return Scaffold(
      appBar: AppBar(title: const Text('material_ui')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('Appearance', style: sectionStyle),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode),
              ),
            ],
            selected: <ThemeMode>{widget.themeMode},
            onSelectionChanged: (Set<ThemeMode> selection) {
              widget.onThemeModeChanged(selection.first);
            },
          ),
          const SizedBox(height: 24),
          Text('Buttons', style: sectionStyle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton(onPressed: () {}, child: const Text('Filled')),
              ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
              OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
              TextButton(onPressed: () {}, child: const Text('Text')),
            ],
          ),
          const SizedBox(height: 24),
          Text('Topics', style: sectionStyle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: <Widget>[
              for (final String topic in _topics)
                FilterChip(
                  label: Text(topic),
                  selected: _selectedTopics.contains(topic),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedTopics.add(topic);
                      } else {
                        _selectedTopics.remove(topic);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  title: const Text('Enable notifications'),
                  value: _notificationsEnabled,
                  onChanged: (bool value) {
                    setState(() => _notificationsEnabled = value);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Volume'),
                  subtitle: Slider(
                    value: _volume,
                    onChanged: (double value) {
                      setState(() => _volume = value);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('Button tapped $_counter times', style: sectionStyle),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _counter++),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
