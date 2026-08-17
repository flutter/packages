// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Do not edit by hand. The code is generated from data in the Material
// Design token database by the script:
//   packages/material_ui/tool/gen_defaults/bin/gen_defaults.dart.
part of '../icon_button.dart';

class _IconButtonDefaultsM3E extends ButtonStyle {
  _IconButtonDefaultsM3E(
    this.context,
    this.toggleable,
    this.sizeVariant,
    this.iconButtonWidth,
    this.shapeVariant,
  ) : super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: Alignment.center,
      );

  final BuildContext context;
  final bool toggleable;
  final ButtonSize? sizeVariant;
  final IconButtonWidth? iconButtonWidth;
  final ButtonShapeVariant? shapeVariant;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      const MaterialStatePropertyAll<Color?>(Colors.transparent);

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withOpacity(0.38);
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return _colors.primary;
        }
        return _colors.onSurfaceVariant;
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (toggleable && states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.pressed)) {
            return _colors.primary.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return _colors.primary.withOpacity(0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return _colors.primary.withOpacity(0.1);
          }
        }
        if (states.contains(WidgetState.pressed)) {
          return _colors.onSurfaceVariant.withOpacity(0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.onSurfaceVariant.withOpacity(0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.onSurfaceVariant.withOpacity(0.1);
        }
        return Colors.transparent;
      });

  @override
  WidgetStateProperty<double>? get elevation => const MaterialStatePropertyAll<double>(0.0);

  @override
  WidgetStateProperty<Color>? get shadowColor =>
      const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
      const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding =>
      MaterialStatePropertyAll<EdgeInsetsGeometry>(switch (sizeVariant ?? ButtonSize.small) {
        ButtonSize.xSmall => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(4.0, 6.0, 4.0, 6.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(10.0, 6.0, 10.0, 6.0),
        },
        ButtonSize.small => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(14.0, 8.0, 14.0, 8.0),
        },
        ButtonSize.medium => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(12.0, 16.0, 12.0, 16.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
        },
        ButtonSize.large => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(16.0, 32.0, 16.0, 32.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(32.0, 32.0, 32.0, 32.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(48.0, 32.0, 48.0, 32.0),
        },
        ButtonSize.xLarge => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(32.0, 48.0, 32.0, 48.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(48.0, 48.0, 48.0, 48.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(72.0, 48.0, 72.0, 48.0),
        },
      });

  @override
  WidgetStateProperty<Size>? get minimumSize =>
      MaterialStatePropertyAll<Size>(switch (sizeVariant ?? ButtonSize.small) {
        ButtonSize.xSmall => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(28.0, 32.0),
          IconButtonWidth.standard => const Size(32.0, 32.0),
          IconButtonWidth.wide => const Size(40.0, 32.0),
        },
        ButtonSize.small => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(32.0, 40.0),
          IconButtonWidth.standard => const Size(40.0, 40.0),
          IconButtonWidth.wide => const Size(52.0, 40.0),
        },
        ButtonSize.medium => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(48.0, 56.0),
          IconButtonWidth.standard => const Size(56.0, 56.0),
          IconButtonWidth.wide => const Size(72.0, 56.0),
        },
        ButtonSize.large => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(64.0, 96.0),
          IconButtonWidth.standard => const Size(96.0, 96.0),
          IconButtonWidth.wide => const Size(128.0, 96.0),
        },
        ButtonSize.xLarge => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(104.0, 136.0),
          IconButtonWidth.standard => const Size(136.0, 136.0),
          IconButtonWidth.wide => const Size(184.0, 136.0),
        },
      });

  @override
  WidgetStateProperty<Size>? get maximumSize => const MaterialStatePropertyAll<Size>(Size.infinite);

  @override
  WidgetStateProperty<double>? get iconSize =>
      MaterialStatePropertyAll<double>(switch (sizeVariant ?? ButtonSize.small) {
        ButtonSize.xSmall => 20.0,
        ButtonSize.small => 24.0,
        ButtonSize.medium => 24.0,
        ButtonSize.large => 32.0,
        ButtonSize.xLarge => 40.0,
      });

  @override
  WidgetStateProperty<OutlinedBorder>? get shape =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return switch (sizeVariant ?? ButtonSize.small) {
            ButtonSize.xSmall => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            ButtonSize.small => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            ButtonSize.medium => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            ButtonSize.large => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            ButtonSize.xLarge => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
          };
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return switch (shapeVariant ?? ButtonShapeVariant.round) {
            ButtonShapeVariant.round => switch (sizeVariant ?? ButtonSize.small) {
              ButtonSize.xSmall => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              ButtonSize.small => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              ButtonSize.medium => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              ButtonSize.large => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28.0)),
              ),
              ButtonSize.xLarge => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28.0)),
              ),
            },
            ButtonShapeVariant.square => switch (sizeVariant ?? ButtonSize.small) {
              ButtonSize.xSmall => const StadiumBorder(),
              ButtonSize.small => const StadiumBorder(),
              ButtonSize.medium => const StadiumBorder(),
              ButtonSize.large => const StadiumBorder(),
              ButtonSize.xLarge => const StadiumBorder(),
            },
          };
        }
        return switch (shapeVariant ?? ButtonShapeVariant.round) {
          ButtonShapeVariant.round => switch (sizeVariant ?? ButtonSize.small) {
            ButtonSize.xSmall => const StadiumBorder(),
            ButtonSize.small => const StadiumBorder(),
            ButtonSize.medium => const StadiumBorder(),
            ButtonSize.large => const StadiumBorder(),
            ButtonSize.xLarge => const StadiumBorder(),
          },
          ButtonShapeVariant.square => switch (sizeVariant ?? ButtonSize.small) {
            ButtonSize.xSmall => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            ButtonSize.small => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            ButtonSize.medium => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            ButtonSize.large => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(28.0)),
            ),
            ButtonSize.xLarge => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(28.0)),
            ),
          },
        };
      });

  @override
  WidgetStateProperty<BorderSide?>? get side => null;

  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor => WidgetStateMouseCursor.adaptiveClickable;

  @override
  VisualDensity? get visualDensity => VisualDensity.standard;

  @override
  MaterialTapTargetSize? get tapTargetSize => MaterialTapTargetSize.padded;

  @override
  InteractiveInkFeatureFactory? get splashFactory => Theme.of(context).splashFactory;
}

class _FilledIconButtonDefaultsM3E extends ButtonStyle {
  _FilledIconButtonDefaultsM3E(
    this.context,
    this.toggleable,
    this.sizeVariant,
    this.iconButtonWidth,
    this.shapeVariant,
  ) : super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: Alignment.center,
      );

  final BuildContext context;
  final bool toggleable;
  final ButtonSize? sizeVariant;
  final IconButtonWidth? iconButtonWidth;
  final ButtonShapeVariant? shapeVariant;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withOpacity(0.1);
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return _colors.primary;
        }
        if (toggleable) {
          return _colors.surfaceContainer;
        }
        return _colors.primary;
      });

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withOpacity(0.38);
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return _colors.onPrimary;
        }
        if (toggleable) {
          return _colors.onSurfaceVariant;
        }
        return _colors.onPrimary;
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (toggleable && states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.pressed)) {
            return _colors.onPrimary.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return _colors.onPrimary.withOpacity(0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return _colors.onPrimary.withOpacity(0.1);
          }
        }
        if (toggleable) {
          if (states.contains(WidgetState.pressed)) {
            return _colors.onSurfaceVariant.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return _colors.onSurfaceVariant.withOpacity(0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return _colors.onSurfaceVariant.withOpacity(0.1);
          }
        }
        if (states.contains(WidgetState.pressed)) {
          return _colors.onPrimary.withOpacity(0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.onPrimary.withOpacity(0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.onPrimary.withOpacity(0.1);
        }
        return Colors.transparent;
      });

  @override
  WidgetStateProperty<double>? get elevation => const MaterialStatePropertyAll<double>(0.0);

  @override
  WidgetStateProperty<Color>? get shadowColor =>
      const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
      const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding =>
      MaterialStatePropertyAll<EdgeInsetsGeometry>(switch (sizeVariant ?? ButtonSize.small) {
        ButtonSize.xSmall => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(4.0, 6.0, 4.0, 6.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(10.0, 6.0, 10.0, 6.0),
        },
        ButtonSize.small => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(14.0, 8.0, 14.0, 8.0),
        },
        ButtonSize.medium => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(12.0, 16.0, 12.0, 16.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
        },
        ButtonSize.large => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(16.0, 32.0, 16.0, 32.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(32.0, 32.0, 32.0, 32.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(48.0, 32.0, 48.0, 32.0),
        },
        ButtonSize.xLarge => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(32.0, 48.0, 32.0, 48.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(48.0, 48.0, 48.0, 48.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(72.0, 48.0, 72.0, 48.0),
        },
      });

  @override
  WidgetStateProperty<Size>? get minimumSize =>
      MaterialStatePropertyAll<Size>(switch (sizeVariant ?? ButtonSize.small) {
        ButtonSize.xSmall => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(28.0, 32.0),
          IconButtonWidth.standard => const Size(32.0, 32.0),
          IconButtonWidth.wide => const Size(40.0, 32.0),
        },
        ButtonSize.small => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(32.0, 40.0),
          IconButtonWidth.standard => const Size(40.0, 40.0),
          IconButtonWidth.wide => const Size(52.0, 40.0),
        },
        ButtonSize.medium => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(48.0, 56.0),
          IconButtonWidth.standard => const Size(56.0, 56.0),
          IconButtonWidth.wide => const Size(72.0, 56.0),
        },
        ButtonSize.large => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(64.0, 96.0),
          IconButtonWidth.standard => const Size(96.0, 96.0),
          IconButtonWidth.wide => const Size(128.0, 96.0),
        },
        ButtonSize.xLarge => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(104.0, 136.0),
          IconButtonWidth.standard => const Size(136.0, 136.0),
          IconButtonWidth.wide => const Size(184.0, 136.0),
        },
      });

  @override
  WidgetStateProperty<Size>? get maximumSize => const MaterialStatePropertyAll<Size>(Size.infinite);

  @override
  WidgetStateProperty<double>? get iconSize =>
      MaterialStatePropertyAll<double>(switch (sizeVariant ?? ButtonSize.small) {
        ButtonSize.xSmall => 20.0,
        ButtonSize.small => 24.0,
        ButtonSize.medium => 24.0,
        ButtonSize.large => 32.0,
        ButtonSize.xLarge => 40.0,
      });

  @override
  WidgetStateProperty<OutlinedBorder>? get shape =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return switch (sizeVariant ?? ButtonSize.small) {
            ButtonSize.xSmall => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            ButtonSize.small => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            ButtonSize.medium => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            ButtonSize.large => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            ButtonSize.xLarge => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
          };
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return switch (shapeVariant ?? ButtonShapeVariant.round) {
            ButtonShapeVariant.round => switch (sizeVariant ?? ButtonSize.small) {
              ButtonSize.xSmall => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              ButtonSize.small => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              ButtonSize.medium => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              ButtonSize.large => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28.0)),
              ),
              ButtonSize.xLarge => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28.0)),
              ),
            },
            ButtonShapeVariant.square => switch (sizeVariant ?? ButtonSize.small) {
              ButtonSize.xSmall => const StadiumBorder(),
              ButtonSize.small => const StadiumBorder(),
              ButtonSize.medium => const StadiumBorder(),
              ButtonSize.large => const StadiumBorder(),
              ButtonSize.xLarge => const StadiumBorder(),
            },
          };
        }
        return switch (shapeVariant ?? ButtonShapeVariant.round) {
          ButtonShapeVariant.round => switch (sizeVariant ?? ButtonSize.small) {
            ButtonSize.xSmall => const StadiumBorder(),
            ButtonSize.small => const StadiumBorder(),
            ButtonSize.medium => const StadiumBorder(),
            ButtonSize.large => const StadiumBorder(),
            ButtonSize.xLarge => const StadiumBorder(),
          },
          ButtonShapeVariant.square => switch (sizeVariant ?? ButtonSize.small) {
            ButtonSize.xSmall => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            ButtonSize.small => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            ButtonSize.medium => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            ButtonSize.large => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(28.0)),
            ),
            ButtonSize.xLarge => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(28.0)),
            ),
          },
        };
      });

  @override
  WidgetStateProperty<BorderSide?>? get side => null;

  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor => WidgetStateMouseCursor.adaptiveClickable;

  @override
  VisualDensity? get visualDensity => VisualDensity.standard;

  @override
  MaterialTapTargetSize? get tapTargetSize => MaterialTapTargetSize.padded;

  @override
  InteractiveInkFeatureFactory? get splashFactory => Theme.of(context).splashFactory;
}

class _FilledTonalIconButtonDefaultsM3E extends ButtonStyle {
  _FilledTonalIconButtonDefaultsM3E(
    this.context,
    this.toggleable,
    this.sizeVariant,
    this.iconButtonWidth,
    this.shapeVariant,
  ) : super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: Alignment.center,
      );

  final BuildContext context;
  final bool toggleable;
  final ButtonSize? sizeVariant;
  final IconButtonWidth? iconButtonWidth;
  final ButtonShapeVariant? shapeVariant;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withOpacity(0.1);
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return _colors.secondary;
        }
        if (toggleable) {
          return _colors.secondaryContainer;
        }
        return _colors.secondaryContainer;
      });

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withOpacity(0.38);
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return _colors.onSecondary;
        }
        if (toggleable) {
          return _colors.onSecondaryContainer;
        }
        return _colors.onSecondaryContainer;
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (toggleable && states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.pressed)) {
            return _colors.onSecondary.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return _colors.onSecondary.withOpacity(0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return _colors.onSecondary.withOpacity(0.1);
          }
        }
        if (toggleable) {
          if (states.contains(WidgetState.pressed)) {
            return _colors.onSecondaryContainer.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return _colors.onSecondaryContainer.withOpacity(0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return _colors.onSecondaryContainer.withOpacity(0.1);
          }
        }
        if (states.contains(WidgetState.pressed)) {
          return _colors.onSecondaryContainer.withOpacity(0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.onSecondaryContainer.withOpacity(0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.onSecondaryContainer.withOpacity(0.1);
        }
        return Colors.transparent;
      });

  @override
  WidgetStateProperty<double>? get elevation => const MaterialStatePropertyAll<double>(0.0);

  @override
  WidgetStateProperty<Color>? get shadowColor =>
      const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
      const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding =>
      MaterialStatePropertyAll<EdgeInsetsGeometry>(switch (sizeVariant ?? ButtonSize.small) {
        ButtonSize.xSmall => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(4.0, 6.0, 4.0, 6.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(10.0, 6.0, 10.0, 6.0),
        },
        ButtonSize.small => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(14.0, 8.0, 14.0, 8.0),
        },
        ButtonSize.medium => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(12.0, 16.0, 12.0, 16.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
        },
        ButtonSize.large => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(16.0, 32.0, 16.0, 32.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(32.0, 32.0, 32.0, 32.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(48.0, 32.0, 48.0, 32.0),
        },
        ButtonSize.xLarge => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(32.0, 48.0, 32.0, 48.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(48.0, 48.0, 48.0, 48.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(72.0, 48.0, 72.0, 48.0),
        },
      });

  @override
  WidgetStateProperty<Size>? get minimumSize =>
      MaterialStatePropertyAll<Size>(switch (sizeVariant ?? ButtonSize.small) {
        ButtonSize.xSmall => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(28.0, 32.0),
          IconButtonWidth.standard => const Size(32.0, 32.0),
          IconButtonWidth.wide => const Size(40.0, 32.0),
        },
        ButtonSize.small => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(32.0, 40.0),
          IconButtonWidth.standard => const Size(40.0, 40.0),
          IconButtonWidth.wide => const Size(52.0, 40.0),
        },
        ButtonSize.medium => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(48.0, 56.0),
          IconButtonWidth.standard => const Size(56.0, 56.0),
          IconButtonWidth.wide => const Size(72.0, 56.0),
        },
        ButtonSize.large => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(64.0, 96.0),
          IconButtonWidth.standard => const Size(96.0, 96.0),
          IconButtonWidth.wide => const Size(128.0, 96.0),
        },
        ButtonSize.xLarge => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(104.0, 136.0),
          IconButtonWidth.standard => const Size(136.0, 136.0),
          IconButtonWidth.wide => const Size(184.0, 136.0),
        },
      });

  @override
  WidgetStateProperty<Size>? get maximumSize => const MaterialStatePropertyAll<Size>(Size.infinite);

  @override
  WidgetStateProperty<double>? get iconSize =>
      MaterialStatePropertyAll<double>(switch (sizeVariant ?? ButtonSize.small) {
        ButtonSize.xSmall => 20.0,
        ButtonSize.small => 24.0,
        ButtonSize.medium => 24.0,
        ButtonSize.large => 32.0,
        ButtonSize.xLarge => 40.0,
      });

  @override
  WidgetStateProperty<OutlinedBorder>? get shape =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return switch (sizeVariant ?? ButtonSize.small) {
            ButtonSize.xSmall => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            ButtonSize.small => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            ButtonSize.medium => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            ButtonSize.large => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            ButtonSize.xLarge => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
          };
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return switch (shapeVariant ?? ButtonShapeVariant.round) {
            ButtonShapeVariant.round => switch (sizeVariant ?? ButtonSize.small) {
              ButtonSize.xSmall => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              ButtonSize.small => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              ButtonSize.medium => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              ButtonSize.large => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28.0)),
              ),
              ButtonSize.xLarge => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28.0)),
              ),
            },
            ButtonShapeVariant.square => switch (sizeVariant ?? ButtonSize.small) {
              ButtonSize.xSmall => const StadiumBorder(),
              ButtonSize.small => const StadiumBorder(),
              ButtonSize.medium => const StadiumBorder(),
              ButtonSize.large => const StadiumBorder(),
              ButtonSize.xLarge => const StadiumBorder(),
            },
          };
        }
        return switch (shapeVariant ?? ButtonShapeVariant.round) {
          ButtonShapeVariant.round => switch (sizeVariant ?? ButtonSize.small) {
            ButtonSize.xSmall => const StadiumBorder(),
            ButtonSize.small => const StadiumBorder(),
            ButtonSize.medium => const StadiumBorder(),
            ButtonSize.large => const StadiumBorder(),
            ButtonSize.xLarge => const StadiumBorder(),
          },
          ButtonShapeVariant.square => switch (sizeVariant ?? ButtonSize.small) {
            ButtonSize.xSmall => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            ButtonSize.small => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            ButtonSize.medium => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            ButtonSize.large => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(28.0)),
            ),
            ButtonSize.xLarge => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(28.0)),
            ),
          },
        };
      });

  @override
  WidgetStateProperty<BorderSide?>? get side => null;

  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor => WidgetStateMouseCursor.adaptiveClickable;

  @override
  VisualDensity? get visualDensity => VisualDensity.standard;

  @override
  MaterialTapTargetSize? get tapTargetSize => MaterialTapTargetSize.padded;

  @override
  InteractiveInkFeatureFactory? get splashFactory => Theme.of(context).splashFactory;
}

class _OutlinedIconButtonDefaultsM3E extends ButtonStyle {
  _OutlinedIconButtonDefaultsM3E(
    this.context,
    this.toggleable,
    this.sizeVariant,
    this.iconButtonWidth,
    this.shapeVariant,
  ) : super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: Alignment.center,
      );

  final BuildContext context;
  final bool toggleable;
  final ButtonSize? sizeVariant;
  final IconButtonWidth? iconButtonWidth;
  final ButtonShapeVariant? shapeVariant;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          if (toggleable && states.contains(WidgetState.selected)) {
            return _colors.onSurface.withOpacity(0.1);
          }
          return Colors.transparent;
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return _colors.inverseSurface;
        }
        return Colors.transparent;
      });

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withOpacity(0.38);
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return _colors.onInverseSurface;
        }
        return _colors.onSurfaceVariant;
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (toggleable && states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.pressed)) {
            return _colors.onInverseSurface.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return _colors.onInverseSurface.withOpacity(0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return _colors.onInverseSurface.withOpacity(0.1);
          }
        }
        if (states.contains(WidgetState.pressed)) {
          return _colors.onSurfaceVariant.withOpacity(0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.onSurfaceVariant.withOpacity(0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.onSurfaceVariant.withOpacity(0.1);
        }
        return Colors.transparent;
      });

  @override
  WidgetStateProperty<double>? get elevation => const MaterialStatePropertyAll<double>(0.0);

  @override
  WidgetStateProperty<Color>? get shadowColor =>
      const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
      const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding =>
      MaterialStatePropertyAll<EdgeInsetsGeometry>(switch (sizeVariant ?? ButtonSize.small) {
        ButtonSize.xSmall => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(4.0, 6.0, 4.0, 6.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(10.0, 6.0, 10.0, 6.0),
        },
        ButtonSize.small => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(14.0, 8.0, 14.0, 8.0),
        },
        ButtonSize.medium => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(12.0, 16.0, 12.0, 16.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
        },
        ButtonSize.large => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(16.0, 32.0, 16.0, 32.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(32.0, 32.0, 32.0, 32.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(48.0, 32.0, 48.0, 32.0),
        },
        ButtonSize.xLarge => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const EdgeInsetsDirectional.fromSTEB(32.0, 48.0, 32.0, 48.0),
          IconButtonWidth.standard => const EdgeInsetsDirectional.fromSTEB(48.0, 48.0, 48.0, 48.0),
          IconButtonWidth.wide => const EdgeInsetsDirectional.fromSTEB(72.0, 48.0, 72.0, 48.0),
        },
      });

  @override
  WidgetStateProperty<Size>? get minimumSize =>
      MaterialStatePropertyAll<Size>(switch (sizeVariant ?? ButtonSize.small) {
        ButtonSize.xSmall => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(28.0, 32.0),
          IconButtonWidth.standard => const Size(32.0, 32.0),
          IconButtonWidth.wide => const Size(40.0, 32.0),
        },
        ButtonSize.small => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(32.0, 40.0),
          IconButtonWidth.standard => const Size(40.0, 40.0),
          IconButtonWidth.wide => const Size(52.0, 40.0),
        },
        ButtonSize.medium => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(48.0, 56.0),
          IconButtonWidth.standard => const Size(56.0, 56.0),
          IconButtonWidth.wide => const Size(72.0, 56.0),
        },
        ButtonSize.large => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(64.0, 96.0),
          IconButtonWidth.standard => const Size(96.0, 96.0),
          IconButtonWidth.wide => const Size(128.0, 96.0),
        },
        ButtonSize.xLarge => switch (iconButtonWidth ?? IconButtonWidth.standard) {
          IconButtonWidth.narrow => const Size(104.0, 136.0),
          IconButtonWidth.standard => const Size(136.0, 136.0),
          IconButtonWidth.wide => const Size(184.0, 136.0),
        },
      });

  @override
  WidgetStateProperty<Size>? get maximumSize => const MaterialStatePropertyAll<Size>(Size.infinite);

  @override
  WidgetStateProperty<double>? get iconSize =>
      MaterialStatePropertyAll<double>(switch (sizeVariant ?? ButtonSize.small) {
        ButtonSize.xSmall => 20.0,
        ButtonSize.small => 24.0,
        ButtonSize.medium => 24.0,
        ButtonSize.large => 32.0,
        ButtonSize.xLarge => 40.0,
      });

  @override
  WidgetStateProperty<OutlinedBorder>? get shape =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return switch (sizeVariant ?? ButtonSize.small) {
            ButtonSize.xSmall => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            ButtonSize.small => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            ButtonSize.medium => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            ButtonSize.large => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            ButtonSize.xLarge => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
          };
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return switch (shapeVariant ?? ButtonShapeVariant.round) {
            ButtonShapeVariant.round => switch (sizeVariant ?? ButtonSize.small) {
              ButtonSize.xSmall => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              ButtonSize.small => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              ButtonSize.medium => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              ButtonSize.large => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28.0)),
              ),
              ButtonSize.xLarge => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28.0)),
              ),
            },
            ButtonShapeVariant.square => switch (sizeVariant ?? ButtonSize.small) {
              ButtonSize.xSmall => const StadiumBorder(),
              ButtonSize.small => const StadiumBorder(),
              ButtonSize.medium => const StadiumBorder(),
              ButtonSize.large => const StadiumBorder(),
              ButtonSize.xLarge => const StadiumBorder(),
            },
          };
        }
        return switch (shapeVariant ?? ButtonShapeVariant.round) {
          ButtonShapeVariant.round => switch (sizeVariant ?? ButtonSize.small) {
            ButtonSize.xSmall => const StadiumBorder(),
            ButtonSize.small => const StadiumBorder(),
            ButtonSize.medium => const StadiumBorder(),
            ButtonSize.large => const StadiumBorder(),
            ButtonSize.xLarge => const StadiumBorder(),
          },
          ButtonShapeVariant.square => switch (sizeVariant ?? ButtonSize.small) {
            ButtonSize.xSmall => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            ButtonSize.small => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            ButtonSize.medium => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            ButtonSize.large => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(28.0)),
            ),
            ButtonSize.xLarge => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(28.0)),
            ),
          },
        };
      });

  @override
  WidgetStateProperty<BorderSide?>? get side =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (toggleable && states.contains(WidgetState.selected)) {
          return null;
        }
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(
            color: _colors.outlineVariant,
            width: switch (sizeVariant ?? ButtonSize.small) {
              ButtonSize.xSmall => 1.0,
              ButtonSize.small => 1.0,
              ButtonSize.medium => 1.0,
              ButtonSize.large => 2.0,
              ButtonSize.xLarge => 3.0,
            },
          );
        }
        return BorderSide(
          color: _colors.outlineVariant,
          width: switch (sizeVariant ?? ButtonSize.small) {
            ButtonSize.xSmall => 1.0,
            ButtonSize.small => 1.0,
            ButtonSize.medium => 1.0,
            ButtonSize.large => 2.0,
            ButtonSize.xLarge => 3.0,
          },
        );
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
