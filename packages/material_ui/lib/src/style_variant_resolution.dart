// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'icon_button_theme.dart';
library;

import 'package:flutter/widgets.dart';

import 'theme_data.dart';

/// Returns the [StyleVariant] specified by the closest [T] ancestor of
/// [context] whose [variantOf] is non-null.
///
/// Component themes, such as [IconButtonTheme], use this to inherit the style
/// variant from their ancestors when they don't specify one. [T] ancestors
/// whose [variantOf] is null are skipped.
///
/// [context] depends on every [T] ancestor that is visited, so it is rebuilt
/// when any of them changes.
///
/// Returns null if none of the [T] ancestors specify a variant.
StyleVariant? findClosestStyleVariant<T extends InheritedWidget>(
  BuildContext context,
  StyleVariant? Function(T widget) variantOf,
) {
  InheritedElement? element = context.getElementForInheritedWidgetOfExactType<T>();
  while (element != null) {
    context.dependOnInheritedElement(element);
    final StyleVariant? variant = variantOf(element.widget as T);
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
    element = parent?.getElementForInheritedWidgetOfExactType<T>();
  }
  return null;
}
