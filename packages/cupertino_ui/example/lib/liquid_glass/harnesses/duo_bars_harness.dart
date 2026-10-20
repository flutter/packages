// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Parity harness — the package's bars beside iPhone Duo's native vertical bars.
//
// Each scenario rebuilds one of the native reference screens (a SwiftUI
// NavigationStack / TabView built against the iOS 27.1 SDK) with the package's
// own bars, so a screenshot of the two side by side shows where they differ.
// The screens are deliberately the same: the same titles, the same items in
// the same groups, the same forty coloured rows.
//
// NOT a showcase demo, which is why it does not live in lib/demos. It needs
// Xcode 27.1 and the iOS 27.1 simulator runtime: the iPhone Duo device type
// only runs on 27.1, and an app built against an older SDK gets horizontal
// bars. With the 27.1 Xcode selected:
//
//   xcodebuild -downloadPlatform iOS
//   xcrun simctl create "iPhone Duo" com.apple.CoreSimulator.SimDeviceType.iPhone-Duo \
//     com.apple.CoreSimulator.SimRuntime.iOS-27-1
//
// Fold and unfold with the Closed / Book / Open buttons under the device in
// DeviceHub.
//
// The scenario is read from a file in the app's tmp directory, so one build
// covers them all:
//
//   cd example && flutter build ios --simulator --debug \
//     -t lib/harnesses/duo_bars_harness.dart
//   echo SCENARIO=tabsnav > "$(xcrun simctl get_app_container <udid> \
//     <bundle id> data)/tmp/duo_harness.env"
//   xcrun simctl launch --terminate-running-process <udid> <bundle id>
//
// Scenarios: nav, navbottom, tabs, tabsnav, root, search, axis, alert (a
// dialog over the detail screen, 1.5s in), popover (a popover from the
// strip's compose button, 1.5s in), menu (the ••• of [_routeMenuItem],
// tapped open 1.5s in and closed 2s later), sheet (a sheet over a root
// screen, 1s in) push (the detail screen pushed 1s in and popped 2.5s later,
// to record the morph) and nested (the detail screen in a nested navigator,
// kept out of
// the shell, with a bar that draws its own capsules; the native `nav` is its
// reference). A `DIRECTION=rtl` line
// lays the app out right to left, `BARS=disabled` sets
// GlassVerticalBarBehavior.disabled on the shell, `COMPRESSION=` one of
// GlassVerticalBarCompression's names sets that, and
// `ORIENT=portrait|landscapeLeft|landscapeRight` locks the orientation, as the
// native scenarios' `-orient` does. As the native launch arguments of the same
// names: `SEARCHTAB=YES` gives the tabs scenario a search tab
// (GlassTabBar.searchable) and `TAB=search` opens on it; `SEARCH=active` opens
// the search 1s in; `SCROLL=<row>` scrolls a large-title screen 1s in, to
// bring that row to the top; and `DETENT=medium` and
// `PLACEMENT=leading|center|trailing` present the sheet that way.
// `SHOWPILL=NO` takes the search pill off the searchable tab bar
// (GlassSearchBarConfig.showPill), which natively is the TabView without its
// search tab.
// `REDUCETRANSPARENCY=YES` turns on the package's stand-in for Reduce
// Transparency, which the native screens are shot with from DeviceHub.
// `SCAFFOLD=none` lays the tabs scenario's bar over its body in a plain Stack,
// at GlassQuality.premium, rather than as a GlassScaffold's bottom bar.
library;

import 'dart:io' show Directory, File;
import 'dart:ui' show DisplayFeatureType;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// `KEY=value` lines from `tmp/duo_harness.env` in the app's data container.
///
/// Dart's `Platform.environment` is empty on iOS, so `SIMCTL_CHILD_` variables
/// never reach it; the app's tmp directory is `Directory.systemTemp`, which the
/// host can write through `xcrun simctl get_app_container <udid> <bundle> data`.
final Map<String, String> _env = () {
  final file = File('${Directory.systemTemp.path}/duo_harness.env');
  if (!file.existsSync()) return const <String, String>{};
  return {
    for (final line in file.readAsLinesSync())
      if (line.contains('='))
        line.substring(0, line.indexOf('=')).trim():
            line.substring(line.indexOf('=') + 1).trim(),
  };
}();

final String _scenario = _env['SCENARIO'] ?? 'nav';
final bool _rtl = _env['DIRECTION'] == 'rtl';
final bool _barsDisabled = _env['BARS'] == 'disabled';
final bool _searchTab = _env['SEARCHTAB'] == 'YES';
final bool _searchActive = _env['SEARCH'] == 'active';
final bool _showPill = _env['SHOWPILL'] != 'NO';
final int _scrollTo = int.tryParse(_env['SCROLL'] ?? '') ?? 0;
final bool _mediumDetent = _env['DETENT'] == 'medium';
final bool _reduceTransparency = _env['REDUCETRANSPARENCY'] == 'YES';
final bool _noScaffold = _env['SCAFFOLD'] == 'none';
final GlassSheetPlacement _placement = GlassSheetPlacement.values.firstWhere(
  (value) => value.name == _env['PLACEMENT'],
  orElse: () => GlassSheetPlacement.automatic,
);
final GlassVerticalBarCompression _compression =
    GlassVerticalBarCompression.values.firstWhere(
  (value) => value.name == _env['COMPRESSION'],
  orElse: () => GlassVerticalBarCompression.automatic,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  switch (_env['ORIENT']) {
    case 'portrait':
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
    case 'landscapeLeft':
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft]);
    case 'landscapeRight':
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeRight]);
  }
  runApp(LiquidGlassWidgets.wrap(child: const _App()));
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) => CupertinoApp(
        debugShowCheckedModeBanner: false,
        title: 'Duo Bars',
        theme: const CupertinoThemeData(brightness: Brightness.light),
        builder: (context, child) => Directionality(
          textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
          // The package reads Reduce Transparency from highContrast until
          // Flutter surfaces it (flutter/flutter#190318).
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              highContrast:
                  _reduceTransparency || MediaQuery.highContrastOf(context),
            ),
            child: GlassNavigationShell(
              verticalBarBehavior: _barsDisabled
                  ? GlassVerticalBarBehavior.disabled
                  : GlassVerticalBarBehavior.automatic,
              verticalBarCompression: _compression,
              child: child!,
            ),
          ),
        ),
        // A navigator is only built with a route source; every route this
        // harness shows comes from the initial stack below.
        onGenerateRoute: (_) => _route(const _ListScreen(title: 'Inbox')),
        onGenerateInitialRoutes: (_) => _initialRoutes(),
      );

  /// The native scenarios open on a pushed detail screen, with the root
  /// underneath, so the back button is showing.
  static List<Route<void>> _initialRoutes() => switch (_scenario) {
        'root' => [_route(const _RootScreen())],
        'sheet' => [_route(const _SheetScreen())],
        'popover' => [
            _route(const _ListScreen(title: 'Inbox')),
            _route(const _DetailScreen(popover: true)),
          ],
        'menu' => [
            _route(const _ListScreen(title: 'Inbox')),
            _route(const _DetailScreen(menu: true)),
          ],
        'search' => [_route(const _RootScreen(searchable: true))],
        'tabs' => [_route(const _TabsScreen(pushed: false))],
        'tabsnav' => [_route(const _TabsScreen())],
        'navbottom' => [
            _route(const _ListScreen(title: 'Inbox')),
            _route(const _BottomBarScreen()),
          ],
        'axis' => [
            _route(const _ListScreen(title: 'Inbox')),
            _route(const _AxisScreen()),
          ],
        'alert' => [
            _route(const _ListScreen(title: 'Inbox')),
            _route(const _DetailScreen(alert: true)),
          ],
        'push' => [_route(const _ListScreen(title: 'Inbox', pushes: true))],
        'nested' => [_route(const _NestedScreen())],
        _ => [
            _route(const _ListScreen(title: 'Inbox')),
            _route(const _DetailScreen()),
          ],
      };
}

/// The iOS 27 material, which the native bars are drawn in.
const _glass = LiquidGlassSettings.ios27Light;

Route<void> _route(Widget page) =>
    CupertinoPageRoute<void>(builder: (_) => page);

// ─────────────────────────────────────────────────────────────────────────────
// Shared content
// ─────────────────────────────────────────────────────────────────────────────

/// Forty coloured rows, as the native DemoList draws them.
class _Rows extends StatelessWidget {
  const _Rows({
    required this.title,
    this.stripTop = 82,
    this.barTop = 44 + 8,
    this.count = 40,
  });

  final String title;

  /// Where the content starts in the strip layout.
  final double stripTop;

  /// Where the content starts below a horizontal bar, under the top inset.
  final double barTop;

  final int count;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    // Natively the content starts 82pt down in the strip layout, below the
    // title row, under the inset where the bar shares the status bar's row,
    // and under the navigation bar otherwise. DemoList pads it by another
    // 16pt, less the row's own 6pt.
    final top = GlassVerticalBar.maybeOf(context) != null
        ? stripTop + 10
        : _barInStatusRow(context)
            ? padding.top + 10
            : padding.top + barTop;
    return ListView.builder(
      padding: EdgeInsets.only(top: top, bottom: 120),
      itemCount: count,
      itemBuilder: (context, i) => _Row(title: title, index: i),
    );
  }
}

/// Whether the bar shares the status bar's row, as natively on the inner
/// display held upright: beside a status cluster in a top corner, as tall as
/// the top inset. The content then starts right under the inset.
bool _barInStatusRow(BuildContext context) {
  final padding = MediaQuery.viewPaddingOf(context);
  final width = MediaQuery.sizeOf(context).width;
  return GlassVerticalBar.maybeOf(context) == null &&
      padding.top > 0 &&
      MediaQuery.displayFeaturesOf(context).any((feature) {
        final bounds = feature.bounds;
        return feature.type == DisplayFeatureType.cutout &&
            bounds.top <= 0 &&
            (bounds.bottom - padding.top).abs() <= 1 &&
            (bounds.left <= 1) != (bounds.right >= width - 1);
      });
}

/// One coloured row.
class _Row extends StatelessWidget {
  const _Row({required this.title, required this.index});

  final String title;
  final int index;

  @override
  Widget build(BuildContext context) {
    final i = index;
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: HSVColor.fromAHSV(1, (i % 12) * 30.0, 0.7, 0.9).toColor(),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          // SwiftUI's headline and subheadline: their tracking, and the line
          // heights the native rows measure at.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  '$title row ${i + 1}',
                  style: const TextStyle(
                    fontSize: 17,
                    height: 22 / 17,
                    letterSpacing: -0.43,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                // A non-breaking space for iOS's line breaking, which keeps a
                // lone word off the last line.
                const Text(
                  'Secondary text that fills the width of the\u00a0row',
                  style: TextStyle(
                    fontSize: 15,
                    height: 18.4 / 15,
                    letterSpacing: -0.23,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _ListScreen extends StatefulWidget {
  const _ListScreen({required this.title, this.pushes = false});

  final String title;

  /// Whether to push the detail screen 1s in, and pop it 2.5s later.
  final bool pushes;

  @override
  State<_ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<_ListScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.pushes) return;
    Future<void>.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;
      final navigator = Navigator.of(context);
      navigator.push(_route(const _DetailScreen()));
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      navigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) => GlassScaffold(
        backgroundColor: CupertinoColors.white,
        appBar: GlassAppBar.pinned(
          title: Text(widget.title),
          buttonSettings: _glass,
        ),
        body: _Rows(title: widget.title),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Scenarios
// ─────────────────────────────────────────────────────────────────────────────

/// The detail screen's trailing items, in the order the native strip reads
/// them: the pinned compose button first, then share and favourite sharing a
/// capsule, then a spacer, then the overflow menu on its own.
List<GlassBarItem> _detailActions() => [
      GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.square_pencil),
        label: 'Compose',
        background: GlassBarItemBackground.separate,
        onTap: () {},
      ),
      GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.share),
        label: 'Share',
        onTap: () {},
      ),
      GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.heart),
        label: 'Favourite',
        onTap: () {},
      ),
      const GlassBarItem.spacer(),
      GlassBarItem.menu(
        icon: const Icon(CupertinoIcons.ellipsis),
        label: 'More',
        menuItems: [
          GlassMenuItem(
            title: 'Copy',
            icon: const Icon(CupertinoIcons.doc_on_doc),
            onTap: () {},
          ),
          GlassMenuItem(
            title: 'Delete',
            icon: const Icon(CupertinoIcons.delete),
            isDestructive: true,
            onTap: () {},
          ),
        ],
      ),
    ];

class _DetailScreen extends StatefulWidget {
  const _DetailScreen({
    this.alert = false,
    this.popover = false,
    this.menu = false,
  });

  /// Whether to present a dialog over the screen 1.5s in, as the native
  /// `alert` scenario does.
  final bool alert;

  /// Whether the compose button opens a popover, 1.5s in, as in the native
  /// `popover` scenario.
  final bool popover;

  /// Whether the screen keeps only its ••• menu, which is tapped open 1.5s
  /// in and closed again 2s later, as in the `menu` scenario.
  final bool menu;

  @override
  State<_DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<_DetailScreen> {
  /// Opens the compose popover; see [_ComposePopover].
  VoidCallback? _openPopover;

  @override
  void initState() {
    super.initState();
    if (widget.popover) {
      Future<void>.delayed(
        const Duration(milliseconds: 1500),
        () => _openPopover?.call(),
      );
    }
    if (widget.menu) {
      Future<void>.delayed(const Duration(milliseconds: 1500), () async {
        final trigger = _iconCentre(CupertinoIcons.ellipsis);
        if (trigger == null) return;
        _tap(trigger);
        await Future<void>.delayed(const Duration(seconds: 2));
        // Anywhere off the menu lands on its dismiss barrier.
        _tap(const Offset(40, 400));
      });
    }
    if (!widget.alert) return;
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      GlassDialog.show<void>(
        context: context,
        settings: _glass,
        title: 'Delete message?',
        message: 'An alert over the vertical bar.',
        actions: [
          GlassDialogAction(label: 'Cancel', onPressed: () {}),
          GlassDialogAction(
            label: 'Delete',
            isDestructive: true,
            onPressed: () {},
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = GlassScaffold(
      backgroundColor: CupertinoColors.white,
      appBar: GlassAppBar.pinned(
        title: const Text('Detail'),
        buttonSettings: _glass,
        actions: [
          if (widget.menu)
            _routeMenuItem(context)
          else if (widget.popover)
            GlassBarItem.custom(
              child: _ComposePopover(
                onReady: (open) => _openPopover = open,
              ),
              label: 'Compose',
              background: GlassBarItemBackground.separate,
              axisBehavior: GlassBarItemAxisBehavior.verticalPreferred,
            )
          else
            _detailActions().first,
          if (!widget.menu) ..._detailActions().skip(1),
        ],
      ),
      body: const _Rows(title: 'Detail'),
    );
    // Kept clear of the strip, as an app laying its whole screen out in the
    // safe area does, so the bar stops short of the strip.
    return widget.menu
        ? ColoredBox(
            color: CupertinoColors.white,
            child: SafeArea(top: false, bottom: false, child: screen),
          )
        : screen;
  }
}

/// An overflow menu as an app builds its own: a [GlassBarItem.sheet] whose
/// tap pushes a transparent route holding a [GlassMenu] over the icon, so the
/// menu can take content of any height.
GlassBarItem _routeMenuItem(BuildContext screen) {
  BuildContext? iconContext;
  return GlassBarItem.sheet(
    id: 'more',
    label: 'More',
    icon: Builder(builder: (context) {
      iconContext = context;
      return const Icon(CupertinoIcons.ellipsis);
    }),
    onPresent: (_) {
      // The icon drawn in the strip lives above the navigator, so the route
      // is pushed from the screen.
      final context = iconContext;
      if (context == null || !context.mounted) return;
      final box = context.findRenderObject()! as RenderBox;
      final icon = box.localToGlobal(Offset.zero) & box.size;
      Navigator.of(screen, rootNavigator: true).push(RawDialogRoute<void>(
        barrierDismissible: false,
        barrierColor: const Color(0x00000000),
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => _RouteMenu(
          source: Rect.fromCenter(center: icon.center, width: 48, height: 48),
        ),
      ));
    },
  );
}

class _RouteMenu extends StatefulWidget {
  const _RouteMenu({required this.source});

  /// Where the tapped control is on screen.
  final Rect source;

  @override
  State<_RouteMenu> createState() => _RouteMenuState();
}

class _RouteMenuState extends State<_RouteMenu> {
  final _controller = GlassMenuController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.open());
  }

  @override
  Widget build(BuildContext context) => Stack(children: [
        Positioned.fromRect(
          rect: widget.source,
          child: GlassMenu(
            controller: _controller,
            settings: _glass,
            trigger: const SizedBox.expand(),
            menuWidth: 250,
            autoAdjustToScreen: true,
            // Pop once the droplet is home.
            onClose: () {
              final navigator = Navigator.of(context);
              Future<void>.delayed(
                const Duration(milliseconds: 700),
                () {
                  if (mounted) navigator.pop();
                },
              );
            },
            // As tall as the native `menu` scenario's: taller than the room
            // between the item's centre and the status cluster.
            items: [
              for (final (title, icon) in [
                ('Unpin', CupertinoIcons.pin_slash),
                ('Share', CupertinoIcons.share),
                ('Invite', CupertinoIcons.person_badge_plus),
                ('Copy ID', CupertinoIcons.doc_on_doc),
                ('Add to folder', CupertinoIcons.folder_badge_plus),
                ('Edit', CupertinoIcons.pencil),
              ])
                GlassMenuItem(title: title, icon: Icon(icon), onTap: () {}),
              GlassMenuItem(
                title: 'Delete',
                icon: const Icon(CupertinoIcons.delete),
                isDestructive: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ]);
}

/// The global centre of the painted [icon], or null where none is painted.
///
/// The bar keeps an unpainted copy of each item to measure, under a zero
/// [Opacity], which is not the one to tap.
Offset? _iconCentre(IconData icon) {
  Offset? centre;
  void visit(Element element) {
    final widget = element.widget;
    if (centre == null &&
        widget is Icon &&
        widget.icon == icon &&
        element.findAncestorWidgetOfExactType<Opacity>()?.opacity != 0) {
      final box = element.renderObject! as RenderBox;
      centre = box.localToGlobal(box.size.center(Offset.zero));
    }
    element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  return centre;
}

/// A finger's tap at [position], through the gesture binding.
void _tap(Offset position) {
  GestureBinding.instance
    ..handlePointerEvent(PointerDownEvent(pointer: 1 << 20, position: position))
    ..handlePointerEvent(PointerUpEvent(pointer: 1 << 20, position: position));
}

/// The compose button with a popover, as the native `popover` scenario
/// declares it.
///
/// Flutter has no popover bar item, so this is a custom item holding a
/// [GlassPopover], squeezed into the strip as natively.
class _ComposePopover extends StatelessWidget {
  const _ComposePopover({required this.onReady});

  /// Receives the callback that opens the popover.
  final ValueChanged<VoidCallback> onReady;

  @override
  Widget build(BuildContext context) => GlassPopover(
        settings: _glass,
        // The native popover's frame: a 68pt capsule around one line of body
        // text, 18pt in from each end.
        popoverWidth: 282,
        popoverHeight: 68,
        popoverBorderRadius: 34,
        triggerBuilder: (context, toggle) {
          // The shell draws the strip's copy; the bar keeps an unpainted one
          // to measure, which is not the one to open.
          if (context.findAncestorWidgetOfExactType<Opacity>()?.opacity != 0) {
            onReady(toggle);
          }
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: toggle,
            child: const SizedBox.square(
              dimension: 48,
              child: Icon(CupertinoIcons.square_pencil),
            ),
          );
        },
        contentBuilder: (context, close) => const Center(
          child: Text(
            'Popover from a vertical bar item',
            maxLines: 1,
            style: TextStyle(
              fontSize: 17,
              letterSpacing: -0.43,
              color: CupertinoColors.label,
            ),
          ),
        ),
      );
}

/// The native `sheet` scenario: a root screen that presents a sheet 1s in.
class _SheetScreen extends StatefulWidget {
  const _SheetScreen();

  @override
  State<_SheetScreen> createState() => _SheetScreenState();
}

class _SheetScreenState extends State<_SheetScreen> {
  final _title = GlassLargeTitleController();

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      GlassModalSheet.show<void>(
        context: context,
        initialState:
            _mediumDetent ? GlassSheetState.half : GlassSheetState.full,
        // The native medium detent on the outer display, in portrait.
        halfSize: 398,
        detents: _mediumDetent
            ? const {GlassSheetDetent.medium, GlassSheetDetent.large}
            : const {GlassSheetDetent.large},
        placement: _placement,
        // The iOS 27 material, frosted as heavily as the sheet's default: the
        // material's own blur is measured on controls.
        settings: _glass.copyWith(blur: 10),
        // As natively: a 20% dim, and a grabber only where there is a detent
        // to drag to.
        barrierColor: const Color(0x33000000),
        showDragIndicator: _mediumDetent,
        builder: (_) => const _SheetBody(),
      );
    });
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GlassScaffold(
        backgroundColor: CupertinoColors.white,
        appBar: GlassAppBar.pinned(
          title: const Text('Notes'),
          buttonSettings: _glass,
          largeTitleController: _title,
          actions: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.add),
              label: 'New',
              onTap: () {},
            ),
          ],
        ),
        body: _LargeTitleRows(
          title: 'Notes',
          rowTitle: 'Notes',
          controller: _title,
        ),
      );
}

/// The sheet's own navigation stack: an inline title, cancel and done.
class _SheetBody extends StatelessWidget {
  const _SheetBody();

  @override
  Widget build(BuildContext context) => GlassScaffold(
        backgroundColor: const Color(0x00000000),
        statusBarStyle: GlassStatusBarStyle.none,
        appBar: GlassAppBar.pinned(
          title: const Text('New Note'),
          buttonSettings: _glass,
          // A sheet's horizontal bar, 16pt in from its edges.
          toolbarHeight: 48,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          leading: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.xmark),
              label: 'Cancel',
              background: GlassBarItemBackground.separate,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ],
          actions: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.checkmark),
              label: 'Done',
              background: GlassBarItemBackground.separate,
              tintColor: CupertinoColors.systemBlue,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
        body: const _Rows(title: 'Sheet', count: 12, stripTop: 74, barTop: 84),
      );
}

class _BottomBarScreen extends StatelessWidget {
  const _BottomBarScreen();

  @override
  Widget build(BuildContext context) {
    // The group runs down the strip with the toolbar, at the strip's control
    // size.
    final vertical = GlassVerticalBar.maybeOf(context) != null;
    return GlassScaffold(
      backgroundColor: CupertinoColors.white,
      appBar: const GlassAppBar.pinned(
        title: Text('Detail'),
        buttonSettings: _glass,
      ),
      bottomBar: GlassToolbar(
        children: [
          GlassButtonGroup.icons(
              settings: _glass,
              direction: vertical ? Axis.vertical : Axis.horizontal,
              itemPadding: vertical
                  ? const EdgeInsets.symmetric(horizontal: 13, vertical: 14)
                  : const EdgeInsets.all(12),
              items: [
                GlassButtonGroupItem(
                  icon: const Icon(CupertinoIcons.archivebox),
                  onTap: () {},
                ),
                GlassButtonGroupItem(
                  icon: const Icon(CupertinoIcons.flag),
                  onTap: () {},
                ),
              ]),
          const Spacer(),
          GlassButton(
            settings: _glass,
            icon: const Icon(CupertinoIcons.reply),
            width: vertical ? 48 : 44,
            height: vertical ? 48 : 44,
            onTap: () {},
          ),
        ],
      ),
      body: const _Rows(title: 'Detail'),
    );
  }
}

/// A root screen with a large title, as a SwiftUI NavigationStack root has by
/// default: the native `root` scenario, and `search` with a `searchable`
/// field.
class _RootScreen extends StatefulWidget {
  const _RootScreen({this.searchable = false});

  final bool searchable;

  @override
  State<_RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<_RootScreen> {
  final _title = GlassLargeTitleController();

  @override
  void initState() {
    super.initState();
    if (widget.searchable && _searchActive) {
      Future<void>.delayed(const Duration(seconds: 1), () {
        if (mounted) _title.reportSearchPresented(true);
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GlassScaffold(
        backgroundColor: CupertinoColors.white,
        appBar: GlassAppBar.pinned(
          title: const Text('Mailboxes'),
          buttonSettings: _glass,
          largeTitleController: _title,
          leading: [
            GlassBarItem.custom(
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Center(child: Text('Edit')),
              ),
              label: 'Edit',
              onTap: () {},
            ),
          ],
          actions: [
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.add),
              label: 'Add',
              onTap: () {},
            ),
          ],
        ),
        body: _LargeTitleRows(
          title: 'Mailboxes',
          rowTitle: 'Mail',
          controller: _title,
          searchable: widget.searchable,
        ),
      );
}

/// The forty rows under a [GlassLargeTitle], as a NavigationStack root lays
/// them out.
class _LargeTitleRows extends StatefulWidget {
  const _LargeTitleRows({
    required this.title,
    required this.rowTitle,
    required this.controller,
    this.searchable = false,
  });

  final String title;
  final String rowTitle;
  final GlassLargeTitleController controller;
  final bool searchable;

  @override
  State<_LargeTitleRows> createState() => _LargeTitleRowsState();
}

class _LargeTitleRowsState extends State<_LargeTitleRows> {
  final _rowKeys = List.generate(40, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    if (_scrollTo <= 0) return;
    // As the native `-scroll`: the row reaches the top of the content, which
    // is the edge margin once the title row has scrolled away.
    Future<void>.delayed(const Duration(seconds: 1), () {
      final row = _rowKeys[_scrollTo].currentContext;
      if (!mounted || row == null || !row.mounted) return;
      final scroll = widget.controller.scrollController;
      final box = row.findRenderObject()! as RenderBox;
      final top = box.localToGlobal(Offset.zero).dy + scroll.offset;
      final inset = GlassVerticalBar.maybeOf(context) == null
          ? MediaQuery.paddingOf(context).top + 44
          : GlassVerticalBarMetrics.edgeMargin;
      // The row's own 6pt padding is spacing between rows natively.
      scroll.animateTo(
        top + 6 - inset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final vertical = GlassVerticalBar.maybeOf(context) != null;
    return DefaultButtonSettings(
      settings: _glass,
      child: CustomScrollView(
        controller: widget.controller.scrollController,
        slivers: [
          // Clears a horizontal navigation bar, which in the status bar's row
          // takes no room below the inset. The strip's title row is the large
          // title's own to place.
          if (!vertical)
            SliverToBoxAdapter(
              child: SizedBox(
                height: padding.top + (_barInStatusRow(context) ? 0 : 44),
              ),
            ),
          GlassLargeTitle(
            text: widget.title,
            controller: widget.controller,
            // In the strip the field is 48pt, with a label-coloured magnifier
            // and 17pt text, as native draws it there.
            searchBar: widget.searchable
                ? vertical
                    ? const GlassSearchBar(
                        height: 48,
                        searchIconColor: CupertinoColors.label,
                        textStyle: TextStyle(fontSize: 17),
                        placeholderStyle: TextStyle(
                          fontSize: 17,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      )
                    : const GlassSearchBar(height: 36)
                : null,
          ),
          SliverPadding(
            // DemoList's 16pt vertical padding, less the row's own 6pt.
            padding: const EdgeInsets.only(top: 10, bottom: 120),
            sliver: SliverList.builder(
              itemCount: 40,
              itemBuilder: (context, i) => KeyedSubtree(
                key: _rowKeys[i],
                child: _Row(title: widget.rowTitle, index: i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Title-only, custom and icon items with each axis behaviour, as the native
/// `axis` scenario declares them.
class _AxisScreen extends StatelessWidget {
  const _AxisScreen();

  /// A red dot and a label. [squeezed] lays the two out in a Wrap, which
  /// wraps like SwiftUI's HStack where the strip squeezes the pill to 48pt; a
  /// Row keeps one line in the horizontal capsule.
  static Widget _pill(String label, {bool squeezed = false}) {
    const dot = DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.systemRed,
        shape: BoxShape.circle,
      ),
      child: SizedBox(width: 8, height: 8),
    );
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: squeezed ? 4 : 8),
      child: squeezed
          ? Wrap(
              spacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: [dot, text],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [dot, const SizedBox(width: 4), text],
            ),
    );
  }

  static Widget _text(String label) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Center(child: Text(label)),
      );

  @override
  Widget build(BuildContext context) => GlassScaffold(
        backgroundColor: CupertinoColors.white,
        appBar: GlassAppBar.pinned(
          title: const Text('Detail'),
          buttonSettings: _glass,
          actions: [
            GlassBarItem.custom(child: _text('Text'), onTap: () {}),
            GlassBarItem.custom(
              child: _text('Text VP'),
              axisBehavior: GlassBarItemAxisBehavior.verticalPreferred,
              onTap: () {},
            ),
            GlassBarItem.custom(child: _pill('Custom')),
            GlassBarItem.custom(
              child: _pill('Custom VP', squeezed: true),
              axisBehavior: GlassBarItemAxisBehavior.verticalPreferred,
            ),
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.star),
              axisBehavior: GlassBarItemAxisBehavior.horizontalOnly,
              onTap: () {},
            ),
            GlassBarItem.icon(
              icon: const Icon(CupertinoIcons.bell),
              onTap: () {},
            ),
          ],
        ),
        body: const _Rows(title: 'Detail'),
      );
}

/// The detail screen in a nested navigator, its bar drawn by the app from
/// [GlassPinnedBarChrome.builder] rather than by the package.
///
/// The nested stack is kept out of the shell, as
/// [GlassPinnedBarChrome.enabled] advises, so the chrome is never hoisted and
/// the strip is drawn in-route. The bar draws its own back button and
/// capsules while the package does not; the strip is the package's either
/// way.
class _NestedScreen extends StatelessWidget {
  const _NestedScreen();

  @override
  Widget build(BuildContext context) => Navigator(
        onGenerateInitialRoutes: (_, __) => [
          _route(const ColoredBox(color: CupertinoColors.white)),
          _route(const _OwnBarDetail()),
        ],
      );
}

class _OwnBarDetail extends StatelessWidget {
  const _OwnBarDetail();

  @override
  Widget build(BuildContext context) => GlassPinnedBarChrome(
        enabled: false,
        buttonSettings: _glass,
        actions: _detailActions(),
        builder: (context, chrome) {
          final ownChrome = !chrome.hoisted && !chrome.inStrip;
          return ColoredBox(
            color: CupertinoColors.white,
            child: Stack(children: [
              const _Rows(title: 'Detail'),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 24,
                left: 20,
                right: 20,
                height: GlassVerticalBarMetrics.rowHeight,
                child: Row(spacing: 12, children: [
                  if (ownChrome)
                    GlassButton(
                      settings: _glass,
                      icon: const Icon(CupertinoIcons.back),
                      width: 44,
                      height: 44,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  const Text(
                    'Detail',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                  const Spacer(),
                  if (ownChrome)
                    GlassButtonGroup.icons(
                      settings: _glass,
                      items: [
                        for (final icon in [
                          CupertinoIcons.square_pencil,
                          CupertinoIcons.share,
                          CupertinoIcons.heart,
                          CupertinoIcons.ellipsis,
                        ])
                          GlassButtonGroupItem(
                            icon: Icon(icon),
                            onTap: () {},
                          ),
                      ],
                    ),
                ]),
              ),
            ]),
          );
        },
      );
}

/// Four tabs, each its own navigation stack: opened on a pushed detail screen
/// (`tabsnav`), or on a root screen with a large title (`tabs`). `SEARCHTAB`
/// adds the search tab, as GlassTabBar.searchable.
class _TabsScreen extends StatefulWidget {
  const _TabsScreen({this.pushed = true});

  final bool pushed;

  @override
  State<_TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<_TabsScreen> {
  static const _titles = ['Home', 'Library', 'Radio', 'Profile'];
  static const _tabs = [
    GlassTab(icon: Icon(CupertinoIcons.house_fill), label: 'Home'),
    GlassTab(icon: Icon(CupertinoIcons.book_fill), label: 'Library'),
    GlassTab(
      icon: Icon(CupertinoIcons.dot_radiowaves_left_right),
      label: 'Radio',
    ),
    GlassTab(
      icon: Icon(CupertinoIcons.person_crop_circle_fill),
      label: 'Profile',
    ),
  ];

  int _tab = 0;
  bool _searching = _searchTab && _env['TAB'] == 'search';

  @override
  void initState() {
    super.initState();
    if (_searchTab && _searchActive && !_searching) {
      Future<void>.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _searching = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bar = _searchTab
        ? GlassTabBar.searchable(
            settings: _glass,
            quality: _noScaffold ? GlassQuality.premium : null,
            selectedIndex: _tab,
            onTabSelected: (i) => setState(() => _tab = i),
            selectedIconColor: CupertinoColors.systemBlue,
            isSearchActive: _searching,
            searchConfig: GlassSearchBarConfig(
              onSearchToggle: (active) => setState(() => _searching = active),
              showPill: _showPill,
            ),
            tabs: _tabs,
          )
        : GlassTabBar.bottom(
            settings: _glass,
            quality: _noScaffold ? GlassQuality.premium : null,
            selectedIndex: _tab,
            onTabSelected: (i) => setState(() => _tab = i),
            // The native TabView's selected tab takes the app's tint.
            selectedIconColor: CupertinoColors.systemBlue,
            tabs: _tabs,
          );
    // Only the selected tab is built: the shell ranks the routes of one
    // Navigator, and the stacks of the tabs behind would keep their chrome
    // registered.
    final body = _searching
        // The search tab's screen. In a compact width the open field takes
        // its title's row; in a regular width the title stays beside it.
        ? MediaQuery.sizeOf(context).width < 800
            ? const GlassScaffold(
                backgroundColor: CupertinoColors.white,
                body: _Rows(title: 'Search', stripTop: 78),
              )
            : const _TabRootScreen(title: 'Search', adds: false)
        : Navigator(
            key: ValueKey(_tab),
            onGenerateInitialRoutes: (_, __) => [
              if (widget.pushed) ...[
                _route(_ListScreen(title: _titles[_tab])),
                _route(const _DetailScreen()),
              ] else
                _route(_TabRootScreen(title: _titles[_tab])),
            ],
          );
    if (_noScaffold) {
      return Stack(children: [body, Positioned.fill(child: bar)]);
    }
    return GlassScaffold(
      backgroundColor: CupertinoColors.white,
      bottomBar: bar,
      body: body,
    );
  }
}

/// A tab's root screen, with a large title and an add button.
class _TabRootScreen extends StatefulWidget {
  const _TabRootScreen({required this.title, this.adds = true});

  final String title;

  /// Whether the screen has the add button; the search tab's has none.
  final bool adds;

  @override
  State<_TabRootScreen> createState() => _TabRootScreenState();
}

class _TabRootScreenState extends State<_TabRootScreen> {
  final _title = GlassLargeTitleController();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GlassScaffold(
        backgroundColor: CupertinoColors.white,
        appBar: GlassAppBar.pinned(
          title: Text(widget.title),
          buttonSettings: _glass,
          largeTitleController: _title,
          actions: [
            if (widget.adds)
              GlassBarItem.icon(
                icon: const Icon(CupertinoIcons.add),
                label: 'Add',
                onTap: () {},
              ),
          ],
        ),
        body: _LargeTitleRows(
          title: widget.title,
          rowTitle: widget.title,
          controller: _title,
        ),
      );
}
