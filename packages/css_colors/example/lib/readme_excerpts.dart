// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #docregion Import
import 'package:css_colors/css_colors.dart';
// #enddocregion Import
import 'package:flutter/material.dart';

/// Demonstrates using CSS Colors for the README.
Container useCSSColors() {
  // #docregion Usage
  final Container orange = Container(color: CSSColors.orange);
  // #enddocregion Usage

  return orange;
}
