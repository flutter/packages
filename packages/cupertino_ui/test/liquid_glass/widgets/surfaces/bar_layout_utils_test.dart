// Unit tests for resolveTabPillWidth in bar_layout_utils.dart.
//
// These tests are pure Dart — no Flutter widget tree needed — so they
// run fast and can be executed in any CI environment.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_layout_utils.dart';

void main() {
  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Wraps resolveTabPillWidth with a fixed maxAvailable for brevity.
  double resolve({
    required double? tabWidth,
    required int tabCount,
    double maxAvailable = 390.0,
  }) =>
      resolveTabPillWidth(
        tabWidth: tabWidth,
        tabCount: tabCount,
        maxAvailable: maxAvailable,
      );

  // ── Expand (null) behaviour ────────────────────────────────────────────────

  group('tabWidth null → expand behaviour', () {
    test('returns maxAvailable exactly', () {
      expect(resolve(tabWidth: null, tabCount: 3), 390.0);
    });

    test('tab count is irrelevant when null', () {
      expect(resolve(tabWidth: null, tabCount: 1), 390.0);
      expect(resolve(tabWidth: null, tabCount: 10), 390.0);
    });

    test('works with non-standard maxAvailable', () {
      expect(
        resolveTabPillWidth(
          tabWidth: null,
          tabCount: 2,
          maxAvailable: 275.0,
        ),
        275.0,
      );
    });
  });

  // ── Compact (non-null) behaviour ───────────────────────────────────────────

  group('tabWidth non-null → compact behaviour', () {
    test('2 tabs × 88 px = 176 px', () {
      expect(resolve(tabWidth: 88.0, tabCount: 2), 176.0);
    });

    test('3 tabs × 88 px = 264 px', () {
      expect(resolve(tabWidth: 88.0, tabCount: 3), 264.0);
    });

    test('icon-only slot (72 px) × 3 tabs = 216 px', () {
      expect(resolve(tabWidth: 72.0, tabCount: 3), 216.0);
    });

    test('wide slot (110 px) × 2 tabs = 220 px', () {
      expect(resolve(tabWidth: 110.0, tabCount: 2), 220.0);
    });

    test('single tab returns tabWidth itself', () {
      expect(resolve(tabWidth: 88.0, tabCount: 1), 88.0);
    });
  });

  // ── Clamping ───────────────────────────────────────────────────────────────

  group('clamping — natural width never exceeds maxAvailable', () {
    test('4 tabs × 88 px = 352 > 390? No — not clamped', () {
      // 352 < 390 — should NOT be clamped
      expect(resolve(tabWidth: 88.0, tabCount: 4, maxAvailable: 390.0), 352.0);
    });

    test('5 tabs × 88 px = 440 > 390 — clamped to 390', () {
      expect(
        resolve(tabWidth: 88.0, tabCount: 5, maxAvailable: 390.0),
        390.0,
      );
    });

    test('very large tabWidth clamped to maxAvailable', () {
      expect(
        resolve(tabWidth: 500.0, tabCount: 2, maxAvailable: 300.0),
        300.0,
      );
    });

    test('result is always ≤ maxAvailable regardless of inputs', () {
      const max = 320.0;
      expect(
        resolve(tabWidth: 200.0, tabCount: 10, maxAvailable: max),
        lessThanOrEqualTo(max),
      );
    });

    // ── safeMax guard — negative maxAvailable must not throw RangeError ──────

    test('maxAvailable = 0 → result is 0, no crash', () {
      expect(
        resolveTabPillWidth(tabWidth: 88.0, tabCount: 3, maxAvailable: 0.0),
        0.0,
      );
    });

    test('maxAvailable < 0 → result is 0, no RangeError thrown', () {
      // Dart's clamp(min, max) requires min ≤ max.
      // Without the safeMax guard, clamp(0.0, -50.0) throws a RangeError.
      expect(
        () => resolveTabPillWidth(
          tabWidth: 88.0,
          tabCount: 3,
          maxAvailable: -50.0,
        ),
        returnsNormally,
      );
      expect(
        resolveTabPillWidth(tabWidth: 88.0, tabCount: 3, maxAvailable: -50.0),
        0.0,
      );
    });

    test('expand (null) with negative maxAvailable → 0, no crash', () {
      expect(
        resolveTabPillWidth(
          tabWidth: null,
          tabCount: 3,
          maxAvailable: -100.0,
        ),
        0.0,
      );
    });
  });

  // ── Narrower-than-max narrow layouts ──────────────────────────────────────

  group('compact pill leaves space for extra elements', () {
    const total = 390.0;
    const extraBtnW = 72.0;
    const spacing = 8.0;
    const maxTabW = total - extraBtnW - spacing; // 310.0

    test('2-tab compact pill is narrower than the full available space', () {
      final pill = resolveTabPillWidth(
        tabWidth: 88.0,
        tabCount: 2,
        maxAvailable: maxTabW,
      );
      expect(pill, lessThan(maxTabW));
      expect(pill, 176.0);
    });

    test('expand leaves no gap (pill == maxTabW)', () {
      final pill = resolveTabPillWidth(
        tabWidth: null,
        tabCount: 2,
        maxAvailable: maxTabW,
      );
      expect(pill, maxTabW); // 310.0
    });

    test('compact pill is always narrower than expand for the same inputs', () {
      final compact = resolveTabPillWidth(
        tabWidth: 88.0,
        tabCount: 3,
        maxAvailable: maxTabW,
      );
      final expand = resolveTabPillWidth(
        tabWidth: null,
        tabCount: 3,
        maxAvailable: maxTabW,
      );
      expect(compact, lessThan(expand));
    });
  });

  // ── Symmetry with GlassTabBar.bottom/GlassTabBar.searchable defaults ─────────

  group('iOS 26 default (88 px) produces expected pill widths', () {
    // Simulates a 390-wide iPhone display with no extra button
    const phoneW = 390.0;

    test('2 tabs → 176 px (< half of 390 → looks compact)', () {
      expect(
        resolveTabPillWidth(tabWidth: 88.0, tabCount: 2, maxAvailable: phoneW),
        176.0,
      );
    });

    test('3 tabs → 264 px (standard iPhone use case)', () {
      expect(
        resolveTabPillWidth(tabWidth: 88.0, tabCount: 3, maxAvailable: phoneW),
        264.0,
      );
    });

    test('4 tabs → 352 px (still fits on a 390-wide screen)', () {
      expect(
        resolveTabPillWidth(tabWidth: 88.0, tabCount: 4, maxAvailable: phoneW),
        352.0,
      );
    });

    test('5 tabs → clamped to 390 px', () {
      expect(
        resolveTabPillWidth(tabWidth: 88.0, tabCount: 5, maxAvailable: phoneW),
        phoneW,
      );
    });
  });
}
