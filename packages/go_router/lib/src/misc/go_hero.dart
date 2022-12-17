// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pages/cupertino.dart';
import '../pages/material.dart';

/// Helper class used to retrieve the correct HeroController based on the app type.
class GoHero {
  /// Default HeroController.
  final HeroController base = HeroController();

  /// Material HeroController.
  final HeroController material = MaterialApp.createMaterialHeroController();

  /// Cupertino HeroController.
  final HeroController cupertino = CupertinoApp.createCupertinoHeroController();

  /// Return the correct HeroController type based on the app type.
  HeroController get(BuildContext context) {
    if (context is Element) {
      if (isMaterialApp(context)) {
        return material;
      } else if (isCupertinoApp(context)) {
        return cupertino;
      }
    }
    return base;
  }
}
