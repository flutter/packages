import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // GlassInteractionSettings — construction, copyWith, equality
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassInteractionSettings', () {
    group('construction defaults', () {
      test('all fields are null by default', () {
        const s = GlassInteractionSettings();
        expect(s.stretch, isNull);
        expect(s.interactionScale, isNull);
        expect(s.resistance, isNull);
        expect(s.anchorStretch, isNull);
        expect(s.anchorStretchSettings, isNull);
      });

      test('explicit values are stored', () {
        const s = GlassInteractionSettings(
          stretch: 0.2,
          interactionScale: 1.1,
          resistance: 0.05,
          anchorStretch: false,
          anchorStretchSettings: AnchorStretchSettings(intensity: 0.8),
        );
        expect(s.stretch, 0.2);
        expect(s.interactionScale, 1.1);
        expect(s.resistance, 0.05);
        expect(s.anchorStretch, false);
        expect(s.anchorStretchSettings?.intensity, 0.8);
      });

      test('defaults constant matches empty constructor', () {
        expect(
          GlassInteractionSettings.defaults,
          equals(const GlassInteractionSettings()),
        );
      });
    });

    group('copyWith', () {
      const original = GlassInteractionSettings(
        stretch: 0.3,
        interactionScale: 1.03,
      );

      test('copy with no args equals original', () {
        expect(original.copyWith(), equals(original));
        expect(original.copyWith().hashCode, equals(original.hashCode));
      });

      test('copyWith stretch', () {
        final copy = original.copyWith(stretch: 0.0);
        expect(copy.stretch, 0.0);
        expect(copy.interactionScale, 1.03); // unchanged
      });

      test('copyWith interactionScale', () {
        final copy = original.copyWith(interactionScale: 1.1);
        expect(copy.interactionScale, 1.1);
        expect(copy.stretch, 0.3); // unchanged
      });

      test('copyWith resistance', () {
        final copy = original.copyWith(resistance: 0.05);
        expect(copy.resistance, 0.05);
        expect(copy.stretch, 0.3); // unchanged
      });

      test('copyWith anchorStretch', () {
        final copy = original.copyWith(anchorStretch: false);
        expect(copy.anchorStretch, false);
      });

      test('copyWith anchorStretchSettings', () {
        const settings = AnchorStretchSettings(intensity: 0.9);
        final copy = original.copyWith(anchorStretchSettings: settings);
        expect(copy.anchorStretchSettings, settings);
      });
    });

    group('equality and hashCode', () {
      test('identical instances are equal', () {
        const a = GlassInteractionSettings(stretch: 0.2);
        const b = GlassInteractionSettings(stretch: 0.2);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different stretch breaks equality', () {
        const a = GlassInteractionSettings(stretch: 0.2);
        const b = GlassInteractionSettings(stretch: 0.5);
        expect(a, isNot(equals(b)));
      });

      test('different interactionScale breaks equality', () {
        const a = GlassInteractionSettings(interactionScale: 1.05);
        const b = GlassInteractionSettings(interactionScale: 1.1);
        expect(a, isNot(equals(b)));
      });

      test('all-null instances are equal', () {
        const a = GlassInteractionSettings();
        const b = GlassInteractionSettings();
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassThemeData — interaction field integration
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeData interaction field', () {
    test('default constructor has empty interaction settings', () {
      const data = GlassThemeData();
      expect(data.interaction, equals(const GlassInteractionSettings()));
    });

    test('custom interaction is stored', () {
      const interaction = GlassInteractionSettings(stretch: 0.1);
      const data = GlassThemeData(interaction: interaction);
      expect(data.interaction, equals(interaction));
      expect(data.interaction.stretch, 0.1);
    });

    test('copyWith interaction', () {
      const original = GlassThemeData();
      const newInteraction = GlassInteractionSettings(stretch: 0.0);
      final copy = original.copyWith(interaction: newInteraction);
      expect(copy.interaction.stretch, 0.0);
      // light/dark unchanged
      expect(copy.light, equals(original.light));
      expect(copy.dark, equals(original.dark));
    });

    test('different interaction breaks equality', () {
      const a = GlassThemeData(
        interaction: GlassInteractionSettings(stretch: 0.2),
      );
      const b = GlassThemeData(
        interaction: GlassInteractionSettings(stretch: 0.5),
      );
      expect(a, isNot(equals(b)));
    });

    test('same interaction preserves equality', () {
      const a = GlassThemeData(
        interaction: GlassInteractionSettings(stretch: 0.2),
      );
      const b = GlassThemeData(
        interaction: GlassInteractionSettings(stretch: 0.2),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('fallback() has empty interaction settings', () {
      final fallback = GlassThemeData.fallback();
      expect(
        fallback.interaction,
        equals(const GlassInteractionSettings()),
      );
    });

    test('simple() passes interaction through', () {
      const interaction = GlassInteractionSettings(stretch: 0.15);
      final data = GlassThemeData.simple(interaction: interaction);
      expect(data.interaction, equals(interaction));
    });

    test('simple() defaults to empty interaction when not specified', () {
      final data = GlassThemeData.simple(blur: 10);
      expect(data.interaction, equals(const GlassInteractionSettings()));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Theme propagation — interaction accessible via GlassThemeData.of()
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeData.of interaction propagation', () {
    testWidgets('interaction is accessible via GlassThemeData.of()',
        (tester) async {
      const interaction = GlassInteractionSettings(
        stretch: 0.1,
        interactionScale: 1.02,
      );
      const data = GlassThemeData(interaction: interaction);

      GlassInteractionSettings? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: GlassTheme(
            data: data,
            child: Builder(builder: (context) {
              captured = GlassThemeData.of(context).interaction;
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(captured, isNotNull);
      expect(captured!.stretch, 0.1);
      expect(captured!.interactionScale, 1.02);
    });

    testWidgets('returns default interaction when no GlassTheme in tree',
        (tester) async {
      GlassInteractionSettings? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            captured = GlassThemeData.of(context).interaction;
            return const SizedBox.shrink();
          }),
        ),
      );

      expect(captured, isNotNull);
      expect(captured!.stretch, isNull);
      expect(captured!.interactionScale, isNull);
    });
  });
}
