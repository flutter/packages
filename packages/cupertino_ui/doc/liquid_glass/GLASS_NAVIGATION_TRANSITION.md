# Glass Navigation Transition

Pinned navigation-bar chrome across route transitions — the iOS 26 navigation
bar model, where bar items belong to the navigation stack rather than to any
one screen.

During a push or pop (including the interactive back-swipe, scrubbed
proportionally with the gesture), page content and the title slide with the
route transition while the glass back button and the trailing actions capsule
stay pinned in place above the `Navigator`. A capsule present on both routes
morphs in place: its width animates between the two measured clusters, matched
items hold their position, and changed icons cross-fade. Apple documents the
same behaviour on
[`UIBarButtonItem.identifier`](https://developer.apple.com/documentation/uikit/uibarbuttonitem/identifier):
*"When the set of bar button items in a navigation bar or toolbar changes (for
example, when pushing or popping view controllers), UIKit automatically
animates the transition between the different sets of items."*

## Setup

Install `GlassNavigationShell` once, wrapping whatever `Navigator` your app
builds:

```dart
CupertinoApp(
  builder: (context, child) => GlassNavigationShell(child: child!),
  home: const HomeScreen(),
);
```

This works with **any routing library built on the Pages API** — go_router,
auto_route, beamer — because the shell only reads `ModalRoute` animations and
never intercepts navigation:

```dart
CupertinoApp.router(
  routerConfig: router,
  builder: (context, child) => GlassNavigationShell(child: child!),
);
```

With go_router, use `CupertinoPage` in your `pageBuilder`s to keep the native
slide and back-swipe.

### If your bar is not a `GlassAppBar`

The shell hoists chrome above the `Navigator` and redraws it at
`GlassNavPinnedMetrics`. A bar that draws its own back button and actions —
an app with an existing design system adopting pinning incrementally — must
use the same numbers, or the chrome visibly resizes and shifts at the moment
of hand-over:

```dart
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

SizedBox(
  height: GlassNavPinnedMetrics.toolbarHeight,      // 44
  child: Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: GlassNavPinnedMetrics.horizontalPadding, // 8
    ),
    child: ...,
  ),
);
```

The two clusters are **not** the same size: the back button is
`backDiameter` (44) while each action slot is `slot` (46). Mirroring both
takes two numbers.

Align to the geometry members only. `crossFadeStart`, `crossFadeEnd`,
`swapAt` and `capsuleStretch` describe the shell's own choreography and may be
retuned.

## Declaring a screen's bar items

Screens opt in with the `GlassAppBar.pinned` constructor, declaring items as
data — the analogue of `UIBarButtonItem`:

```dart
GlassScaffold(
  appBar: GlassAppBar.pinned(
    title: const Text('Repository'),
    actions: [
      GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.add),
        id: 'add',
        onTap: _create,
      ),
      GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.ellipsis),
        onTap: _showMore,
      ),
    ],
  ),
  body: ...,
);
```

`actions` defaults to empty, so the common back-button-only screen is just
`GlassAppBar.pinned(title: ...)`. The plain `GlassAppBar` constructor keeps
the widget-based `leading`/`actions` API and never participates in pinning —
the constructor choice *is* the mode, so the two APIs cannot be mixed on one
bar.

- **The back button is automatic.** It appears whenever the route can be
  popped (`ModalRoute.impliesAppBarDismissal`) and never on a root route. The
  default action is `Navigator.maybePop` — what Flutter's own `BackButton`
  calls, and what Pages-API routers handle correctly. Override with `onBack`
  for router-specific semantics such as go_router's `context.pop()`, or set
  `backButton: false` to suppress it.
- **`leading` replaces the back button.** A non-empty `leading` stands in for
  it, which is UIKit's rule for `leftBarButtonItems` — *"A custom left item
  replaces the regular back button unless you set
  leftItemsSupplementBackButton to YES"* — and Flutter's own `AppBar`, which
  implies a leading only when none was given. Set
  `leadingItemsSupplementBackButton: true` for both, mirroring the UIKit
  property of the same name. `backButton: false` still wins over either.

  ```dart
  GlassAppBar.pinned(
    title: const Text('New Issue'),
    leading: [
      GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.xmark),
        label: 'Cancel',
        background: GlassBarItemBackground.separate,
        onTap: () => Navigator.of(context).pop(),
      ),
    ],
  )
  ```
- **`GlassBarItemBackground` decides what glass an item gets.** It collapses
  the two booleans iOS 26 added to `UIBarButtonItem` into their three distinct
  results: `shared` (the default — `sharesBackground`, items form one capsule),
  `separate` (`sharesBackground: NO` — its own shell, which at a lone icon's
  size is the circular button the back button already is), and `none`
  (`hidesSharedBackground` — no glass, for content that carries its own shape,
  such as a profile photo). A fourth, `own`, is `none` for content that is
  itself a glass surface: the shell dissolves it through the surface's own
  visibility instead of fading it under a layer, which a glass surface cannot
  survive. Two `own` items matched across a route change take turns rather
  than cross-fading, since each would sample the other.
- **`GlassBarItem.spacer()` splits a capsule.** It mirrors SwiftUI's
  `ToolbarSpacer(.fixed)` and UIKit's `fixedSpace`: the shared items on either
  side of it form separate capsules, the standard gap apart. Across a route
  change a capsule follows its items, and a capsule the destination adds
  beside it buds out of it, joined by a liquid bridge until they part, as iOS
  27 grows one shell out of another; one it drops merges back in. Under reduce
  motion, the plain cross-fade, or a tinted item, the new capsule materializes
  on its own instead.
- **`id` mirrors `UIBarButtonItem.identifier`.** Items sharing an `id` across
  two routes are treated as the same item and hold their position while
  everything around them morphs. Without an `id`, items are matched
  positionally from the edge their cluster is anchored to — the trailing edge
  for `actions`, the leading edge for `leading` — UIKit's documented default
  heuristic.
- **`GlassBarItem.custom` is the `customView:` analogue.** Any widget can sit
  in the capsule; it is measured at its intrinsic width during layout and the
  capsule sizes itself around it. There is deliberately no API to offset or
  reposition a cluster — iOS 26 has none either, which is exactly why custom
  content needs no coordination: the widget *is* an item, and layout flows
  from that.
- **`GlassBarItem.menu` is the `UIBarButtonItem.menu` analogue.** The whole
  capsule morphs into the pull-down, matching iOS 26's `GlassEffectContainer`
  and `GlassButtonGroupItem.menu`. Only the first menu item in a cluster opens
  a menu; a second is treated as a plain icon. A menu cannot be opened while a
  transition is running, and one already open is dismissed if navigation
  starts — the capsule outlives the route that owns the menu, so nothing else
  would take it down.
- **`GlassBarItem.sheet` morphs the capsule into a `GlassModalSheet`.** Its
  tap is handed a `GlassMorphAnchor` for `GlassModalSheet.show(morphFrom:)`,
  and the whole capsule empties for it, for the same reason `menu` morphs the
  whole capsule. The anchor is the capsule on screen — the hoisted copy under
  a shell. Presenting hands the chrome back to the route, but the shell keeps
  this one capsule through the sheet: the morph has emptied it, so nothing of
  it is drawn above the sheet, and the droplet has somewhere to come home to.
  The route's bar keeps that slot as a placeholder meanwhile. Present
  synchronously from `onPresent`; a capsule no sheet has claimed by the end of
  the next frame hands back with the rest.
- **Participation is the constructor.** A `GlassAppBar.pinned` screen keeps
  the chrome pinned even with no actions; a plain `GlassAppBar` screen does
  not participate, and the pinned chrome retreats while it covers the bar.

## Pinning from a bar that isn't `GlassAppBar`

An app that already has its own bar — a Material `AppBar` carrying its own
backdrop, a collapsing large-title sliver, anything a design system already
owns — pins with `GlassPinnedBarChrome` instead. It performs the same
registration `GlassAppBar.pinned` does internally. Declare the items once, as
data, and drop the resolved slots into your bar:

```dart
GlassPinnedBarChrome(
  actions: [
    GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: _create),
  ],
  builder: (context, chrome) => AppBar(
    automaticallyImplyLeading: false,
    leading: chrome.leading,
    actions: chrome.actions,
    title: const Text('Repository'),
  ),
);
```

`chrome.leading` and `chrome.actions` swap themselves at the right moment. Until
the shell has both accepted the registration *and* had a frame to render its
copy, they hold the real glass back button and actions capsule — the same
widgets the shell will draw. After, they hold unpainted placeholders that lay
out the real content, so the bar keeps the layout it had and the title never
shifts. The hand-over is deliberately a frame late: at the swap both copies are
static and identical, so they never overlap and never both disappear.

Where there is no shell, or the device can't render the effect, the slots
simply keep the real buttons — so a bar written this way needs no fallback of
its own, and there is nothing to keep in sync with the item data.

`chrome.hoisted` is there for a bar that wants to substitute *its own* chrome
rather than the package's; reading it is not needed for the common case.

`horizontalInset` is the guide your capsules sit on, defaulting to the
`GlassNavPinnedMetrics.horizontalPadding` a `GlassAppBar` uses for its own.
Pass yours if the bar is aligned to something else — an app's page gutter,
say. The chrome hands back to the route whenever a sheet or dialog is
presented over it, and that hand-over is invisible only while both renderings
land on the same guide; a bar that disagrees steps sideways at every one.

`chrome.presenting` is the one exception to that hand-back: the
`GlassBarItem.sheet` whose sheet is up out of the hoisted chrome. Its capsule
stays the shell's, emptied by the morph, and its slot keeps the placeholder
while every other slot holds the real buttons. A bar drawing its own chrome
leaves that capsule unpainted likewise.

`platformViewBackdrop` is for a bar floating over a native platform view — a
map, a video. `buttonSettings` cannot cover this on its own: the shader reads a
captured backdrop the platform view is never part of, so the shell's capsule
has nothing to refract there. The flag routes it to a live `BackdropFilter`
instead, as `GlassButton.platformViewBackdrop` does for the bar's own, and is
applied in-route as well so the two agree across the hand-over.

`leading`, `backButton`, `leadingItemsSupplementBackButton`, `onBack` and
`buttonSettings` mean exactly what they do on `GlassAppBar.pinned` — a
non-empty `leading` replaces the back button in `chrome.leading` unless
`leadingItemsSupplementBackButton` is set. The one addition is `enabled`,
which is how an app with a **nested navigator** keeps the nested stack's roots
out of the shell — the shell ranks registered routes against one another,
which only has meaning inside a single `Navigator`:

```dart
enabled: ModalRoute.of(context)?.impliesAppBarDismissal ?? false,
```

## Behaviour and constraints

| Situation | Behaviour |
|---|---|
| Push/pop between participating routes | Chrome pinned; a surviving cluster morphs — a gel swell past its resting size, a spring to the target that overshoots and settles, item positions riding the same spring — while glyphs blur out and arrive soft, sharpening last |
| Interactive back-swipe | The page and its title track the finger, but the pinned chrome holds still until the gesture commits — then plays its whole transition over the travel that is left. An abandoned swipe leaves the chrome untouched, with nothing to rebound |
| Destination has no actions (or no back button) | The cluster materializes or dematerializes — a fade and gaussian blur with a subtle scale, mirroring SwiftUI's `glassEffectTransition(.materialize)` — over a window straddling the transition midpoint |
| Leading changes between a glass item and a bare one | The same materialize window, not a cross-fade: glass cannot cross-fade into something that is not glass |
| Tap while a transition runs | Ignored. The chrome is showing a blend of two routes' items, so a tap would fire an action the user can no longer see |
| Navigation starts with a menu open | The menu is dismissed; the capsule outlives the route, so nothing else would |
| Non-participating route **pushed** on top | Chrome retreats with the covering route's transition and returns on pop |
| Dialog, action sheet, modal sheet or fullscreen dialog **presented** | Chrome returns to the route, so the presentation and its barrier cover it as they cover the rest of the page; pinned again on dismissal |
| No shell installed, or `GlassQuality.minimal` | `GlassAppBar.pinned` renders in-route: the same leading and trailing groups, drawn inside the bar |

A surviving cluster's morph rides the package's bouncy spring profile for the
full length of the route transition — cluster and page share one clock, so
the bounce settles in the same breath the page lands, and a pop plays the
same forward choreography toward the other cluster rather than the push in
reverse. The gel swell is real geometry: the cluster lays out at scale and
the glass re-renders its true shape, carrying the glyphs with it. Timing and
blur constants live together in `GlassNavPinnedMetrics`.

A glass surface's backdrop pass still renders fully or not at all, so glass is
never faded with an ancestor `Opacity`. A cluster that appears or disappears
instead dissolves through the shader's own visibility uniforms — the one fade
the backdrop pass honours — which is what makes the materialize effect
possible. A cluster present on *both* routes never dissolves at all: it keeps
one persistent glass shell whose geometry animates, and only its item
*contents* cross-fade.

### `effectTransition`

`GlassNavigationShell.effectTransition` selects the effect:

```dart
GlassNavigationShell(
  effectTransition: GlassEffectTransition.identity, // no dissolve
  child: child!,
)
```

`GlassEffectTransition.materialize` is the default. `identity` restores the
single switch at the transition midpoint that shipped in 1.1.0. Reduce Motion
selects `identity` automatically, so the effect never needs to be disabled for
accessibility.

It is set on the shell rather than per screen because the choreography spans
two routes: with a knob on each bar, a push between routes that disagree would
have no answer for which one wins.

The same effect is available on any glass, in or out of a bar, as
[`GlassMaterialize`](../lib/widgets/effects/glass_materialize.dart) (the
`AnimatedOpacity`-style implicit form) and `GlassMaterializeTransition` (the
`FadeTransition`-style explicit form, which also works as an
`AnimatedSwitcher.transitionBuilder`).

## iPhone Duo vertical bars

On iPhone Duo an app built against the iOS 27.1 SDK gets vertical bars: always
on the outer display, and on the inner display in landscape. The back button,
bar items and tab bar leave the top and bottom edges and stack in an 84pt strip
beside the status bar. UIKit only moves the bars a container owns, and a
`FlutterViewController` owns none, so the shell stands in for the container:
it resolves the strip and the package's bars follow it, with nothing to change
in a screen.

| Bar | In the strip |
|---|---|
| `GlassAppBar.pinned` / `GlassPinnedBarChrome` | Back button, then the leading and trailing groups in order, stacked from the top of the strip. The title stays in a row at the top of the content, beside any item that stays horizontal |
| `GlassBarItem` | `.icon`, `.menu` and `.sheet` go vertical; `.custom` stays in the horizontal row. `axisBehavior` overrides either way, mirroring SwiftUI's `axisBehavior(_:)` |
| `GlassTabBar.bottom` / `.minimizable` | An icon-only capsule at the bottom of the strip |
| `GlassTabBar.searchable` | The same capsule, with search as its last slot. The field it opens stays horizontal, in the row at the top of the content: in place of the title on the outer display, beside it on the inner one |
| `GlassLargeTitle` | The title moves into the row at the top of the content at 28pt, drawn by the `GlassAppBar.pinned` sharing its controller, and scrolls away with the content. A `searchBar` becomes a magnifier at the bottom of the strip, which opens the field along the bottom of the content and hides the bar |
| `GlassToolbar` | Its items stack at the bottom of the strip; spacers collapse to the strip's gap |
| `GlassModalSheet` | Takes the strip's place where it covers it: its `GlassAppBar.pinned` stacks down a strip of its own on the outer display, and at `GlassSheetPlacement.trailing` on the inner display, where it is otherwise a 653pt card with a horizontal bar |
| `GlassMenu` / `GlassPopover` | Opened from the strip, they open towards the content, centred on their item |

```dart
GlassNavigationShell(
  verticalBarBehavior: GlassVerticalBarBehavior.automatic, // .disabled keeps horizontal bars
  verticalBarCompression: GlassVerticalBarCompression.automatic,
  child: child!,
)

final edge = GlassVerticalBar.edgeOf(context); // null where bars are horizontal
```

The strip is read from `MediaQuery.viewPadding`: a zero top inset with exactly
one lateral inset is the strip, on that side, and the insets are physical, so
it keeps its side under RTL. Where the strip runs out of height, the chrome
collapses the groups that no longer fit into a ••• menu, and the tab bar
collapses to its selected tab — on its own in outer landscape, or always with
`GlassVerticalBarCompression.prefersBarItems`. A bar the app draws in the strip
reserves its height with `GlassNavigationShellState.reserveVerticalBarBottom`,
as the package's tab bar and toolbar do.

`GlassVerticalBarBehavior.disabled` keeps the package's bars horizontal, but
the system still reserves the strip. To give the width back, override
`preferredVerticalBarBehavior` in a `FlutterViewController` subclass:

```swift
class HorizontalBarsFlutterViewController: FlutterViewController {
  @available(iOS 27.1, *)
  override var preferredVerticalBarBehavior: UIVerticalBarBehavior { .disabled }
}
```

`example/lib/harnesses/duo_bars_harness.dart` rebuilds the native reference
screens with the package's bars, for comparing the two on the simulator.

## Direction

`GlassAppBar.pinned` is deliberately the opt-in, not the default — but that
is a transition state, not the end state. On iOS 26 the pinned behaviour *is*
the navigation bar, so the intended trajectory is:

1. Land the data API additively (this release) — nothing shipped changes.
2. Bring `GlassBarItem` to parity with the widget API. Menus, `leading`,
   per-item backgrounds and `GlassBarItem.spacer()` have landed; what remains
   is text styles.
3. At the next major, make pinning the default `GlassAppBar` and demote the
   widget-based `leading`/`actions` constructor to a legacy mode.

Screens written against `GlassAppBar.pinned` today are already written for
that future.

## Current limitations

- A lone `shared` item still renders at the capsule's height rather than the
  circular button's, so a single action is 2pt larger than a single `separate`
  one. Unifying them would resize every shipped one-action bar, so it is
  deliberately left for a major.
- Two wide clusters can meet in the middle of the bar. iOS 27 answers this
  with `UIBarButtonItem.visibilityPriority` and `ToolbarOverflowMenu`; nothing
  here clamps or overflows yet.
- Changing a pinned bar's `actions` in place via `setState` swaps the capsule's
  contents without animating the resize, and without materializing an item
  that appears or disappears. The effect is driven by route progress, and at
  rest there is none to drive it.
- One navigator per shell; nested navigators (for example go_router's
  `StatefulShellRoute` branches) are not yet supported. A presentation made on
  a *different* navigator from the route that owns the chrome — a
  `useRootNavigator: true` dialog raised from inside a nested stack — is not
  seen as covering it, for the same reason.
- On iPhone Duo, where the first control in the strip starts depends on the
  status cluster and the camera, which Flutter does not report yet: until
  `displayFeatures` is populated on iOS (flutter/flutter#193025) it comes from
  a table of the postures measured on the iOS 27.1 simulator. For the same
  reason inner portrait keeps its bar a row below the status bar rather than
  beside it, and a half-folded display does not move sheets and dialogs into
  one half. `GlassTabBar.searchable`, modal sheets, popovers and the Reduce
  Transparency strip background do not follow the strip yet.
- RTL layouts are untested. The clusters themselves are now placed with
  `Positioned.directional` and anchored to the logical edge, but item order
  within a cluster is not mirrored.

## Demos

The example showcase app uses pinned chrome throughout — every category page
pins its back button, and the navigation-patterns demo pins its actions,
including a **Nested Navigation** pattern that walks a three-level drill-down
with identifier-matched items morphing at each push, and a **Custom Bar
Pinning** pattern whose bar is a plain Material `AppBar` pinned through
`GlassPinnedBarChrome`:

The **Leading Items** pattern in the same demo walks the four leading
configurations — a bare avatar, the implied back button, a leading that
replaces it, and one that sits beside it — while the trailing capsule holds
its identifier-matched items throughout.

```bash
cd example
flutter run                                         # full showcase
flutter run -t lib/demos/nav_bar_patterns_demo.dart # nav patterns
```
