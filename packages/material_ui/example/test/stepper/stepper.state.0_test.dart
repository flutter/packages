// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/stepper/stepper.state.0.dart' as example;

void main() {
  testWidgets('Stepper state example test', (WidgetTester tester) async {
    await tester.pumpWidget(const example.StepperStateExampleApp());

    expect(find.widgetWithText(AppBar, 'Stepper state Sample'), findsOneWidget);
    expect(find.text('Create account title').hitTestable(), findsOneWidget);
    expect(find.text('Complete profile').hitTestable(), findsOneWidget);
    expect(find.text('Finish setup').hitTestable(), findsOneWidget);

    // The first step is initially expanded.
    expect(find.text('Create account button').hitTestable(), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(3));

    // current: 0th step
    final Stepper stepper = tester.widget<Stepper>(find.byType(Stepper));
    await tester.pumpAndSettle();
    expect(find.text('Create account title').hitTestable(), findsOneWidget);

    // current: 0 and taps the 0th step
    stepper.onStepTapped?.call(0);
    await tester.pumpAndSettle();
    expect(find.text('Create account title').hitTestable(), findsOneWidget);

    // Create the account so the next step becomes active.
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Create account button'),
    );
    await tester.pumpAndSettle();

    // current: 0 and clicks continue
    stepper.onStepContinue?.call();
    await tester.pumpAndSettle();
    expect(find.text('Complete profile').hitTestable(), findsOneWidget);
    expect(find.text('Complete profile button').hitTestable(), findsOneWidget);

    // current: 1 and taps the 1st step
    stepper.onStepTapped?.call(1);
    await tester.pumpAndSettle();
    expect(find.text('Complete profile').hitTestable(), findsOneWidget);

    // Complete the profile so the next step becomes active.
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Complete profile button'),
    );
    await tester.pumpAndSettle();

    // current: 1 and clicks continue
    stepper.onStepContinue?.call();
    await tester.pumpAndSettle();
    expect(find.text('Finish setup').hitTestable(), findsOneWidget);
    expect(find.text('Finish setup button').hitTestable(), findsOneWidget);

    // current: 2 and clicks cancel
    stepper.onStepCancel?.call();
    await tester.pumpAndSettle();
    expect(find.text('Complete profile').hitTestable(), findsOneWidget);

    // current: 1 and taps the 0th step
    stepper.onStepTapped?.call(0);
    await tester.pumpAndSettle();
    expect(find.text('Create account title').hitTestable(), findsOneWidget);

    // current: 0 and taps the 2nd step
    stepper.onStepTapped?.call(2);
    await tester.pumpAndSettle();
    expect(find.text('Finish setup').hitTestable(), findsOneWidget);
  });
}
