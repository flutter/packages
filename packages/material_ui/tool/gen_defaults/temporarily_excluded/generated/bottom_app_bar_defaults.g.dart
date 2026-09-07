// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _BottomAppBarDefaultsM3 extends BottomAppBarThemeData {
  _BottomAppBarDefaultsM3(this.context)
    : super(
        elevation: 3.0,
        height: 80.0,
        shape: const AutomaticNotchedShape(RoundedRectangleBorder()),
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get color => _colors.surfaceContainer;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get shadowColor => Colors.transparent;
}
