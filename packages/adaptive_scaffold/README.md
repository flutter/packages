# Helper Widgets for Making Adaptive Layouts in Flutter (AdaptiveScaffold)

This package contains some helper widgets that make the process of developing adaptive layouts easier, especially with navigational elements.

To see examples of using these helper widgets to make a simple but common adaptive layout:

```bash
cd example/
flutter run --release
```
## AdaptiveScaffold:
AdaptiveScaffold implements the basic visual layout structure for Material Design 3 that adapts to a variety of screens. It provides a preset of layout, including positions and animations, by handling macro changes in navigational elements and bodies based on the current features of the screen, namely screen width and platform. For example, the navigational elements would be a BottomNavigationBar on a small mobile device and a NavigationRail on larger devices. The body is the primary screen that takes up the space left by the navigational elements. The secondaryBody acts as an option to split the space between two panes for purposes such as having a detail view. There is some automatic functionality with foldables to handle the split between panels properly. AdaptiveScaffold is much simpler to use but is not the best if you would like high customizability. Apps that would like more refined layout and/or animation should use AdaptiveLayout.
### Example Usage:

<?code-excerpt ...>
```dart
 AdaptiveScaffold(
  destinations: const [
    NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
    NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
    NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
    NavigationDestination(icon: Icon(Icons.video_call), label: 'Video'),
  ],
  smallBody: (_) => ListView.builder(
    itemCount: children.length,
    itemBuilder: (_, idx) => children[idx]
  ),
  body: (_) => GridView.count(crossAxisCount: 2, children: children),
 )
```
## The Background Widget Suite
These are the set of widgets that are used on a lower level and offer more customizability at a cost of more lines of code.
#### AdaptiveLayout:
!["AdaptiveLayout's Assigned Slots Displayed on Screen"](example/demo_files/screenSlots.png)
AdaptiveLayout is the top-level widget class that arranges the layout of the slots and their animation, similar to Scaffold. It takes in several LayoutSlots and returns an appropriate layout based on the diagram above. AdaptiveScaffold is built upon AdaptiveLayout internally but abstracts some of the complexity with presets based on the Material 3 Design specification.
#### SlotLayout:
SlotLayout handles the adaptivity or the changes between widgets at certain Breakpoints. It also holds the logic for animating between breakpoints. It takes SlotLayoutConfigs mapped to Breakpoints in a config and displays a widget based on that information.
#### SlotLayout.from:
SlotLayout.from creates a SlotLayoutConfig holds the actual widget to be displayed and the entrance animation and exit animation.
### Example Usage:

<?code-excerpt ...>
```dart
AdaptiveLayout(
 primaryNavigation: SlotLayout(
   config: {
     Breakpoints.small: SlotLayout.from(key: const Key('pnav'), builder: (_) => const SizedBox.shrink()),
     Breakpoints.medium: SlotLayout.from(
       inAnimation: leftOutIn,
       key: const Key('pnav1'),
       builder: (_) => AdaptiveScaffold.toNavigationRail(destinations: destinations),
     ),
     Breakpoints.large: SlotLayout.from(
       key: const Key('pnav2'),
       inAnimation: leftOutIn,
       builder: (_) => AdaptiveScaffold.toNavigationRail(extended: true, destinations: destinations),
     ),
   },
 ),
 body: SlotLayout(
   config: {
     Breakpoints.small: SlotLayout.from(
       key: const Key('body'),
       builder: (_) => ListView.builder(
         itemCount: children.length,
         itemBuilder: (_, idx) => children[idx]
       ),
     ),
     Breakpoints.medium: SlotLayout.from(
       key: const Key('body1'),
       builder: (_) => GridView.count(
         crossAxisCount: 2,
         children: children
       ),
     ),
   },
 ),
 bottomNavigation: SlotLayout(
   config: {
     Breakpoints.small: SlotLayout.from(
       key: const Key('botnav'),
       inAnimation: bottomToTop,
       builder: (_) => AdaptiveScaffold.toBottomNavigationBar(destinations: destinations),
     ),
   },
 ),
)
```
##
Both of the examples shown here produce the same output:
!["Example of a display made with AdaptiveScaffold"](example/demo_files/adaptiveScaffold.gif)

## Additional information
You can find more information on this package and its usage in the public [design doc](https://docs.google.com/document/d/1qhrpTWYs5f67X8v32NCCNTRMIjSrVHuaMEFAul-Q_Ms/edit?usp=sharing)
