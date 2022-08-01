# Helper Widgets for Making Adaptive Layouts in Flutter (AdaptiveScaffold)

This package contains some helper widgets that make the process of developing adaptive layouts easier, especially with navigational elements.

To see examples of using these helper widgets to make a simple but common adaptive layout:

```bash
cd example/
flutter run --release
```
## AdaptiveScaffold:
AdaptiveScaffold is an abstracted form built upon the aforementioned widgets. It takes a list of destinations and handles all the moving navigational pieces. It still allows for customizability in body/secondaryBody adaptivity. It is much simpler to use but is not the best if you would like high customizability.
### Example Usage:
```dart
AdaptiveScaffold(
 selectedIndex: 0,
 destinations: const [
   NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
   NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
   NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
   NavigationDestination(icon: Icon(Icons.video_call), label: 'Video'),
 ],
 smallBody: (_) => ListView.builder(
   itemCount: allItems.length,
   itemBuilder: (context, index) => Padding(
     padding: const EdgeInsets.all(8.0),
     child: Container(
       height: 250,
       color: const Color.fromARGB(255, 255, 201, 197),
     ),
   ),
 ),
 body: (_) => GridView.count(
   crossAxisCount: 2,
   children: allItems.map((item) => Padding(
     padding: const EdgeInsets.all(8.0),
     child: Container(
       color: const Color.fromARGB(255, 255, 201, 197),
       height: 400,
     ),
   )).toList(),
 ),
),
```
## The Background Widget Suite
These are the set of widgets that are used on a lower level and offer more customizability at a cost of more lines of code.
#### AdaptiveLayout:
AdaptiveLayout is the top-level widget class that arranges the layout of the slots and their animation, similar to Scaffold. It takes in several LayoutSlots and returns an appropriate layout based on the diagram above. [IMAGE]
#### SlotLayout:
SlotLayout handles the adaptivity or the changes between widgets at certain Breakpoints. It also holds the logic for animating between switches. It takes SlotLayoutConfigs mapped to Breakpoints in a config and displays a widget based on that information.
#### SlotLayoutConfig:
SlotLayoutConfig holds the actual widget to be displayed and the entrance animation and exit animation.
### Example Usage:
```dart
AdaptiveLayout(
 primaryNavigation: SlotLayout(
   config: {
     Breakpoints.small: SlotLayoutConfig(key: const Key('pnav'), builder: (_) => const SizedBox.shrink()),
     Breakpoints.medium: SlotLayoutConfig(
       inAnimation: leftOutIn,
       key: const Key('pnav1'),
       builder: (_) => AdaptiveScaffold.toNavigationRail(destinations: destinations),
     ),
     Breakpoints.large: SlotLayoutConfig(
       key: const Key('pnav2'),
       inAnimation: leftOutIn,
       builder: (_) => AdaptiveScaffold.toNavigationRail(extended: true, destinations: destinations),
     ),
   },
 ),
 body: SlotLayout(
   config: {
     Breakpoints.small: SlotLayoutConfig(
       key: const Key('body'),
       builder: (_) => ListView.builder(
         itemCount: allItems.length,
         itemBuilder: (context, index) => Padding(
           padding: const EdgeInsets.all(8.0),
           child: Container(
             color: const Color.fromARGB(255, 255, 201, 197),
             height: 400,
           ),
         ),
       ),
     ),
     Breakpoints.medium: SlotLayoutConfig(
       key: const Key('body1'),
       builder: (_) => GridView.count(
         crossAxisCount: 2,
         children: allItems.map((item) => Padding(
           padding: const EdgeInsets.all(8.0),
           child: Container(
             color: const Color.fromARGB(255, 255, 201, 197),
             height: 400,
           ),
         )).toList(),
       ),
     ),
   },
 ),
 bottomNavigation: SlotLayout(
   config: {
     Breakpoints.small: SlotLayoutConfig(
       key: const Key('botnav'),
       inAnimation: bottomToTop,
       builder: (_) => AdaptiveScaffold.toBottomNavigationBar(destinations: destinations),
     ),
   },
 ),
),
```
##
Both of the examples shown here produce the same output:
[IMAGE]

## Additional information
You can find more information on this package and its usage in the public [design doc](https://docs.google.com/document/d/1qhrpTWYs5f67X8v32NCCNTRMIjSrVHuaMEFAul-Q_Ms/edit?usp=sharing)
