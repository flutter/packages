import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/types/glass_button_style.dart';
import 'package:liquid_glass_widgets/types/glass_quality.dart';
import 'package:liquid_glass_widgets/types/glass_specular_sharpness.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // GlassQuality enum
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassQuality', () {
    test('has exactly 3 values', () {
      expect(GlassQuality.values, hasLength(3));
    });

    test('values are standard, premium, minimal', () {
      expect(
          GlassQuality.values,
          containsAll([
            GlassQuality.standard,
            GlassQuality.premium,
            GlassQuality.minimal,
          ]));
    });

    group('GlassQualityExtension.usesLightweightShader', () {
      test('standard uses lightweight shader', () {
        expect(GlassQuality.standard.usesLightweightShader, isTrue);
      });

      test('premium does NOT use lightweight shader', () {
        expect(GlassQuality.premium.usesLightweightShader, isFalse);
      });

      test('minimal does NOT use lightweight shader', () {
        expect(GlassQuality.minimal.usesLightweightShader, isFalse);
      });
    });

    group('GlassQualityExtension.usesAnyShader', () {
      test('standard uses a shader', () {
        expect(GlassQuality.standard.usesAnyShader, isTrue);
      });

      test('premium uses a shader', () {
        expect(GlassQuality.premium.usesAnyShader, isTrue);
      });

      test('minimal does NOT use any shader', () {
        expect(GlassQuality.minimal.usesAnyShader, isFalse);
      });
    });

    group('shader matrix is consistent', () {
      // Any quality that uses the lightweight shader should also use any shader.
      test('usesLightweightShader implies usesAnyShader', () {
        for (final q in GlassQuality.values) {
          if (q.usesLightweightShader) {
            expect(q.usesAnyShader, isTrue,
                reason: '$q uses lightweight shader so must use any shader');
          }
        }
      });

      // minimal is the only one with no shaders at all.
      test('only minimal has usesAnyShader == false', () {
        final noShader =
            GlassQuality.values.where((q) => !q.usesAnyShader).toList();
        expect(noShader, equals([GlassQuality.minimal]));
      });

      // only standard uses the lightweight path.
      test('only standard has usesLightweightShader == true', () {
        final lightweight =
            GlassQuality.values.where((q) => q.usesLightweightShader).toList();
        expect(lightweight, equals([GlassQuality.standard]));
      });
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassButtonStyle enum
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassButtonStyle', () {
    test('has exactly 3 values', () {
      expect(GlassButtonStyle.values, hasLength(3));
    });

    test('values are filled, prominent, and transparent', () {
      expect(
          GlassButtonStyle.values,
          containsAll([
            GlassButtonStyle.filled,
            GlassButtonStyle.prominent,
            GlassButtonStyle.transparent,
          ]));
    });

    test('filled is distinct from transparent', () {
      expect(
          GlassButtonStyle.filled, isNot(equals(GlassButtonStyle.transparent)));
    });

    test('prominent is distinct from filled and transparent', () {
      expect(
          GlassButtonStyle.prominent, isNot(equals(GlassButtonStyle.filled)));
      expect(GlassButtonStyle.prominent,
          isNot(equals(GlassButtonStyle.transparent)));
    });

    test('can be compared with ==', () {
      const a = GlassButtonStyle.filled;
      const b = GlassButtonStyle.filled;
      expect(a, equals(b));
    });

    test('enum name matches declaration', () {
      expect(GlassButtonStyle.filled.name, 'filled');
      expect(GlassButtonStyle.prominent.name, 'prominent');
      expect(GlassButtonStyle.transparent.name, 'transparent');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassSpecularSharpness enum
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassSpecularSharpness', () {
    test('has exactly 3 values', () {
      expect(GlassSpecularSharpness.values, hasLength(3));
    });

    test('values are soft, medium, sharp', () {
      expect(
          GlassSpecularSharpness.values,
          containsAll([
            GlassSpecularSharpness.soft,
            GlassSpecularSharpness.medium,
            GlassSpecularSharpness.sharp,
          ]));
    });

    group('glslIndex', () {
      test('soft has glslIndex 0', () {
        expect(GlassSpecularSharpness.soft.glslIndex, 0);
      });

      test('medium has glslIndex 1', () {
        expect(GlassSpecularSharpness.medium.glslIndex, 1);
      });

      test('sharp has glslIndex 2', () {
        expect(GlassSpecularSharpness.sharp.glslIndex, 2);
      });

      test('glslIndex equals enum index', () {
        for (final s in GlassSpecularSharpness.values) {
          expect(s.glslIndex, s.index,
              reason: '${s.name}.glslIndex should equal its enum index');
        }
      });

      test('glslIndex values are 0, 1, 2 in order', () {
        final indices =
            GlassSpecularSharpness.values.map((s) => s.glslIndex).toList();
        expect(indices, [0, 1, 2]);
      });
    });

    group('ordering', () {
      test('soft < medium < sharp by index', () {
        expect(GlassSpecularSharpness.soft.index,
            lessThan(GlassSpecularSharpness.medium.index));
        expect(GlassSpecularSharpness.medium.index,
            lessThan(GlassSpecularSharpness.sharp.index));
      });
    });
  });
}
