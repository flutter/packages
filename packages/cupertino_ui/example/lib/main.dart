// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';

void main() {
  runApp(const CupertinoExampleApp());
}

/// A small showcase app for the cupertino_ui package.
class CupertinoExampleApp extends StatefulWidget {
  const CupertinoExampleApp({super.key});

  @override
  State<CupertinoExampleApp> createState() => _CupertinoExampleAppState();
}

class _CupertinoExampleAppState extends State<CupertinoExampleApp> {
  // A null brightness follows the system setting.
  Brightness? _brightness;

  void _setBrightness(Brightness? brightness) {
    setState(() {
      _brightness = brightness;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'cupertino_ui example',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(brightness: _brightness),
      home: _HomeScreen(
        brightness: _brightness,
        onBrightnessChanged: _setBrightness,
      ),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen({
    required this.brightness,
    required this.onBrightnessChanged,
  });

  final Brightness? brightness;
  final ValueChanged<Brightness?> onBrightnessChanged;

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  bool _notificationsEnabled = true;
  double _volume = 0.5;
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _showInfoDialog() {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('cupertino_ui'),
          content: const Text(
            'The official Cupertino widget library for Flutter, as a '
            'standalone package.',
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('cupertino_ui')),
      child: SafeArea(
        child: ListView(
          children: <Widget>[
            CupertinoListSection.insetGrouped(
              header: const Text('Appearance'),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<int>(
                      groupValue: _brightnessToSegment(widget.brightness),
                      onValueChanged: (int? value) {
                        if (value != null) {
                          widget.onBrightnessChanged(
                            _segmentToBrightness(value),
                          );
                        }
                      },
                      children: const <int, Widget>{
                        0: _SegmentLabel('Auto'),
                        1: _SegmentLabel('Light'),
                        2: _SegmentLabel('Dark'),
                      },
                    ),
                  ),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('Controls'),
              hasLeading: false,
              children: <Widget>[
                CupertinoListTile(
                  title: const Text('Notifications'),
                  trailing: CupertinoSwitch(
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                ),
                CupertinoListTile(
                  title: const Text('Volume'),
                  subtitle: CupertinoSlider(
                    value: _volume,
                    onChanged: (double value) {
                      setState(() => _volume = value);
                    },
                  ),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('Profile'),
              children: <Widget>[
                CupertinoTextField.borderless(
                  controller: _nameController,
                  placeholder: 'Name',
                  padding: const EdgeInsets.all(16),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoButton.filled(
                onPressed: _showInfoDialog,
                child: const Text('About this package'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static int _brightnessToSegment(Brightness? brightness) {
    return switch (brightness) {
      null => 0,
      Brightness.light => 1,
      Brightness.dark => 2,
    };
  }

  static Brightness? _segmentToBrightness(int segment) {
    return switch (segment) {
      1 => Brightness.light,
      2 => Brightness.dark,
      _ => null,
    };
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(text),
    );
  }
}
