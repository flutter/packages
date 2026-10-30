// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #region body
import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [Typography.material2025].

void main() {
  runApp(const TypographyExampleApp());
}

class TypographyExampleApp extends StatelessWidget {
  const TypographyExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The default typography provides an emphasized variant of each text
    // style, such as TextTheme.titleMediumEmphasized.
    return MaterialApp(theme: ThemeData(), home: const TypographyExample());
  }
}

enum TypeStyleVariant { baseline, emphasized }

class TypographyExample extends StatefulWidget {
  const TypographyExample({super.key});

  @override
  State<TypographyExample> createState() => _TypographyExampleState();
}

class _TypographyExampleState extends State<TypographyExample> {
  TypeStyleVariant _variant = TypeStyleVariant.baseline;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = TextTheme.of(context);
    final ColorScheme colorScheme = ColorScheme.of(context);
    final emphasized = _variant == TypeStyleVariant.emphasized;

    final styles = <(String, TextStyle?, TextStyle?)>[
      (
        'Display Large',
        textTheme.displayLarge,
        textTheme.displayLargeEmphasized,
      ),
      (
        'Display Medium',
        textTheme.displayMedium,
        textTheme.displayMediumEmphasized,
      ),
      (
        'Display Small',
        textTheme.displaySmall,
        textTheme.displaySmallEmphasized,
      ),
      (
        'Headline Large',
        textTheme.headlineLarge,
        textTheme.headlineLargeEmphasized,
      ),
      (
        'Headline Medium',
        textTheme.headlineMedium,
        textTheme.headlineMediumEmphasized,
      ),
      (
        'Headline Small',
        textTheme.headlineSmall,
        textTheme.headlineSmallEmphasized,
      ),
      ('Title Large', textTheme.titleLarge, textTheme.titleLargeEmphasized),
      ('Title Medium', textTheme.titleMedium, textTheme.titleMediumEmphasized),
      ('Title Small', textTheme.titleSmall, textTheme.titleSmallEmphasized),
      ('Label Large', textTheme.labelLarge, textTheme.labelLargeEmphasized),
      ('Label Medium', textTheme.labelMedium, textTheme.labelMediumEmphasized),
      ('Label Small', textTheme.labelSmall, textTheme.labelSmallEmphasized),
      ('Body Large', textTheme.bodyLarge, textTheme.bodyLargeEmphasized),
      ('Body Medium', textTheme.bodyMedium, textTheme.bodyMediumEmphasized),
      ('Body Small', textTheme.bodySmall, textTheme.bodySmallEmphasized),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Typography')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<TypeStyleVariant>(
              segments: const <ButtonSegment<TypeStyleVariant>>[
                ButtonSegment<TypeStyleVariant>(
                  value: TypeStyleVariant.baseline,
                  label: Text('Baseline'),
                ),
                ButtonSegment<TypeStyleVariant>(
                  value: TypeStyleVariant.emphasized,
                  label: Text('Emphasized'),
                ),
              ],
              selected: <TypeStyleVariant>{_variant},
              onSelectionChanged: (Set<TypeStyleVariant> selection) {
                setState(() {
                  _variant = selection.single;
                });
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: <Widget>[
                for (final (
                      String name,
                      TextStyle? baseline,
                      TextStyle? emphasizedStyle,
                    )
                    in styles)
                  Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: <Widget>[
                          Text(
                            emphasized
                                ? 'md.sys.typescale.emphasized'
                                : 'md.sys.typescale',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            name,
                            style: emphasized ? emphasizedStyle : baseline,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// #endregion body
