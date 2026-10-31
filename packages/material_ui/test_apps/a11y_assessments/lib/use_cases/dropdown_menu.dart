// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';
import '../utils.dart';
import 'use_cases.dart';

class DropdownMenuUseCase extends UseCase {
  DropdownMenuUseCase();

  @override
  String get name => 'DropdownMenu';

  @override
  String get route => '/dropdown-menu';

  @override
  List<Tag> get tags => <Tag>[Tag.batch3, Tag.core];

  @override
  Widget build(BuildContext context) => const _MainWidget();
}

class _MainWidget extends StatelessWidget {
  const _MainWidget();

  static const List<String> _kOptions = <String>['apple', 'banana', 'lemon'];
  static final List<DropdownMenuEntry<String>> _kMenuEntries = _kOptions
      .map<DropdownMenuEntry<String>>(
        (String name) => DropdownMenuEntry<String>(value: name, label: name),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final String pageTitle = getUseCaseName(DropdownMenuUseCase());
    final ThemeData theme = Theme.of(context);
    // Under standard contrast, tertiaryContainer against surfaceContainerLow does
    // not reach a 3:1 contrast ratio. Medium contrast (contrastLevel: 0.5) is
    // required to satisfy WCAG 2.1 Success Criterion 1.4.11 (Non-text Contrast).
    final ThemeData mediumContrastTheme = theme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        brightness: theme.brightness,
        seedColor: const Color(0xff6750a4),
        contrastLevel: 0.5,
      ),
    );
    return Theme(
      data: mediumContrastTheme,
      child: Scaffold(
        appBar: AppBar(title: Semantics(headingLevel: 1, child: Text('$pageTitle Demo'))),
        body: ListView(
          padding: const EdgeInsets.all(24.0),
          children: <Widget>[
            Semantics(
              label: 'Enabled dropdown menu',
              child: DropdownMenu<String>(
                key: const Key('enabled dropdown menu'),
                label: const Text('Fruit'),
                expandedInsets: EdgeInsets.zero,
                initialSelection: _kOptions.first,
                dropdownMenuEntries: _kMenuEntries,
              ),
            ),
            const SizedBox(height: 24.0),
            Semantics(
              label: 'Disabled dropdown menu',
              child: DropdownMenu<String>(
                key: const Key('disabled dropdown menu'),
                label: const Text('Fruit'),
                expandedInsets: EdgeInsets.zero,
                enabled: false,
                initialSelection: _kOptions.first,
                dropdownMenuEntries: _kMenuEntries,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
