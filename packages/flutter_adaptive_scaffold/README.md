# Adaptive Scaffold

`AdaptiveScaffold` reacts to input from users, devices and screen elements and
renders your Flutter application according to the
[Material 3](https://m3.material.io/foundations/adaptive-design/overview)
guidelines.

To see examples of using these widgets to make a simple but common adaptive
layout:

```bash
cd example/
flutter run --release
```

## AdaptiveScaffold

`AdaptiveScaffold` implements the basic visual layout structure for Material
Design 3 that adapts to a variety of screens. It provides a preset of layout,
including positions and animations, by handling macro changes in navigational
elements and bodies based on the current features of the screen, namely screen
width and platform. For example, the navigational elements would be a
`BottomNavigationBar` on a small mobile device and a `NavigationRail` on larger
devices. The body is the primary screen that takes up the space left by the
navigational elements. The secondaryBody acts as an option to split the space
between two panes for purposes such as having a detail view. There is some
automatic functionality with foldables to handle the split between panels
properly. `AdaptiveScaffold` is much simpler to use but is not the best if you
would like high customizability. Apps that would like more refined layout and/or
animation should use `AdaptiveLayout`.

### Example Usage

<?code-excerpt "example/lib/adaptive_scaffold_demo.dart (Example)"?>
```dart
@override
Widget build(BuildContext context) {
  // Define the children to display within the body at different breakpoints.
  final List<Widget> children = <Widget>[
    for (int i = 0; i < 10; i++)
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: const Color.fromARGB(255, 255, 201, 197),
          height: 400,
        ),
      )
  ];
  return AdaptiveScaffold(
    // An option to override the default transition duration.
    transitionDuration: Duration(milliseconds: _transitionDuration),
    // An option to override the default breakpoints used for small, medium,
    // mediumLarge, large, and extraLarge.
    smallBreakpoint: const Breakpoint(endWidth: 700),
    mediumBreakpoint: const Breakpoint(beginWidth: 700, endWidth: 1000),
    mediumLargeBreakpoint: const Breakpoint(beginWidth: 1000, endWidth: 1200),
    largeBreakpoint: const Breakpoint(beginWidth: 1200, endWidth: 1600),
    extraLargeBreakpoint: const Breakpoint(beginWidth: 1600),
    useDrawer: false,
    selectedIndex: _selectedTab,
    onSelectedIndexChange: (int index) {
      setState(() {
        _selectedTab = index;
      });
    },
    destinations: const <NavigationDestination>[
      NavigationDestination(
        icon: Icon(Icons.inbox_outlined),
        selectedIcon: Icon(Icons.inbox),
        label: 'Inbox',
      ),
      NavigationDestination(
        icon: Icon(Icons.article_outlined),
        selectedIcon: Icon(Icons.article),
        label: 'Articles',
      ),
      NavigationDestination(
        icon: Icon(Icons.chat_outlined),
        selectedIcon: Icon(Icons.chat),
        label: 'Chat',
      ),
      NavigationDestination(
        icon: Icon(Icons.video_call_outlined),
        selectedIcon: Icon(Icons.video_call),
        label: 'Video',
      ),
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Inbox',
      ),
    ],
    smallBody: (_) => ListView.builder(
      itemCount: children.length,
      itemBuilder: (_, int idx) => children[idx],
    ),
    body: (_) => GridView.count(crossAxisCount: 2, children: children),
    mediumLargeBody: (_) =>
        GridView.count(crossAxisCount: 3, children: children),
    largeBody: (_) => GridView.count(crossAxisCount: 4, children: children),
    extraLargeBody: (_) =>
        GridView.count(crossAxisCount: 5, children: children),
    // Define a default secondaryBody.
    // Override the default secondaryBody during the smallBreakpoint to be
    // empty. Must use AdaptiveScaffold.emptyBuilder to ensure it is properly
    // overridden.
    smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
    secondaryBody: (_) => Container(
      color: const Color.fromARGB(255, 234, 158, 192),
    ),
    mediumLargeSecondaryBody: (_) => Container(
      color: const Color.fromARGB(255, 234, 158, 192),
    ),
    largeSecondaryBody: (_) => Container(
      color: const Color.fromARGB(255, 234, 158, 192),
    ),
    extraLargeSecondaryBody: (_) => Container(
      color: const Color.fromARGB(255, 234, 158, 192),
    ),
  );
}
```

## The Background Widget Suite

These are the set of widgets that are used on a lower level and offer more
customizability at a cost of more lines of code.

### Breakpoint

A `Breakpoint` controls the responsive behavior at different screens and configurations.

You can either use a predefined Material3 breakpoint or create your own.

<?code-excerpt "lib/src/breakpoints.dart (Breakpoints)"?>
```dart
/// Returns a const [Breakpoint] with the given constraints.
const Breakpoint({
  this.beginWidth,
  this.endWidth,
  this.beginHeight,
  this.endHeight,
  this.andUp = false,
  this.platform,
  this.spacing = kMaterialMediumAndUpSpacing,
  this.margin = kMaterialMediumAndUpMargin,
  this.padding = kMaterialPadding,
  this.recommendedPanes = 1,
  this.maxPanes = 1,
});

/// Returns a [Breakpoint] that can be used as a fallthrough in the
/// case that no other breakpoint is active.
const Breakpoint.standard({this.platform})
    : beginWidth = -1,
      endWidth = null,
      beginHeight = null,
      endHeight = null,
      spacing = kMaterialMediumAndUpSpacing,
      margin = kMaterialMediumAndUpMargin,
      padding = kMaterialPadding,
      recommendedPanes = 1,
      maxPanes = 1,
      andUp = true;

/// Returns a [Breakpoint] with the given constraints for a small screen.
const Breakpoint.small({this.andUp = false, this.platform})
    : beginWidth = 0,
      endWidth = 600,
      beginHeight = null,
      endHeight = 480,
      spacing = kMaterialCompactSpacing,
      margin = kMaterialCompactMargin,
      padding = kMaterialPadding,
      recommendedPanes = 1,
      maxPanes = 1;

/// Returns a [Breakpoint] with the given constraints for a medium screen.
const Breakpoint.medium({this.andUp = false, this.platform})
    : beginWidth = 600,
      endWidth = 840,
      beginHeight = 480,
      endHeight = 900,
      spacing = kMaterialMediumAndUpSpacing,
      margin = kMaterialMediumAndUpMargin,
      padding = kMaterialPadding * 2,
      recommendedPanes = 1,
      maxPanes = 2;

/// Returns a [Breakpoint] with the given constraints for a mediumLarge screen.
const Breakpoint.mediumLarge({this.andUp = false, this.platform})
    : beginWidth = 840,
      endWidth = 1200,
      beginHeight = 900,
      endHeight = null,
      spacing = kMaterialMediumAndUpSpacing,
      margin = kMaterialMediumAndUpMargin,
      padding = kMaterialPadding * 3,
      recommendedPanes = 2,
      maxPanes = 2;

/// Returns a [Breakpoint] with the given constraints for a large screen.
const Breakpoint.large({this.andUp = false, this.platform})
    : beginWidth = 1200,
      endWidth = 1600,
      beginHeight = 900,
      endHeight = null,
      spacing = kMaterialMediumAndUpSpacing,
      margin = kMaterialMediumAndUpMargin,
      padding = kMaterialPadding * 4,
      recommendedPanes = 2,
      maxPanes = 2;

/// Returns a [Breakpoint] with the given constraints for an extraLarge screen.
const Breakpoint.extraLarge({this.andUp = false, this.platform})
    : beginWidth = 1600,
      endWidth = null,
      beginHeight = 900,
      endHeight = null,
      spacing = kMaterialMediumAndUpSpacing,
      margin = kMaterialMediumAndUpMargin,
      padding = kMaterialPadding * 5,
      recommendedPanes = 2,
      maxPanes = 3;
```

It is possible to compare Breakpoints:

<?code-excerpt "lib/src/breakpoints.dart (Breakpoint operators)"?>
```dart
/// Returns true if this [Breakpoint] is greater than the given [Breakpoint].
bool operator >(Breakpoint breakpoint)
// ···
/// Returns true if this [Breakpoint] is less than the given [Breakpoint].
bool operator <(Breakpoint breakpoint)
// ···
/// Returns true if this [Breakpoint] is greater than or equal to the
/// given [Breakpoint].
bool operator >=(Breakpoint breakpoint)
// ···
/// Returns true if this [Breakpoint] is less than or equal to the
/// given [Breakpoint].
bool operator <=(Breakpoint breakpoint)
// ···
/// Returns true if this [Breakpoint] is between the given [Breakpoint]s.
bool between(Breakpoint lower, Breakpoint upper)
```

### AdaptiveLayout

!["AdaptiveLayout's Assigned Slots Displayed on Screen"](example/demo_files/screenSlots.png)
`AdaptiveLayout` is the top-level widget class that arranges the layout of the
slots and their animation, similar to Scaffold. It takes in several LayoutSlots
and returns an appropriate layout based on the diagram above. `AdaptiveScaffold`
is built upon `AdaptiveLayout` internally but abstracts some of the complexity
with presets based on the Material 3 Design specification.

### SlotLayout

`SlotLayout` handles the adaptivity or the changes between widgets at certain
`Breakpoints`. It also holds the logic for animating between breakpoints. It takes
SlotLayoutConfigs mapped to Breakpoints in a config and displays a widget based
on that information.

### SlotLayout.from

SlotLayout.from creates a SlotLayoutConfig holds the actual widget to be
displayed and the entrance animation and exit animation.

### Example Usage

<?code-excerpt "example/lib/adaptive_layout_demo.dart (Example)"?>
```dart
// AdaptiveLayout has a number of slots that take SlotLayouts and these
// SlotLayouts' configs take maps of Breakpoints to SlotLayoutConfigs.
return AdaptiveLayout(
  // An option to override the default transition duration.
  transitionDuration: Duration(milliseconds: _transitionDuration),
  // Primary navigation config has nothing from 0 to 600 dp screen width,
  // then an unextended NavigationRail with no labels and just icons then an
  // extended NavigationRail with both icons and labels.
  primaryNavigation: SlotLayout(
    config: <Breakpoint, SlotLayoutConfig>{
      Breakpoints.medium: SlotLayout.from(
        inAnimation: AdaptiveScaffold.leftOutIn,
        key: const Key('Primary Navigation Medium'),
        builder: (_) => AdaptiveScaffold.standardNavigationRail(
          selectedIndex: selectedNavigation,
          onDestinationSelected: (int newIndex) {
            setState(() {
              selectedNavigation = newIndex;
            });
          },
          leading: const Icon(Icons.menu),
          destinations: destinations
              .map((NavigationDestination destination) =>
                  AdaptiveScaffold.toRailDestination(destination))
              .toList(),
          backgroundColor: navRailTheme.backgroundColor,
          selectedIconTheme: navRailTheme.selectedIconTheme,
          unselectedIconTheme: navRailTheme.unselectedIconTheme,
          selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
          unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
        ),
      ),
      Breakpoints.mediumLarge: SlotLayout.from(
        key: const Key('Primary Navigation MediumLarge'),
        inAnimation: AdaptiveScaffold.leftOutIn,
        builder: (_) => AdaptiveScaffold.standardNavigationRail(
          selectedIndex: selectedNavigation,
          onDestinationSelected: (int newIndex) {
            setState(() {
              selectedNavigation = newIndex;
            });
          },
          extended: true,
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                'REPLY',
                style: headerColor,
              ),
              const Icon(Icons.menu_open)
            ],
          ),
          destinations: destinations
              .map((NavigationDestination destination) =>
                  AdaptiveScaffold.toRailDestination(destination))
              .toList(),
          trailing: trailingNavRail,
          backgroundColor: navRailTheme.backgroundColor,
          selectedIconTheme: navRailTheme.selectedIconTheme,
          unselectedIconTheme: navRailTheme.unselectedIconTheme,
          selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
          unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
        ),
      ),
      Breakpoints.large: SlotLayout.from(
        key: const Key('Primary Navigation Large'),
        inAnimation: AdaptiveScaffold.leftOutIn,
        builder: (_) => AdaptiveScaffold.standardNavigationRail(
          selectedIndex: selectedNavigation,
          onDestinationSelected: (int newIndex) {
            setState(() {
              selectedNavigation = newIndex;
            });
          },
          extended: true,
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                'REPLY',
                style: headerColor,
              ),
              const Icon(Icons.menu_open)
            ],
          ),
          destinations: destinations
              .map((NavigationDestination destination) =>
                  AdaptiveScaffold.toRailDestination(destination))
              .toList(),
          trailing: trailingNavRail,
          backgroundColor: navRailTheme.backgroundColor,
          selectedIconTheme: navRailTheme.selectedIconTheme,
          unselectedIconTheme: navRailTheme.unselectedIconTheme,
          selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
          unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
        ),
      ),
      Breakpoints.extraLarge: SlotLayout.from(
        key: const Key('Primary Navigation ExtraLarge'),
        inAnimation: AdaptiveScaffold.leftOutIn,
        builder: (_) => AdaptiveScaffold.standardNavigationRail(
          selectedIndex: selectedNavigation,
          onDestinationSelected: (int newIndex) {
            setState(() {
              selectedNavigation = newIndex;
            });
          },
          extended: true,
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                'REPLY',
                style: headerColor,
              ),
              const Icon(Icons.menu_open)
            ],
          ),
          destinations: destinations
              .map((NavigationDestination destination) =>
                  AdaptiveScaffold.toRailDestination(destination))
              .toList(),
          trailing: trailingNavRail,
          backgroundColor: navRailTheme.backgroundColor,
          selectedIconTheme: navRailTheme.selectedIconTheme,
          unselectedIconTheme: navRailTheme.unselectedIconTheme,
          selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
          unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
        ),
      ),
    },
  ),
  // Body switches between a ListView and a GridView from small to medium
  // breakpoints and onwards.
  body: SlotLayout(
    config: <Breakpoint, SlotLayoutConfig>{
      Breakpoints.small: SlotLayout.from(
        key: const Key('Body Small'),
        builder: (_) => ListView.builder(
          itemCount: children.length,
          itemBuilder: (BuildContext context, int index) => children[index],
        ),
      ),
      Breakpoints.medium: SlotLayout.from(
        key: const Key('Body Medium'),
        builder: (_) =>
            GridView.count(crossAxisCount: 2, children: children),
      ),
      Breakpoints.mediumLarge: SlotLayout.from(
        key: const Key('Body MediumLarge'),
        builder: (_) =>
            GridView.count(crossAxisCount: 3, children: children),
      ),
      Breakpoints.large: SlotLayout.from(
        key: const Key('Body Large'),
        builder: (_) =>
            GridView.count(crossAxisCount: 4, children: children),
      ),
      Breakpoints.extraLarge: SlotLayout.from(
        key: const Key('Body ExtraLarge'),
        builder: (_) =>
            GridView.count(crossAxisCount: 5, children: children),
      ),
    },
  ),
  // BottomNavigation is only active in small views defined as under 600 dp
  // width.
  bottomNavigation: SlotLayout(
    config: <Breakpoint, SlotLayoutConfig>{
      Breakpoints.small: SlotLayout.from(
        key: const Key('Bottom Navigation Small'),
        inAnimation: AdaptiveScaffold.bottomToTop,
        outAnimation: AdaptiveScaffold.topToBottom,
        builder: (_) => AdaptiveScaffold.standardBottomNavigationBar(
          destinations: destinations,
          currentIndex: selectedNavigation,
          onDestinationSelected: (int newIndex) {
            setState(() {
              selectedNavigation = newIndex;
            });
          },
        ),
      )
    },
  ),
);
```

Both of the examples shown here produce the same output:
!["Example of a display made with AdaptiveScaffold"](example/demo_files/adaptiveScaffold.gif)
