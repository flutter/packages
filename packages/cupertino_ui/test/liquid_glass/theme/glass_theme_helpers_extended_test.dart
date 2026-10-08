// Tests for GlassThemeHelpers covering the one remaining uncovered path:
// resolveQuality when an InheritedLiquidGlass ancestor is present but its
// quality is a specific value — and the GlassTheme (priority 3) path.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/theme/glass_theme_helpers.dart';

void main() {
  // ── Additional resolveQuality paths ─────────────────────────────────────────

  group('GlassThemeHelpers.resolveQuality — extended paths', () {
    testWidgets(
        'returns GlassTheme quality when no ancestor layer set (priority 3)',
        (tester) async {
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: GlassTheme(
            // GlassThemeVariant.minimal sets quality = GlassQuality.minimal
            // for both light and dark — so resolveQuality should return minimal
            // when there is no InheritedLiquidGlass ancestor.
            data: const GlassThemeData(
              light: GlassThemeVariant.minimal,
              dark: GlassThemeVariant.minimal,
            ),
            child: Builder(builder: (context) {
              // No InheritedLiquidGlass ancestor → falls through to theme
              result = GlassThemeHelpers.resolveQuality(
                context,
                widgetQuality: null,
              );
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(result, GlassQuality.minimal);
    });

    testWidgets(
        'widgetQuality null + no ancestor + no theme returns custom fallback',
        (tester) async {
      late GlassQuality result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            result = GlassThemeHelpers.resolveQuality(
              context,
              widgetQuality: null,
              fallback: GlassQuality.minimal,
            );
            return const SizedBox.shrink();
          }),
        ),
      );

      expect(result, GlassQuality.minimal);
    });

    testWidgets('ancestor layer quality is returned (all values)',
        (tester) async {
      for (final quality in GlassQuality.values) {
        late GlassQuality result;
        await tester.pumpWidget(
          MaterialApp(
            home: AdaptiveLiquidGlassLayer(
              quality: quality,
              child: Builder(builder: (context) {
                result = GlassThemeHelpers.resolveQuality(context);
                return const SizedBox.shrink();
              }),
            ),
          ),
        );
        expect(result, quality,
            reason: 'expected $quality from ancestor layer');
      }
    });
  });
}
