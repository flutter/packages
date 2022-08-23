// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_scaffold/adaptive_scaffold.dart';
import 'package:flutter/material.dart';

/// A more functional demo of the usage of the adaptive layout helper widgets.
/// Specifically, it is built using an [AdaptiveLayout] and uses static helpers
/// from [AdaptiveScaffold].
///
/// Modeled off of the example on the Material 3 page regarding adaptive layouts.
/// For a more clear cut example usage, please look at adaptive_layout_demo.dart
/// or adaptive_scaffold_demo.dart

void main() {
  runApp(const _MyApp());
}

class _MyApp extends StatelessWidget {
  const _MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Layout Demo',
      routes: <String, Widget Function(BuildContext)>{
        _ExtractRouteArguments.routeName: (_) => const _ExtractRouteArguments()
      },
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(),
    );
  }
}

/// Creates an example mail page using [AdaptiveLayout].
class MyHomePage extends StatefulWidget {
  /// Creates a const [MyHomePage].
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin, ChangeNotifier {
  // A listener used for the controllers to reanimate the staggered animation of
  // the navigation elements.
  ValueNotifier<bool?> showGridView = ValueNotifier<bool?>(false);

  // The index of the selected mail card.
  int? selected;
  void selectCard(int? index) {
    setState(() {
      selected = index;
    });
  }

  // The index of the navigation screen. Only impacts body/secondaryBody
  int _navigationIndex = 0;

  // The controllers used for the staggered animation of the navigation elements.
  late AnimationController _controller;
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  @override
  void initState() {
    showGridView.addListener(() {
      Navigator.popUntil(
          context, (Route<dynamic> route) => route.settings.name == '/');
      _controller
        ..reset()
        ..forward();
      _controller1
        ..reset()
        ..forward();
      _controller2
        ..reset()
        ..forward();
      _controller3
        ..reset()
        ..forward();
    });
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..forward();
    _controller3 = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color iconColor = Color.fromARGB(255, 29, 25, 43);

    // These are the destinations used within the AdaptiveScaffold navigation
    // builders.
    const List<NavigationDestination> destinations = <NavigationDestination>[
      NavigationDestination(
          label: 'Inbox', icon: Icon(Icons.inbox, color: iconColor)),
      NavigationDestination(
          label: 'Articles',
          icon: Icon(Icons.article_outlined, color: iconColor)),
      NavigationDestination(
          label: 'Chat',
          icon: Icon(Icons.chat_bubble_outline, color: iconColor)),
      NavigationDestination(
          label: 'Video',
          icon: Icon(Icons.video_call_outlined, color: iconColor)),
    ];

    // Updating the listener value.
    showGridView.value = Breakpoints.mediumAndUp.isActive(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 227, 241),
      // Usage of AdaptiveLayout suite begins here. AdaptiveLayout takes
      // LayoutSlots for its variety of screen slots.
      body: AdaptiveLayout(
        // Each SlotLayout has a config which maps Breakpoints to
        // SlotLayoutConfigs.
        primaryNavigation: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig?>{
            // The breakpoint used here is from the Breakpoints class but custom
            // Breakpoints can be defined by extending the Breakpoint class
            Breakpoints.medium: SlotLayout.from(
              // Every SlotLayoutConfig takes a key and a builder. The builder
              // is to save memory that would be spent on initialization.
              key: const Key('primaryNavigation'),
              builder: (_) => SizedBox(
                width: 72,
                height: MediaQuery.of(context).size.height,
                // Usually it would be easier to use a builder from
                // AdaptiveScaffold for these types of navigations but this
                // navigation has custom staggered item animations.
                child: NavigationRail(
                  onDestinationSelected: (int index) {
                    setState(() {
                      _navigationIndex = index;
                    });
                  },
                  selectedIndex: _navigationIndex,
                  leading: ScaleTransition(
                    scale: _controller1,
                    child: const _ComposeIcon(),
                  ),
                  backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                  labelType: NavigationRailLabelType.none,
                  destinations: <NavigationRailDestination>[
                    slideInNavigationItem(
                      begin: -1,
                      controller: _controller,
                      icon: Icons.inbox,
                      label: 'Inbox',
                    ),
                    slideInNavigationItem(
                      begin: -2,
                      controller: _controller1,
                      icon: Icons.article_outlined,
                      label: 'Articles',
                    ),
                    slideInNavigationItem(
                      begin: -3,
                      controller: _controller2,
                      icon: Icons.chat_bubble_outline,
                      label: 'Chat',
                    ),
                    slideInNavigationItem(
                      begin: -4,
                      controller: _controller3,
                      icon: Icons.video_call_outlined,
                      label: 'Video',
                    )
                  ],
                ),
              ),
            ),
            Breakpoints.large: SlotLayout.from(
              key: const Key('primaryNavigation1'),
              // The AdaptiveScaffold builder here greatly simplifies
              // navigational elements.
              builder: (_) => AdaptiveScaffold.toNavigationRail(
                leading: const _ComposeButton(),
                onDestinationSelected: (int index) {
                  setState(() {
                    _navigationIndex = index;
                  });
                },
                selectedIndex: _navigationIndex,
                extended: true,
                destinations: destinations,
              ),
            ),
          },
        ),
        body: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig?>{
            Breakpoints.standard: SlotLayout.from(
              key: const Key('body'),
              // The conditional here is for navigation screens. The first
              // screen shows the main screen and every other screeen shows
              //  ExamplePage.
              builder: (_) => (_navigationIndex == 0)
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                      child: _ItemList(
                        selected: selected,
                        items: _all_Items,
                        selectCard: selectCard,
                      ),
                    )
                  : const _ExamplePage(),
            ),
          },
        ),
        secondaryBody: _navigationIndex == 0
            ? SlotLayout(
                config: <Breakpoint, SlotLayoutConfig?>{
                  Breakpoints.mediumAndUp: SlotLayout.from(
                    // This overrides the default behavior of the secondaryBody
                    // disappearing as it is animating out.
                    outAnimation: AdaptiveScaffold.stayOnScreen,
                    key: const Key('sBody'),
                    builder: (_) =>
                        _DetailTile(item: _all_Items[selected ?? 0]),
                  ),
                },
              )
            : null,
        bottomNavigation: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig?>{
            Breakpoints.small: SlotLayout.from(
              key: const Key('bottomNavigation'),
              // You can define inAnimations or outAnimations to override the
              // default offset transition.
              outAnimation: AdaptiveScaffold.topToBottom,
              builder: (_) => BottomNavigationBarTheme(
                data: const BottomNavigationBarThemeData(
                  unselectedItemColor: Colors.black,
                  selectedItemColor: Colors.black,
                ),
                child: AdaptiveScaffold.toBottomNavigationBar(
                    destinations: destinations),
              ),
            ),
          },
        ),
      ),
    );
  }

  NavigationRailDestination slideInNavigationItem({
    required double begin,
    required AnimationController controller,
    required IconData icon,
    required String label,
  }) {
    return NavigationRailDestination(
        icon: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(begin, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic),
            ),
            child: Icon(icon)),
        label: Text(label));
  }
}

class _ComposeIcon extends StatelessWidget {
  const _ComposeIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 254, 215, 227),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      width: 50,
      height: 50,
      child: const Icon(Icons.edit_outlined),
    );
  }
}

class _ComposeButton extends StatelessWidget {
  const _ComposeButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 216, 228),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          boxShadow: Breakpoints.mediumAndUp.isActive(context)
              ? null
              : <BoxShadow>[
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        width: 200,
        height: 50,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
          child: Row(
            children: const <Widget>[
              Icon(Icons.edit_outlined),
              SizedBox(width: 20),
              Center(child: Text('Compose')),
            ],
          ),
        ),
      ),
    );
  }
}

// ItemList creates the list of cards and the search bar.
class _ItemList extends StatelessWidget {
  const _ItemList({
    Key? key,
    required this.items,
    required this.selectCard,
    required this.selected,
  }) : super(key: key);

  final List<_Item> items;
  final int? selected;
  final Function selectCard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      floatingActionButton: Breakpoints.mediumAndUp.isActive(context)
          ? null
          : const _ComposeIcon(),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Icon(Icons.search),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(_all_Items[0].image),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.all(25),
                hintStyle:
                    const TextStyle(color: Color.fromARGB(255, 135, 129, 138)),
                hintText: 'Search replies',
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, int index) => _ItemListTile(
                selected: selected,
                item: items[index],
                selectCard: selectCard,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemListTile extends StatelessWidget {
  const _ItemListTile({
    Key? key,
    required this.item,
    required this.selectCard,
    required this.selected,
  }) : super(key: key);

  final _Item item;
  final int? selected;
  final Function selectCard;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // The behavior of opening a detail view is different on small screens
        // than large screens.
        // Small screens open a modal with the detail view while large screens
        // simply show the details on the secondaryBody.
        selectCard(_all_Items.indexOf(item));
        if (!Breakpoints.mediumAndUp.isActive(context)) {
          Navigator.of(context).pushNamed(
            _ExtractRouteArguments.routeName,
            arguments: _ScreenArguments(item: item, selectCard: selectCard),
          );
        } else {
          selectCard(_all_Items.indexOf(item));
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              color: selected == _all_Items.indexOf(item)
                  ? const Color.fromARGB(255, 234, 222, 255)
                  : const Color.fromARGB(255, 243, 237, 247),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(item.image),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(item.name,
                            style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 3),
                        Text('${item.time} ago',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      child: const Icon(Icons.star_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(item.title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(item.body.replaceRange(80, item.body.length, '...'),
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.item,
    Key? key,
  }) : super(key: key);
  final _Item item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 300,
        child: Container(
          decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 251, 254),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                Text('3 Messages',
                    style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(
                  height: 20,
                ),
                Text(item.body, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// The ScreenArguments used to pass arguments to the RouteDetailView as a named
// route.
class _ScreenArguments {
  _ScreenArguments({
    required this.item,
    required this.selectCard,
  });
  final _Item item;
  final Function selectCard;
}

class _ExtractRouteArguments extends StatelessWidget {
  const _ExtractRouteArguments({Key? key}) : super(key: key);

  static const String routeName = '/detailView';

  @override
  Widget build(BuildContext context) {
    final _ScreenArguments args =
        ModalRoute.of(context)!.settings.arguments! as _ScreenArguments;

    return _RouteDetailView(item: args.item, selectCard: args.selectCard);
  }
}

class _RouteDetailView extends StatelessWidget {
  const _RouteDetailView({
    required this.item,
    required this.selectCard,
    Key? key,
  }) : super(key: key);

  final _Item item;
  final Function selectCard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: TextButton(
              onPressed: () {
                Navigator.popUntil(context,
                    (Route<dynamic> route) => route.settings.name == '/');
                selectCard(null);
              },
              child: const Icon(Icons.arrow_back),
            ),
          ),
          _DetailTile(item: item),
        ],
      ),
    );
  }
}

class _ExamplePage extends StatelessWidget {
  const _ExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.grey);
  }
}

class _Item {
  const _Item({
    required this.name,
    required this.time,
    required this.title,
    required this.body,
    required this.image,
  });

  final String name;
  final String time;
  final String title;
  final String body;
  final String image;
}

const List<_Item> _all_Items = <_Item>[
  _Item(
    name: 'So Duri',
    time: '20 min',
    title: 'Dinner Club',
    body:
        "I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1463453091185-61582044d556?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fHByb2ZpbGUlMjBwaWN0dXJlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=400&q=60',
  ),
  _Item(
    name: 'Lily Mac',
    time: '2 hours',
    title: 'This food show is made for you',
    body:
        "3I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1603415526960-f7e0328c63b1?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8cHJvZmlsZSUyMHBpY3R1cmV8ZW58MHx8MHx8&auto=format&fit=crop&w=400&q=60',
  ),
  _Item(
    name: 'Lani Mansell',
    time: '10 min',
    title: 'Dinner Club 4',
    body:
        "4I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1629467057571-42d22d8f0cbd?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTN8fHByb2ZpbGUlMjBwaWN0dXJlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=400&q=60',
  ),
  _Item(
    name: 'Caitlyn Mars',
    time: '10 min',
    title: 'This food ',
    body:
        "1I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1619895862022-09114b41f16f?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Nnx8cHJvZmlsZSUyMHBpY3R1cmV8ZW58MHx8MHx8&auto=format&fit=crop&w=400&q=60',
  ),
  _Item(
    name: 'Robin Goff',
    time: '10 min',
    title: 'Dinner Club 5',
    body:
        "5I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTh8fHByb2ZpbGUlMjBwaWN0dXJlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=400&q=60',
  ),
  _Item(
    name: 'Klara Blan',
    time: '10 min',
    title: 'Dinner Club 6',
    body:
        "6I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTh8fHByb2ZpbGUlMjBwaWN0dXJlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=400&q=60',
  ),
  _Item(
    name: 'Bianka Bass',
    time: '10 min',
    title: 'Dinner Club 7',
    body:
        "7I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTh8fHByb2ZpbGUlMjBwaWN0dXJlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=400&q=60',
  ),
  _Item(
    name: 'Beau Kline',
    time: '10 min',
    title: 'Dinner Club 8',
    body:
        "8I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTh8fHByb2ZpbGUlMjBwaWN0dXJlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=400&q=60',
  ),
  _Item(
    name: 'Fran Martin',
    time: '10 min',
    title: 'Dinner Club 9',
    body:
        "9I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTh8fHByb2ZpbGUlMjBwaWN0dXJlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=400&q=60',
  ),
];
