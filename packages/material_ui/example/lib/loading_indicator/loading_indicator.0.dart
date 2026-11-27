// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #region body
import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [LoadingIndicator].

void main() => runApp(const LoadingIndicatorExampleApp());

class LoadingIndicatorExampleApp extends StatelessWidget {
  const LoadingIndicatorExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LoadingIndicatorExample());
  }
}

class LoadingIndicatorExample extends StatefulWidget {
  const LoadingIndicatorExample({super.key});

  @override
  State<LoadingIndicatorExample> createState() =>
      _LoadingIndicatorExampleState();
}

class _LoadingIndicatorExampleState extends State<LoadingIndicatorExample> {
  double _value = 0.5;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Loading Indicator Sample')),
      body: Center(
        child: Column(
          mainAxisSize: .min,
          spacing: 16.0,
          children: <Widget>[
            Text('Indeterminate', style: textTheme.titleMedium),
            const Row(
              mainAxisAlignment: .center,
              spacing: 32.0,
              children: <Widget>[
                LoadingIndicator(semanticsLabel: 'Loading'),
                LoadingIndicator.contained(semanticsLabel: 'Loading'),
              ],
            ),
            const SizedBox(height: 16.0),
            Text('Determinate', style: textTheme.titleMedium),
            Row(
              mainAxisAlignment: .center,
              spacing: 32.0,
              children: <Widget>[
                LoadingIndicator(value: _value, semanticsLabel: 'Progress'),
                LoadingIndicator.contained(
                  value: _value,
                  semanticsLabel: 'Progress',
                ),
              ],
            ),
            SizedBox(
              width: 300.0,
              child: Slider(
                value: _value,
                onChanged: (double value) => setState(() => _value = value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// #endregion body
