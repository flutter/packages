import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/src/scene_container.dart';
import 'package:stager/stager.dart';

void main() {
  final scenes = [
    ButtonScene(),
    TextScene(),
  ];

  testWidgets('Displays a list of Scenes', (WidgetTester tester) async {
    final stagerApp = StagerApp(scenes: scenes);
    await tester.pumpWidget(stagerApp);
    await tester.pumpAndSettle();
    expect(find.text('Text'), findsOneWidget);
    expect(find.text('Button'), findsOneWidget);
  });

  testWidgets('Displays a back button after navigating to a Scene',
      (WidgetTester tester) async {
    final stagerApp = StagerApp(scenes: scenes);
    await tester.pumpWidget(stagerApp);
    await tester.pumpAndSettle();

    // Tap the "Text" row to push TextScene onto the navigation stack.
    await tester.tap(find.text('Text'));
    await tester.pumpAndSettle();

    // Verify that our SceneContainer is present.
    expect(find.byType(SceneContainer), findsOneWidget);

    // Verify that tapping the back button navigates back.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(SceneContainer), findsNothing);
    expect(find.text('Text'), findsOneWidget);
    expect(find.text('Button'), findsOneWidget);
  });
}

class TextScene extends Scene {
  @override
  String get title => 'Text';

  @override
  Widget build() => const Text('Text Scene');
}

class ButtonScene extends Scene {
  @override
  String get title => 'Button';

  @override
  Widget build() => ElevatedButton(
        onPressed: () {},
        child: Text('My Button'),
      );
}
