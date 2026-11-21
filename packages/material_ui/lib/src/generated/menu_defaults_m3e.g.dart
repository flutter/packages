// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Do not edit by hand. The code is generated from data in the Material
// Design token database by the script:
//   packages/material_ui/tool/gen_defaults/bin/gen_defaults.dart.
part of '../menu_anchor.dart';

class _MenuButtonDefaultsM3E extends _MenuButtonDefaultsM3 {
  _MenuButtonDefaultsM3E(super.context);

  @override
  WidgetStateProperty<Color?>? get backgroundColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.tertiaryContainer.withValues(alpha: 0.38);
        }
        return _colors.tertiaryContainer;
      }
      return Colors.transparent;
    });
  }

  @override
  WidgetStateProperty<Color?>? get foregroundColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onTertiaryContainer.withValues(alpha: 0.38);
        }
        if (states.contains(WidgetState.pressed)) {
          return _colors.onTertiaryContainer;
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.onTertiaryContainer;
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.onTertiaryContainer;
        }
        return _colors.onTertiaryContainer;
      }
      if (states.contains(WidgetState.disabled)) {
        return _colors.onSurface.withValues(alpha: 0.38);
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
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onTertiaryContainer.withValues(alpha: 0.38);
        }
        if (states.contains(WidgetState.pressed)) {
          return _colors.onTertiaryContainer;
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.onTertiaryContainer;
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.onTertiaryContainer;
        }
        return _colors.onTertiaryContainer;
      }
      if (states.contains(WidgetState.disabled)) {
        return _colors.onSurface.withValues(alpha: 0.38);
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

  @override
  WidgetStateProperty<Color?>? get overlayColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return _colors.onTertiaryContainer.withValues(alpha: 0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.onTertiaryContainer.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.onTertiaryContainer.withValues(alpha: 0.1);
        }
        return Colors.transparent;
      }
      if (states.contains(WidgetState.pressed)) {
        return _colors.onSurface.withValues(alpha: 0.1);
      }
      if (states.contains(WidgetState.hovered)) {
        return _colors.onSurface.withValues(alpha: 0.08);
      }
      if (states.contains(WidgetState.focused)) {
        return _colors.onSurface.withValues(alpha: 0.1);
      }
      return Colors.transparent;
    });
  }
}

class _MenuDefaultsM3E extends _MenuDefaultsM3 {
  _MenuDefaultsM3E(super.context);

  @override
  WidgetStateProperty<Color?> get backgroundColor {
    return MaterialStatePropertyAll<Color?>(_colors.surfaceContainerLow);
  }

  @override
  WidgetStateProperty<Color?>? get shadowColor {
    return MaterialStatePropertyAll<Color?>(_colors.shadow);
  }
}
