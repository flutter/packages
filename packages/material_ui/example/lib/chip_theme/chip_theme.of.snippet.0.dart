// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [ChipTheme.of].

// #region body
class Spaceship extends StatelessWidget {
  const Spaceship({super.key});

  @override
  Widget build(BuildContext context) {
    return ChipTheme(
      data: ChipTheme.of(context).copyWith(backgroundColor: Colors.red),
      child: ActionChip(
        label: const Text('Launch'),
        onPressed: () {
          print('We have liftoff!');
        },
      ),
    );
  }
}
// #endregion body
