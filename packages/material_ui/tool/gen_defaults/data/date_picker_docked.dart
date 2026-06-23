// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Version: 38.0.1

import 'color_role.dart';
import 'shape_struct.dart';
import 'typescale.dart';
import 'typescale_struct.dart';

class TokenDatePickerDocked {
  /// md.comp.date-picker.docked.container.elevation
  static const double containerElevation = 6.00;

  /// md.comp.date-picker.docked.container.height
  static const double containerHeight = 456.00;

  /// md.comp.date-picker.docked.container.shape
  static const ShapeStruct containerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 16.00,
    topRight: 16.00,
    bottomLeft: 16.00,
    bottomRight: 16.00,
  );

  /// md.comp.date-picker.docked.container.width
  static const double containerWidth = 360.00;

  /// md.comp.date-picker.docked.date.container.height
  static const double dateContainerHeight = 48.00;

  /// md.comp.date-picker.docked.date.container.shape
  static const ShapeStruct dateContainerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_CIRCULAR',
    topLeft: 0.00,
    topRight: 0.00,
    bottomLeft: 0.00,
    bottomRight: 0.00,
  );

  /// md.comp.date-picker.docked.date.container.width
  static const double dateContainerWidth = 48.00;

  /// md.comp.date-picker.docked.date.focus.state-layer.opacity
  static const double dateFocusStateLayerOpacity = 0.10;

  /// md.comp.date-picker.docked.date.hover.state-layer.opacity
  static const double dateHoverStateLayerOpacity = 0.08;

  /// md.comp.date-picker.docked.date.label-text.type
  static const TypescaleStruct dateLabelTextType = TokenTypescale.bodyLarge;

  /// md.comp.date-picker.docked.date.pressed.state-layer.opacity
  static const double datePressedStateLayerOpacity = 0.10;

  /// md.comp.date-picker.docked.date.state-layer.height
  static const double dateStateLayerHeight = 40.00;

  /// md.comp.date-picker.docked.date.state-layer.shape
  static const ShapeStruct dateStateLayerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_CIRCULAR',
    topLeft: 0.00,
    topRight: 0.00,
    bottomLeft: 0.00,
    bottomRight: 0.00,
  );

  /// md.comp.date-picker.docked.date.state-layer.width
  static const double dateStateLayerWidth = 40.00;

  /// md.comp.date-picker.docked.date.today.container.outline.width
  static const double dateTodayContainerOutlineWidth = 1.00;

  /// md.comp.date-picker.docked.date.unselected.outside-month.label-text.opacity
  static const double dateUnselectedOutsideMonthLabelTextOpacity = 0.38;

  /// md.comp.date-picker.docked.header.height
  static const double headerHeight = 64.00;

  /// md.comp.date-picker.docked.menu-button.container.height
  static const double menuButtonContainerHeight = 40.00;

  /// md.comp.date-picker.docked.menu-button.container.shape
  static const ShapeStruct menuButtonContainerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_CIRCULAR',
    topLeft: 0.00,
    topRight: 0.00,
    bottomLeft: 0.00,
    bottomRight: 0.00,
  );

  /// md.comp.date-picker.docked.menu-button.disabled.icon.opacity
  static const double menuButtonDisabledIconOpacity = 0.38;

  /// md.comp.date-picker.docked.menu-button.disabled.label-text.opacity
  static const double menuButtonDisabledLabelTextOpacity = 0.38;

  /// md.comp.date-picker.docked.menu-button.focus.state-layer.opacity
  static const double menuButtonFocusStateLayerOpacity = 0.10;

  /// md.comp.date-picker.docked.menu-button.hover.state-layer.opacity
  static const double menuButtonHoverStateLayerOpacity = 0.08;

  /// md.comp.date-picker.docked.menu-button.icon.size
  static const double menuButtonIconSize = 18.00;

  /// md.comp.date-picker.docked.menu-button.label-text.type
  static const TypescaleStruct menuButtonLabelTextType =
      TokenTypescale.labelLarge;

  /// md.comp.date-picker.docked.menu-button.pressed.state-layer.opacity
  static const double menuButtonPressedStateLayerOpacity = 0.10;

  /// md.comp.date-picker.docked.menu.list-item.container.height
  static const double menuListItemContainerHeight = 48.00;

  /// md.comp.date-picker.docked.menu.list-item.focus.state-layer.opacity
  static const double menuListItemFocusStateLayerOpacity = 0.10;

  /// md.comp.date-picker.docked.menu.list-item.hover.state-layer.opacity
  static const double menuListItemHoverStateLayerOpacity = 0.08;

  /// md.comp.date-picker.docked.menu.list-item.label-text.type
  static const TypescaleStruct menuListItemLabelTextType =
      TokenTypescale.bodyLarge;

  /// md.comp.date-picker.docked.menu.list-item.pressed.state-layer.opacity
  static const double menuListItemPressedStateLayerOpacity = 0.10;

  /// md.comp.date-picker.docked.menu.list-item.selected.leading-icon.size
  static const double menuListItemSelectedLeadingIconSize = 24.00;

  /// md.comp.date-picker.docked.weekdays.label-text.type
  static const TypescaleStruct weekdaysLabelTextType = TokenTypescale.bodyLarge;
}

class TokenDatePickerDockedDark {
  /// md.comp.date-picker.docked.container.color
  static const TokenColorRole containerColor =
      TokenColorRole.surfaceContainerHigh;

  /// md.comp.date-picker.docked.menu.list-item.selected.container.color
  static const TokenColorRole menuListItemSelectedContainerColor =
      TokenColorRole.surfaceVariant;
}

class TokenDatePickerDockedDarkDefault {
  /// md.comp.date-picker.docked.date.selected.container.color
  static const TokenColorRole dateSelectedContainerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.selected.focus.state-layer.color
  static const TokenColorRole dateSelectedFocusStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.hover.state-layer.color
  static const TokenColorRole dateSelectedHoverStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.label-text.color
  static const TokenColorRole dateSelectedLabelTextColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.pressed.state-layer.color
  static const TokenColorRole dateSelectedPressedStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.today.container.outline.color
  static const TokenColorRole dateTodayContainerOutlineColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.focus.state-layer.color
  static const TokenColorRole dateTodayFocusStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.hover.state-layer.color
  static const TokenColorRole dateTodayHoverStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.label-text.color
  static const TokenColorRole dateTodayLabelTextColor = TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.pressed.state-layer.color
  static const TokenColorRole dateTodayPressedStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.unselected.focus.state-layer.color
  static const TokenColorRole dateUnselectedFocusStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.date.unselected.hover.state-layer.color
  static const TokenColorRole dateUnselectedHoverStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.date.unselected.label-text.color
  static const TokenColorRole dateUnselectedLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.date.unselected.outside-month.label-text.color
  static const TokenColorRole dateUnselectedOutsideMonthLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.date.unselected.pressed.state-layer.color
  static const TokenColorRole dateUnselectedPressedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.disabled.icon.color
  static const TokenColorRole menuButtonDisabledIconColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu-button.disabled.label-text.color
  static const TokenColorRole menuButtonDisabledLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu-button.focus.icon.color
  static const TokenColorRole menuButtonFocusIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.focus.label-text.color
  static const TokenColorRole menuButtonFocusLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.focus.state-layer.color
  static const TokenColorRole menuButtonFocusStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.icon.color
  static const TokenColorRole menuButtonHoverIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.label-text.color
  static const TokenColorRole menuButtonHoverLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.state-layer.color
  static const TokenColorRole menuButtonHoverStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.icon.color
  static const TokenColorRole menuButtonIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.label-text.color
  static const TokenColorRole menuButtonLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.icon.color
  static const TokenColorRole menuButtonPressedIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.label-text.color
  static const TokenColorRole menuButtonPressedLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.state-layer.color
  static const TokenColorRole menuButtonPressedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.focus.label-text.color
  static const TokenColorRole menuListItemFocusLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.focus.state-layer.color
  static const TokenColorRole menuListItemFocusStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.hover.label-text.color
  static const TokenColorRole menuListItemHoverLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.hover.state-layer.color
  static const TokenColorRole menuListItemHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.label-text.color
  static const TokenColorRole menuListItemLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.pressed.label-text.color
  static const TokenColorRole menuListItemPressedLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.pressed.state-layer.color
  static const TokenColorRole menuListItemPressedStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.selected.focus.leading-icon.color
  static const TokenColorRole menuListItemSelectedFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.selected.hover.leading-icon.color
  static const TokenColorRole menuListItemSelectedHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.selected.leading-icon.color
  static const TokenColorRole menuListItemSelectedLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.selected.pressed.leading-icon.color
  static const TokenColorRole menuListItemSelectedPressedLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.weekdays.label-text.color
  static const TokenColorRole weekdaysLabelTextColor = TokenColorRole.onSurface;
}

class TokenDatePickerDockedDarkHighContrast {
  /// md.comp.date-picker.docked.date.selected.container.color
  static const TokenColorRole dateSelectedContainerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.selected.focus.state-layer.color
  static const TokenColorRole dateSelectedFocusStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.hover.state-layer.color
  static const TokenColorRole dateSelectedHoverStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.label-text.color
  static const TokenColorRole dateSelectedLabelTextColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.pressed.state-layer.color
  static const TokenColorRole dateSelectedPressedStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.today.container.outline.color
  static const TokenColorRole dateTodayContainerOutlineColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.focus.state-layer.color
  static const TokenColorRole dateTodayFocusStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.hover.state-layer.color
  static const TokenColorRole dateTodayHoverStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.label-text.color
  static const TokenColorRole dateTodayLabelTextColor = TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.pressed.state-layer.color
  static const TokenColorRole dateTodayPressedStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.unselected.focus.state-layer.color
  static const TokenColorRole dateUnselectedFocusStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.date.unselected.hover.state-layer.color
  static const TokenColorRole dateUnselectedHoverStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.date.unselected.label-text.color
  static const TokenColorRole dateUnselectedLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.date.unselected.outside-month.label-text.color
  static const TokenColorRole dateUnselectedOutsideMonthLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.date.unselected.pressed.state-layer.color
  static const TokenColorRole dateUnselectedPressedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.disabled.icon.color
  static const TokenColorRole menuButtonDisabledIconColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu-button.disabled.label-text.color
  static const TokenColorRole menuButtonDisabledLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu-button.focus.icon.color
  static const TokenColorRole menuButtonFocusIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.focus.label-text.color
  static const TokenColorRole menuButtonFocusLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.focus.state-layer.color
  static const TokenColorRole menuButtonFocusStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.icon.color
  static const TokenColorRole menuButtonHoverIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.label-text.color
  static const TokenColorRole menuButtonHoverLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.state-layer.color
  static const TokenColorRole menuButtonHoverStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.icon.color
  static const TokenColorRole menuButtonIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.label-text.color
  static const TokenColorRole menuButtonLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.icon.color
  static const TokenColorRole menuButtonPressedIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.label-text.color
  static const TokenColorRole menuButtonPressedLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.state-layer.color
  static const TokenColorRole menuButtonPressedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.focus.label-text.color
  static const TokenColorRole menuListItemFocusLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.focus.state-layer.color
  static const TokenColorRole menuListItemFocusStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.hover.label-text.color
  static const TokenColorRole menuListItemHoverLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.hover.state-layer.color
  static const TokenColorRole menuListItemHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.label-text.color
  static const TokenColorRole menuListItemLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.pressed.label-text.color
  static const TokenColorRole menuListItemPressedLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.pressed.state-layer.color
  static const TokenColorRole menuListItemPressedStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.selected.focus.leading-icon.color
  static const TokenColorRole menuListItemSelectedFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.selected.hover.leading-icon.color
  static const TokenColorRole menuListItemSelectedHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.selected.leading-icon.color
  static const TokenColorRole menuListItemSelectedLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.selected.pressed.leading-icon.color
  static const TokenColorRole menuListItemSelectedPressedLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.weekdays.label-text.color
  static const TokenColorRole weekdaysLabelTextColor = TokenColorRole.onSurface;
}

class TokenDatePickerDockedDarkMediumContrast {
  /// md.comp.date-picker.docked.date.selected.container.color
  static const TokenColorRole dateSelectedContainerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.selected.focus.state-layer.color
  static const TokenColorRole dateSelectedFocusStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.hover.state-layer.color
  static const TokenColorRole dateSelectedHoverStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.label-text.color
  static const TokenColorRole dateSelectedLabelTextColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.pressed.state-layer.color
  static const TokenColorRole dateSelectedPressedStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.today.container.outline.color
  static const TokenColorRole dateTodayContainerOutlineColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.focus.state-layer.color
  static const TokenColorRole dateTodayFocusStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.hover.state-layer.color
  static const TokenColorRole dateTodayHoverStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.label-text.color
  static const TokenColorRole dateTodayLabelTextColor = TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.pressed.state-layer.color
  static const TokenColorRole dateTodayPressedStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.unselected.focus.state-layer.color
  static const TokenColorRole dateUnselectedFocusStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.date.unselected.hover.state-layer.color
  static const TokenColorRole dateUnselectedHoverStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.date.unselected.label-text.color
  static const TokenColorRole dateUnselectedLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.date.unselected.outside-month.label-text.color
  static const TokenColorRole dateUnselectedOutsideMonthLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.date.unselected.pressed.state-layer.color
  static const TokenColorRole dateUnselectedPressedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.disabled.icon.color
  static const TokenColorRole menuButtonDisabledIconColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu-button.disabled.label-text.color
  static const TokenColorRole menuButtonDisabledLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu-button.focus.icon.color
  static const TokenColorRole menuButtonFocusIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.focus.label-text.color
  static const TokenColorRole menuButtonFocusLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.focus.state-layer.color
  static const TokenColorRole menuButtonFocusStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.icon.color
  static const TokenColorRole menuButtonHoverIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.label-text.color
  static const TokenColorRole menuButtonHoverLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.state-layer.color
  static const TokenColorRole menuButtonHoverStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.icon.color
  static const TokenColorRole menuButtonIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.label-text.color
  static const TokenColorRole menuButtonLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.icon.color
  static const TokenColorRole menuButtonPressedIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.label-text.color
  static const TokenColorRole menuButtonPressedLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.state-layer.color
  static const TokenColorRole menuButtonPressedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.focus.label-text.color
  static const TokenColorRole menuListItemFocusLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.focus.state-layer.color
  static const TokenColorRole menuListItemFocusStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.hover.label-text.color
  static const TokenColorRole menuListItemHoverLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.hover.state-layer.color
  static const TokenColorRole menuListItemHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.label-text.color
  static const TokenColorRole menuListItemLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.pressed.label-text.color
  static const TokenColorRole menuListItemPressedLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.pressed.state-layer.color
  static const TokenColorRole menuListItemPressedStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.selected.focus.leading-icon.color
  static const TokenColorRole menuListItemSelectedFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.selected.hover.leading-icon.color
  static const TokenColorRole menuListItemSelectedHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.selected.leading-icon.color
  static const TokenColorRole menuListItemSelectedLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.selected.pressed.leading-icon.color
  static const TokenColorRole menuListItemSelectedPressedLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.weekdays.label-text.color
  static const TokenColorRole weekdaysLabelTextColor = TokenColorRole.onSurface;
}

class TokenDatePickerDockedLight {
  /// md.comp.date-picker.docked.container.color
  static const TokenColorRole containerColor =
      TokenColorRole.surfaceContainerHigh;

  /// md.comp.date-picker.docked.menu.list-item.selected.container.color
  static const TokenColorRole menuListItemSelectedContainerColor =
      TokenColorRole.surfaceVariant;
}

class TokenDatePickerDockedLightDefault {
  /// md.comp.date-picker.docked.date.selected.container.color
  static const TokenColorRole dateSelectedContainerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.selected.focus.state-layer.color
  static const TokenColorRole dateSelectedFocusStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.hover.state-layer.color
  static const TokenColorRole dateSelectedHoverStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.label-text.color
  static const TokenColorRole dateSelectedLabelTextColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.pressed.state-layer.color
  static const TokenColorRole dateSelectedPressedStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.today.container.outline.color
  static const TokenColorRole dateTodayContainerOutlineColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.focus.state-layer.color
  static const TokenColorRole dateTodayFocusStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.hover.state-layer.color
  static const TokenColorRole dateTodayHoverStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.label-text.color
  static const TokenColorRole dateTodayLabelTextColor = TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.pressed.state-layer.color
  static const TokenColorRole dateTodayPressedStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.unselected.focus.state-layer.color
  static const TokenColorRole dateUnselectedFocusStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.date.unselected.hover.state-layer.color
  static const TokenColorRole dateUnselectedHoverStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.date.unselected.label-text.color
  static const TokenColorRole dateUnselectedLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.date.unselected.outside-month.label-text.color
  static const TokenColorRole dateUnselectedOutsideMonthLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.date.unselected.pressed.state-layer.color
  static const TokenColorRole dateUnselectedPressedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.disabled.icon.color
  static const TokenColorRole menuButtonDisabledIconColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu-button.disabled.label-text.color
  static const TokenColorRole menuButtonDisabledLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu-button.focus.icon.color
  static const TokenColorRole menuButtonFocusIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.focus.label-text.color
  static const TokenColorRole menuButtonFocusLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.focus.state-layer.color
  static const TokenColorRole menuButtonFocusStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.icon.color
  static const TokenColorRole menuButtonHoverIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.label-text.color
  static const TokenColorRole menuButtonHoverLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.state-layer.color
  static const TokenColorRole menuButtonHoverStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.icon.color
  static const TokenColorRole menuButtonIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.label-text.color
  static const TokenColorRole menuButtonLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.icon.color
  static const TokenColorRole menuButtonPressedIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.label-text.color
  static const TokenColorRole menuButtonPressedLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.state-layer.color
  static const TokenColorRole menuButtonPressedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.focus.label-text.color
  static const TokenColorRole menuListItemFocusLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.focus.state-layer.color
  static const TokenColorRole menuListItemFocusStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.hover.label-text.color
  static const TokenColorRole menuListItemHoverLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.hover.state-layer.color
  static const TokenColorRole menuListItemHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.label-text.color
  static const TokenColorRole menuListItemLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.pressed.label-text.color
  static const TokenColorRole menuListItemPressedLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.pressed.state-layer.color
  static const TokenColorRole menuListItemPressedStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.selected.focus.leading-icon.color
  static const TokenColorRole menuListItemSelectedFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.selected.hover.leading-icon.color
  static const TokenColorRole menuListItemSelectedHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.selected.leading-icon.color
  static const TokenColorRole menuListItemSelectedLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.selected.pressed.leading-icon.color
  static const TokenColorRole menuListItemSelectedPressedLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.weekdays.label-text.color
  static const TokenColorRole weekdaysLabelTextColor = TokenColorRole.onSurface;
}

class TokenDatePickerDockedLightHighContrast {
  /// md.comp.date-picker.docked.date.selected.container.color
  static const TokenColorRole dateSelectedContainerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.selected.focus.state-layer.color
  static const TokenColorRole dateSelectedFocusStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.hover.state-layer.color
  static const TokenColorRole dateSelectedHoverStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.label-text.color
  static const TokenColorRole dateSelectedLabelTextColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.pressed.state-layer.color
  static const TokenColorRole dateSelectedPressedStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.today.container.outline.color
  static const TokenColorRole dateTodayContainerOutlineColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.focus.state-layer.color
  static const TokenColorRole dateTodayFocusStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.hover.state-layer.color
  static const TokenColorRole dateTodayHoverStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.label-text.color
  static const TokenColorRole dateTodayLabelTextColor = TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.pressed.state-layer.color
  static const TokenColorRole dateTodayPressedStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.unselected.focus.state-layer.color
  static const TokenColorRole dateUnselectedFocusStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.date.unselected.hover.state-layer.color
  static const TokenColorRole dateUnselectedHoverStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.date.unselected.label-text.color
  static const TokenColorRole dateUnselectedLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.date.unselected.outside-month.label-text.color
  static const TokenColorRole dateUnselectedOutsideMonthLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.date.unselected.pressed.state-layer.color
  static const TokenColorRole dateUnselectedPressedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.disabled.icon.color
  static const TokenColorRole menuButtonDisabledIconColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu-button.disabled.label-text.color
  static const TokenColorRole menuButtonDisabledLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu-button.focus.icon.color
  static const TokenColorRole menuButtonFocusIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.focus.label-text.color
  static const TokenColorRole menuButtonFocusLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.focus.state-layer.color
  static const TokenColorRole menuButtonFocusStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.icon.color
  static const TokenColorRole menuButtonHoverIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.label-text.color
  static const TokenColorRole menuButtonHoverLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.state-layer.color
  static const TokenColorRole menuButtonHoverStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.icon.color
  static const TokenColorRole menuButtonIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.label-text.color
  static const TokenColorRole menuButtonLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.icon.color
  static const TokenColorRole menuButtonPressedIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.label-text.color
  static const TokenColorRole menuButtonPressedLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.state-layer.color
  static const TokenColorRole menuButtonPressedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.focus.label-text.color
  static const TokenColorRole menuListItemFocusLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.focus.state-layer.color
  static const TokenColorRole menuListItemFocusStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.hover.label-text.color
  static const TokenColorRole menuListItemHoverLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.hover.state-layer.color
  static const TokenColorRole menuListItemHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.label-text.color
  static const TokenColorRole menuListItemLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.pressed.label-text.color
  static const TokenColorRole menuListItemPressedLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.pressed.state-layer.color
  static const TokenColorRole menuListItemPressedStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.selected.focus.leading-icon.color
  static const TokenColorRole menuListItemSelectedFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.selected.hover.leading-icon.color
  static const TokenColorRole menuListItemSelectedHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.selected.leading-icon.color
  static const TokenColorRole menuListItemSelectedLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.selected.pressed.leading-icon.color
  static const TokenColorRole menuListItemSelectedPressedLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.weekdays.label-text.color
  static const TokenColorRole weekdaysLabelTextColor = TokenColorRole.onSurface;
}

class TokenDatePickerDockedLightMediumContrast {
  /// md.comp.date-picker.docked.date.selected.container.color
  static const TokenColorRole dateSelectedContainerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.selected.focus.state-layer.color
  static const TokenColorRole dateSelectedFocusStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.hover.state-layer.color
  static const TokenColorRole dateSelectedHoverStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.label-text.color
  static const TokenColorRole dateSelectedLabelTextColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.selected.pressed.state-layer.color
  static const TokenColorRole dateSelectedPressedStateLayerColor =
      TokenColorRole.onPrimary;

  /// md.comp.date-picker.docked.date.today.container.outline.color
  static const TokenColorRole dateTodayContainerOutlineColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.focus.state-layer.color
  static const TokenColorRole dateTodayFocusStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.hover.state-layer.color
  static const TokenColorRole dateTodayHoverStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.label-text.color
  static const TokenColorRole dateTodayLabelTextColor = TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.today.pressed.state-layer.color
  static const TokenColorRole dateTodayPressedStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.date-picker.docked.date.unselected.focus.state-layer.color
  static const TokenColorRole dateUnselectedFocusStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.date.unselected.hover.state-layer.color
  static const TokenColorRole dateUnselectedHoverStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.date.unselected.label-text.color
  static const TokenColorRole dateUnselectedLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.date.unselected.outside-month.label-text.color
  static const TokenColorRole dateUnselectedOutsideMonthLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.date.unselected.pressed.state-layer.color
  static const TokenColorRole dateUnselectedPressedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.disabled.icon.color
  static const TokenColorRole menuButtonDisabledIconColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu-button.disabled.label-text.color
  static const TokenColorRole menuButtonDisabledLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu-button.focus.icon.color
  static const TokenColorRole menuButtonFocusIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.focus.label-text.color
  static const TokenColorRole menuButtonFocusLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.focus.state-layer.color
  static const TokenColorRole menuButtonFocusStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.icon.color
  static const TokenColorRole menuButtonHoverIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.label-text.color
  static const TokenColorRole menuButtonHoverLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.hover.state-layer.color
  static const TokenColorRole menuButtonHoverStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.icon.color
  static const TokenColorRole menuButtonIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.label-text.color
  static const TokenColorRole menuButtonLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.icon.color
  static const TokenColorRole menuButtonPressedIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.label-text.color
  static const TokenColorRole menuButtonPressedLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu-button.pressed.state-layer.color
  static const TokenColorRole menuButtonPressedStateLayerColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.focus.label-text.color
  static const TokenColorRole menuListItemFocusLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.focus.state-layer.color
  static const TokenColorRole menuListItemFocusStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.hover.label-text.color
  static const TokenColorRole menuListItemHoverLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.hover.state-layer.color
  static const TokenColorRole menuListItemHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.label-text.color
  static const TokenColorRole menuListItemLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.pressed.label-text.color
  static const TokenColorRole menuListItemPressedLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.pressed.state-layer.color
  static const TokenColorRole menuListItemPressedStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.selected.focus.leading-icon.color
  static const TokenColorRole menuListItemSelectedFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.selected.hover.leading-icon.color
  static const TokenColorRole menuListItemSelectedHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.menu.list-item.selected.leading-icon.color
  static const TokenColorRole menuListItemSelectedLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.date-picker.docked.menu.list-item.selected.pressed.leading-icon.color
  static const TokenColorRole menuListItemSelectedPressedLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.date-picker.docked.weekdays.label-text.color
  static const TokenColorRole weekdaysLabelTextColor = TokenColorRole.onSurface;
}
