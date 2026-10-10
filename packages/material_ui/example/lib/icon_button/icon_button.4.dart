// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #region body
import 'package:material_ui/material_ui.dart';

/// Flutter code sample for Material 3 Expressive [IconButton].

void main() {
  runApp(const IconButtonM3EExampleApp());
}

class IconButtonM3EExampleApp extends StatelessWidget {
  const IconButtonM3EExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        iconButtonTheme: const IconButtonThemeData(
          variant: StyleVariant.material3Expressive,
        ),
      ),
      title: 'Material 3 Expressive IconButton',
      home: const Scaffold(body: SafeArea(child: IconButtonM3EExample())),
    );
  }
}

class IconButtonM3EExample extends StatefulWidget {
  const IconButtonM3EExample({super.key});

  @override
  State<IconButtonM3EExample> createState() => _IconButtonM3EExampleState();
}

class _IconButtonM3EExampleState extends State<IconButtonM3EExample> {
  final Set<String> _selectedButtonIds = <String>{};

  bool _isSelected(String id) {
    return _selectedButtonIds.contains(id);
  }

  void _toggle(String id) {
    setState(() {
      if (!_selectedButtonIds.add(id)) {
        _selectedButtonIds.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: <Widget>[
        _Section(
          title: 'Sizes',
          child: Wrap(
            spacing: 16.0,
            runSpacing: 20.0,
            children: _sizeOptions.map((_SizeOption option) {
              final String id = 'size-${option.key}';
              return _IconButtonDemoTile(
                label: option.label,
                child: IconButton.filledTonal(
                  key: ValueKey<String>('m3e-icon-button-${option.key}'),
                  icon: Icon(option.icon),
                  selectedIcon: Icon(option.selectedIcon),
                  isSelected: _isSelected(id),
                  onPressed: () {
                    _toggle(id);
                  },
                  style: ButtonStyle(sizeVariant: option.sizeVariant),
                ),
              );
            }).toList(),
          ),
        ),
        _Section(
          title: 'Widths',
          child: Wrap(
            spacing: 16.0,
            runSpacing: 20.0,
            children: _widthOptions.map((_WidthOption option) {
              final String id = 'width-${option.key}';
              return _IconButtonDemoTile(
                label: option.label,
                child: IconButton.filled(
                  key: ValueKey<String>('m3e-icon-button-width-${option.key}'),
                  icon: Icon(option.icon),
                  selectedIcon: Icon(option.selectedIcon),
                  isSelected: _isSelected(id),
                  onPressed: () {
                    _toggle(id);
                  },
                  style: ButtonStyle(
                    iconButtonWidth: option.iconButtonWidth,
                    sizeVariant: ButtonSizeVariant.medium,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        _Section(
          title: 'Shapes',
          child: Wrap(
            spacing: 16.0,
            runSpacing: 20.0,
            children: _shapeOptions.map((_ShapeOption option) {
              final String id = 'shape-${option.key}';
              return _IconButtonDemoTile(
                label: option.label,
                child: IconButton.filledTonal(
                  key: ValueKey<String>('m3e-icon-button-shape-${option.key}'),
                  icon: Icon(option.icon),
                  selectedIcon: Icon(option.selectedIcon),
                  isSelected: _isSelected(id),
                  onPressed: () {
                    _toggle(id);
                  },
                  style: ButtonStyle(shapeVariant: option.shapeVariant),
                ),
              );
            }).toList(),
          ),
        ),
        const _Section(
          title: 'Disabled',
          child: Wrap(
            spacing: 16.0,
            runSpacing: 20.0,
            children: <Widget>[
              // A null onPressed disables the button.
              _IconButtonDemoTile(
                label: 'Unselected',
                child: IconButton.filledTonal(
                  key: ValueKey<String>('m3e-icon-button-disabled-unselected'),
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  isSelected: false,
                  onPressed: null,
                ),
              ),
              _IconButtonDemoTile(
                label: 'Selected',
                child: IconButton.filledTonal(
                  key: ValueKey<String>('m3e-icon-button-disabled-selected'),
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  isSelected: true,
                  onPressed: null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12.0),
          child,
        ],
      ),
    );
  }
}

class _IconButtonDemoTile extends StatelessWidget {
  const _IconButtonDemoTile({required this.label, required this.child});

  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 152.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 148.0, child: Center(child: child)),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SizeOption {
  const _SizeOption(
    this.label,
    this.key,
    this.sizeVariant,
    this.icon,
    this.selectedIcon,
  );

  final IconData icon;
  final String key;
  final String label;
  final IconData selectedIcon;
  final ButtonSizeVariant sizeVariant;
}

const List<_SizeOption> _sizeOptions = <_SizeOption>[
  _SizeOption(
    'Extra small',
    'x-small',
    ButtonSizeVariant.xSmall,
    Icons.add,
    Icons.add_circle,
  ),
  _SizeOption(
    'Small',
    'small',
    ButtonSizeVariant.small,
    Icons.search,
    Icons.manage_search,
  ),
  _SizeOption(
    'Medium',
    'medium',
    ButtonSizeVariant.medium,
    Icons.bookmark_border,
    Icons.bookmark,
  ),
  _SizeOption(
    'Large',
    'large',
    ButtonSizeVariant.large,
    Icons.edit_outlined,
    Icons.edit,
  ),
  _SizeOption(
    'Extra large',
    'x-large',
    ButtonSizeVariant.xLarge,
    Icons.star_border,
    Icons.star,
  ),
];

class _WidthOption {
  const _WidthOption(
    this.label,
    this.key,
    this.iconButtonWidth,
    this.icon,
    this.selectedIcon,
  );

  final IconData icon;
  final IconButtonWidthVariant iconButtonWidth;
  final String key;
  final String label;
  final IconData selectedIcon;
}

const List<_WidthOption> _widthOptions = <_WidthOption>[
  _WidthOption(
    'Narrow',
    'narrow',
    IconButtonWidthVariant.narrow,
    Icons.arrow_back,
    Icons.keyboard_double_arrow_left,
  ),
  _WidthOption(
    'Standard',
    'standard',
    IconButtonWidthVariant.standard,
    Icons.horizontal_rule,
    Icons.remove_circle,
  ),
  _WidthOption(
    'Wide',
    'wide',
    IconButtonWidthVariant.wide,
    Icons.arrow_forward,
    Icons.keyboard_double_arrow_right,
  ),
];

class _ShapeOption {
  const _ShapeOption(
    this.label,
    this.key,
    this.shapeVariant,
    this.icon,
    this.selectedIcon,
  );

  final IconData icon;
  final String key;
  final String label;
  final IconData selectedIcon;
  final ButtonShapeVariant shapeVariant;
}

const List<_ShapeOption> _shapeOptions = <_ShapeOption>[
  _ShapeOption(
    'Round',
    'round',
    ButtonShapeVariant.round,
    Icons.check_circle_outline,
    Icons.check_circle,
  ),
  _ShapeOption(
    'Square',
    'square',
    ButtonShapeVariant.square,
    Icons.check_box_outline_blank,
    Icons.check_box,
  ),
];
// #endregion body
