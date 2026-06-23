// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Version: 38.0.1

import 'color_role.dart';
import 'shape_struct.dart';
import 'typescale.dart';
import 'typescale_struct.dart';

class TokenChips {
  /// md.comp.chips.avatar.shape
  static const ShapeStruct avatarShape = ShapeStruct(
    family: 'SHAPE_FAMILY_CIRCULAR',
    topLeft: 0.00,
    topRight: 0.00,
    bottomLeft: 0.00,
    bottomRight: 0.00,
  );

  /// md.comp.chips.avatar.size
  static const double avatarSize = 24.00;

  /// md.comp.chips.container.elevation
  static const double containerElevation = 0.00;

  /// md.comp.chips.disabled.avatar.opacity
  static const double disabledAvatarOpacity = 0.38;

  /// md.comp.chips.disabled.label-text.opacity
  static const double disabledLabelTextOpacity = 0.38;

  /// md.comp.chips.disabled.leading-icon.opacity
  static const double disabledLeadingIconOpacity = 0.38;

  /// md.comp.chips.disabled.trailing-icon.opacity
  static const double disabledTrailingIconOpacity = 0.38;

  /// md.comp.chips.dragged.container.elevation
  static const double draggedContainerElevation = 8.00;

  /// md.comp.chips.filter.padding.leading
  static const double filterPaddingLeading = 16.00;

  /// md.comp.chips.filter.padding.trailing
  static const double filterPaddingTrailing = 16.00;

  /// md.comp.chips.focused.indicator.outline.offset
  static const double focusedIndicatorOutlineOffset = 2.00;

  /// md.comp.chips.focused.indicator.thickness
  static const double focusedIndicatorThickness = 3.00;

  /// md.comp.chips.gap.horizontal
  static const double gapHorizontal = 4.00;

  /// md.comp.chips.height
  static const double height = 32.00;

  /// md.comp.chips.input.padding.leading
  static const double inputPaddingLeading = 12.00;

  /// md.comp.chips.input.padding.trailing
  static const double inputPaddingTrailing = 12.00;

  /// md.comp.chips.label-text
  static const TypescaleStruct labelText = TokenTypescale.labelLarge;

  /// md.comp.chips.leading-icon.size
  static const double leadingIconSize = 18.00;

  /// md.comp.chips.padding.bottom
  static const double paddingBottom = 6.00;

  /// md.comp.chips.padding.top
  static const double paddingTop = 6.00;

  /// md.comp.chips.pressed.shape
  static const ShapeStruct pressedShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 8.00,
    topRight: 8.00,
    bottomLeft: 8.00,
    bottomRight: 8.00,
  );

  /// md.comp.chips.selected.disabled.container.opacity
  static const double selectedDisabledContainerOpacity = 0.12;

  /// md.comp.chips.selected.dragged.state-layer.opacity
  static const double selectedDraggedStateLayerOpacity = 0.16;

  /// md.comp.chips.selected.focused.state-layer.opacity
  static const double selectedFocusedStateLayerOpacity = 0.10;

  /// md.comp.chips.selected.hovered.state-layer.opacity
  static const double selectedHoveredStateLayerOpacity = 0.08;

  /// md.comp.chips.selected.outline.width
  static const double selectedOutlineWidth = 0.00;

  /// md.comp.chips.selected.pressed.state-layer.opacity
  static const double selectedPressedStateLayerOpacity = 0.10;

  /// md.comp.chips.selected.shape
  static const ShapeStruct selectedShape = ShapeStruct(
    family: 'SHAPE_FAMILY_CIRCULAR',
    topLeft: 0.00,
    topRight: 0.00,
    bottomLeft: 0.00,
    bottomRight: 0.00,
  );

  /// md.comp.chips.state-layer.opacity
  static const double stateLayerOpacity = 0.00;

  /// md.comp.chips.trailing-icon.size
  static const double trailingIconSize = 18.00;

  /// md.comp.chips.unselected.disabled.outline.opacity
  static const double unselectedDisabledOutlineOpacity = 0.10;

  /// md.comp.chips.unselected.dragged.state-layer.opacity
  static const double unselectedDraggedStateLayerOpacity = 0.16;

  /// md.comp.chips.unselected.focused.state-layer.opacity
  static const double unselectedFocusedStateLayerOpacity = 0.10;

  /// md.comp.chips.unselected.hovered.state-layer.opacity
  static const double unselectedHoveredStateLayerOpacity = 0.08;

  /// md.comp.chips.unselected.outline.width
  static const double unselectedOutlineWidth = 1.00;

  /// md.comp.chips.unselected.pressed.state-layer.opacity
  static const double unselectedPressedStateLayerOpacity = 0.10;

  /// md.comp.chips.unselected.shape
  static const ShapeStruct unselectedShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 12.00,
    topRight: 12.00,
    bottomLeft: 12.00,
    bottomRight: 12.00,
  );

  /// md.comp.chips.with-avatar.padding.leading
  static const double withAvatarPaddingLeading = 4.00;

  /// md.comp.chips.with-leading-icon.padding.leading
  static const double withLeadingIconPaddingLeading = 8.00;

  /// md.comp.chips.with-trailing-icon.padding.trailing
  static const double withTrailingIconPaddingTrailing = 8.00;
}

class TokenChipsDarkDefault {
  /// md.comp.chips.disabled.label-text.color
  static const TokenColorRole disabledLabelTextColor = TokenColorRole.onSurface;

  /// md.comp.chips.disabled.leading-icon.color
  static const TokenColorRole disabledLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.disabled.trailing-icon.color
  static const TokenColorRole disabledTrailingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.focused.indicator.color
  static const TokenColorRole focusedIndicatorColor = TokenColorRole.secondary;

  /// md.comp.chips.selected.container.color
  static const TokenColorRole selectedContainerColor =
      TokenColorRole.secondaryContainer;

  /// md.comp.chips.selected.disabled.container.color
  static const TokenColorRole selectedDisabledContainerColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.selected.label-text.color
  static const TokenColorRole selectedLabelTextColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.leading-icon.color
  static const TokenColorRole selectedLeadingIconColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.state-layer.color
  static const TokenColorRole selectedStateLayerColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.trailing-icon.color
  static const TokenColorRole selectedTrailingIconColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.unselected.disabled.outline.color
  static const TokenColorRole unselectedDisabledOutlineColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.unselected.label-text.color
  static const TokenColorRole unselectedLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.leading-icon.color
  static const TokenColorRole unselectedLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.outline.color
  static const TokenColorRole unselectedOutlineColor =
      TokenColorRole.outlineVariant;

  /// md.comp.chips.unselected.state-layer.color
  static const TokenColorRole unselectedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.trailing-icon.color
  static const TokenColorRole unselectedTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenChipsDarkHighContrast {
  /// md.comp.chips.disabled.label-text.color
  static const TokenColorRole disabledLabelTextColor = TokenColorRole.onSurface;

  /// md.comp.chips.disabled.leading-icon.color
  static const TokenColorRole disabledLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.disabled.trailing-icon.color
  static const TokenColorRole disabledTrailingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.focused.indicator.color
  static const TokenColorRole focusedIndicatorColor = TokenColorRole.secondary;

  /// md.comp.chips.selected.container.color
  static const TokenColorRole selectedContainerColor =
      TokenColorRole.secondaryContainer;

  /// md.comp.chips.selected.disabled.container.color
  static const TokenColorRole selectedDisabledContainerColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.selected.label-text.color
  static const TokenColorRole selectedLabelTextColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.leading-icon.color
  static const TokenColorRole selectedLeadingIconColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.state-layer.color
  static const TokenColorRole selectedStateLayerColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.trailing-icon.color
  static const TokenColorRole selectedTrailingIconColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.unselected.disabled.outline.color
  static const TokenColorRole unselectedDisabledOutlineColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.unselected.label-text.color
  static const TokenColorRole unselectedLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.leading-icon.color
  static const TokenColorRole unselectedLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.outline.color
  static const TokenColorRole unselectedOutlineColor =
      TokenColorRole.outlineVariant;

  /// md.comp.chips.unselected.state-layer.color
  static const TokenColorRole unselectedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.trailing-icon.color
  static const TokenColorRole unselectedTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenChipsDarkMediumContrast {
  /// md.comp.chips.disabled.label-text.color
  static const TokenColorRole disabledLabelTextColor = TokenColorRole.onSurface;

  /// md.comp.chips.disabled.leading-icon.color
  static const TokenColorRole disabledLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.disabled.trailing-icon.color
  static const TokenColorRole disabledTrailingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.focused.indicator.color
  static const TokenColorRole focusedIndicatorColor = TokenColorRole.secondary;

  /// md.comp.chips.selected.container.color
  static const TokenColorRole selectedContainerColor =
      TokenColorRole.secondaryContainer;

  /// md.comp.chips.selected.disabled.container.color
  static const TokenColorRole selectedDisabledContainerColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.selected.label-text.color
  static const TokenColorRole selectedLabelTextColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.leading-icon.color
  static const TokenColorRole selectedLeadingIconColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.state-layer.color
  static const TokenColorRole selectedStateLayerColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.trailing-icon.color
  static const TokenColorRole selectedTrailingIconColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.unselected.disabled.outline.color
  static const TokenColorRole unselectedDisabledOutlineColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.unselected.label-text.color
  static const TokenColorRole unselectedLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.leading-icon.color
  static const TokenColorRole unselectedLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.outline.color
  static const TokenColorRole unselectedOutlineColor =
      TokenColorRole.outlineVariant;

  /// md.comp.chips.unselected.state-layer.color
  static const TokenColorRole unselectedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.trailing-icon.color
  static const TokenColorRole unselectedTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenChipsLightDefault {
  /// md.comp.chips.disabled.label-text.color
  static const TokenColorRole disabledLabelTextColor = TokenColorRole.onSurface;

  /// md.comp.chips.disabled.leading-icon.color
  static const TokenColorRole disabledLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.disabled.trailing-icon.color
  static const TokenColorRole disabledTrailingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.focused.indicator.color
  static const TokenColorRole focusedIndicatorColor = TokenColorRole.secondary;

  /// md.comp.chips.selected.container.color
  static const TokenColorRole selectedContainerColor =
      TokenColorRole.secondaryContainer;

  /// md.comp.chips.selected.disabled.container.color
  static const TokenColorRole selectedDisabledContainerColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.selected.label-text.color
  static const TokenColorRole selectedLabelTextColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.leading-icon.color
  static const TokenColorRole selectedLeadingIconColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.state-layer.color
  static const TokenColorRole selectedStateLayerColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.trailing-icon.color
  static const TokenColorRole selectedTrailingIconColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.unselected.disabled.outline.color
  static const TokenColorRole unselectedDisabledOutlineColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.unselected.label-text.color
  static const TokenColorRole unselectedLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.leading-icon.color
  static const TokenColorRole unselectedLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.outline.color
  static const TokenColorRole unselectedOutlineColor =
      TokenColorRole.outlineVariant;

  /// md.comp.chips.unselected.state-layer.color
  static const TokenColorRole unselectedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.trailing-icon.color
  static const TokenColorRole unselectedTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenChipsLightHighContrast {
  /// md.comp.chips.disabled.label-text.color
  static const TokenColorRole disabledLabelTextColor = TokenColorRole.onSurface;

  /// md.comp.chips.disabled.leading-icon.color
  static const TokenColorRole disabledLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.disabled.trailing-icon.color
  static const TokenColorRole disabledTrailingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.focused.indicator.color
  static const TokenColorRole focusedIndicatorColor = TokenColorRole.secondary;

  /// md.comp.chips.selected.container.color
  static const TokenColorRole selectedContainerColor =
      TokenColorRole.secondaryContainer;

  /// md.comp.chips.selected.disabled.container.color
  static const TokenColorRole selectedDisabledContainerColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.selected.label-text.color
  static const TokenColorRole selectedLabelTextColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.leading-icon.color
  static const TokenColorRole selectedLeadingIconColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.state-layer.color
  static const TokenColorRole selectedStateLayerColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.trailing-icon.color
  static const TokenColorRole selectedTrailingIconColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.unselected.disabled.outline.color
  static const TokenColorRole unselectedDisabledOutlineColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.unselected.label-text.color
  static const TokenColorRole unselectedLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.leading-icon.color
  static const TokenColorRole unselectedLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.outline.color
  static const TokenColorRole unselectedOutlineColor =
      TokenColorRole.outlineVariant;

  /// md.comp.chips.unselected.state-layer.color
  static const TokenColorRole unselectedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.trailing-icon.color
  static const TokenColorRole unselectedTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenChipsLightMediumContrast {
  /// md.comp.chips.disabled.label-text.color
  static const TokenColorRole disabledLabelTextColor = TokenColorRole.onSurface;

  /// md.comp.chips.disabled.leading-icon.color
  static const TokenColorRole disabledLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.disabled.trailing-icon.color
  static const TokenColorRole disabledTrailingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.focused.indicator.color
  static const TokenColorRole focusedIndicatorColor = TokenColorRole.secondary;

  /// md.comp.chips.selected.container.color
  static const TokenColorRole selectedContainerColor =
      TokenColorRole.secondaryContainer;

  /// md.comp.chips.selected.disabled.container.color
  static const TokenColorRole selectedDisabledContainerColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.selected.label-text.color
  static const TokenColorRole selectedLabelTextColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.leading-icon.color
  static const TokenColorRole selectedLeadingIconColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.state-layer.color
  static const TokenColorRole selectedStateLayerColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.selected.trailing-icon.color
  static const TokenColorRole selectedTrailingIconColor =
      TokenColorRole.onSecondaryContainer;

  /// md.comp.chips.unselected.disabled.outline.color
  static const TokenColorRole unselectedDisabledOutlineColor =
      TokenColorRole.onSurface;

  /// md.comp.chips.unselected.label-text.color
  static const TokenColorRole unselectedLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.leading-icon.color
  static const TokenColorRole unselectedLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.outline.color
  static const TokenColorRole unselectedOutlineColor =
      TokenColorRole.outlineVariant;

  /// md.comp.chips.unselected.state-layer.color
  static const TokenColorRole unselectedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.chips.unselected.trailing-icon.color
  static const TokenColorRole unselectedTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}
