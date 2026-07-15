// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _DividerDefaultsM3 extends DividerThemeData {
  const _DividerDefaultsM3(this.context)
    : super(space: 16, thickness: 1.0, indent: 0, endIndent: 0);

  final BuildContext context;

  @override
  Color? get color => Theme.of(context).colorScheme.outlineVariant;
}
