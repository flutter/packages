// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [ChipThemeData].

// #region body
class CarColor extends StatefulWidget {
  const CarColor({super.key});

  @override
  State<CarColor> createState() => _CarColorState();
}

class _CarColorState extends State<CarColor> {
  Color _color = Colors.red;

  @override
  Widget build(BuildContext context) {
    return ChipTheme(
      data: ChipTheme.of(context).copyWith(backgroundColor: Colors.lightBlue),
      child: ChoiceChip(
        label: const Text('Light Blue'),
        onSelected: (bool value) {
          setState(() {
            _color = value ? Colors.lightBlue : Colors.red;
          });
        },
        selected: _color == Colors.lightBlue,
      ),
    );
  }
}
// #endregion body
