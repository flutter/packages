// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #region body
import 'package:cupertino_ui/cupertino_ui.dart';

/// Flutter code sample for [CupertinoColorPicker] and
/// [showCupertinoColorPicker].
void main() => runApp(const CupertinoColorPickerApp());

class CupertinoColorPickerApp extends StatelessWidget {
  const CupertinoColorPickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(brightness: .light),
      home: ColorPickerExample(),
    );
  }
}

class ColorPickerExample extends StatefulWidget {
  const ColorPickerExample({super.key});

  @override
  State<ColorPickerExample> createState() => _ColorPickerExampleState();
}

class _ColorPickerExampleState extends State<ColorPickerExample> {
  Color _color = const Color(0xFF007AFF);

  Future<void> _showColorPicker(BuildContext context) async {
    final Color? selectedColor = await showCupertinoColorPicker(
      context: context,
      initialColor: _color,
    );
    if (selectedColor != null && mounted) {
      setState(() {
        _color = selectedColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('CupertinoColorPicker Sample'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            CupertinoColorPicker(
              color: _color,
              label: const Text('Accent Color'),
              onChanged: (Color color) {
                setState(() {
                  _color = color;
                });
              },
            ),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: () => _showColorPicker(context),
              child: const Text('Present Color Picker'),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '#${(_color.toARGB32() & 0x00FFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
                style: const TextStyle(
                  fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// #endregion body
