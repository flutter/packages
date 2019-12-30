// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/src/shared_z_axis_transition.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets(
    'FadeThroughPageTransitionsBuilder builds a FadeThroughTransition',
    (WidgetTester tester) async {
      final AnimationController animation = AnimationController(
        vsync: const TestVSync(),
      );
      final AnimationController secondaryAnimation = AnimationController(
        vsync: const TestVSync(),
      );

      await tester.pumpWidget(
        const SharedZAxisPageTransitionsBuilder().buildTransitions<void>(
          null,
          null,
          animation,
          secondaryAnimation,
          const Placeholder(),
        ),
      );

      expect(find.byType(SharedZAxisTransition), findsOneWidget);
    },
  );
}