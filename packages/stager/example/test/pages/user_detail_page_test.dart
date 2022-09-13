import 'package:example/pages/user_detail/user_detail_page_scenes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a loading state', (WidgetTester tester) async {
    final scene = LoadingUserDetailPageScene();
    await scene.setUp();
    await tester.pumpWidget(scene.build());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows an error state', (WidgetTester tester) async {
    final scene = ErrorUserDetailPageScene();
    await scene.setUp();
    await tester.pumpWidget(scene.build());
    await tester.pump();
    expect(find.text('Error'), findsOneWidget);
  });

  testWidgets('shows an empty state', (WidgetTester tester) async {
    final scene = EmptyUserDetailPageScene();
    await scene.setUp();
    await tester.pumpWidget(scene.build());
    await tester.pump();
    expect(find.text('No posts'), findsOneWidget);
  });

  testWidgets('shows posts', (WidgetTester tester) async {
    final scene = WithPostsUserDetailPageScene();
    await scene.setUp();
    await tester.pumpWidget(scene.build());
    await tester.pump();
    expect(find.text('Post 1'), findsOneWidget);
  });
}
