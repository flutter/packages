import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/engine/liquid_glass_layer.dart';
import 'package:liquid_glass_widgets/src/engine/rendering/liquid_glass_render_object.dart';
import 'package:liquid_glass_widgets/src/renderer/glass_backdrop_group_boundary.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_searchable_internal.dart'
    show SearchPill;

/// A premium glass layer as the engine builds it, joined to the enclosing
/// group like LiquidGlassLayer does. Offstage in the tests: what is checked
/// is the group bookkeeping, not the shader.
class _Member extends SingleChildRenderObjectWidget {
  const _Member({super.key});

  @override
  RenderLiquidGlassLayer createRenderObject(BuildContext context) {
    final key = GlassBackdropGroup.keyOf(context);
    return RenderLiquidGlassLayer(
      renderShader: null,
      devicePixelRatio: 3,
      settings: const LiquidGlassSettings(),
      shadows: const [],
      link: GeometryRenderLink(),
      backdropKey: key,
    )..sharedBackdrop = key != null;
  }
}

RenderLiquidGlassLayer _layer(WidgetTester tester, Key key) => tester
    .renderObject<RenderLiquidGlassLayer>(find.byKey(key, skipOffstage: false));

void main() {
  testWidgets('descendants share one key; none outside a group',
      (tester) async {
    BackdropKey? a, b, outside;
    await tester.pumpWidget(Column(
      children: [
        GlassBackdropGroup(
          child: Column(children: [
            Builder(builder: (context) {
              a = GlassBackdropGroup.keyOf(context);
              return const SizedBox();
            }),
            Builder(builder: (context) {
              b = GlassBackdropGroup.keyOf(context);
              return const SizedBox();
            }),
          ]),
        ),
        Builder(builder: (context) {
          outside = GlassBackdropGroup.keyOf(context);
          return const SizedBox();
        }),
      ],
    ));
    expect(a, isNotNull);
    expect(identical(a, b), isTrue);
    expect(outside, isNull);
  });

  testWidgets('the key survives rebuilds', (tester) async {
    BackdropKey? first, second;
    Widget app() => GlassBackdropGroup(
          child: Builder(builder: (context) {
            first ??= GlassBackdropGroup.keyOf(context);
            second = GlassBackdropGroup.keyOf(context);
            return const SizedBox();
          }),
        );
    await tester.pumpWidget(app());
    await tester.pumpWidget(app());
    expect(identical(first, second), isTrue);
  });

  testWidgets('a disabled group hands out no key and hides the outer one',
      (tester) async {
    BackdropKey? inner;
    await tester.pumpWidget(GlassBackdropGroup(
      child: GlassBackdropGroup(
        enabled: false,
        child: Builder(builder: (context) {
          inner = GlassBackdropGroup.keyOf(context);
          return const SizedBox();
        }),
      ),
    ));
    expect(inner, isNull);
  });

  group('members', () {
    const a = Key('a'), b = Key('b'), c = Key('c');

    Future<void> pump(WidgetTester tester, Widget Function(Widget) third,
            {bool withB = true}) =>
        tester.pumpWidget(Offstage(
          child: GlassBackdropGroup(
            child: Column(children: [
              const _Member(key: a),
              if (withB) const _Member(key: b),
              third(const _Member(key: c)),
            ]),
          ),
        ));

    testWidgets('share only with another member in the group', (tester) async {
      await pump(tester, (m) => m, withB: false);
      // Alone in the group: no other surface to share with, and the folded
      // frost weight would cost more than the separate pass.
      expect(_layer(tester, a).debugResolveSharing(), isFalse);
      expect(_layer(tester, c).debugResolveSharing(), isTrue);
      expect(_layer(tester, a).debugResolveSharing(), isTrue);
    });

    testWidgets(
        'stay out of the group under an opacity, at any value, fully '
        'opaque included', (tester) async {
      Future<void> fade(double opacity) => pump(
            tester,
            (m) => Opacity(opacity: opacity, child: m),
          );
      await fade(0.5);
      _layer(tester, a).debugResolveSharing();
      expect(_layer(tester, b).debugResolveSharing(), isTrue);
      expect(_layer(tester, a).debugResolveSharing(), isTrue);
      expect(_layer(tester, c).debugResolveSharing(), isFalse);
      final group = tester.renderObject<RenderGlassBackdropGroupBoundary>(
          find.byType(GlassBackdropGroupBoundary, skipOffstage: false));
      expect(group.memberCount, 2);

      // At 1 the opacity may start a fade without the member painting again
      // (see opensRenderPassBelow), so it stays out.
      await fade(1);
      expect(_layer(tester, c).debugResolveSharing(), isFalse);
      expect(group.memberCount, 2);
    });

    testWidgets(
        'a fade that starts after the first paint finds the member '
        'already out of the group', (tester) async {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 200),
        value: 1,
      );
      addTearDown(controller.dispose);
      // As in LiquidGlassLayer: the glass layer paints below a repaint
      // boundary, which a fade re-composites without painting it again.
      await pump(
        tester,
        (m) => FadeTransition(
          opacity: controller,
          child: RepaintBoundary(child: m),
        ),
      );
      for (final key in [a, b, c]) {
        _layer(tester, key).debugResolveSharing();
      }
      expect(_layer(tester, c).debugSharesBackdrop, isFalse);

      controller.value = 0.5;
      await tester.pump();
      // No repaint of c happened, and none was needed: it never held the
      // group's key.
      expect(_layer(tester, c).debugSharesBackdrop, isFalse);
      // The two members outside the fade still share.
      expect(_layer(tester, a).debugResolveSharing(), isTrue);
    });

    testWidgets('leave on detach', (tester) async {
      await pump(tester, (m) => m);
      for (final key in [a, b, c]) {
        _layer(tester, key).debugResolveSharing();
      }
      final group = tester.renderObject<RenderGlassBackdropGroupBoundary>(
          find.byType(GlassBackdropGroupBoundary, skipOffstage: false));
      expect(group.memberCount, 3);
      await pump(tester, (m) => const SizedBox());
      expect(group.memberCount, 2);
    });
  });

  group('render passes of their own', () {
    Future<RenderObject> inner(
        WidgetTester tester, Widget Function(Widget) wrap) async {
      const key = Key('inner');
      await tester.pumpWidget(GlassBackdropGroup(
        child: wrap(const SizedBox(key: key)),
      ));
      return tester.renderObject(find.byKey(key, skipOffstage: false));
    }

    testWidgets('are found between a member and its group', (tester) async {
      final opening = <String, Widget Function(Widget)>{
        'opacity': (c) => Opacity(opacity: 0.4, child: c),
        'opaque opacity': (c) => Opacity(opacity: 1, child: c),
        'fade': (c) => FadeTransition(
              opacity: const AlwaysStoppedAnimation(0.5),
              child: c,
            ),
        'fade at rest': (c) => FadeTransition(
              opacity: const AlwaysStoppedAnimation(1),
              child: c,
            ),
        'shader mask': (c) => ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                colors: [Color(0xFF000000), Color(0x00000000)],
              ).createShader(r),
              child: c,
            ),
        'save-layer clip': (c) => ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: BorderRadius.circular(8),
              child: c,
            ),
      };
      for (final MapEntry(:key, :value) in opening.entries) {
        final node = await inner(tester, value);
        expect(enclosingBackdropGroup(node), isNull, reason: key);
      }
      final staying = <String, Widget Function(Widget)>{
        'nothing': (c) => c,
        'clip': (c) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: c,
            ),
        'transform': (c) => Transform.scale(scale: 1.05, child: c),
        'repaint boundary': (c) => RepaintBoundary(child: c),
      };
      for (final MapEntry(:key, :value) in staying.entries) {
        final node = await inner(tester, value);
        expect(enclosingBackdropGroup(node), isNotNull, reason: key);
      }
    });
  });

  testWidgets(
      'GlassTabBar and GlassAppBar group their glass unless told not '
      'to', (tester) async {
    Future<GlassBackdropGroup> barGroup(Widget bar) async {
      await tester.pumpWidget(CupertinoApp(
        home: CupertinoPageScaffold(child: Align(child: bar)),
      ));
      return tester.widget<GlassBackdropGroup>(
        find.byType(GlassBackdropGroup).first,
      );
    }

    const tabs = [
      GlassTab(icon: Icon(CupertinoIcons.home), label: 'Home'),
      GlassTab(icon: Icon(CupertinoIcons.search), label: 'Search'),
    ];
    final tabBarGroup = await barGroup(GlassTabBar.bottom(
      tabs: tabs,
      selectedIndex: 0,
      onTabSelected: (_) {},
    ));
    expect(tabBarGroup.enabled, isTrue);
    expect(tabBarGroup.joinEnclosing, isTrue);
    expect(
      (await barGroup(GlassTabBar.bottom(
        tabs: tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        groupBackdrop: false,
      )))
          .enabled,
      isFalse,
    );
    final appBarGroup = await barGroup(const GlassAppBar(title: Text('Title')));
    expect(appBarGroup.enabled, isTrue);
    expect(appBarGroup.joinEnclosing, isTrue);
    expect(
      (await barGroup(const GlassAppBar(
        title: Text('Title'),
        groupBackdrop: false,
      )))
          .enabled,
      isFalse,
    );
  });

  group('joining an enclosing group', () {
    const a = Key('a'), b = Key('b');

    RenderGlassBackdropGroupBoundary boundary(WidgetTester tester, int i) =>
        tester.renderObject<RenderGlassBackdropGroupBoundary>(
          find.byType(GlassBackdropGroupBoundary, skipOffstage: false).at(i),
        );

    // Two bars' groups side by side, optionally inside one of the app's own.
    Future<void> pump(WidgetTester tester,
            {bool outer = true, bool second = true}) =>
        tester.pumpWidget(Offstage(
          child: GlassBackdropGroup(
            enabled: outer,
            child: Column(children: [
              const GlassBackdropGroup(
                joinEnclosing: true,
                child: _Member(key: a),
              ),
              GlassBackdropGroup(
                enabled: second,
                joinEnclosing: true,
                child: const _Member(key: b),
              ),
            ]),
          ),
        ));

    testWidgets('makes two bars one group', (tester) async {
      await pump(tester);
      expect(_layer(tester, a).backdropKey, isNotNull);
      expect(
        identical(_layer(tester, a).backdropKey, _layer(tester, b).backdropKey),
        isTrue,
      );
      _layer(tester, a).debugResolveSharing();
      expect(_layer(tester, b).debugResolveSharing(), isTrue);
      expect(_layer(tester, a).debugResolveSharing(), isTrue);
      expect(boundary(tester, 0).memberCount, 2);
      expect(boundary(tester, 1).memberCount, 0);
      expect(boundary(tester, 2).memberCount, 0);
    });

    testWidgets('starts a group of its own without one', (tester) async {
      await pump(tester, outer: false);
      expect(_layer(tester, a).backdropKey, isNotNull);
      expect(
        identical(_layer(tester, a).backdropKey, _layer(tester, b).backdropKey),
        isFalse,
      );
      // Each bar alone in its group: nothing to share with.
      expect(_layer(tester, a).debugResolveSharing(), isFalse);
      expect(boundary(tester, 1).memberCount, 1);
    });

    testWidgets('a disabled bar stays out of the enclosing group',
        (tester) async {
      await pump(tester, second: false);
      expect(_layer(tester, b).backdropKey, isNull);
      expect(_layer(tester, a).debugResolveSharing(), isFalse);
      expect(boundary(tester, 0).memberCount, 1);
    });

    testWidgets('members move when the enclosing group goes away',
        (tester) async {
      await pump(tester);
      _layer(tester, a).debugResolveSharing();
      _layer(tester, b).debugResolveSharing();
      expect(boundary(tester, 0).memberCount, 2);

      await pump(tester, outer: false);
      _layer(tester, a).debugResolveSharing();
      _layer(tester, b).debugResolveSharing();
      expect(boundary(tester, 0).memberCount, 0);
      expect(boundary(tester, 1).memberCount, 1);
      expect(boundary(tester, 2).memberCount, 1);
    });
  });

  group('GlassTabBar.searchable keeps glass that lies over the bar out', () {
    // No page scaffold: it would take the keyboard's inset away from the bar.
    Widget bar({Widget? accessory}) => CupertinoApp(
          home: ColoredBox(
            color: const Color(0xFFFFFFFF),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GlassTabBar.searchable(
                tabs: const [
                  GlassTab(icon: Icon(CupertinoIcons.home), label: 'Home'),
                  GlassTab(icon: Icon(CupertinoIcons.person), label: 'Me'),
                ],
                selectedIndex: 0,
                onTabSelected: (_) {},
                searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
                bottomAccessory: accessory,
                bottomAccessoryHeight: accessory == null ? null : 48,
              ),
            ),
          ),
        );

    GlassBackdropGroup nearestGroup(WidgetTester tester, Finder of) =>
        tester.widget<GlassBackdropGroup>(
          find
              .ancestor(of: of, matching: find.byType(GlassBackdropGroup))
              .first,
        );

    testWidgets('the search pill only while the keyboard is down',
        (tester) async {
      await tester.pumpWidget(bar());
      await tester.pump();
      final search = find.byType(SearchPill);
      expect(nearestGroup(tester, search).enabled, isTrue);

      tester.view.viewInsets = const FakeViewPadding(bottom: 900);
      addTearDown(tester.view.resetViewInsets);
      await tester.pump();
      expect(nearestGroup(tester, search).enabled, isFalse);
    });

    testWidgets('the bottom accessory', (tester) async {
      const accessory = Key('accessory');
      await tester.pumpWidget(bar(accessory: const SizedBox(key: accessory)));
      await tester.pump();
      expect(nearestGroup(tester, find.byKey(accessory)).enabled, isFalse);
    });
  });
}
