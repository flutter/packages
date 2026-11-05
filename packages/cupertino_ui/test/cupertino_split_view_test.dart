import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('iPhone uses compact full-width sidebar in portrait', (WidgetTester tester) async {
    await _testSidebarWidth(tester, size: const Size(390.0, 844.0), expectedWidth: 390.0);
  });

  testWidgets('iPhone uses a fixed-width overlay sidebar in landscape', (
    WidgetTester tester,
  ) async {
    await _testSidebarWidth(tester, size: const Size(844.0, 390.0), expectedWidth: 320.0);
  });

  testWidgets('iPhone landscape automatic starts detail-only and overlays', (
    WidgetTester tester,
  ) async {
    await _setSurfaceSize(tester, const Size(844.0, 390.0));
    await tester.pumpWidget(_testApp(key: const ValueKey<String>('landscape')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('sidebar')), findsNothing);
    expect(find.text('Detail Body none'), findsOneWidget);
    expect(_floatingToggleFinder, findsOneWidget);

    await tester.tap(_floatingToggleFinder);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('sidebar')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('sidebar'))).width,
      closeTo(320.0, 0.01),
    );
    expect(tester.getSize(find.byKey(_detailColumnKey)).width, closeTo(844.0, 0.01));
    expect(find.byKey(_overlayScrimKey), findsOneWidget);
    expect(_floatingToggleFinder, findsNothing);

    await tester.tap(find.text('Select Inbox'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Body inbox'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('sidebar')), findsOneWidget);
    expect(find.byType(CupertinoNavigationBarBackButton), findsNothing);

    await tester.tap(find.byKey(_overlayScrimKey));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('sidebar')), findsNothing);
    expect(find.text('Detail Body inbox'), findsOneWidget);
    expect(_floatingToggleFinder, findsOneWidget);
  });

  testWidgets('iPhone landscape overlay includes the leading safe area', (
    WidgetTester tester,
  ) async {
    await _setSurfaceSize(tester, const Size(844.0, 390.0));
    await tester.pumpWidget(
      _testApp(
        key: const ValueKey<String>('landscape-safe-area'),
        initialColumnVisibility: CupertinoSplitViewVisibility.doubleColumn,
        padding: const EdgeInsets.only(left: 59.0),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const ValueKey<String>('sidebar'))).width,
      closeTo(379.0, 0.01),
    );
  });

  testWidgets('iPhone moves between compact and overlay with orientation', (
    WidgetTester tester,
  ) async {
    await _setSurfaceSize(tester, const Size(430.0, 932.0));
    await tester.pumpWidget(_testApp(key: const ValueKey<String>('rotate')));
    await tester.pumpAndSettle();

    expect(find.text('Sidebar'), findsOneWidget);
    expect(find.byKey(_detailColumnKey), findsNothing);

    tester.view.physicalSize = const Size(932.0, 430.0);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('sidebar')), findsNothing);
    expect(find.text('Detail Body none'), findsOneWidget);

    tester.view.physicalSize = const Size(430.0, 932.0);
    await tester.pumpAndSettle();

    expect(find.text('Sidebar'), findsOneWidget);
    expect(find.byKey(_detailColumnKey), findsNothing);
  });

  testWidgets('iPad uses a fixed 320pt sidebar in portrait', (WidgetTester tester) async {
    await _testSidebarWidth(tester, size: const Size(834.0, 1194.0), expectedWidth: 320.0);
  });

  testWidgets('iPad uses a fixed 320pt sidebar in landscape', (WidgetTester tester) async {
    await _testSidebarWidth(tester, size: const Size(1194.0, 834.0), expectedWidth: 320.0);
  });

  testWidgets('sidebar uses Cupertino direction-specific transition curves', (
    WidgetTester tester,
  ) async {
    await _setSurfaceSize(tester, const Size(834.0, 1194.0));
    final controller = CupertinoSplitViewController<String>();
    await tester.pumpWidget(
      _testApp(controller: controller, animationDuration: const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();

    TweenAnimationBuilder<double> animation = tester.widget<TweenAnimationBuilder<double>>(
      find.byType(TweenAnimationBuilder<double>),
    );
    expect(animation.curve, Curves.easeInToLinear);

    await tester.tap(find.byIcon(CupertinoIcons.sidebar_left));
    await tester.pump();
    animation = tester.widget<TweenAnimationBuilder<double>>(
      find.byType(TweenAnimationBuilder<double>),
    );
    expect(animation.curve, Curves.linearToEaseOut);

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(CupertinoIcons.sidebar_left));
    await tester.pump();
    animation = tester.widget<TweenAnimationBuilder<double>>(
      find.byType(TweenAnimationBuilder<double>),
    );
    expect(animation.curve, Curves.easeInToLinear);
  });

  testWidgets('divider uses the requested hairline width and separator color', (
    WidgetTester tester,
  ) async {
    await _setSurfaceSize(tester, const Size(834.0, 1194.0));
    await tester.pumpWidget(
      CupertinoApp(
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(devicePixelRatio: 2.0),
            child: child!,
          );
        },
        home: CupertinoSplitView<String>(
          key: const ValueKey<String>('divider'),
          initialColumnVisibility: CupertinoSplitViewVisibility.doubleColumn,
          sidebar: const _TestSidebar(),
          detailBuilder: (BuildContext context, String? selection) {
            return Text('Body ${selection ?? 'none'}');
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder dividerFinder = find.byKey(const ValueKey<String>('cupertino-split-view-divider'));
    final Finder decoratedFinder = find.descendant(
      of: dividerFinder,
      matching: find.byType(DecoratedBox),
    );
    final DecoratedBox decoratedBox = tester.widget<DecoratedBox>(decoratedFinder);
    final decoration = decoratedBox.decoration as BoxDecoration;
    final border = decoration.border! as Border;
    expect(MediaQuery.devicePixelRatioOf(tester.element(decoratedFinder)), 2.0);
    expect(border.right.width, 0.5);
    expect(
      border.right.color,
      CupertinoColors.separator.resolveFrom(tester.element(decoratedFinder)),
    );
  });

  testWidgets('floating toggle respects LTR safe area', (WidgetTester tester) async {
    await _setSurfaceSize(tester, const Size(834.0, 1194.0));
    await tester.pumpWidget(
      _safeAreaTestApp(
        textDirection: TextDirection.ltr,
        padding: const EdgeInsets.fromLTRB(24.0, 20.0, 30.0, 0.0),
      ),
    );
    await tester.pumpAndSettle();

    final Rect toggleRect = tester.getRect(_floatingToggleFinder);
    expect(toggleRect.left, closeTo(40.0, 0.01));
    expect(toggleRect.top, closeTo(24.0, 0.01));
    expect(find.byIcon(CupertinoIcons.sidebar_left), findsOneWidget);
  });

  testWidgets('floating toggle respects RTL safe area', (WidgetTester tester) async {
    await _setSurfaceSize(tester, const Size(834.0, 1194.0));
    await tester.pumpWidget(
      _safeAreaTestApp(
        textDirection: TextDirection.rtl,
        padding: const EdgeInsets.fromLTRB(24.0, 20.0, 30.0, 0.0),
      ),
    );
    await tester.pumpAndSettle();

    final Rect toggleRect = tester.getRect(_floatingToggleFinder);
    expect(toggleRect.right, closeTo(788.0, 0.01));
    expect(toggleRect.top, closeTo(24.0, 0.01));
    expect(find.byIcon(CupertinoIcons.sidebar_right), findsOneWidget);
  });

  testWidgets('compact selection pushes and pops a Cupertino route', (WidgetTester tester) async {
    await _setSurfaceSize(tester, const Size(390.0, 844.0));
    final controller = CupertinoSplitViewController<String>();
    await tester.pumpWidget(
      _testApp(controller: controller, key: const ValueKey<String>('compact')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sidebar'), findsOneWidget);
    expect(find.text('Detail Body none'), findsNothing);

    await tester.tap(find.text('Select Inbox'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Body inbox'), findsOneWidget);
    expect(find.byType(CupertinoNavigationBarBackButton), findsOneWidget);

    controller.selection = 'sent';
    await tester.pumpAndSettle();

    expect(find.text('Detail Body sent'), findsOneWidget);
    expect(find.text('Detail Body inbox'), findsNothing);
    expect(find.byType(CupertinoNavigationBarBackButton), findsOneWidget);

    await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    await tester.pumpAndSettle();

    expect(find.text('Sidebar'), findsOneWidget);
    expect(find.text('Detail Body inbox'), findsNothing);
  });

  testWidgets('selection scope rebuilds dependents when selection changes', (
    WidgetTester tester,
  ) async {
    await _setSurfaceSize(tester, const Size(834.0, 1194.0));
    final controller = CupertinoSplitViewController<String>(
      initialColumnVisibility: CupertinoSplitViewVisibility.doubleColumn,
    );
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoSplitView<String>(
          controller: controller,
          sidebar: const _SelectionScopeProbe(),
          detailBuilder: (BuildContext context, String? selection) {
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('selection none'), findsOneWidget);

    controller.selection = 'inbox';
    await tester.pumpAndSettle();

    expect(find.text('selection inbox'), findsOneWidget);
  });

  testWidgets('iPad automatic visibility collapses and reveals the sidebar', (
    WidgetTester tester,
  ) async {
    await _setSurfaceSize(tester, const Size(834.0, 1194.0));
    final controller = CupertinoSplitViewController<String>();
    await tester.pumpWidget(_testApp(controller: controller, key: const ValueKey<String>('ipad')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('sidebar')), findsNothing);
    expect(find.text('Detail Body none'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.sidebar_left), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.sidebar_left));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('sidebar')), findsOneWidget);
    expect(find.text('Sidebar'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.sidebar_left), findsOneWidget);

    await tester.tap(find.text('Select Inbox'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Body inbox'), findsOneWidget);
    expect(find.text('Sidebar'), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.sidebar_left));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('sidebar')), findsNothing);
    expect(find.text('Detail Body inbox'), findsOneWidget);
  });

  testWidgets('regular columns isolate Cupertino navigation bar heroes', (
    WidgetTester tester,
  ) async {
    await _setSurfaceSize(tester, const Size(834.0, 1194.0));
    await tester.pumpWidget(_heroIsolationTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open About'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('About Page'), findsOneWidget);
  });

  testWidgets('detail navigation defaults to the enclosing navigator', (WidgetTester tester) async {
    await _setSurfaceSize(tester, const Size(834.0, 1194.0));
    await tester.pumpWidget(_detailNavigationTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Detail Route'));
    await tester.pumpAndSettle();

    expect(find.text('About Page'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('sidebar')), findsNothing);
    expect(tester.getSize(find.byKey(_aboutPageKey)).width, closeTo(834.0, 0.01));
  });

  testWidgets('useNestedNavigation keeps detail pushes inside its column', (
    WidgetTester tester,
  ) async {
    await _setSurfaceSize(tester, const Size(834.0, 1194.0));
    await tester.pumpWidget(_detailNavigationTestApp(useNestedNavigation: true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Detail Route'));
    await tester.pumpAndSettle();

    expect(find.text('About Page'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('sidebar')), findsOneWidget);
    final Rect aboutRect = tester.getRect(find.byKey(_aboutPageKey));
    expect(aboutRect.left, closeTo(321.0, 0.01));
    expect(aboutRect.width, closeTo(513.0, 0.01));
    expect(find.byType(CupertinoNavigationBarBackButton), findsOneWidget);

    await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    await tester.pumpAndSettle();

    expect(find.text('Open Detail Route'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('sidebar')), findsOneWidget);
  });

  testWidgets('nested navigation handles system back before the outer route', (
    WidgetTester tester,
  ) async {
    await _setSurfaceSize(tester, const Size(834.0, 1194.0));
    await tester.pumpWidget(_detailNavigationTestApp(useNestedNavigation: true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Detail Route'));
    await tester.pumpAndSettle();
    expect(find.text('About Page'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('About Page'), findsNothing);
    expect(find.text('Open Detail Route'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('sidebar')), findsOneWidget);
  });

  testWidgets('changing selection clears the nested detail stack', (WidgetTester tester) async {
    await _setSurfaceSize(tester, const Size(834.0, 1194.0));
    await tester.pumpWidget(_detailNavigationTestApp(useNestedNavigation: true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select Inbox'));
    await tester.pumpAndSettle();
    expect(find.text('Detail inbox'), findsOneWidget);

    await tester.tap(find.text('Open Detail Route'));
    await tester.pumpAndSettle();
    expect(find.text('About Page'), findsOneWidget);

    await tester.tap(find.text('Select Sent'));
    await tester.pumpAndSettle();

    expect(find.text('About Page'), findsNothing);
    expect(find.text('Detail sent'), findsOneWidget);
    expect(find.text('Open Detail Route'), findsOneWidget);
    expect(find.byType(CupertinoNavigationBarBackButton), findsNothing);
  });

  testWidgets('collapsed sidebar reserves room for the floating toggle in nested navigation bars', (
    WidgetTester tester,
  ) async {
    await _setSurfaceSize(tester, const Size(834.0, 1194.0));
    await tester.pumpWidget(_nestedNavigationBarInsetTestApp());
    await tester.pumpAndSettle();

    final Finder rootLeading = find.byKey(_detailNavigationLeadingKey);
    expect(tester.getRect(rootLeading).left, closeTo(337.0, 0.01));

    await tester.tap(_floatingToggleFinder);
    await tester.pumpAndSettle();

    final Rect collapsedToggleRect = tester.getRect(_floatingToggleFinder);
    final Rect collapsedRootLeadingRect = tester.getRect(rootLeading);
    expect(collapsedRootLeadingRect.left, greaterThanOrEqualTo(collapsedToggleRect.right));

    await tester.tap(rootLeading);
    await tester.pumpAndSettle();

    final Finder backButton = find.byType(CupertinoNavigationBarBackButton);
    expect(backButton, findsOneWidget);
    final Rect backButtonRect = tester.getRect(backButton);
    final Rect pushedToggleRect = tester.getRect(_floatingToggleFinder);
    expect(backButtonRect.left, greaterThanOrEqualTo(pushedToggleRect.right));
  });

  testWidgets('nested root back bubbles to the enclosing navigator', (WidgetTester tester) async {
    await _setSurfaceSize(tester, const Size(834.0, 1194.0));
    await tester.pumpWidget(_pushedSplitViewTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Split View'));
    await tester.pumpAndSettle();
    expect(find.text('Open Detail Route'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Open Split View'), findsOneWidget);
    expect(find.text('Open Detail Route'), findsNothing);
    expect(find.byKey(const ValueKey<String>('sidebar')), findsNothing);
  });

  testWidgets('controller controls selection and column visibility', (WidgetTester tester) async {
    await _setSurfaceSize(tester, const Size(834.0, 1194.0));
    final controller = CupertinoSplitViewController<String>(
      initialColumnVisibility: CupertinoSplitViewVisibility.detailOnly,
    );
    await tester.pumpWidget(
      _testApp(controller: controller, key: const ValueKey<String>('controlled')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Detail Body none'), findsOneWidget);

    controller.selection = 'inbox';
    await tester.pumpAndSettle();

    expect(find.text('Detail Body inbox'), findsOneWidget);

    controller.showSidebar();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('sidebar')), findsOneWidget);

    controller.hideSidebar();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('sidebar')), findsNothing);
  });

  testWidgets('floating toggle semantics describe the next action', (WidgetTester tester) async {
    await _setSurfaceSize(tester, const Size(834.0, 1194.0));
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _testApp(
        initialColumnVisibility: CupertinoSplitViewVisibility.detailOnly,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          _SplitViewLocalizations.delegate,
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('显示侧边栏'), findsOneWidget);
    expect(find.bySemanticsLabel('隐藏侧边栏'), findsNothing);

    await tester.tap(_floatingToggleFinder);
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('显示侧边栏'), findsNothing);
    expect(find.bySemanticsLabel('隐藏侧边栏'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('overlay sidebar blocks detail semantics and dismisses on back', (
    WidgetTester tester,
  ) async {
    await _setSurfaceSize(tester, const Size(844.0, 390.0));
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.pumpWidget(_testApp(key: const ValueKey<String>('a11y')));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Detail Body none'), findsOneWidget);

    await tester.tap(_floatingToggleFinder);
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Dismiss sidebar'), findsOneWidget);
    expect(find.bySemanticsLabel('Detail Body none'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('sidebar')), findsNothing);
    expect(find.bySemanticsLabel('Detail Body none'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('Escape dismisses an overlay sidebar', (WidgetTester tester) async {
    await _setSurfaceSize(tester, const Size(844.0, 390.0));
    await tester.pumpWidget(_testApp(key: const ValueKey<String>('escape-overlay')));
    await tester.pumpAndSettle();

    await tester.tap(_floatingToggleFinder);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('sidebar')), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('sidebar')), findsNothing);
  });

  testWidgets('reduced motion disables sidebar animations', (WidgetTester tester) async {
    await _setSurfaceSize(tester, const Size(834.0, 1194.0));
    await tester.pumpWidget(
      CupertinoApp(
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          );
        },
        home: CupertinoSplitView<String>(
          initialColumnVisibility: CupertinoSplitViewVisibility.detailOnly,
          animationDuration: const Duration(seconds: 2),
          sidebar: const _TestSidebar(),
          detailBuilder: (BuildContext context, String? selection) {
            return Text('Body ${selection ?? 'none'}');
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final TweenAnimationBuilder<double> animation = tester.widget<TweenAnimationBuilder<double>>(
      find.byType(TweenAnimationBuilder<double>),
    );
    expect(animation.duration, Duration.zero);
  });
}

const ValueKey<String> _aboutPageKey = ValueKey<String>('detail-navigation-about-page');

Widget _detailNavigationTestApp({bool useNestedNavigation = false}) {
  return CupertinoApp(
    routes: <String, WidgetBuilder>{
      '/about': (BuildContext context) {
        return const CupertinoPageScaffold(
          key: _aboutPageKey,
          navigationBar: CupertinoNavigationBar(middle: Text('About Page')),
          child: Center(child: Text('About Body')),
        );
      },
    },
    home: CupertinoSplitView<String>(
      initialColumnVisibility: CupertinoSplitViewVisibility.doubleColumn,
      animationDuration: Duration.zero,
      useNestedNavigation: useNestedNavigation,
      sidebar: const _TestSidebar(),
      detailBuilder: (BuildContext context, String? selection) {
        return CupertinoPageScaffold(
          key: _detailColumnKey,
          navigationBar: CupertinoNavigationBar(middle: Text('Detail ${selection ?? 'none'}')),
          child: Center(
            child: CupertinoButton(
              onPressed: () => Navigator.of(context).pushNamed('/about'),
              child: const Text('Open Detail Route'),
            ),
          ),
        );
      },
    ),
  );
}

Widget _pushedSplitViewTestApp() {
  return CupertinoApp(
    routes: <String, WidgetBuilder>{
      '/about': (BuildContext context) {
        return const CupertinoPageScaffold(
          key: _aboutPageKey,
          navigationBar: CupertinoNavigationBar(middle: Text('About Page')),
          child: Center(child: Text('About Body')),
        );
      },
    },
    home: Builder(
      builder: (BuildContext homeContext) {
        return CupertinoPageScaffold(
          child: Center(
            child: CupertinoButton(
              onPressed: () {
                Navigator.of(homeContext).push<void>(
                  CupertinoPageRoute<void>(
                    builder: (BuildContext context) {
                      return CupertinoSplitView<String>(
                        initialColumnVisibility: CupertinoSplitViewVisibility.doubleColumn,
                        animationDuration: Duration.zero,
                        useNestedNavigation: true,
                        sidebar: const _TestSidebar(),
                        detailBuilder: (BuildContext context, String? selection) {
                          return CupertinoPageScaffold(
                            key: _detailColumnKey,
                            navigationBar: CupertinoNavigationBar(
                              middle: Text('Detail ${selection ?? 'none'}'),
                            ),
                            child: Center(
                              child: CupertinoButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/about');
                                },
                                child: const Text('Open Detail Route'),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
              child: const Text('Open Split View'),
            ),
          ),
        );
      },
    ),
  );
}

Widget _heroIsolationTestApp() {
  return CupertinoApp(
    routes: <String, WidgetBuilder>{
      '/about': (BuildContext context) {
        return const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('About Page')),
          child: Center(child: Text('About Body')),
        );
      },
    },
    home: CupertinoSplitView<String>(
      initialColumnVisibility: CupertinoSplitViewVisibility.doubleColumn,
      animationDuration: Duration.zero,
      sidebar: CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: <Widget>[
            const CupertinoSliverNavigationBar(largeTitle: Text('Hero Sidebar')),
            SliverToBoxAdapter(
              child: CupertinoButton(onPressed: () {}, child: const Text('Sidebar Body')),
            ),
          ],
        ),
      ),
      detailBuilder: (BuildContext context, String? selection) {
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(middle: Text('Hero Detail')),
          child: Center(
            child: CupertinoButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/about');
              },
              child: const Text('Open About'),
            ),
          ),
        );
      },
    ),
  );
}

final Finder _floatingToggleFinder = find.byKey(
  const ValueKey<String>('cupertino-split-view-toggle'),
);
const ValueKey<String> _detailColumnKey = ValueKey<String>('cupertino-split-view-detail-column');
const ValueKey<String> _overlayScrimKey = ValueKey<String>('cupertino-split-view-sidebar-scrim');
const ValueKey<String> _detailNavigationLeadingKey = ValueKey<String>('detail-navigation-leading');

Widget _safeAreaTestApp({required TextDirection textDirection, required EdgeInsets padding}) {
  return CupertinoApp(
    builder: (BuildContext context, Widget? child) {
      return Directionality(
        textDirection: textDirection,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(padding: padding),
          child: child!,
        ),
      );
    },
    home: CupertinoSplitView<String>(
      initialColumnVisibility: CupertinoSplitViewVisibility.detailOnly,
      animationDuration: Duration.zero,
      sidebar: const _TestSidebar(),
      detailBuilder: (BuildContext context, String? selection) {
        return Text('Body ${selection ?? 'none'}');
      },
    ),
  );
}

Widget _nestedNavigationBarInsetTestApp() {
  return CupertinoApp(
    routes: <String, WidgetBuilder>{
      '/about': (BuildContext context) {
        return const CupertinoPageScaffold(
          key: _aboutPageKey,
          child: CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(largeTitle: Text('About Page')),
              SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('About Body'))),
            ],
          ),
        );
      },
    },
    home: CupertinoSplitView<String>(
      initialColumnVisibility: CupertinoSplitViewVisibility.doubleColumn,
      animationDuration: Duration.zero,
      useNestedNavigation: true,
      sidebar: const _TestSidebar(),
      detailBuilder: (BuildContext context, String? selection) {
        return CupertinoPageScaffold(
          key: _detailColumnKey,
          child: CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                largeTitle: const Text('Detail'),
                leading: CupertinoButton(
                  key: _detailNavigationLeadingKey,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/about');
                  },
                  child: const Icon(CupertinoIcons.info_circle),
                ),
              ),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Detail Body')),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Future<void> _testSidebarWidth(
  WidgetTester tester, {
  required Size size,
  required double expectedWidth,
}) async {
  await _setSurfaceSize(tester, size);
  await tester.pumpWidget(
    _testApp(
      key: ValueKey<Size>(size),
      initialColumnVisibility: CupertinoSplitViewVisibility.doubleColumn,
    ),
  );
  await tester.pumpAndSettle();

  final Size sidebarSize = tester.getSize(find.byKey(const ValueKey<String>('sidebar')));
  expect(sidebarSize.width, closeTo(expectedWidth, 0.01));
}

Future<void> _setSurfaceSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Widget _testApp({
  Key? key,
  CupertinoSplitViewController<String>? controller,
  CupertinoSplitViewVisibility initialColumnVisibility = CupertinoSplitViewVisibility.automatic,
  List<LocalizationsDelegate<dynamic>>? localizationsDelegates,
  Duration animationDuration = Duration.zero,
  EdgeInsets? padding,
}) {
  return CupertinoApp(
    localizationsDelegates: localizationsDelegates,
    builder: padding == null
        ? null
        : (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(padding: padding),
              child: child!,
            );
          },
    home: CupertinoSplitView<String>(
      key: key,
      controller: controller,
      initialColumnVisibility: initialColumnVisibility,
      animationDuration: animationDuration,
      sidebar: const _TestSidebar(),
      detailBuilder: (BuildContext context, String? selection) {
        return CupertinoPageScaffold(
          key: _detailColumnKey,
          navigationBar: CupertinoNavigationBar(middle: Text('Detail ${selection ?? 'none'}')),
          child: Center(child: Text('Detail Body ${selection ?? 'none'}')),
        );
      },
    ),
  );
}

class _SplitViewLocalizations extends DefaultCupertinoLocalizations {
  const _SplitViewLocalizations();

  static const LocalizationsDelegate<CupertinoLocalizations> delegate =
      _SplitViewLocalizationsDelegate();

  @override
  String get splitViewShowSidebarButtonLabel => '显示侧边栏';

  @override
  String get splitViewHideSidebarButtonLabel => '隐藏侧边栏';
}

class _SplitViewLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _SplitViewLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(const _SplitViewLocalizations());
  }

  @override
  bool shouldReload(_SplitViewLocalizationsDelegate old) => false;
}

class _SelectionScopeProbe extends StatelessWidget {
  const _SelectionScopeProbe();

  @override
  Widget build(BuildContext context) {
    final CupertinoSplitViewState<String>? splitView = CupertinoSplitView.maybeOf<String>(context);
    return Text('selection ${splitView?.selection ?? 'none'}');
  }
}

class _TestSidebar extends StatelessWidget {
  const _TestSidebar();

  @override
  Widget build(BuildContext context) {
    final CupertinoSplitViewState<String>? splitView = CupertinoSplitView.maybeOf<String>(context);
    return SizedBox(
      key: const ValueKey<String>('sidebar'),
      child: CupertinoPageScaffold(
        child: Column(
          children: <Widget>[
            const Text('Sidebar'),
            CupertinoButton(
              onPressed: () => splitView?.select('inbox'),
              child: const Text('Select Inbox'),
            ),
            CupertinoButton(
              onPressed: () => splitView?.select('sent'),
              child: const Text('Select Sent'),
            ),
          ],
        ),
      ),
    );
  }
}
