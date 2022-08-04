import 'package:flutter/material.dart';
import 'package:adaptive_scaffold/adaptive_helper.dart';

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
    final ContextInformation? result =
        context.dependOnInheritedWidgetOfExactType<ContextInformation>();
    assert(result != null, 'No ContextInformation found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ContextInformation oldWidget) =>
      selected != oldWidget.selected || displayed != displayed;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin, ChangeNotifier {
  ValueNotifier showGridView = ValueNotifier<bool>(false);

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
    Widget trailingNavRail = Column(
      children: [
        const Divider(
          color: Colors.white,
          thickness: 1.5,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const SizedBox(
              width: 22,
            ),
            Text(
              "Folders",
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ),
        const SizedBox(
          height: 22,
        ),
        Row(
          children: [
            const SizedBox(
              width: 16,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.folder_copy_outlined),
              iconSize: 21,
            ),
            const SizedBox(
              width: 21,
            ),
            const Text("Freelance"),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Row(
          children: [
            const SizedBox(
              width: 16,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.folder_copy_outlined),
              iconSize: 21,
            ),
            const SizedBox(
              width: 21,
            ),
            const Text("Mortage"),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Row(
          children: [
            const SizedBox(
              width: 16,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.folder_copy_outlined),
              iconSize: 21,
            ),
            const SizedBox(
              width: 21,
            ),
            const Flexible(
                child: Text(
              "Taxes",
              overflow: TextOverflow.ellipsis,
            )),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Row(
          children: [
            const SizedBox(
              width: 16,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.folder_copy_outlined),
              iconSize: 21,
            ),
            const SizedBox(
              width: 21,
            ),
            const Flexible(
                child: Text(
              "Receipts",
              overflow: TextOverflow.ellipsis,
            )),
          ],
        ),
      ],
    );

    const List<NavigationDestination> destinations = [
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

    List<NavigationDestination> destinations2 = [
      NavigationDestination(
          icon: SlideTransition(
              position: Tween(begin: const Offset(-1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(
                      parent: _controller1, curve: Curves.easeInOutCubic)),
              child: const Icon(
                Icons.inbox,
              )),
          label: 'Inbox'),
      NavigationDestination(
          icon: SlideTransition(
              position: Tween(begin: const Offset(-2, 0), end: Offset.zero)
                  .animate(CurvedAnimation(
                      parent: _controller2, curve: Curves.easeInOutCubic)),
              child: const Icon(Icons.article_outlined)),
          label: 'Articles'),
      NavigationDestination(
          icon: SlideTransition(
              position: Tween(begin: const Offset(-3, 0), end: Offset.zero)
                  .animate(CurvedAnimation(
                      parent: _controller3, curve: Curves.easeInOutCubic)),
              child: const Icon(Icons.chat_bubble_outline)),
          label: 'Chat'),
      NavigationDestination(
          icon: SlideTransition(
              position: Tween(begin: const Offset(-4, 0), end: Offset.zero)
                  .animate(CurvedAnimation(
                      parent: _controller4, curve: Curves.easeInOutCubic)),
              child: const Icon(Icons.video_call_outlined)),
          label: 'Video'),
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
                      builder: (_) => AdaptiveScaffold.toNavigationRail(
                            onDestinationSelected: (int index) {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            width: 72,
                            selectedIndex: _selectedIndex,
                            leading: ScaleTransition(
                              scale: _controller1,
                              child: const ComposeIcon(),
                            ),
                            backgroundColor:
                                const Color.fromARGB(0, 255, 255, 255),
                            labelType: NavigationRailLabelType.none,
                            destinations: destinations2,
                          )),
                  Breakpoints.expanded: SlotLayoutConfig(
                    key: const Key('primaryNavigation1'),
                    inAnimation: AdaptiveScaffold.leftOutIn,
                    builder: (_) => AdaptiveScaffold.toNavigationRail(
                      leading: const ComposeButton(),
                      trailing: trailingNavRail,
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
                  Breakpoints.compact: SlotLayoutConfig(
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
                          builder: (_) =>
                              DetailTile(item: allItems[selected ?? 0]),
                        ),
                        Breakpoints.expanded: SlotLayoutConfig(
                          outAnimation: AdaptiveScaffold.stayOnScreen,
                          key: const Key('sb1'),
                          builder: (_) =>
                              DetailTile(item: allItems[selected ?? 0]),
                        ),
                      },
                    )
                  : null,
              bottomNavigation: SlotLayout(
                config: {
                  Breakpoints.compact: SlotLayoutConfig(
                    key: const Key('bn'),
                    outAnimation: AdaptiveScaffold.topToBottom,
                    builder: (_) => AdaptiveScaffold.toBottomNavigationBar(
                        destinations: destinations),
                  ),
                  Breakpoints.medium: SlotLayoutConfig.empty(),
                  Breakpoints.expanded: SlotLayoutConfig.empty(),
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
    return Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
        child: const Icon(
          Icons.menu,
        ),
      ),
      Container(
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
      )
    ]);
  }
}

class ComposeButton extends StatelessWidget {
  const ComposeButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 5, 0, 12),
      child: Column(children: [
        Container(
            padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "REPLY",
                  style: TextStyle(color: Colors.deepPurple, fontSize: 15),
                ),
                Icon(
                  Icons.menu_open,
                  size: 22,
                )
              ],
            )),
        const SizedBox(
          height: 10,
        ),
        Container(
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
        )
      ]),
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
      floatingActionButton: Breakpoints.medium.isActive(context)
          ? null
          : Container(
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
            ),
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
                    radius: 18,
                    child: Image.asset('images/woman.png'),
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
                email: items[index].emails![0],
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
    required this.email,
    required this.selectCard,
    required this.showGridView,
    required this.setDisplayed,
  }) : super(key: key);

  final Item item;
  final Email email;
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
          Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
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
              color: isSelected
                  ? const Color.fromARGB(255, 237, 221, 255)
                  : const Color.fromARGB(255, 245, 241, 248),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      child: Image.asset(email.image),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(email.sender,
                            style: TextStyle(
                                color: Colors.grey[850], fontSize: 13)),
                        const SizedBox(height: 3),
                        Text('${email.time} ago',
                            style: Theme.of(context).textTheme.caption),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      child: Icon(
                        Icons.star_outline,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Text(item.title,
                    style: const TextStyle(color: Colors.black, fontSize: 17)),
                const SizedBox(height: 9),
                Text(email.body.replaceRange(116, email.body.length, '...'),
                    style: TextStyle(
                        color: Colors.grey[700], height: 1.35, fontSize: 14.5)),
                const SizedBox(height: 9),
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: (email.bodyImage != '')
                        ? Image.asset(email.bodyImage)
                        : Container()),
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
        height: MediaQuery.of(context).size.height,
        child: Container(
          decoration: const BoxDecoration(
              color: Color.fromARGB(255, 245, 241, 248),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                  Text('${item.emails!.length} Messages',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall)
                                ]),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                  child: Icon(
                                    Icons.restore_from_trash,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                  child: Icon(
                                    Icons.more_vert,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ]),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  )),
              Expanded(
                child: ListView.builder(
                    itemCount: item.emails!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Email thisEmail = item.emails![index];
                      return EmailTile(
                        sender: thisEmail.sender,
                        time: thisEmail.time,
                        senderIcon: thisEmail.image,
                        recepients: thisEmail.recepients,
                        body: thisEmail.body,
                        bodyImage: thisEmail.bodyImage,
                      );
                    }),
              ),
              //Text(item.body, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailTile extends StatelessWidget {
  const EmailTile({
    required this.sender,
    required this.time,
    required this.senderIcon,
    required this.recepients,
    required this.body,
    required this.bodyImage,
    Key? key,
  }) : super(key: key);

  final String sender;
  final String time;
  final String senderIcon;
  final String recepients;
  final String body;
  final String bodyImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    child: Image.asset(senderIcon),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sender,
                          style:
                              TextStyle(color: Colors.grey[850], fontSize: 13)),
                      const SizedBox(height: 3),
                      Text('$time ago',
                          style: Theme.of(context).textTheme.caption),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 245, 241, 248),
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Icon(
                      Icons.star_outline,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text('To $recepients',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 15),
              Text(body,
                  style: TextStyle(
                      color: Colors.grey[700], height: 1.35, fontSize: 14.5)),
              const SizedBox(height: 9),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child:
                      (bodyImage != '') ? Image.asset(bodyImage) : Container()),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                      width: 150,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0))),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 245, 241, 248)),
                          side: MaterialStateProperty.all(const BorderSide(
                              width: 0.0, color: Colors.transparent)),
                        ),
                        child: Text(
                          'Reply',
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 12),
                        ),
                      )),
                  SizedBox(
                      width: 150,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0))),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 245, 241, 248)),
                          side: MaterialStateProperty.all(const BorderSide(
                              width: 0.0, color: Colors.transparent)),
                        ),
                        child: Text(
                          'Reply all',
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 12),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RouteDetailView extends StatelessWidget {
  const RouteDetailView(
      {required this.item,
      required this.selectCard,
      required this.setDisplayed,
      super.key});
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
    required this.title,
    required this.emails,
  });

  final String title;
  final List<Email>? emails;
}

class Email {
  const Email({
    required this.sender,
    required this.recepients,
    required this.image,
    required this.time,
    required this.body,
    required this.bodyImage,
  });

  final String sender;
  final String recepients;
  final String image;
  final String time;
  final String body;
  final String bodyImage;
}

const List<Item> allItems = [
  Item(
    title: 'Dinner Club',
    emails: [
      Email(
        sender: 'So Duri',
        recepients: 'me, Ziad and Lily',
        image: 'images/young-man.png',
        time: '20 min',
        body:
            "I think it's time for us to finally try that new noodle shop downtown that doesn't use menus. I'm so intrigued by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)",
        bodyImage: '',
      ),
      Email(
          sender: 'Me',
          recepients: 'me, Ziad, and Lily',
          image: 'images/woman.png',
          time: '4 min',
          body:
              'Yes! I forgot about that place! Im definitely up for taking a risk this week and handing control over to this mysterious noodle chef. I wonder what happens if you have allergies though? Lucky none of us have any otherwise Id be a bit concerned.',
          bodyImage: ''),
      Email(
          sender: 'Ziad Aouad',
          recepients: 'me, Ziad and Lily',
          image: 'images/man.png',
          time: '2 min',
          body:
              'Hey guys! Im pretty sure if you tell your waiter about any food restrictions or allergies, they should be able to cater to it. Im super excited though, see yall soon!',
          bodyImage: ''),
    ],
  ),
  Item(
    title: '7 Best Yoga Poses for Strength Training',
    emails: [
      Email(
        sender: 'Elaine Howley',
        time: '2 hours',
        body:
            "Though many people think of yoga as mostly a way to stretch out and relax, in actuality, it can provide a fantastic full-body workout that can even make you stronger.",
        image: 'images/beauty.png',
        bodyImage: 'images/yoga.png',
        recepients: '',
      ),
    ],
  ),
  Item(
    title: 'A Programming Language for Hardware Accelerators',
    emails: [
      Email(
        sender: 'Laney Mansell',
        time: '10 min',
        body:
            "Moore’s Law needs a hug. The days of stuffing transistors on little silicon computer chips are numbered, and their life rafts — hardware accelerators — come with a price. ",
        image: 'images/woman2.png',
        bodyImage: '',
        recepients: '',
      ),
    ],
  ),
];
