// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _MenuBarDefaultsM3 extends MenuStyle {
  _MenuBarDefaultsM3(this.context)
    : super(
        elevation: const MaterialStatePropertyAll<double?>(3.0),
        shape: const MaterialStatePropertyAll<OutlinedBorder>(_defaultMenuBorder),
        alignment: AlignmentDirectional.bottomStart,
      );

  static const RoundedRectangleBorder _defaultMenuBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(4.0)),
  );

  final BuildContext context;

  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  WidgetStateProperty<Color?> get backgroundColor {
    return MaterialStatePropertyAll<Color?>(_colors.surfaceContainer);
  }

  @override
  WidgetStateProperty<Color?>? get shadowColor {
    return MaterialStatePropertyAll<Color?>(_colors.shadow);
  }

  @override
  WidgetStateProperty<Color?>? get surfaceTintColor {
    return const MaterialStatePropertyAll<Color?>(Colors.transparent);
  }

  @override
  WidgetStateProperty<EdgeInsetsGeometry?>? get padding {
    return const MaterialStatePropertyAll<EdgeInsetsGeometry>(
      EdgeInsetsDirectional.symmetric(horizontal: _kTopLevelMenuHorizontalMinPadding),
    );
  }

  @override
  VisualDensity get visualDensity => Theme.of(context).visualDensity;
}

class _MenuButtonDefaultsM3 extends ButtonStyle {
  _MenuButtonDefaultsM3(this.context)
    : super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: AlignmentDirectional.centerStart,
      );

  final BuildContext context;

  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  WidgetStateProperty<Color?>? get backgroundColor {
    return ButtonStyleButton.allOrNull<Color>(Colors.transparent);
  }

  // No default shadow color

  // No default surface tint color

  @override
  WidgetStateProperty<double>? get elevation {
    return ButtonStyleButton.allOrNull<double>(0.0);
  }

  @override
  WidgetStateProperty<Color?>? get foregroundColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return _colors.onSurface.withOpacity(0.38);
      }
      if (states.contains(WidgetState.pressed)) {
        return _colors.onSurface;
      }
      if (states.contains(WidgetState.hovered)) {
        return _colors.onSurface;
      }
      if (states.contains(WidgetState.focused)) {
        return _colors.onSurface;
      }
      return _colors.onSurface;
    });
  }

  @override
  WidgetStateProperty<Color?>? get iconColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return _colors.onSurface.withOpacity(0.38);
      }
      if (states.contains(WidgetState.pressed)) {
        return _colors.onSurfaceVariant;
      }
      if (states.contains(WidgetState.hovered)) {
        return _colors.onSurfaceVariant;
      }
      if (states.contains(WidgetState.focused)) {
        return _colors.onSurfaceVariant;
      }
      return _colors.onSurfaceVariant;
    });
  }

  // No default fixedSize

  @override
  WidgetStateProperty<double>? get iconSize {
    return const MaterialStatePropertyAll<double>(24.0);
  }

  @override
  WidgetStateProperty<Size>? get maximumSize {
    return ButtonStyleButton.allOrNull<Size>(Size.infinite);
  }

  @override
  WidgetStateProperty<Size>? get minimumSize {
    return ButtonStyleButton.allOrNull<Size>(const Size(64.0, 48.0));
  }

  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor => WidgetStateMouseCursor.adaptiveClickable;

  @override
  WidgetStateProperty<Color?>? get overlayColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed)) {
        return _colors.onSurface.withOpacity(0.1);
      }
      if (states.contains(WidgetState.hovered)) {
        return _colors.onSurface.withOpacity(0.08);
      }
      if (states.contains(WidgetState.focused)) {
        return _colors.onSurface.withOpacity(0.1);
      }
      return Colors.transparent;
    });
  }

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding {
    return ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(_scaledPadding(context));
  }

  // No default side

  @override
  WidgetStateProperty<OutlinedBorder>? get shape {
    return ButtonStyleButton.allOrNull<OutlinedBorder>(const RoundedRectangleBorder());
  }

  @override
  InteractiveInkFeatureFactory? get splashFactory => Theme.of(context).splashFactory;

  @override
  MaterialTapTargetSize? get tapTargetSize => Theme.of(context).materialTapTargetSize;

  @override
  WidgetStateProperty<TextStyle?> get textStyle {
    // TODO(tahatesser): This is taken from https://m3.material.io/components/menus/specs
    // Update this when the token is available.
    return MaterialStatePropertyAll<TextStyle?>(_textTheme.labelLarge);
  }

  @override
  VisualDensity? get visualDensity => Theme.of(context).visualDensity;

  // The horizontal padding number comes from the spec.
  EdgeInsetsGeometry _scaledPadding(BuildContext context) {
    VisualDensity visualDensity = Theme.of(context).visualDensity;
    // When horizontal VisualDensity is greater than zero, set it to zero
    // because the [ButtonStyleButton] has already handle the padding based on the density.
    // However, the [ButtonStyleButton] doesn't allow the [VisualDensity] adjustment
    // to reduce the width of the left/right padding, so we need to handle it here if
    // the density is less than zero, such as on desktop platforms.
    if (visualDensity.horizontal > 0) {
      visualDensity = VisualDensity(vertical: visualDensity.vertical);
    }
    // Since the threshold paddings used below are empirical values determined
    // at a font size of 14.0, 14.0 is used as the base value for scaling the
    // padding.
    final double fontSize = Theme.of(context).textTheme.labelLarge?.fontSize ?? 14.0;
    final double fontSizeRatio = MediaQuery.textScalerOf(context).scale(fontSize) / 14.0;
    return ButtonStyleButton.scaledPadding(
      EdgeInsets.symmetric(
        horizontal: math.max(
          _kMenuViewPadding,
          _kLabelItemDefaultSpacing + visualDensity.baseSizeAdjustment.dx,
        ),
      ),
      EdgeInsets.symmetric(
        horizontal: math.max(_kMenuViewPadding, 8 + visualDensity.baseSizeAdjustment.dx),
      ),
      const EdgeInsets.symmetric(horizontal: _kMenuViewPadding),
      fontSizeRatio,
    );
  }
}

class _MenuDefaultsM3 extends MenuStyle {
  _MenuDefaultsM3(this.context)
    : super(
        elevation: const MaterialStatePropertyAll<double?>(3.0),
        shape: const MaterialStatePropertyAll<OutlinedBorder>(_defaultMenuBorder),
        alignment: AlignmentDirectional.topEnd,
      );

  static const RoundedRectangleBorder _defaultMenuBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(4.0)),
  );

  final BuildContext context;

  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  WidgetStateProperty<Color?> get backgroundColor {
    return MaterialStatePropertyAll<Color?>(_colors.surfaceContainer);
  }

  @override
  WidgetStateProperty<Color?>? get surfaceTintColor {
    return const MaterialStatePropertyAll<Color?>(Colors.transparent);
  }

  @override
  WidgetStateProperty<Color?>? get shadowColor {
    return MaterialStatePropertyAll<Color?>(_colors.shadow);
  }

  @override
  WidgetStateProperty<EdgeInsetsGeometry?>? get padding {
    return const MaterialStatePropertyAll<EdgeInsetsGeometry>(
      EdgeInsetsDirectional.symmetric(vertical: _kMenuVerticalMinPadding),
    );
  }

  @override
  VisualDensity get visualDensity => Theme.of(context).visualDensity;
}
