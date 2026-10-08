import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

// ---------------------------------------------------------------------------
// RTL Layout Audit Tests
//
// Verifies that widgets updated in the RTL audit (0.28.0) use directional
// padding/alignment primitives and mirror correctly under TextDirection.rtl.
// ---------------------------------------------------------------------------

/// Minimal LTR wrapper — no extra Padding injected by scaffolds.
Widget _ltrBare(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(),
      child: child,
    ),
  );
}

/// Minimal RTL wrapper.
Widget _rtlBare(Widget child) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: MediaQuery(
      data: const MediaQueryData(),
      child: child,
    ),
  );
}

/// Resolve a geometry to physical insets.
EdgeInsets _resolve(EdgeInsetsGeometry geo, TextDirection dir) =>
    geo.resolve(dir);

void main() {
  // =========================================================================
  // GlassDivider — indent / endIndent directional mapping
  // =========================================================================

  group('GlassDivider — RTL indent mapping', () {
    testWidgets('padding is EdgeInsetsDirectional, not EdgeInsets',
        (tester) async {
      await tester.pumpWidget(
        _ltrBare(const Center(child: GlassDivider(indent: 24, endIndent: 8))),
      );
      // ExcludeSemantics → Padding → SizedBox → Center → Container
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(GlassDivider),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(
        padding.padding,
        isA<EdgeInsetsDirectional>(),
        reason: 'GlassDivider should use EdgeInsetsDirectional for RTL support',
      );
    });

    testWidgets('indent maps to physical left in LTR', (tester) async {
      await tester.pumpWidget(
        _ltrBare(const Center(child: GlassDivider(indent: 24, endIndent: 8))),
      );
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(GlassDivider),
              matching: find.byType(Padding),
            )
            .first,
      );
      final insets = _resolve(padding.padding, TextDirection.ltr);
      expect(insets.left, 24, reason: 'start(24) → left in LTR');
      expect(insets.right, 8, reason: 'end(8) → right in LTR');
    });

    testWidgets('indent maps to physical right in RTL', (tester) async {
      await tester.pumpWidget(
        _rtlBare(const Center(child: GlassDivider(indent: 24, endIndent: 8))),
      );
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(GlassDivider),
              matching: find.byType(Padding),
            )
            .first,
      );
      final insets = _resolve(padding.padding, TextDirection.rtl);
      expect(insets.right, 24,
          reason: 'start(24) → right in RTL (leading side)');
      expect(insets.left, 8, reason: 'end(8) → left in RTL (trailing side)');
    });

    testWidgets('vertical divider top/bottom are unaffected by text direction',
        (tester) async {
      await tester.pumpWidget(
        _rtlBare(
          const SizedBox(
              height: 100,
              child: GlassDivider.vertical(indent: 10, endIndent: 5)),
        ),
      );
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(GlassDivider),
              matching: find.byType(Padding),
            )
            .first,
      );
      final insets = _resolve(padding.padding, TextDirection.rtl);
      expect(insets.top, 10, reason: 'indent → top for vertical divider');
      expect(insets.bottom, 5,
          reason: 'endIndent → bottom for vertical divider');
    });
  });

  // =========================================================================
  // GlassGroupedSection — header / footer insets
  // =========================================================================

  group('GlassGroupedSection — RTL header padding', () {
    testWidgets('header start=16 → left=16 in LTR', (tester) async {
      await tester.pumpWidget(
        _ltrBare(
          GlassGroupedSection(
            header: const Text('Header'),
            children: const [SizedBox.shrink()],
          ),
        ),
      );
      final headerPadding =
          tester.widgetList<Padding>(find.byType(Padding)).firstWhere(
                (p) => tester
                    .widgetList(find.descendant(
                      of: find.byWidget(p),
                      matching: find.byType(DefaultTextStyle),
                    ))
                    .isNotEmpty,
              );
      final insets = _resolve(headerPadding.padding, TextDirection.ltr);
      expect(insets.left, 16);
      expect(insets.right, 16);
    });

    testWidgets('header start=16 → right=16 in RTL', (tester) async {
      await tester.pumpWidget(
        _rtlBare(
          GlassGroupedSection(
            header: const Text('رأس'),
            children: const [SizedBox.shrink()],
          ),
        ),
      );
      final headerPadding =
          tester.widgetList<Padding>(find.byType(Padding)).firstWhere(
                (p) => tester
                    .widgetList(find.descendant(
                      of: find.byWidget(p),
                      matching: find.byType(DefaultTextStyle),
                    ))
                    .isNotEmpty,
              );
      final insets = _resolve(headerPadding.padding, TextDirection.rtl);
      // start=16 (logical leading) → physical right in RTL
      expect(insets.right, 16);
      expect(insets.left, 16);
    });
  });

  // =========================================================================
  // GlassAppBar — title alignment
  // =========================================================================

  group('GlassAppBar — RTL title alignment', () {
    // The _ToolbarLayout MultiChildLayoutDelegate positions children at the
    // RenderObject level — there are no Align or Center widgets in the toolbar
    // tree. The correct invariant is the geometric position of the title.

    testWidgets('centerTitle:false — title starts after leading widget (LTR)',
        (tester) async {
      await tester.pumpWidget(
        _ltrBare(
          const GlassAppBar(
            title: Text('Title'),
            centerTitle: false,
            leading: SizedBox(width: 44, height: 44),
          ),
        ),
      );

      final appBarBox =
          tester.renderObject<RenderBox>(find.byType(GlassAppBar));
      final barCenter =
          appBarBox.localToGlobal(Offset.zero).dx + appBarBox.size.width / 2;

      final titleBox = tester.renderObject<RenderBox>(find.text('Title'));
      final titleCenter =
          titleBox.localToGlobal(Offset.zero).dx + titleBox.size.width / 2;

      expect(
        titleCenter,
        lessThan(barCenter),
        reason:
            'LTR centerTitle:false — title centre must be left of bar centre',
      );
    });

    testWidgets('centered title is geometrically centred on bar (LTR)',
        (tester) async {
      await tester.pumpWidget(
        _ltrBare(
          const GlassAppBar(
            title: Text('Title'),
            leading: SizedBox(width: 44, height: 44),
          ),
        ),
      );

      final appBarBox =
          tester.renderObject<RenderBox>(find.byType(GlassAppBar));
      final barCenter =
          appBarBox.localToGlobal(Offset.zero).dx + appBarBox.size.width / 2;

      final titleBox = tester.renderObject<RenderBox>(find.text('Title'));
      final titleCenter =
          titleBox.localToGlobal(Offset.zero).dx + titleBox.size.width / 2;

      expect(
        titleCenter,
        closeTo(barCenter, 2.0),
        reason:
            'centerTitle:true — title midpoint must coincide with bar midpoint',
      );
    });

    testWidgets('centerTitle:false — title starts after leading widget (RTL)',
        (tester) async {
      await tester.pumpWidget(
        _rtlBare(
          const GlassAppBar(
            title: Text('Title'),
            centerTitle: false,
            leading: SizedBox(width: 44, height: 44),
          ),
        ),
      );

      final appBarBox =
          tester.renderObject<RenderBox>(find.byType(GlassAppBar));
      final barCenter =
          appBarBox.localToGlobal(Offset.zero).dx + appBarBox.size.width / 2;

      final titleBox = tester.renderObject<RenderBox>(find.text('Title'));
      final titleCenter =
          titleBox.localToGlobal(Offset.zero).dx + titleBox.size.width / 2;

      // In RTL the leading is on the right, so the title starts from the
      // right — its centre should be to the RIGHT of the bar centre.
      expect(
        titleCenter,
        greaterThan(barCenter),
        reason:
            'RTL centerTitle:false — title centre must be right of bar centre',
      );
    });

    testWidgets(
        'centerTitle:false — title aligns to right padding without leading (RTL regression #282)',
        (tester) async {
      const double horizontalPadding = 16.0;

      await tester.pumpWidget(
        _rtlBare(
          const Scaffold(
            appBar: GlassAppBar(
              title: Text('Title'),
              centerTitle: false,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            ),
          ),
        ),
      );

      final appBarBox =
          tester.renderObject<RenderBox>(find.byType(GlassAppBar));
      final titleRight = tester.getTopRight(find.text('Title')).dx;

      // In RTL with no leading, title's right edge should be at barWidth - horizontalPadding
      expect(
        titleRight,
        appBarBox.size.width - horizontalPadding,
        reason: 'RTL title should align to right padding without extra gap',
      );
    });

    testWidgets(
        'centerTitle:false — title places 8px to the left of leading without overlapping (RTL)',
        (tester) async {
      const double horizontalPadding = 16.0;
      const double leadingWidth = 44.0;

      await tester.pumpWidget(
        _rtlBare(
          const Scaffold(
            appBar: GlassAppBar(
              title: Text('Title'),
              centerTitle: false,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              leading: SizedBox(width: leadingWidth, height: 44),
            ),
          ),
        ),
      );

      final appBarBox =
          tester.renderObject<RenderBox>(find.byType(GlassAppBar));
      final titleRight = tester.getTopRight(find.text('Title')).dx;

      // Leading occupies [width - padding - 44, width - padding]
      // Title right edge must be width - padding - leadingWidth - 8.0
      expect(
        titleRight,
        appBarBox.size.width - horizontalPadding - leadingWidth - 8.0,
        reason: 'RTL title should have an 8px gap to the left of leading',
      );
    });
  });

  // =========================================================================
  // GlassLargeTitle — scaling alignment
  //
  // Smoke test for the Transform.scale anchor fix. Full RTL padding coverage
  // lives in test/widgets/surfaces/glass_large_title_test.dart.
  // =========================================================================

  group('GlassLargeTitle — RTL scaling alignment', () {
    testWidgets('title scales from AlignmentDirectional.bottomStart',
        (tester) async {
      final controller = GlassLargeTitleController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _rtlBare(
          CustomScrollView(
            controller: controller.scrollController,
            slivers: [
              GlassLargeTitle(text: 'Title', controller: controller),
            ],
          ),
        ),
      );
      final transforms = tester.widgetList<Transform>(find.byType(Transform));
      final hasDirectionalAlign = transforms
          .any((t) => t.alignment == AlignmentDirectional.bottomStart);
      expect(
        hasDirectionalAlign,
        isTrue,
        reason: 'GlassLargeTitle rubber-band scale must anchor to '
            'AlignmentDirectional.bottomStart — not Alignment.bottomLeft — '
            'so the title stretches from the leading edge in both LTR and RTL.',
      );
    });
  });
}
