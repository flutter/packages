// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [TextField.buildCounter].

// #region body
Widget counter(
  BuildContext context, {
  required int currentLength,
  required int? maxLength,
  required bool isFocused,
}) {
  return Text(
    '$currentLength of $maxLength characters',
    semanticsLabel: 'character count',
  );
}
// #endregion body

class TextFieldBuildCounterExample extends StatelessWidget {
  const TextFieldBuildCounterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextField(maxLength: 10, buildCounter: counter);
  }
}
