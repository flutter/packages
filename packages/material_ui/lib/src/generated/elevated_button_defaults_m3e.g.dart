// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Do not edit by hand. The code is generated from data in the Material
// Design token database by the script:
//   packages/material_ui/tool/gen_defaults/bin/gen_defaults.dart.
part of '../elevated_button.dart';

class _ElevatedButtonDefaultsM3E extends ButtonStyle {
  _ElevatedButtonDefaultsM3E(
    this.context,
    this.toggleable,
    ButtonSizeVariant? sizeVariant,
    ButtonShapeVariant? shapeVariant,
  ) : _sizeVariant = sizeVariant,
      _shapeVariant = shapeVariant,
      super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: Alignment.center,
      );

  final BuildContext context;
  final bool toggleable;
  final ButtonSizeVariant? _sizeVariant;
  final ButtonShapeVariant? _shapeVariant;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  ButtonSizeVariant get sizeVariant => _sizeVariant ?? ButtonSizeVariant.small;

  @override
  ButtonShapeVariant get shapeVariant => _shapeVariant ?? ButtonShapeVariant.round;

  /// The space between the icon and the label for the given [sizeVariant].
  static double iconLabelSpace(ButtonSizeVariant sizeVariant) => switch (sizeVariant) {
    ButtonSizeVariant.xSmall => 4.0,
    ButtonSizeVariant.small => 8.0,
    ButtonSizeVariant.medium => 8.0,
    ButtonSizeVariant.large => 12.0,
    ButtonSizeVariant.xLarge => 16.0,
  };

  @override
  WidgetStateProperty<TextStyle?> get textStyle =>
      WidgetStatePropertyAll<TextStyle?>(switch (sizeVariant) {
        ButtonSizeVariant.xSmall => Theme.of(context).textTheme.labelLarge,
        ButtonSizeVariant.small => Theme.of(context).textTheme.labelLarge,
        ButtonSizeVariant.medium => Theme.of(context).textTheme.titleMedium,
        ButtonSizeVariant.large => Theme.of(context).textTheme.headlineSmall,
        ButtonSizeVariant.xLarge => Theme.of(context).textTheme.headlineLarge,
      });

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.1);
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return _colors.primary;
        }
        if (toggleable) {
          return _colors.surfaceContainerLow;
        }
        return _colors.surfaceContainerLow;
      });

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.38);
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return _colors.onPrimary;
        }
        if (toggleable) {
          return _colors.primary;
        }
        return _colors.primary;
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        final bool selected = toggleable && states.contains(WidgetState.selected);
        if (states.contains(WidgetState.pressed)) {
          return selected
              ? _colors.onPrimary.withValues(alpha: 0.1)
              : _colors.primary.withValues(alpha: 0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return selected
              ? _colors.onPrimary.withValues(alpha: 0.08)
              : _colors.primary.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return selected
              ? _colors.onPrimary.withValues(alpha: 0.1)
              : _colors.primary.withValues(alpha: 0.1);
        }
        return null;
      });

  @override
  WidgetStateProperty<Color>? get shadowColor => WidgetStatePropertyAll<Color>(_colors.shadow);

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
      const WidgetStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<double>? get elevation =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return 0.0;
        }
        if (states.contains(WidgetState.pressed)) {
          return 1.0;
        }
        if (states.contains(WidgetState.hovered)) {
          return 3.0;
        }
        if (states.contains(WidgetState.focused)) {
          return 1.0;
        }
        return 1.0;
      });

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding {
    final double fontSize = textStyle.resolve(const <WidgetState>{})?.fontSize ?? 14.0;
    final double effectiveTextScale = MediaQuery.textScalerOf(context).scale(fontSize) / fontSize;
    return WidgetStatePropertyAll<EdgeInsetsGeometry>(
      ButtonStyleButton.scaledPadding(
        switch (sizeVariant) {
          ButtonSizeVariant.xSmall => const EdgeInsets.symmetric(horizontal: 12.0),
          ButtonSizeVariant.small => const EdgeInsets.symmetric(horizontal: 16.0),
          ButtonSizeVariant.medium => const EdgeInsets.symmetric(horizontal: 24.0),
          ButtonSizeVariant.large => const EdgeInsets.symmetric(horizontal: 48.0),
          ButtonSizeVariant.xLarge => const EdgeInsets.symmetric(horizontal: 64.0),
        },
        switch (sizeVariant) {
          ButtonSizeVariant.xSmall => const EdgeInsets.symmetric(horizontal: 6.0),
          ButtonSizeVariant.small => const EdgeInsets.symmetric(horizontal: 8.0),
          ButtonSizeVariant.medium => const EdgeInsets.symmetric(horizontal: 12.0),
          ButtonSizeVariant.large => const EdgeInsets.symmetric(horizontal: 24.0),
          ButtonSizeVariant.xLarge => const EdgeInsets.symmetric(horizontal: 32.0),
        },
        switch (sizeVariant) {
          ButtonSizeVariant.xSmall => const EdgeInsets.symmetric(horizontal: 3.0),
          ButtonSizeVariant.small => const EdgeInsets.symmetric(horizontal: 4.0),
          ButtonSizeVariant.medium => const EdgeInsets.symmetric(horizontal: 6.0),
          ButtonSizeVariant.large => const EdgeInsets.symmetric(horizontal: 12.0),
          ButtonSizeVariant.xLarge => const EdgeInsets.symmetric(horizontal: 16.0),
        },
        effectiveTextScale,
      ),
    );
  }

  @override
  WidgetStateProperty<Size>? get minimumSize => WidgetStatePropertyAll<Size>(switch (sizeVariant) {
    ButtonSizeVariant.xSmall => const Size(64.0, 32.0),
    ButtonSizeVariant.small => const Size(64.0, 40.0),
    ButtonSizeVariant.medium => const Size(64.0, 56.0),
    ButtonSizeVariant.large => const Size(64.0, 96.0),
    ButtonSizeVariant.xLarge => const Size(64.0, 136.0),
  });

  @override
  WidgetStateProperty<Size>? get maximumSize => const WidgetStatePropertyAll<Size>(Size.infinite);

  @override
  WidgetStateProperty<double>? get iconSize => WidgetStatePropertyAll<double>(switch (sizeVariant) {
    ButtonSizeVariant.xSmall => 20.0,
    ButtonSizeVariant.small => 20.0,
    ButtonSizeVariant.medium => 24.0,
    ButtonSizeVariant.large => 32.0,
    ButtonSizeVariant.xLarge => 40.0,
  });

  @override
  WidgetStateProperty<Color>? get iconColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.38);
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return _colors.onPrimary;
        }
        if (toggleable) {
          return _colors.primary;
        }
        return _colors.primary;
      });

  @override
  WidgetStateProperty<OutlinedBorder>? get shape =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return switch (sizeVariant) {
            ButtonSizeVariant.xSmall => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            ButtonSizeVariant.small => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            ButtonSizeVariant.medium => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            ButtonSizeVariant.large => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            ButtonSizeVariant.xLarge => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
          };
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return switch (shapeVariant) {
            ButtonShapeVariant.round => switch (sizeVariant) {
              ButtonSizeVariant.xSmall => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              ButtonSizeVariant.small => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              ButtonSizeVariant.medium => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              ButtonSizeVariant.large => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28.0)),
              ),
              ButtonSizeVariant.xLarge => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28.0)),
              ),
            },
            ButtonShapeVariant.square => switch (sizeVariant) {
              ButtonSizeVariant.xSmall => const StadiumBorder(),
              ButtonSizeVariant.small => const StadiumBorder(),
              ButtonSizeVariant.medium => const StadiumBorder(),
              ButtonSizeVariant.large => const StadiumBorder(),
              ButtonSizeVariant.xLarge => const StadiumBorder(),
            },
          };
        }
        return switch (shapeVariant) {
          ButtonShapeVariant.round => switch (sizeVariant) {
            ButtonSizeVariant.xSmall => const StadiumBorder(),
            ButtonSizeVariant.small => const StadiumBorder(),
            ButtonSizeVariant.medium => const StadiumBorder(),
            ButtonSizeVariant.large => const StadiumBorder(),
            ButtonSizeVariant.xLarge => const StadiumBorder(),
          },
          ButtonShapeVariant.square => switch (sizeVariant) {
            ButtonSizeVariant.xSmall => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            ButtonSizeVariant.small => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            ButtonSizeVariant.medium => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            ButtonSizeVariant.large => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(28.0)),
            ),
            ButtonSizeVariant.xLarge => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(28.0)),
            ),
          },
        };
      });

  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor => WidgetStateMouseCursor.adaptiveClickable;

  @override
  VisualDensity? get visualDensity => VisualDensity.standard;

  @override
  MaterialTapTargetSize? get tapTargetSize => MaterialTapTargetSize.padded;

  @override
  InteractiveInkFeatureFactory? get splashFactory => Theme.of(context).splashFactory;
}
