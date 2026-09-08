// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _DialogFullscreenDefaultsM3 extends DialogThemeData {
  const _DialogFullscreenDefaultsM3(this.context) : super(clipBehavior: Clip.none);

  final BuildContext context;

  @override
  Color? get backgroundColor => Theme.of(context).colorScheme.surface;
}
