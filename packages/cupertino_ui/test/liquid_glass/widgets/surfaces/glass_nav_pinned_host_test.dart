import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as barrel;
import 'package:liquid_glass_widgets/widgets/surfaces/glass_bar_item.dart';
import 'package:liquid_glass_widgets/widgets/surfaces/shared/glass_nav_pinned_host.dart';

GlassBarIconItem _icon(IconData icon, {Object? id}) =>
    GlassBarIconItem(icon: Icon(icon), onTap: () {}, id: id);

void main() {
  group('cluster materialize phase', () {
    double phase(double p, {bool inFrom = true, bool inTo = false}) =>
        GlassNavPinnedMetrics.clusterPhaseAt(
          inFrom: inFrom,
          inTo: inTo,
          progress: p,
        );

    test('a cluster that disappears dematerializes over the head', () {
      expect(phase(0.0), 1.0);
      expect(phase(GlassNavPinnedMetrics.dematerializeEnd / 2),
          closeTo(0.5, 1e-9));
      expect(phase(GlassNavPinnedMetrics.dematerializeEnd), 0.0);
      expect(phase(1.0), 0.0);
    });

    test('a cluster that appears materializes over the tail', () {
      double p(double v) => phase(v, inFrom: false, inTo: true);
      expect(p(0.0), 0.0);
      expect(p(GlassNavPinnedMetrics.materializeStart), 0.0);
      expect(p(1.0), 1.0);
      final mid = (GlassNavPinnedMetrics.materializeStart + 1.0) / 2;
      expect(p(mid), closeTo(0.5, 1e-9));
    });

    test('both phases are monotone, so a scrubbed swipe never jumps', () {
      var lastExit = phase(0.0);
      var lastEnter = phase(0.0, inFrom: false, inTo: true);
      for (var i = 1; i <= 100; i++) {
        final p = i / 100;
        final exit = phase(p);
        final enter = phase(p, inFrom: false, inTo: true);
        expect(exit, lessThanOrEqualTo(lastExit + 1e-9));
        expect(enter, greaterThanOrEqualTo(lastEnter - 1e-9));
        lastExit = exit;
        lastEnter = enter;
      }
    });

    test(
      'the outgoing cluster is never solid once the incoming one begins, so '
      'the two are never both fully present',
      () {
        for (var i = 0; i <= 100; i++) {
          final p = i / 100;
          final exit = phase(p);
          final enter = phase(p, inFrom: false, inTo: true);
          expect(
            exit + enter,
            lessThanOrEqualTo(1.0 + 1e-9),
            reason: 'phases overlap at p=$p',
          );
        }
      },
    );

    test('the configuration never swaps while a cluster is still solid', () {
      // The window must straddle swapAt: swapping the items shown inside a
      // fully opaque capsule is the pop this effect exists to remove.
      expect(phase(GlassNavPinnedMetrics.swapAt), lessThan(1.0));
      expect(
        phase(GlassNavPinnedMetrics.swapAt, inFrom: false, inTo: true),
        greaterThan(0.0),
      );
    });

    test('a cluster present on both sides never dissolves', () {
      for (var i = 0; i <= 100; i++) {
        expect(
          phase(i / 100, inFrom: true, inTo: true),
          1.0,
          reason: 'a surviving capsule morphs in place, it does not blink',
        );
      }
    });

    test('nothing to show on either side renders nothing', () {
      for (var i = 0; i <= 100; i++) {
        expect(phase(i / 100, inFrom: false, inTo: false), 0.0);
      }
    });
  });

  group('configuration swap', () {
    test('switches from the outgoing to the incoming side at the midpoint', () {
      expect(GlassNavPinnedMetrics.showsIncomingAt(0.0), isFalse);
      expect(GlassNavPinnedMetrics.showsIncomingAt(0.49), isFalse);
      expect(GlassNavPinnedMetrics.showsIncomingAt(0.5), isTrue);
      expect(GlassNavPinnedMetrics.showsIncomingAt(1.0), isTrue);
    });

    test('the incoming capsule is already forming when its items swap in', () {
      // Items appear with their side, so the capsule that contains them must
      // have begun materializing by the time the configuration flips.
      expect(
        GlassNavPinnedMetrics.showsIncomingAt(GlassNavPinnedMetrics.swapAt),
        isTrue,
      );
      expect(
        GlassNavPinnedMetrics.clusterPhaseAt(
          inFrom: false,
          inTo: true,
          progress: GlassNavPinnedMetrics.swapAt,
        ),
        greaterThan(0.0),
      );
    });
  });

  group('action matching', () {
    test('identifier match wins over position', () {
      final add = _icon(CupertinoIcons.add, id: 'add');
      final more = _icon(CupertinoIcons.ellipsis);
      final search = _icon(CupertinoIcons.search);
      final addAgain = _icon(CupertinoIcons.add, id: 'add');

      // [add, more] -> [search, add]: 'add' moved slots but must stay matched.
      final slots = matchGlassNavActions([add, more], [search, addAgain]);

      final addSlot = slots.singleWhere((s) => s.toItem == addAgain);
      expect(addSlot.fromItem, same(add));

      // 'more' has no counterpart and exits; 'search' enters.
      expect(slots.singleWhere((s) => s.fromItem == more).isExit, isTrue);
      expect(slots.singleWhere((s) => s.toItem == search).isEnter, isTrue);
    });

    test('unidentified items match positionally from the trailing edge', () {
      final a = _icon(CupertinoIcons.add);
      final b = _icon(CupertinoIcons.ellipsis);
      final c = _icon(CupertinoIcons.search);
      final d = _icon(CupertinoIcons.bell);

      // [a, b] -> [c, d]: trailing-edge pairing gives b->d and a->c.
      final slots = matchGlassNavActions([a, b], [c, d]);

      expect(slots.singleWhere((s) => s.toItem == d).fromItem, same(b));
      expect(slots.singleWhere((s) => s.toItem == c).fromItem, same(a));
    });

    test('an item with a different explicit id never matches positionally', () {
      final flagged = _icon(CupertinoIcons.flag, id: 'flag');
      final search = _icon(CupertinoIcons.search, id: 'search');

      final slots = matchGlassNavActions([flagged], [search]);

      // Same trailing slot, but the ids disagree: exit + enter, not a morph.
      expect(slots.singleWhere((s) => s.fromItem == flagged).isExit, isTrue);
      expect(slots.singleWhere((s) => s.toItem == search).isEnter, isTrue);
    });

    test('each outgoing item is consumed at most once', () {
      final add = _icon(CupertinoIcons.add, id: 'add');
      final one = _icon(CupertinoIcons.circle, id: 'add');
      final two = _icon(CupertinoIcons.square, id: 'add');

      final slots = matchGlassNavActions([add], [one, two]);

      final matched = slots.where((s) => s.fromItem == add);
      expect(matched, hasLength(1));
    });

    test('empty sides produce pure enters or pure exits', () {
      final a = _icon(CupertinoIcons.add);

      expect(
        matchGlassNavActions([], [a]).single.isEnter,
        isTrue,
      );
      expect(
        matchGlassNavActions([a], []).single.isExit,
        isTrue,
      );
      expect(matchGlassNavActions([], []), isEmpty);
    });
  });

  group('spacers', () {
    test('a spacer ends a run of shared items', () {
      final a = _icon(CupertinoIcons.add);
      final b = _icon(CupertinoIcons.search);
      final c = _icon(CupertinoIcons.ellipsis);

      final groups = groupGlassNavBarItems([a, b, const GlassBarSpacer(), c]);

      expect(groups.map((g) => g.items), [
        [a, b],
        [c],
      ]);
    });

    test('a spacer with nothing to split draws nothing', () {
      final a = _icon(CupertinoIcons.add);
      final b = _icon(CupertinoIcons.search);

      final groups = groupGlassNavBarItems([
        const GlassBarSpacer(),
        a,
        const GlassBarSpacer(),
        const GlassBarSpacer(),
        b,
        const GlassBarSpacer(),
      ]);

      expect(groups.map((g) => g.items), [
        [a],
        [b],
      ]);
    });
  });

  group('group matching', () {
    List<GlassNavBarGroup> groups(List<GlassBarItem> items) =>
        groupGlassNavBarItems(items);

    test('a group follows its items before it pairs by position', () {
      final from = groups([
        _icon(CupertinoIcons.add, id: 'add'),
        _icon(CupertinoIcons.search, id: 'search'),
      ]);
      final to = groups([
        _icon(CupertinoIcons.add, id: 'add'),
        _icon(CupertinoIcons.search, id: 'search'),
        const GlassBarSpacer(),
        _icon(CupertinoIcons.ellipsis, id: 'more'),
      ]);

      final pairs = matchGlassNavGroups(from, to);

      // Positionally the capsule would pair with the menu at the trailing
      // edge; its items say it is the capsule a place further in.
      expect(
          pairs.singleWhere((p) => p.to == to.first).from, same(from.single));
      expect(pairs.singleWhere((p) => p.to == to.last).from, isNull);
    });

    test('unidentified groups pair positionally from the anchored edge', () {
      final from = groups([_icon(CupertinoIcons.add)]);
      final to = groups([
        _icon(CupertinoIcons.search),
        const GlassBarSpacer(),
        _icon(CupertinoIcons.bell),
      ]);

      final trailing = matchGlassNavGroups(from, to);
      expect(trailing.singleWhere((p) => p.to == to.last).from, same(from[0]));
      expect(trailing.singleWhere((p) => p.to == to.first).from, isNull);

      final leading = matchGlassNavGroups(from, to, anchoredAtStart: true);
      expect(leading.singleWhere((p) => p.to == to.first).from, same(from[0]));
      expect(leading.singleWhere((p) => p.to == to.last).from, isNull);
    });

    test('a group no partner claims exits', () {
      final from = groups([
        _icon(CupertinoIcons.add, id: 'add'),
        const GlassBarSpacer(),
        _icon(CupertinoIcons.ellipsis, id: 'more'),
      ]);
      final to = groups([_icon(CupertinoIcons.add, id: 'add')]);

      final pairs = matchGlassNavGroups(from, to);

      expect(pairs, hasLength(2));
      expect(pairs.first.from, same(from.first));
      expect(pairs.last.from, same(from.last));
      expect(pairs.last.to, isNull);
    });
  });

  group('item tap handlers', () {
    test('an icon item requires a handler, a custom item does not', () {
      var taps = 0;
      final icon = GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.add),
        onTap: () => taps++,
      ) as GlassBarActionItem;
      final passive =
          const GlassBarItem.custom(child: SizedBox()) as GlassBarActionItem;

      icon.onTap();
      expect(taps, 1);

      // Passive custom content still exposes a callable handler, so nothing
      // downstream has to null-check its way around a status readout.
      expect(passive.onTap, returnsNormally);
    });
  });

  group('barrel export', () {
    test('GlassNavPinnedMetrics is reachable from the package barrel', () {
      // A bar that is not a GlassAppBar aligns its in-route chrome to these
      // numbers. `show` works per declaration, so one reference guards the
      // whole class: drop the export and this file stops compiling.
      expect(
        barrel.GlassNavPinnedMetrics.backDiameter,
        GlassNavPinnedMetrics.backDiameter,
      );
    });
  });
}
