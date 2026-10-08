import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/widgets/overlays/glass_popover.dart';

void main() {
  testWidgets('GlassPopover localToGlobal check after scroll',
      (WidgetTester tester) async {
    final scrollController = ScrollController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                SizedBox(height: 800), // BIG GAP
                GlassPopover(
                  trigger: Container(width: 50, height: 50, color: Colors.blue),
                  contentBuilder: (context, close) =>
                      SizedBox(width: 100, height: 100),
                  onOpen: () {},
                ),
                SizedBox(height: 800), // BIG GAP
              ],
            ),
          ),
        ),
      ),
    );

    // Scroll down by 600 pixels
    scrollController.jumpTo(600);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(GlassPopover));
    await tester.pump();
  });
}
