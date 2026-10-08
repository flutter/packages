import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/widgets/shared/glass_effect.dart';

import '../../shared/test_helpers.dart';

void main() {
  test('horizontal remains the default axis', () {
    final control = GlassSegmentedControl(
      segments: const [
        GlassSegment(label: 'A'),
        GlassSegment(label: 'B'),
      ],
      selectedIndex: 0,
      onSegmentSelected: (_) {},
    );

    expect(control.direction, Axis.horizontal);
    expect(control.segmentExtent, isNull);
  });

  testWidgets('vertical control sizes and stacks segments on its main axis',
      (tester) async {
    await tester.pumpWidget(
      createTestApp(
        child: Align(
          alignment: Alignment.topCenter,
          child: GlassSegmentedControl(
            segments: const [
              GlassSegment(label: 'Top'),
              GlassSegment(label: 'Middle'),
              GlassSegment(label: 'Bottom'),
            ],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            direction: Axis.vertical,
            height: 44,
            segmentExtent: 52,
            useOwnLayer: true,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    final size = tester.getSize(find.byType(GlassSegmentedControl));
    expect(size.width, 44);
    expect(size.height, 52 * 3);

    final top = tester.getCenter(find.text('Top'));
    final middle = tester.getCenter(find.text('Middle'));
    final bottom = tester.getCenter(find.text('Bottom'));
    expect(middle.dy, greaterThan(top.dy));
    expect(bottom.dy, greaterThan(middle.dy));
    expect(middle.dx, closeTo(top.dx, 0.5));
  });

  testWidgets('vertical indicator occupies and follows the vertical axis',
      (tester) async {
    await tester.pumpWidget(
      createTestApp(
        child: Align(
          alignment: Alignment.topCenter,
          child: GlassSegmentedControl(
            segments: const [
              GlassSegment(label: 'Top'),
              GlassSegment(label: 'Middle'),
              GlassSegment(label: 'Bottom'),
            ],
            selectedIndex: 1,
            onSegmentSelected: (_) {},
            direction: Axis.vertical,
            useOwnLayer: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final indicatorBox = tester.widget<FractionallySizedBox>(
      find
          .descendant(
            of: find.byType(GlassSegmentedControl),
            matching: find.byType(FractionallySizedBox),
          )
          .first,
    );
    final alignment = indicatorBox.alignment.resolve(TextDirection.ltr);

    expect(indicatorBox.widthFactor, isNull);
    expect(indicatorBox.heightFactor, closeTo(1 / 3, 1e-9));
    expect(alignment.x, 0);
    expect(alignment.y, 0);
  });

  testWidgets('off-center vertical selection settles at rest', (tester) async {
    await tester.pumpWidget(
      createTestApp(
        child: Align(
          alignment: Alignment.topCenter,
          child: GlassSegmentedControl(
            segments: const [
              GlassSegment(label: 'Top'),
              GlassSegment(label: 'Middle'),
              GlassSegment(label: 'Bottom'),
            ],
            selectedIndex: 2,
            onSegmentSelected: (_) {},
            direction: Axis.vertical,
            useOwnLayer: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
    expect(opacity.opacity, 1);
  });

  testWidgets('vertical mode wires only the vertical drag recognizer',
      (tester) async {
    await tester.pumpWidget(
      createTestApp(
        child: Align(
          alignment: Alignment.topCenter,
          child: GlassSegmentedControl(
            segments: const [
              GlassSegment(label: 'A'),
              GlassSegment(label: 'B'),
            ],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            direction: Axis.vertical,
          ),
        ),
      ),
    );

    final drag = tester
        .widgetList<GestureDetector>(find.byType(GestureDetector))
        .firstWhere(
          (gesture) =>
              gesture.onVerticalDragUpdate != null ||
              gesture.onHorizontalDragUpdate != null,
        );
    expect(drag.onVerticalDragUpdate, isNotNull);
    expect(drag.onHorizontalDragUpdate, isNull);
  });

  testWidgets('vertical icon segments preserve accessibility labels',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      createTestApp(
        child: Align(
          alignment: Alignment.topCenter,
          child: GlassSegmentedControl(
            segments: const [
              GlassSegment(
                icon: Icon(CupertinoIcons.square_grid_2x2),
                semanticLabel: 'Canvas',
              ),
              GlassSegment(
                icon: Icon(CupertinoIcons.circle_grid_hex),
                semanticLabel: 'Flow',
              ),
              GlassSegment(
                icon: Icon(CupertinoIcons.layers_alt),
                semanticLabel: 'Deep Dive',
              ),
            ],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            direction: Axis.vertical,
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Canvas'), findsOneWidget);
    expect(find.bySemanticsLabel('Flow'), findsOneWidget);
    expect(find.bySemanticsLabel('Deep Dive'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('vertical drag selects along the y axis', (tester) async {
    int? selected;
    await tester.pumpWidget(
      createTestApp(
        child: Align(
          alignment: Alignment.topCenter,
          child: GlassSegmentedControl(
            segments: const [
              GlassSegment(label: 'Top'),
              GlassSegment(label: 'Middle'),
              GlassSegment(label: 'Bottom'),
            ],
            selectedIndex: 0,
            onSegmentSelected: (index) => selected = index,
            direction: Axis.vertical,
            height: 44,
            segmentExtent: 52,
            useOwnLayer: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Top')));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 104));
    // The first large move resolves the tap-vs-drag arena. A subsequent event
    // is what the winning drag recognizer reports as an update.
    await gesture.moveBy(const Offset(0, 1));
    // Let the active velocity spring visibly follow the held drag. One frame is
    // intentionally insufficient because the first frame rebuilds and starts
    // the spring; the second advances it.
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    final draggedIndicator = tester.widget<FractionallySizedBox>(
      find
          .descendant(
            of: find.byType(GlassSegmentedControl),
            matching: find.byType(FractionallySizedBox),
          )
          .first,
    );
    expect(
      draggedIndicator.alignment.resolve(TextDirection.ltr).y,
      greaterThan(0.8),
    );

    await gesture.up();
    await tester.pumpAndSettle();

    expect(selected, 2);
  });

  testWidgets('vertical indicator rotates the jelly clip budget',
      (tester) async {
    await tester.pumpWidget(
      createTestApp(
        child: Center(
          child: SizedBox(
            width: 44,
            height: 132,
            child: Stack(
              children: const [
                AnimatedGlassIndicator(
                  velocity: 1,
                  itemCount: 3,
                  alignment: Alignment.topCenter,
                  thickness: 1,
                  quality: GlassQuality.minimal,
                  indicatorColor: CupertinoColors.white,
                  isBackgroundIndicator: false,
                  borderRadius: 18,
                  direction: Axis.vertical,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final effect = tester.widget<GlassEffect>(find.byType(GlassEffect));
    expect(
      effect.clipExpansion,
      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
    );
  });
}
