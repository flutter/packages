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

/// Finds the closest supported app implementation in the widget tree.
AppType? appTypeOf(BuildContext context) {
  AppType? result;
  context.visitAncestorElements((Element element) {
    final Widget widget = element.widget;
    if (widget is flutter_material.MaterialApp) {
      result = AppType.sdkMaterial;
      return false;
    }
    if (widget is material_ui.MaterialApp) {
      result = AppType.materialUi;
      return false;
    }
    if (widget is flutter_cupertino.CupertinoApp) {
      result = AppType.sdkCupertino;
      return false;
    }
    if (widget is cupertino_ui.CupertinoApp) {
      result = AppType.cupertinoUi;
      return false;
    }
    return true;
  });
  return result;
}
