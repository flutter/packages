import 'package:flutter/material.dart';
import 'package:adaptive_helper/adaptive_helper.dart';


// A more functional demo of the usage of the adaptive layout helper widgets.
// Modeled off of the example on the Material 3 page regarding adaptive layouts.
// For a more clear cut example usage, please look at adaptive_layout_demo.dart
// or adaptive_scaffold_demo.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class ContextInformation extends InheritedWidget {
  const ContextInformation({
    Key? key,
    required this.selected,
    required this.displayed,
    required Widget child,
  }) : super(key: key, child: child);

  final int? selected;
  final bool displayed;

  static ContextInformation of(BuildContext context) {
    final ContextInformation? result = context.dependOnInheritedWidgetOfExactType<ContextInformation>();
    assert(result != null, 'No ContextInformation found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ContextInformation oldWidget) => selected != oldWidget.selected || displayed != displayed;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin, ChangeNotifier {
  ValueNotifier showGridView = ValueNotifier(false);

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
    const List<NavigationDestination> destinations = [
      NavigationDestination(label: 'Inbox', icon: Icon(Icons.inbox, color: Colors.black)),
      NavigationDestination(label: 'Articles', icon: Icon(Icons.article_outlined, color: Colors.black)),
      NavigationDestination(label: 'Chat', icon: Icon(Icons.chat_bubble_outline, color: Colors.black)),
      NavigationDestination(label: 'Video', icon: Icon(Icons.video_call_outlined, color: Colors.black)),
    ];
    showGridView.value = Breakpoints.medium.isActive(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 235, 243),
      body: SafeArea(
        child: ContextInformation(
          selected: selected,
          displayed: displayed,
          child: Directionality(
            textDirection: TextDirection.ltr,
            // Adaptive Layout Helper Widgets use starting here:
            child: AdaptiveLayout(
              primaryNavigation: SlotLayout(
                config: {
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
                          child: const ComposeIcon(),
                        ),
                        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                        labelType: NavigationRailLabelType.none,
                        destinations: [
                          NavigationRailDestination(
                              icon: SlideTransition(
                                  position: Tween(begin: const Offset(-1, 0), end: Offset.zero)
                                      .animate(CurvedAnimation(parent: _controller1, curve: Curves.easeInOutCubic)),
                                  child: const Icon(Icons.inbox)),
                              label: const Text('Inbox')),
                          NavigationRailDestination(
                              icon: SlideTransition(
                                  position: Tween(begin: const Offset(-2, 0), end: Offset.zero)
                                      .animate(CurvedAnimation(parent: _controller2, curve: Curves.easeInOutCubic)),
                                  child: const Icon(Icons.article_outlined)),
                              label: const Text('Articles')),
                          NavigationRailDestination(
                              icon: SlideTransition(
                                  position: Tween(begin: const Offset(-3, 0), end: Offset.zero)
                                      .animate(CurvedAnimation(parent: _controller3, curve: Curves.easeInOutCubic)),
                                  child: const Icon(Icons.chat_bubble_outline)),
                              label: const Text('Chat')),
                          NavigationRailDestination(
                              icon: SlideTransition(
                                  position: Tween(begin: const Offset(-4, 0), end: Offset.zero)
                                      .animate(CurvedAnimation(parent: _controller4, curve: Curves.easeInOutCubic)),
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
                      leading: const ComposeButton(),
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
                config: {
                  Breakpoints.small: SlotLayoutConfig(
                    key: const Key('body'),
                    builder: (_) => (_selectedIndex == 0)
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                            child: ItemList(
                              items: allItems,
                              selectCard: selectCard,
                              setDisplayed: setDisplayed,
                              showGridView: false,
                            ),
                          )
                        : const ExamplePage(),
                  ),
                },
              ),
              secondaryBody: _selectedIndex == 0
                  ? SlotLayout(
                      config: {
                        Breakpoints.medium: SlotLayoutConfig(
                          outAnimation: AdaptiveScaffold.stayOnScreen,
                          key: const Key('sb1'),
                          builder: (_) => DetailTile(item: allItems[selected ?? 0]),
                        ),
                        Breakpoints.large: SlotLayoutConfig(
                          outAnimation: AdaptiveScaffold.stayOnScreen,
                          key: const Key('sb1'),
                          builder: (_) => DetailTile(item: allItems[selected ?? 0]),
                        ),
                      },
                    )
                  : null,
              bottomNavigation: SlotLayout(
                config: {
                  Breakpoints.small: SlotLayoutConfig(
                    key: const Key('bn'),
                    inAnimation: AdaptiveScaffold.bottomToTop,
                    outAnimation: AdaptiveScaffold.topToBottom,
                    builder: (_) => AdaptiveScaffold.toBottomNavigationBar(destinations: destinations),
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

class ComposeIcon extends StatelessWidget {
  const ComposeIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 254, 215, 227),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: [
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

class ComposeButton extends StatelessWidget {
  const ComposeButton({
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
          boxShadow: [
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
            children: const [
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

class ItemList extends StatelessWidget {
  const ItemList({
    Key? key,
    required this.items,
    required this.selectCard,
    required this.setDisplayed,
    required this.showGridView,
  }) : super(key: key);

  final List<Item> items;
  final Function selectCard;
  final Function setDisplayed;
  final bool showGridView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      floatingActionButton: Breakpoints.medium.isActive(context) ? null : const ComposeIcon(),
      body: Column(
        children: [
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
                    backgroundImage: NetworkImage(allItems[0].image),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.all(25),
                hintStyle: const TextStyle(color: Color.fromARGB(255, 135, 129, 138)),
                hintText: "Search replies",
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => ItemListTile(
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

class ItemListTile extends StatelessWidget {
  const ItemListTile({
    Key? key,
    required this.item,
    required this.selectCard,
    required this.showGridView,
    required this.setDisplayed,
  }) : super(key: key);

  final Item item;
  final Function selectCard;
  final Function setDisplayed;
  final bool showGridView;

  @override
  Widget build(BuildContext context) {
    final int index = allItems.indexOf(item);
    final bool isSelected = ContextInformation.of(context).selected == index;

    return GestureDetector(
      onTap: (() {
        selectCard(index);
        if (!showGridView) {
          setDisplayed(true);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SafeArea(
                child: RouteDetailView(
                  item: item,
                  selectCard: selectCard,
                  setDisplayed: setDisplayed,
                ),
              ),
            ),
          );
        }
      }),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              color: isSelected ? const Color.fromARGB(255, 237, 221, 255) : const Color.fromARGB(255, 245, 241, 248),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(item.image),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: Theme.of(context).textTheme.bodyText1),
                        const SizedBox(height: 3),
                        Text('${item.time} ago', style: Theme.of(context).textTheme.caption),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration:
                          const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(50))),
                      child: const Icon(Icons.star_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(item.body.replaceRange(80, item.body.length, '...'), style: Theme.of(context).textTheme.bodyText1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetailTile extends StatelessWidget {
  const DetailTile({
    required this.item,
    Key? key,
  }) : super(key: key);
  final Item item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 300,
        child: Container(
          decoration: const BoxDecoration(
              color: Color.fromARGB(255, 245, 241, 248), borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                Text('3 Messages', style: Theme.of(context).textTheme.labelSmall),
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

class RouteDetailView extends StatelessWidget {
  const RouteDetailView({required this.item, required this.selectCard, required this.setDisplayed, super.key});
  final Item item;
  final Function selectCard;
  final Function setDisplayed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
          DetailTile(item: item),
        ],
      ),
    );
  }
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.grey);
  }
}

class Item {
  const Item({
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

const List<Item> allItems = [
  Item(
    name: 'So Duri',
    time: '20 min',
    title: 'Dinner Club',
    body:
        "I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1463453091185-61582044d556?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fHByb2ZpbGUlMjBwaWN0dXJlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=400&q=60',
  ),
  Item(
    name: 'Lily Mac',
    time: '2 hours',
    title: 'This food show is made for you',
    body:
        "3I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1603415526960-f7e0328c63b1?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8cHJvZmlsZSUyMHBpY3R1cmV8ZW58MHx8MHx8&auto=format&fit=crop&w=400&q=60',
  ),
  Item(
    name: 'Lani Mansell',
    time: '10 min',
    title: 'Dinner Club 4',
    body:
        "4I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1629467057571-42d22d8f0cbd?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTN8fHByb2ZpbGUlMjBwaWN0dXJlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=400&q=60',
  ),
  Item(
    name: 'Caitlyn Mars',
    time: '10 min',
    title: 'This food ',
    body:
        "1I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1619895862022-09114b41f16f?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Nnx8cHJvZmlsZSUyMHBpY3R1cmV8ZW58MHx8MHx8&auto=format&fit=crop&w=400&q=60',
  ),
  Item(
    name: 'Robin Goff',
    time: '10 min',
    title: 'Dinner Club 5',
    body:
        "5I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTh8fHByb2ZpbGUlMjBwaWN0dXJlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=400&q=60',
  ),
  Item(
    name: 'Klara Blan',
    time: '10 min',
    title: 'Dinner Club 6',
    body:
        "6I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTh8fHByb2ZpbGUlMjBwaWN0dXJlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=400&q=60',
  ),
  Item(
    name: 'Bianka Bass',
    time: '10 min',
    title: 'Dinner Club 7',
    body:
        "7I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTh8fHByb2ZpbGUlMjBwaWN0dXJlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=400&q=60',
  ),
  Item(
    name: 'Beau Kline',
    time: '10 min',
    title: 'Dinner Club 8',
    body:
        "8I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTh8fHByb2ZpbGUlMjBwaWN0dXJlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=400&q=60',
  ),
  Item(
    name: 'Fran Martin',
    time: '10 min',
    title: 'Dinner Club 9',
    body:
        "9I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. Anyone else have other suggestions for dinner club this week? I'm so intruiged by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
    image:
        'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTh8fHByb2ZpbGUlMjBwaWN0dXJlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=400&q=60',
  ),
];
