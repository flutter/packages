// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_scaffold/adaptive_scaffold.dart';
import 'package:flutter/material.dart';

// A more functional demo of the usage of the adaptive layout helper widgets.
// Modeled off of the example on the Material 3 page regarding adaptive layouts.
// For a more clear cut example usage, please look at adaptive_layout_demo.dart
// or adaptive_scaffold_demo.dart

void main() {
  runApp(const _MyApp());
}

class _MyApp extends StatelessWidget {
  const _MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const _MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class _ContextInformation extends InheritedWidget {
  const _ContextInformation({
    Key? key,
    required this.selected,
    required this.displayed,
    required Widget child,
  }) : super(key: key, child: child);

  final int? selected;
  final bool displayed;

  static _ContextInformation of(BuildContext context) {
    final _ContextInformation? result =
        context.dependOnInheritedWidgetOfExactType<_ContextInformation>();
    assert(result != null, 'No ContextInformation found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_ContextInformation oldWidget) =>
      selected != oldWidget.selected || displayed != displayed;
}

class _MyHomePage extends StatefulWidget {
  const _MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<_MyHomePage> createState() => __MyHomePageState();
}

class __MyHomePageState extends State<_MyHomePage>
    with TickerProviderStateMixin, ChangeNotifier {
  ValueNotifier<bool?> showGridView = ValueNotifier<bool?>(false);

  int? selected;
  void selectCard(int? index) {
    setState(() {
      selected = index;
    });
  }

  bool displayed = false;
  void setDisplayed(bool display) {
    setState(() {
      displayed = display;
    });
  }

  int _selectedIndex = 0;

  late AnimationController _controller;
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late AnimationController _controller4;
  @override
  void initState() {
    showGridView.addListener(() {
      _controller1
        ..reset()
        ..forward();
      _controller2
        ..reset()
        ..forward();
      _controller3
        ..reset()
        ..forward();
      _controller4
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
    _controller4 = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const List<NavigationDestination> destinations = <NavigationDestination>[
      NavigationDestination(
          label: 'Inbox', icon: Icon(Icons.inbox, color: Colors.black)),
      NavigationDestination(
          label: 'Articles',
          icon: Icon(Icons.article_outlined, color: Colors.black)),
      NavigationDestination(
          label: 'Chat',
          icon: Icon(Icons.chat_bubble_outline, color: Colors.black)),
      NavigationDestination(
          label: 'Video',
          icon: Icon(Icons.video_call_outlined, color: Colors.black)),
    ];
    showGridView.value = Breakpoints.medium.isActive(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 235, 243),
      body: SafeArea(
        child: _ContextInformation(
          selected: selected,
          displayed: displayed,
          child: Directionality(
            textDirection: TextDirection.ltr,
            // Adaptive Layout Helper Widgets use starting here:
            child: AdaptiveLayout(
              primaryNavigation: SlotLayout(
                config: <Breakpoint, SlotLayoutConfig?>{
                  Breakpoints.medium: SlotLayoutConfig(
                    key: const Key('primaryNavigation'),
                    builder: (_) => SizedBox(
                      width: 72,
                      height: MediaQuery.of(context).size.height,
                      child: NavigationRail(
                        onDestinationSelected: (int index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        selectedIndex: _selectedIndex,
                        leading: ScaleTransition(
                          scale: _controller1,
                          child: const _ComposeIcon(),
                        ),
                        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                        labelType: NavigationRailLabelType.none,
                        destinations: <NavigationRailDestination>[
                          NavigationRailDestination(
                              icon: SlideTransition(
                                  position: Tween<Offset>(
                                          begin: const Offset(-1, 0),
                                          end: Offset.zero)
                                      .animate(CurvedAnimation(
                                          parent: _controller1,
                                          curve: Curves.easeInOutCubic)),
                                  child: const Icon(Icons.inbox)),
                              label: const Text('Inbox')),
                          NavigationRailDestination(
                              icon: SlideTransition(
                                  position: Tween<Offset>(
                                          begin: const Offset(-2, 0),
                                          end: Offset.zero)
                                      .animate(CurvedAnimation(
                                          parent: _controller2,
                                          curve: Curves.easeInOutCubic)),
                                  child: const Icon(Icons.article_outlined)),
                              label: const Text('Articles')),
                          NavigationRailDestination(
                              icon: SlideTransition(
                                  position: Tween<Offset>(
                                          begin: const Offset(-3, 0),
                                          end: Offset.zero)
                                      .animate(CurvedAnimation(
                                          parent: _controller3,
                                          curve: Curves.easeInOutCubic)),
                                  child: const Icon(Icons.chat_bubble_outline)),
                              label: const Text('Chat')),
                          NavigationRailDestination(
                              icon: SlideTransition(
                                  position: Tween<Offset>(
                                          begin: const Offset(-4, 0),
                                          end: Offset.zero)
                                      .animate(CurvedAnimation(
                                          parent: _controller4,
                                          curve: Curves.easeInOutCubic)),
                                  child: const Icon(Icons.video_call_outlined)),
                              label: const Text('Video')),
                        ],
                      ),
                    ),
                  ),
                  Breakpoints.large: SlotLayoutConfig(
                    key: const Key('primaryNavigation1'),
                    inAnimation: AdaptiveScaffold.leftOutIn,
                    builder: (_) => AdaptiveScaffold.toNavigationRail(
                      leading: const _ComposeButton(),
                      backgroundColor: Colors.transparent,
                      labelType: NavigationRailLabelType.none,
                      selectedIndex: 0,
                      extended: true,
                      destinations: destinations,
                    ),
                  ),
                },
              ),
              body: SlotLayout(
                config: <Breakpoint, SlotLayoutConfig?>{
                  Breakpoints.small: SlotLayoutConfig(
                    key: const Key('body'),
                    builder: (_) => (_selectedIndex == 0)
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                            child: _ItemList(
                              items: _all_Items,
                              selectCard: selectCard,
                              setDisplayed: setDisplayed,
                              showGridView: false,
                            ),
                          )
                        : const _ExamplePage(),
                  ),
                },
              ),
              secondaryBody: _selectedIndex == 0
                  ? SlotLayout(
                      config: <Breakpoint, SlotLayoutConfig?>{
                        Breakpoints.medium: SlotLayoutConfig(
                          outAnimation: AdaptiveScaffold.stayOnScreen,
                          key: const Key('sb1'),
                          builder: (_) =>
                              _DetailTile(item: _all_Items[selected ?? 0]),
                        ),
                        Breakpoints.large: SlotLayoutConfig(
                          outAnimation: AdaptiveScaffold.stayOnScreen,
                          key: const Key('sb1'),
                          builder: (_) =>
                              _DetailTile(item: _all_Items[selected ?? 0]),
                        ),
                      },
                    )
                  : null,
              bottomNavigation: SlotLayout(
                config: <Breakpoint, SlotLayoutConfig?>{
                  Breakpoints.small: SlotLayoutConfig(
                    key: const Key('bn'),
                    outAnimation: AdaptiveScaffold.topToBottom,
                    builder: (_) => AdaptiveScaffold.toBottomNavigationBar(
                        destinations: destinations),
                  ),
                  Breakpoints.medium: SlotLayoutConfig.empty(),
                  Breakpoints.large: SlotLayoutConfig.empty(),
                },
              ),
            ),
          ),
        ),
      ),
    );
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
          color: const Color.fromARGB(255, 255, 225, 231),
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

class _ItemList extends StatelessWidget {
  const _ItemList({
    Key? key,
    required this.items,
    required this.selectCard,
    required this.setDisplayed,
    required this.showGridView,
  }) : super(key: key);

  final List<_Item> items;
  final Function selectCard;
  final Function setDisplayed;
  final bool showGridView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      floatingActionButton:
          Breakpoints.medium.isActive(context) ? null : const _ComposeIcon(),
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
                item: items[index],
                selectCard: selectCard,
                showGridView: showGridView,
                setDisplayed: setDisplayed,
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
    required this.showGridView,
    required this.setDisplayed,
  }) : super(key: key);

  final _Item item;
  final Function selectCard;
  final Function setDisplayed;
  final bool showGridView;

  @override
  Widget build(BuildContext context) {
    final int index = _all_Items.indexOf(item);
    final bool isSelected = _ContextInformation.of(context).selected == index;

    return GestureDetector(
      onTap: () {
        selectCard(index);
        if (!showGridView) {
          setDisplayed(true);
          Navigator.push(
            context,
            MaterialPageRoute<Builder>(
              builder: (_) => SafeArea(
                child: _RouteDetailView(
                  item: item,
                  selectCard: selectCard,
                  setDisplayed: setDisplayed,
                ),
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromARGB(255, 237, 221, 255)
                  : const Color.fromARGB(255, 245, 241, 248),
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
                            style: Theme.of(context).textTheme.bodyText1),
                        const SizedBox(height: 3),
                        Text('${item.time} ago',
                            style: Theme.of(context).textTheme.caption),
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
                    style: Theme.of(context).textTheme.bodyText1),
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
              color: Color.fromARGB(255, 245, 241, 248),
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

class _RouteDetailView extends StatelessWidget {
  const _RouteDetailView(
      {required this.item,
      required this.selectCard,
      required this.setDisplayed,
      Key? key})
      : super(key: key);
  final _Item item;
  final Function selectCard;
  final Function setDisplayed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                selectCard(null);
                setDisplayed(false);
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
