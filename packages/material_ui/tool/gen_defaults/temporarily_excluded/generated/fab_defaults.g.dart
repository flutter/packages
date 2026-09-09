// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _FABDefaultsM3 extends FloatingActionButtonThemeData {
  _FABDefaultsM3(this.context, this.type, this.hasChild)
    : super(
        elevation: 6.0,
        focusElevation: 6.0,
        hoverElevation: 8.0,
        highlightElevation: 6.0,
        enableFeedback: true,
        sizeConstraints: const BoxConstraints.tightFor(width: 56.0, height: 56.0),
        smallSizeConstraints: const BoxConstraints.tightFor(width: 40.0, height: 40.0),
        largeSizeConstraints: const BoxConstraints.tightFor(width: 96.0, height: 96.0),
        extendedSizeConstraints: const BoxConstraints.tightFor(height: 56.0),
        extendedIconLabelSpacing: 8.0,
      );

  final BuildContext context;
  final _FloatingActionButtonType type;
  final bool hasChild;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  bool get _isExtended => type == _FloatingActionButtonType.extended;

  @override
  Color? get foregroundColor => _colors.onPrimaryContainer;
  @override
  Color? get backgroundColor => _colors.primaryContainer;
  @override
  Color? get splashColor => _colors.onPrimaryContainer.withOpacity(0.1);
  @override
  Color? get focusColor => _colors.onPrimaryContainer.withOpacity(0.1);
  @override
  Color? get hoverColor => _colors.onPrimaryContainer.withOpacity(0.08);

  @override
  ShapeBorder? get shape => switch (type) {
    _FloatingActionButtonType.regular => const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
    ),
    _FloatingActionButtonType.small => const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
    ),
    _FloatingActionButtonType.large => const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(28.0)),
    ),
    _FloatingActionButtonType.extended => const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
    ),
  };

  @override
  double? get iconSize => switch (type) {
    _FloatingActionButtonType.regular => 24.0,
    _FloatingActionButtonType.small => 24.0,
    _FloatingActionButtonType.large => 36.0,
    _FloatingActionButtonType.extended => 24.0,
  };

  @override
  EdgeInsetsGeometry? get extendedPadding =>
      EdgeInsetsDirectional.only(start: hasChild && _isExtended ? 16.0 : 20.0, end: 20.0);
  @override
  TextStyle? get extendedTextStyle => _textTheme.labelLarge;
}
