// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Version: 38.0.1

import 'color_role.dart';
import 'shape_struct.dart';
import 'typescale.dart';
import 'typescale_struct.dart';

class TokenFilledSelect {
  /// md.comp.filled-select.menu.cascading-menu-indicator.icon.size
  static const double menuCascadingMenuIndicatorIconSize = 24.00;

  /// md.comp.filled-select.menu.container.elevation
  static const double menuContainerElevation = 3.00;

  /// md.comp.filled-select.menu.container.shape
  static const ShapeStruct menuContainerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 4.00,
    topRight: 4.00,
    bottomLeft: 4.00,
    bottomRight: 4.00,
  );

  /// md.comp.filled-select.menu.divider.height
  static const double menuDividerHeight = 1.00;

  /// md.comp.filled-select.menu.list-item.container.height
  static const double menuListItemContainerHeight = 48.00;

  /// md.comp.filled-select.menu.list-item.label-text.type
  static const TypescaleStruct menuListItemLabelTextType =
      TokenTypescale.titleSmall;

  /// md.comp.filled-select.menu.list-item.with-leading-icon.leading-icon.size
  static const double menuListItemWithLeadingIconLeadingIconSize = 24.00;

  /// md.comp.filled-select.menu.list-item.with-trailing-icon.trailing-icon.size
  static const double menuListItemWithTrailingIconTrailingIconSize = 24.00;

  /// md.comp.filled-select.text-field.active-indicator.height
  static const double textFieldActiveIndicatorHeight = 1.00;

  /// md.comp.filled-select.text-field.container.shape
  static const ShapeStruct textFieldContainerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 4.00,
    topRight: 4.00,
    bottomLeft: 0.00,
    bottomRight: 0.00,
  );

  /// md.comp.filled-select.text-field.disabled.active-indicator.height
  static const double textFieldDisabledActiveIndicatorHeight = 1.00;

  /// md.comp.filled-select.text-field.disabled.active-indicator.opacity
  static const double textFieldDisabledActiveIndicatorOpacity = 0.38;

  /// md.comp.filled-select.text-field.disabled.container.opacity
  static const double textFieldDisabledContainerOpacity = 0.04;

  /// md.comp.filled-select.text-field.disabled.input-text.opacity
  static const double textFieldDisabledInputTextOpacity = 0.38;

  /// md.comp.filled-select.text-field.disabled.label-text.opacity
  static const double textFieldDisabledLabelTextOpacity = 0.38;

  /// md.comp.filled-select.text-field.disabled.leading-icon.opacity
  static const double textFieldDisabledLeadingIconOpacity = 0.38;

  /// md.comp.filled-select.text-field.disabled.supporting-text.opacity
  static const double textFieldDisabledSupportingTextOpacity = 0.38;

  /// md.comp.filled-select.text-field.disabled.trailing-icon.opacity
  static const double textFieldDisabledTrailingIconOpacity = 0.38;

  /// md.comp.filled-select.text-field.error.hover.state-layer.opacity
  static const double textFieldErrorHoverStateLayerOpacity = 0.08;

  /// md.comp.filled-select.text-field.focus.active-indicator.height
  static const double textFieldFocusActiveIndicatorHeight = 2.00;

  /// md.comp.filled-select.text-field.hover.active-indicator.height
  static const double textFieldHoverActiveIndicatorHeight = 1.00;

  /// md.comp.filled-select.text-field.hover.state-layer.opacity
  static const double textFieldHoverStateLayerOpacity = 0.08;

  /// md.comp.filled-select.text-field.input-text.type
  static const TypescaleStruct textFieldInputTextType =
      TokenTypescale.bodyLarge;

  /// md.comp.filled-select.text-field.label-text.type
  static const TypescaleStruct textFieldLabelTextType =
      TokenTypescale.bodyLarge;

  /// md.comp.filled-select.text-field.leading-icon.size
  static const double textFieldLeadingIconSize = 24.00;

  /// md.comp.filled-select.text-field.supporting-text.type
  static const TypescaleStruct textFieldSupportingTextType =
      TokenTypescale.bodySmall;

  /// md.comp.filled-select.text-field.trailing-icon.size
  static const double textFieldTrailingIconSize = 24.00;
}

class TokenFilledSelectDark {
  /// md.comp.filled-select.menu.container.color
  static const TokenColorRole menuContainerColor =
      TokenColorRole.surfaceContainer;

  /// md.comp.filled-select.menu.container.shadow-color
  static const TokenColorRole menuContainerShadowColor = TokenColorRole.shadow;

  /// md.comp.filled-select.menu.divider.color
  static const TokenColorRole menuDividerColor = TokenColorRole.surfaceVariant;

  /// md.comp.filled-select.menu.list-item.selected.container.color
  static const TokenColorRole menuListItemSelectedContainerColor =
      TokenColorRole.surfaceContainerHighest;

  /// md.comp.filled-select.text-field.container.color
  static const TokenColorRole textFieldContainerColor =
      TokenColorRole.surfaceContainerHighest;
}

class TokenFilledSelectDarkDefault {
  /// md.comp.filled-select.menu.cascading-menu-indicator.icon.color
  static const TokenColorRole menuCascadingMenuIndicatorIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.menu.list-item.label-text.color
  static const TokenColorRole menuListItemLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.menu.list-item.with-leading-icon.leading-icon.color
  static const TokenColorRole menuListItemWithLeadingIconLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.menu.list-item.with-trailing-icon.trailing-icon.color
  static const TokenColorRole menuListItemWithTrailingIconTrailingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.active-indicator.color
  static const TokenColorRole textFieldActiveIndicatorColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.disabled.active-indicator.color
  static const TokenColorRole textFieldDisabledActiveIndicatorColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.container.color
  static const TokenColorRole textFieldDisabledContainerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.input-text.color
  static const TokenColorRole textFieldDisabledInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.label-text.color
  static const TokenColorRole textFieldDisabledLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.leading-icon.color
  static const TokenColorRole textFieldDisabledLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.supporting-text.color
  static const TokenColorRole textFieldDisabledSupportingTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.trailing-icon.color
  static const TokenColorRole textFieldDisabledTrailingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.active-indicator.color
  static const TokenColorRole textFieldErrorActiveIndicatorColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.active-indicator.color
  static const TokenColorRole textFieldErrorFocusActiveIndicatorColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.input-text.color
  static const TokenColorRole textFieldErrorFocusInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.focus.label-text.color
  static const TokenColorRole textFieldErrorFocusLabelTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.leading-icon.color
  static const TokenColorRole textFieldErrorFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.focus.supporting-text.color
  static const TokenColorRole textFieldErrorFocusSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.trailing-icon.color
  static const TokenColorRole textFieldErrorFocusTrailingIconColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.hover.active-indicator.color
  static const TokenColorRole textFieldErrorHoverActiveIndicatorColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.hover.input-text.color
  static const TokenColorRole textFieldErrorHoverInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.hover.label-text.color
  static const TokenColorRole textFieldErrorHoverLabelTextColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.hover.leading-icon.color
  static const TokenColorRole textFieldErrorHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.hover.state-layer.color
  static const TokenColorRole textFieldErrorHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.hover.supporting-text.color
  static const TokenColorRole textFieldErrorHoverSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.hover.trailing-icon.color
  static const TokenColorRole textFieldErrorHoverTrailingIconColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.input-text.color
  static const TokenColorRole textFieldErrorInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.label-text.color
  static const TokenColorRole textFieldErrorLabelTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.leading-icon.color
  static const TokenColorRole textFieldErrorLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.supporting-text.color
  static const TokenColorRole textFieldErrorSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.trailing-icon.color
  static const TokenColorRole textFieldErrorTrailingIconColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.focus.active-indicator.color
  static const TokenColorRole textFieldFocusActiveIndicatorColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.focus.input-text.color
  static const TokenColorRole textFieldFocusInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.focus.label-text.color
  static const TokenColorRole textFieldFocusLabelTextColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.focus.leading-icon.color
  static const TokenColorRole textFieldFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.focus.supporting-text.color
  static const TokenColorRole textFieldFocusSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.focus.trailing-icon.color
  static const TokenColorRole textFieldFocusTrailingIconColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.hover.active-indicator.color
  static const TokenColorRole textFieldHoverActiveIndicatorColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.input-text.color
  static const TokenColorRole textFieldHoverInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.label-text.color
  static const TokenColorRole textFieldHoverLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.leading-icon.color
  static const TokenColorRole textFieldHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.hover.state-layer.color
  static const TokenColorRole textFieldHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.supporting-text.color
  static const TokenColorRole textFieldHoverSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.hover.trailing-icon.color
  static const TokenColorRole textFieldHoverTrailingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.input-text.color
  static const TokenColorRole textFieldInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.label-text.color
  static const TokenColorRole textFieldLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.leading-icon.color
  static const TokenColorRole textFieldLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.supporting-text.color
  static const TokenColorRole textFieldSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.trailing-icon.color
  static const TokenColorRole textFieldTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenFilledSelectDarkHighContrast {
  /// md.comp.filled-select.menu.cascading-menu-indicator.icon.color
  static const TokenColorRole menuCascadingMenuIndicatorIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.menu.list-item.label-text.color
  static const TokenColorRole menuListItemLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.menu.list-item.with-leading-icon.leading-icon.color
  static const TokenColorRole menuListItemWithLeadingIconLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.menu.list-item.with-trailing-icon.trailing-icon.color
  static const TokenColorRole menuListItemWithTrailingIconTrailingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.active-indicator.color
  static const TokenColorRole textFieldActiveIndicatorColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.disabled.active-indicator.color
  static const TokenColorRole textFieldDisabledActiveIndicatorColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.container.color
  static const TokenColorRole textFieldDisabledContainerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.input-text.color
  static const TokenColorRole textFieldDisabledInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.label-text.color
  static const TokenColorRole textFieldDisabledLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.leading-icon.color
  static const TokenColorRole textFieldDisabledLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.supporting-text.color
  static const TokenColorRole textFieldDisabledSupportingTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.trailing-icon.color
  static const TokenColorRole textFieldDisabledTrailingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.active-indicator.color
  static const TokenColorRole textFieldErrorActiveIndicatorColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.active-indicator.color
  static const TokenColorRole textFieldErrorFocusActiveIndicatorColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.input-text.color
  static const TokenColorRole textFieldErrorFocusInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.focus.label-text.color
  static const TokenColorRole textFieldErrorFocusLabelTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.leading-icon.color
  static const TokenColorRole textFieldErrorFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.focus.supporting-text.color
  static const TokenColorRole textFieldErrorFocusSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.trailing-icon.color
  static const TokenColorRole textFieldErrorFocusTrailingIconColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.hover.active-indicator.color
  static const TokenColorRole textFieldErrorHoverActiveIndicatorColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.hover.input-text.color
  static const TokenColorRole textFieldErrorHoverInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.hover.label-text.color
  static const TokenColorRole textFieldErrorHoverLabelTextColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.hover.leading-icon.color
  static const TokenColorRole textFieldErrorHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.hover.state-layer.color
  static const TokenColorRole textFieldErrorHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.hover.supporting-text.color
  static const TokenColorRole textFieldErrorHoverSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.hover.trailing-icon.color
  static const TokenColorRole textFieldErrorHoverTrailingIconColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.input-text.color
  static const TokenColorRole textFieldErrorInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.label-text.color
  static const TokenColorRole textFieldErrorLabelTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.leading-icon.color
  static const TokenColorRole textFieldErrorLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.supporting-text.color
  static const TokenColorRole textFieldErrorSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.trailing-icon.color
  static const TokenColorRole textFieldErrorTrailingIconColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.focus.active-indicator.color
  static const TokenColorRole textFieldFocusActiveIndicatorColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.focus.input-text.color
  static const TokenColorRole textFieldFocusInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.focus.label-text.color
  static const TokenColorRole textFieldFocusLabelTextColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.focus.leading-icon.color
  static const TokenColorRole textFieldFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.focus.supporting-text.color
  static const TokenColorRole textFieldFocusSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.focus.trailing-icon.color
  static const TokenColorRole textFieldFocusTrailingIconColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.hover.active-indicator.color
  static const TokenColorRole textFieldHoverActiveIndicatorColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.input-text.color
  static const TokenColorRole textFieldHoverInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.label-text.color
  static const TokenColorRole textFieldHoverLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.leading-icon.color
  static const TokenColorRole textFieldHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.hover.state-layer.color
  static const TokenColorRole textFieldHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.supporting-text.color
  static const TokenColorRole textFieldHoverSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.hover.trailing-icon.color
  static const TokenColorRole textFieldHoverTrailingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.input-text.color
  static const TokenColorRole textFieldInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.label-text.color
  static const TokenColorRole textFieldLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.leading-icon.color
  static const TokenColorRole textFieldLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.supporting-text.color
  static const TokenColorRole textFieldSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.trailing-icon.color
  static const TokenColorRole textFieldTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenFilledSelectDarkMediumContrast {
  /// md.comp.filled-select.menu.cascading-menu-indicator.icon.color
  static const TokenColorRole menuCascadingMenuIndicatorIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.menu.list-item.label-text.color
  static const TokenColorRole menuListItemLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.menu.list-item.with-leading-icon.leading-icon.color
  static const TokenColorRole menuListItemWithLeadingIconLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.menu.list-item.with-trailing-icon.trailing-icon.color
  static const TokenColorRole menuListItemWithTrailingIconTrailingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.active-indicator.color
  static const TokenColorRole textFieldActiveIndicatorColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.disabled.active-indicator.color
  static const TokenColorRole textFieldDisabledActiveIndicatorColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.container.color
  static const TokenColorRole textFieldDisabledContainerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.input-text.color
  static const TokenColorRole textFieldDisabledInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.label-text.color
  static const TokenColorRole textFieldDisabledLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.leading-icon.color
  static const TokenColorRole textFieldDisabledLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.supporting-text.color
  static const TokenColorRole textFieldDisabledSupportingTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.trailing-icon.color
  static const TokenColorRole textFieldDisabledTrailingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.active-indicator.color
  static const TokenColorRole textFieldErrorActiveIndicatorColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.active-indicator.color
  static const TokenColorRole textFieldErrorFocusActiveIndicatorColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.input-text.color
  static const TokenColorRole textFieldErrorFocusInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.focus.label-text.color
  static const TokenColorRole textFieldErrorFocusLabelTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.leading-icon.color
  static const TokenColorRole textFieldErrorFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.focus.supporting-text.color
  static const TokenColorRole textFieldErrorFocusSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.trailing-icon.color
  static const TokenColorRole textFieldErrorFocusTrailingIconColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.hover.active-indicator.color
  static const TokenColorRole textFieldErrorHoverActiveIndicatorColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.hover.input-text.color
  static const TokenColorRole textFieldErrorHoverInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.hover.label-text.color
  static const TokenColorRole textFieldErrorHoverLabelTextColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.hover.leading-icon.color
  static const TokenColorRole textFieldErrorHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.hover.state-layer.color
  static const TokenColorRole textFieldErrorHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.hover.supporting-text.color
  static const TokenColorRole textFieldErrorHoverSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.hover.trailing-icon.color
  static const TokenColorRole textFieldErrorHoverTrailingIconColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.input-text.color
  static const TokenColorRole textFieldErrorInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.label-text.color
  static const TokenColorRole textFieldErrorLabelTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.leading-icon.color
  static const TokenColorRole textFieldErrorLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.supporting-text.color
  static const TokenColorRole textFieldErrorSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.trailing-icon.color
  static const TokenColorRole textFieldErrorTrailingIconColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.focus.active-indicator.color
  static const TokenColorRole textFieldFocusActiveIndicatorColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.focus.input-text.color
  static const TokenColorRole textFieldFocusInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.focus.label-text.color
  static const TokenColorRole textFieldFocusLabelTextColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.focus.leading-icon.color
  static const TokenColorRole textFieldFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.focus.supporting-text.color
  static const TokenColorRole textFieldFocusSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.focus.trailing-icon.color
  static const TokenColorRole textFieldFocusTrailingIconColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.hover.active-indicator.color
  static const TokenColorRole textFieldHoverActiveIndicatorColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.input-text.color
  static const TokenColorRole textFieldHoverInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.label-text.color
  static const TokenColorRole textFieldHoverLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.leading-icon.color
  static const TokenColorRole textFieldHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.hover.state-layer.color
  static const TokenColorRole textFieldHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.supporting-text.color
  static const TokenColorRole textFieldHoverSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.hover.trailing-icon.color
  static const TokenColorRole textFieldHoverTrailingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.input-text.color
  static const TokenColorRole textFieldInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.label-text.color
  static const TokenColorRole textFieldLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.leading-icon.color
  static const TokenColorRole textFieldLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.supporting-text.color
  static const TokenColorRole textFieldSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.trailing-icon.color
  static const TokenColorRole textFieldTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenFilledSelectLight {
  /// md.comp.filled-select.menu.container.color
  static const TokenColorRole menuContainerColor =
      TokenColorRole.surfaceContainer;

  /// md.comp.filled-select.menu.container.shadow-color
  static const TokenColorRole menuContainerShadowColor = TokenColorRole.shadow;

  /// md.comp.filled-select.menu.divider.color
  static const TokenColorRole menuDividerColor = TokenColorRole.surfaceVariant;

  /// md.comp.filled-select.menu.list-item.selected.container.color
  static const TokenColorRole menuListItemSelectedContainerColor =
      TokenColorRole.surfaceContainerHighest;

  /// md.comp.filled-select.text-field.container.color
  static const TokenColorRole textFieldContainerColor =
      TokenColorRole.surfaceContainerHighest;
}

class TokenFilledSelectLightDefault {
  /// md.comp.filled-select.menu.cascading-menu-indicator.icon.color
  static const TokenColorRole menuCascadingMenuIndicatorIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.menu.list-item.label-text.color
  static const TokenColorRole menuListItemLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.menu.list-item.with-leading-icon.leading-icon.color
  static const TokenColorRole menuListItemWithLeadingIconLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.menu.list-item.with-trailing-icon.trailing-icon.color
  static const TokenColorRole menuListItemWithTrailingIconTrailingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.active-indicator.color
  static const TokenColorRole textFieldActiveIndicatorColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.disabled.active-indicator.color
  static const TokenColorRole textFieldDisabledActiveIndicatorColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.container.color
  static const TokenColorRole textFieldDisabledContainerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.input-text.color
  static const TokenColorRole textFieldDisabledInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.label-text.color
  static const TokenColorRole textFieldDisabledLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.leading-icon.color
  static const TokenColorRole textFieldDisabledLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.supporting-text.color
  static const TokenColorRole textFieldDisabledSupportingTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.trailing-icon.color
  static const TokenColorRole textFieldDisabledTrailingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.active-indicator.color
  static const TokenColorRole textFieldErrorActiveIndicatorColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.active-indicator.color
  static const TokenColorRole textFieldErrorFocusActiveIndicatorColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.input-text.color
  static const TokenColorRole textFieldErrorFocusInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.focus.label-text.color
  static const TokenColorRole textFieldErrorFocusLabelTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.leading-icon.color
  static const TokenColorRole textFieldErrorFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.focus.supporting-text.color
  static const TokenColorRole textFieldErrorFocusSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.trailing-icon.color
  static const TokenColorRole textFieldErrorFocusTrailingIconColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.hover.active-indicator.color
  static const TokenColorRole textFieldErrorHoverActiveIndicatorColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.hover.input-text.color
  static const TokenColorRole textFieldErrorHoverInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.hover.label-text.color
  static const TokenColorRole textFieldErrorHoverLabelTextColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.hover.leading-icon.color
  static const TokenColorRole textFieldErrorHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.hover.state-layer.color
  static const TokenColorRole textFieldErrorHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.hover.supporting-text.color
  static const TokenColorRole textFieldErrorHoverSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.hover.trailing-icon.color
  static const TokenColorRole textFieldErrorHoverTrailingIconColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.input-text.color
  static const TokenColorRole textFieldErrorInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.label-text.color
  static const TokenColorRole textFieldErrorLabelTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.leading-icon.color
  static const TokenColorRole textFieldErrorLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.supporting-text.color
  static const TokenColorRole textFieldErrorSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.trailing-icon.color
  static const TokenColorRole textFieldErrorTrailingIconColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.focus.active-indicator.color
  static const TokenColorRole textFieldFocusActiveIndicatorColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.focus.input-text.color
  static const TokenColorRole textFieldFocusInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.focus.label-text.color
  static const TokenColorRole textFieldFocusLabelTextColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.focus.leading-icon.color
  static const TokenColorRole textFieldFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.focus.supporting-text.color
  static const TokenColorRole textFieldFocusSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.focus.trailing-icon.color
  static const TokenColorRole textFieldFocusTrailingIconColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.hover.active-indicator.color
  static const TokenColorRole textFieldHoverActiveIndicatorColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.input-text.color
  static const TokenColorRole textFieldHoverInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.label-text.color
  static const TokenColorRole textFieldHoverLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.leading-icon.color
  static const TokenColorRole textFieldHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.hover.state-layer.color
  static const TokenColorRole textFieldHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.supporting-text.color
  static const TokenColorRole textFieldHoverSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.hover.trailing-icon.color
  static const TokenColorRole textFieldHoverTrailingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.input-text.color
  static const TokenColorRole textFieldInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.label-text.color
  static const TokenColorRole textFieldLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.leading-icon.color
  static const TokenColorRole textFieldLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.supporting-text.color
  static const TokenColorRole textFieldSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.trailing-icon.color
  static const TokenColorRole textFieldTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenFilledSelectLightHighContrast {
  /// md.comp.filled-select.menu.cascading-menu-indicator.icon.color
  static const TokenColorRole menuCascadingMenuIndicatorIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.menu.list-item.label-text.color
  static const TokenColorRole menuListItemLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.menu.list-item.with-leading-icon.leading-icon.color
  static const TokenColorRole menuListItemWithLeadingIconLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.menu.list-item.with-trailing-icon.trailing-icon.color
  static const TokenColorRole menuListItemWithTrailingIconTrailingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.active-indicator.color
  static const TokenColorRole textFieldActiveIndicatorColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.disabled.active-indicator.color
  static const TokenColorRole textFieldDisabledActiveIndicatorColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.container.color
  static const TokenColorRole textFieldDisabledContainerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.input-text.color
  static const TokenColorRole textFieldDisabledInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.label-text.color
  static const TokenColorRole textFieldDisabledLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.leading-icon.color
  static const TokenColorRole textFieldDisabledLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.supporting-text.color
  static const TokenColorRole textFieldDisabledSupportingTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.trailing-icon.color
  static const TokenColorRole textFieldDisabledTrailingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.active-indicator.color
  static const TokenColorRole textFieldErrorActiveIndicatorColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.active-indicator.color
  static const TokenColorRole textFieldErrorFocusActiveIndicatorColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.input-text.color
  static const TokenColorRole textFieldErrorFocusInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.focus.label-text.color
  static const TokenColorRole textFieldErrorFocusLabelTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.leading-icon.color
  static const TokenColorRole textFieldErrorFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.focus.supporting-text.color
  static const TokenColorRole textFieldErrorFocusSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.trailing-icon.color
  static const TokenColorRole textFieldErrorFocusTrailingIconColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.hover.active-indicator.color
  static const TokenColorRole textFieldErrorHoverActiveIndicatorColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.hover.input-text.color
  static const TokenColorRole textFieldErrorHoverInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.hover.label-text.color
  static const TokenColorRole textFieldErrorHoverLabelTextColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.hover.leading-icon.color
  static const TokenColorRole textFieldErrorHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.hover.state-layer.color
  static const TokenColorRole textFieldErrorHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.hover.supporting-text.color
  static const TokenColorRole textFieldErrorHoverSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.hover.trailing-icon.color
  static const TokenColorRole textFieldErrorHoverTrailingIconColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.input-text.color
  static const TokenColorRole textFieldErrorInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.label-text.color
  static const TokenColorRole textFieldErrorLabelTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.leading-icon.color
  static const TokenColorRole textFieldErrorLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.supporting-text.color
  static const TokenColorRole textFieldErrorSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.trailing-icon.color
  static const TokenColorRole textFieldErrorTrailingIconColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.focus.active-indicator.color
  static const TokenColorRole textFieldFocusActiveIndicatorColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.focus.input-text.color
  static const TokenColorRole textFieldFocusInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.focus.label-text.color
  static const TokenColorRole textFieldFocusLabelTextColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.focus.leading-icon.color
  static const TokenColorRole textFieldFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.focus.supporting-text.color
  static const TokenColorRole textFieldFocusSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.focus.trailing-icon.color
  static const TokenColorRole textFieldFocusTrailingIconColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.hover.active-indicator.color
  static const TokenColorRole textFieldHoverActiveIndicatorColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.input-text.color
  static const TokenColorRole textFieldHoverInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.label-text.color
  static const TokenColorRole textFieldHoverLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.leading-icon.color
  static const TokenColorRole textFieldHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.hover.state-layer.color
  static const TokenColorRole textFieldHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.supporting-text.color
  static const TokenColorRole textFieldHoverSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.hover.trailing-icon.color
  static const TokenColorRole textFieldHoverTrailingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.input-text.color
  static const TokenColorRole textFieldInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.label-text.color
  static const TokenColorRole textFieldLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.leading-icon.color
  static const TokenColorRole textFieldLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.supporting-text.color
  static const TokenColorRole textFieldSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.trailing-icon.color
  static const TokenColorRole textFieldTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenFilledSelectLightMediumContrast {
  /// md.comp.filled-select.menu.cascading-menu-indicator.icon.color
  static const TokenColorRole menuCascadingMenuIndicatorIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.menu.list-item.label-text.color
  static const TokenColorRole menuListItemLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.menu.list-item.with-leading-icon.leading-icon.color
  static const TokenColorRole menuListItemWithLeadingIconLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.menu.list-item.with-trailing-icon.trailing-icon.color
  static const TokenColorRole menuListItemWithTrailingIconTrailingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.active-indicator.color
  static const TokenColorRole textFieldActiveIndicatorColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.disabled.active-indicator.color
  static const TokenColorRole textFieldDisabledActiveIndicatorColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.container.color
  static const TokenColorRole textFieldDisabledContainerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.input-text.color
  static const TokenColorRole textFieldDisabledInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.label-text.color
  static const TokenColorRole textFieldDisabledLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.leading-icon.color
  static const TokenColorRole textFieldDisabledLeadingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.supporting-text.color
  static const TokenColorRole textFieldDisabledSupportingTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.disabled.trailing-icon.color
  static const TokenColorRole textFieldDisabledTrailingIconColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.active-indicator.color
  static const TokenColorRole textFieldErrorActiveIndicatorColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.active-indicator.color
  static const TokenColorRole textFieldErrorFocusActiveIndicatorColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.input-text.color
  static const TokenColorRole textFieldErrorFocusInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.focus.label-text.color
  static const TokenColorRole textFieldErrorFocusLabelTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.leading-icon.color
  static const TokenColorRole textFieldErrorFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.focus.supporting-text.color
  static const TokenColorRole textFieldErrorFocusSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.focus.trailing-icon.color
  static const TokenColorRole textFieldErrorFocusTrailingIconColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.hover.active-indicator.color
  static const TokenColorRole textFieldErrorHoverActiveIndicatorColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.hover.input-text.color
  static const TokenColorRole textFieldErrorHoverInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.hover.label-text.color
  static const TokenColorRole textFieldErrorHoverLabelTextColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.hover.leading-icon.color
  static const TokenColorRole textFieldErrorHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.hover.state-layer.color
  static const TokenColorRole textFieldErrorHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.hover.supporting-text.color
  static const TokenColorRole textFieldErrorHoverSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.hover.trailing-icon.color
  static const TokenColorRole textFieldErrorHoverTrailingIconColor =
      TokenColorRole.onErrorContainer;

  /// md.comp.filled-select.text-field.error.input-text.color
  static const TokenColorRole textFieldErrorInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.error.label-text.color
  static const TokenColorRole textFieldErrorLabelTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.leading-icon.color
  static const TokenColorRole textFieldErrorLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.error.supporting-text.color
  static const TokenColorRole textFieldErrorSupportingTextColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.error.trailing-icon.color
  static const TokenColorRole textFieldErrorTrailingIconColor =
      TokenColorRole.error;

  /// md.comp.filled-select.text-field.focus.active-indicator.color
  static const TokenColorRole textFieldFocusActiveIndicatorColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.focus.input-text.color
  static const TokenColorRole textFieldFocusInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.focus.label-text.color
  static const TokenColorRole textFieldFocusLabelTextColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.focus.leading-icon.color
  static const TokenColorRole textFieldFocusLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.focus.supporting-text.color
  static const TokenColorRole textFieldFocusSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.focus.trailing-icon.color
  static const TokenColorRole textFieldFocusTrailingIconColor =
      TokenColorRole.primary;

  /// md.comp.filled-select.text-field.hover.active-indicator.color
  static const TokenColorRole textFieldHoverActiveIndicatorColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.input-text.color
  static const TokenColorRole textFieldHoverInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.label-text.color
  static const TokenColorRole textFieldHoverLabelTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.leading-icon.color
  static const TokenColorRole textFieldHoverLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.hover.state-layer.color
  static const TokenColorRole textFieldHoverStateLayerColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.hover.supporting-text.color
  static const TokenColorRole textFieldHoverSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.hover.trailing-icon.color
  static const TokenColorRole textFieldHoverTrailingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.input-text.color
  static const TokenColorRole textFieldInputTextColor =
      TokenColorRole.onSurface;

  /// md.comp.filled-select.text-field.label-text.color
  static const TokenColorRole textFieldLabelTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.leading-icon.color
  static const TokenColorRole textFieldLeadingIconColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.supporting-text.color
  static const TokenColorRole textFieldSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.filled-select.text-field.trailing-icon.color
  static const TokenColorRole textFieldTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}
