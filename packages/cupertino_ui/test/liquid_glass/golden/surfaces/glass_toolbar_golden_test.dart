import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  group('GlassToolbar Golden Tests', () {
    testWidgets('Standard GlassToolbar appearance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black, // Dark bg to see glass effect
            body: Stack(
              children: [
                // Colorful background content
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // Toolbar at bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GlassToolbar(
                    children: [
                      GlassButton(
                        icon: Icon(CupertinoIcons.share),
                        onTap: () {},
                        label: 'Action 1',
                      ),
                      const Spacer(),
                      GlassButton(
                        icon: Icon(CupertinoIcons.add),
                        onTap: () {},
                        label: 'Action 2',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(GlassToolbar),
        matchesGoldenFile('goldens/glass_toolbar_standard.png'),
      );
    });
  });
}
