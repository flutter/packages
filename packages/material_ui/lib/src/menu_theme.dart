// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'dropdown_menu.dart';
/// @docImport 'menu_bar_theme.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'menu_anchor.dart';
import 'menu_style.dart';
import 'theme.dart';
import 'theme_data.dart';

// Examples can assume:
// late Widget child;
// late BuildContext context;

/// Defines the configuration of the submenus created by the [SubmenuButton],
/// [MenuBar], or [MenuAnchor] widgets.
///
/// Descendant widgets obtain the current [MenuThemeData] object using
/// [MenuTheme.of].
///
/// Typically, a [MenuThemeData] is specified as part of the overall [Theme]
/// with [ThemeData.menuTheme]. Otherwise, [MenuTheme] can be used to configure
/// its own widget subtree.
///
/// All [MenuThemeData] properties are `null` by default. If any of these
/// properties are null, the menu bar will provide its own defaults.
///
/// See also:
///
/// * [ThemeData], which describes the overall theme for the application.
/// * [MenuBarThemeData], which describes the theme for the menu bar itself in a
///   [MenuBar] widget.
@immutable
class MenuThemeData with Diagnosticable {
  /// Creates a const set of properties used to configure [MenuTheme].
  const MenuThemeData({this.style, this.submenuIcon, this.variant});

  /// The [MenuStyle] of a [SubmenuButton] menu.
  ///
  /// Any values not set in the [MenuStyle] will use the menu default for that
  /// property.
  final MenuStyle? style;

  /// If provided, the widget replaces the default [SubmenuButton] arrow icon.
  ///
  /// Resolves in the following states:
  ///  * [WidgetState.disabled].
  ///  * [WidgetState.hovered].
  ///  * [WidgetState.focused].
  final WidgetStateProperty<Widget?>? submenuIcon;

  /// The style variant of Material Design used by menus.
  ///
  /// Set this to [StyleVariant.material3Expressive] to opt the menus of
  /// [MenuAnchor], [SubmenuButton], and [DropdownMenu], as well as their
  /// [MenuItemButton]s and [SubmenuButton]s, into the Material 3 Expressive
  /// colors. Sizes and shapes still use the Material 3 defaults. The bar of a
  /// [MenuBar] is not affected, but its submenus are.
  ///
  /// A [MenuItemButton] uses the selected colors when its
  /// [MenuItemButton.statesController] contains [WidgetState.selected].
  /// [DropdownMenu] does this for the entry that matches its text field.
  ///
  /// If null, the variant is inherited from the closest enclosing [MenuTheme]
  /// that specifies one, and then from [ThemeData.menuTheme]. If none of them
  /// specify a variant, menus use [StyleVariant.material3]. To keep a subtree
  /// on Material 3 when an ancestor opts into Material 3 Expressive, set this
  /// to [StyleVariant.material3].
  ///
  /// An enclosing [MenuTheme] takes precedence over [ThemeData.menuTheme],
  /// even when a closer [Theme] specifies a different variant. This matches
  /// [MenuTheme.of], which only uses [ThemeData.menuTheme] when there is no
  /// enclosing [MenuTheme]. To change the variant of a subtree, wrap it in a
  /// [MenuTheme].
  ///
  /// See also:
  ///
  ///  * [MenuTheme.variantOf], which returns the variant that applies at a
  ///    given location.
  final StyleVariant? variant;

  /// Linearly interpolate between two menu button themes.
  static MenuThemeData? lerp(MenuThemeData? a, MenuThemeData? b, double t) {
    if (identical(a, b)) {
      return a;
    }
    return MenuThemeData(
      style: MenuStyle.lerp(a?.style, b?.style, t),
      submenuIcon: t < 0.5 ? a?.submenuIcon : b?.submenuIcon,
      variant: t < 0.5 ? a?.variant : b?.variant,
    );
  }

  @override
  int get hashCode => Object.hash(style, submenuIcon, variant);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MenuThemeData &&
        other.style == style &&
        other.submenuIcon == submenuIcon &&
        other.variant == variant;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<MenuStyle>('style', style, defaultValue: null));
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<Widget?>>(
        'submenuIcon',
        submenuIcon,
        defaultValue: null,
      ),
    );
    properties.add(EnumProperty<StyleVariant>('variant', variant, defaultValue: null));
  }
}

/// An inherited widget that defines the configuration in this widget's
/// descendants for menus created by the [SubmenuButton], [MenuBar], or
/// [MenuAnchor] widgets.
///
/// Values specified here are used for [SubmenuButton]'s menu properties that
/// are not given an explicit non-null value.
///
/// See also:
///
/// * [MenuThemeData], a configuration object that holds attributes of a menu
///   used by this theme.
/// * [MenuBarTheme], which does the same thing for the [MenuBar] widget.
/// * [MenuBar], a widget that manages [MenuItemButton]s.
/// * [MenuAnchor], a widget that creates a region that has a submenu.
/// * [MenuItemButton], a widget that is a selectable item in a menu bar menu.
/// * [SubmenuButton], a widget that specifies an item with a cascading submenu
///   in a [MenuBar] menu.
class MenuTheme extends InheritedTheme {
  /// Creates a const theme that controls the configurations for the menus
  /// created by the [SubmenuButton] or [MenuAnchor] widgets.
  const MenuTheme({super.key, required this.data, required super.child});

  /// The properties for [MenuBar] and [MenuItemButton] in this widget's
  /// descendants.
  final MenuThemeData data;

  /// Returns the closest instance of this class's [data] value that encloses
  /// the given context. If there is no ancestor, it returns
  /// [ThemeData.menuTheme].
  ///
  /// The returned [MenuThemeData.variant] is the value specified by that
  /// theme, which can be null even when an ancestor specifies a variant. Use
  /// [variantOf] to get the variant that applies at the given [context].
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// MenuThemeData theme = MenuTheme.of(context);
  /// ```
  static MenuThemeData of(BuildContext context) {
    final MenuTheme? menuTheme = context.dependOnInheritedWidgetOfExactType<MenuTheme>();
    return menuTheme?.data ?? Theme.of(context).menuTheme;
  }

  /// Returns the [StyleVariant] that menus use at the given [context].
  ///
  /// The closest enclosing [MenuTheme] whose [MenuThemeData.variant] is
  /// non-null determines the variant, so a [MenuTheme] that doesn't specify a
  /// variant inherits it from its ancestors. If none of the enclosing
  /// [MenuTheme]s specify a variant, the variant of [ThemeData.menuTheme] is
  /// used. If that is also null, [StyleVariant.material3] is returned.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// final StyleVariant variant = MenuTheme.variantOf(context);
  /// ```
  static StyleVariant variantOf(BuildContext context) {
    InheritedElement? element = context.getElementForInheritedWidgetOfExactType<MenuTheme>();
    while (element != null) {
      // Depend on every theme that is visited, so that a change to any of them
      // rebuilds the dependent.
      context.dependOnInheritedElement(element);
      final StyleVariant? variant = (element.widget as MenuTheme).data.variant;
      if (variant != null) {
        return variant;
      }
      // Calling getElementForInheritedWidgetOfExactType on the element itself
      // would return the same element, so continue the search from its parent.
      Element? parent;
      element.visitAncestorElements((Element ancestor) {
        parent = ancestor;
        return false;
      });
      element = parent?.getElementForInheritedWidgetOfExactType<MenuTheme>();
    }
    return Theme.of(context).menuTheme.variant ?? StyleVariant.material3;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MenuTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(MenuTheme oldWidget) => data != oldWidget.data;
}
