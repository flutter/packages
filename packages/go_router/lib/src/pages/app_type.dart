// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart' as cupertino_ui;
import 'package:flutter/cupertino.dart' as flutter_cupertino;
import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' as material_ui;

/// The app implementation that contains a go_router Navigator.
enum AppType {
  /// A MaterialApp from the Flutter SDK.
  sdkMaterial,

  /// A MaterialApp from material_ui.
  materialUi,

  /// A CupertinoApp from the Flutter SDK.
  sdkCupertino,

  /// A CupertinoApp from cupertino_ui.
  cupertinoUi,
}

/// Finds the supported app implementation to use for the Navigator.
///
/// Material apps retain precedence over Cupertino apps, matching the existing
/// go_router adapter selection behavior. Within each app family, the closest
/// supported implementation is used.
AppType? appTypeOf(BuildContext context) {
  AppType? nearestCupertino;
  AppType? material;
  context.visitAncestorElements((Element element) {
    final Widget widget = element.widget;
    if (widget is flutter_material.MaterialApp) {
      material = AppType.sdkMaterial;
      return false;
    }
    if (widget is material_ui.MaterialApp) {
      material = AppType.materialUi;
      return false;
    }
    if (nearestCupertino == null) {
      if (widget is flutter_cupertino.CupertinoApp) {
        nearestCupertino = AppType.sdkCupertino;
      } else if (widget is cupertino_ui.CupertinoApp) {
        nearestCupertino = AppType.cupertinoUi;
      }
    }
    return true;
  });
  return material ?? nearestCupertino;
}
