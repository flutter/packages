// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

class DynamicTitle extends StatelessWidget {
  const DynamicTitle({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Title(title: title, color: Theme.of(context).colorScheme.primary, child: child);
  }
}
