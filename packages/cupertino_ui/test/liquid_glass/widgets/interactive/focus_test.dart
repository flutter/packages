import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/widgets/shared/glass_focus_region.dart';

void main() {
  testWidgets('Focus region test', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: GlassFocusRegion(
              enabled: true,
              isButton: true,
              semanticLabel: 'Semantics A',
              isFocusedNotifier: ValueNotifier(false),
              isHoveredNotifier: ValueNotifier(false),
              child: const SizedBox(width: 50, height: 50),
            ),
          ),
        ),
      );
      final nodeA = tester.getSemantics(find.bySemanticsLabel('Semantics A'));
      debugPrint('NODE A: $nodeA');
    } finally {
      handle.dispose();
    }
  });
}
