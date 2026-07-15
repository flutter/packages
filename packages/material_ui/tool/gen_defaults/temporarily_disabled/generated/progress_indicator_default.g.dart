// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _CircularProgressIndicatorDefaultsM3 extends ProgressIndicatorThemeData {
  _CircularProgressIndicatorDefaultsM3(this.context, {required this.indeterminate});

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  final bool indeterminate;

  @override
  Color get color => _colors.primary;

  @override
  Color? get circularTrackColor => indeterminate ? null : _colors.secondaryContainer;

  @override
  double get strokeWidth => 4.0;

  @override
  double? get strokeAlign => CircularProgressIndicator.strokeAlignInside;

  @override
  BoxConstraints get constraints => const BoxConstraints(minWidth: 40.0, minHeight: 40.0);

  @override
  double? get trackGap => 4.0;

  @override
  EdgeInsetsGeometry? get circularTrackPadding => const EdgeInsets.all(4.0);
}

class _LinearProgressIndicatorDefaultsM3 extends ProgressIndicatorThemeData {
  _LinearProgressIndicatorDefaultsM3(this.context);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color get color => _colors.primary;

  @override
  Color get linearTrackColor => _colors.secondaryContainer;

  @override
  double get linearMinHeight => 4.0;

  @override
  BorderRadius get borderRadius => const BorderRadius.all(Radius.circular(4.0 / 2));

  @override
  Color get stopIndicatorColor => _colors.primary;

  @override
  double? get stopIndicatorRadius => 4.0 / 2;

  @override
  double? get trackGap => 4.0;
}
