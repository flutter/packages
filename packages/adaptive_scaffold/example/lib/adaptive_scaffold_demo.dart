import 'package:flutter/material.dart';
import 'package:adaptive_scaffold/adaptive_helper.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'Adaptive Layout Example',
      home: MyHomePage(),
    ),
  );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget leadingUnExtendedNavRail = Column(
      children: const [
        SizedBox(
          height: 10,
        ),
        Icon(Icons.menu)
      ],
    );
    Widget leadingExtendedNavRail = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        Text(
          "REPLY",
          style: TextStyle(color: Color.fromARGB(255, 255, 201, 197)),
        ),
        Icon(Icons.menu_open)
      ],
    );
    Widget trailingNavRail = Column(
      children: [
        const Divider(
          color: Colors.black,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: const [
            SizedBox(
              width: 27,
            ),
            Text(
              "Folders",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
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
          height: 12,
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
          height: 12,
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
          height: 12,
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

    return AdaptiveScaffold(
      selectedIndex: 0,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
        NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
        NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
        NavigationDestination(icon: Icon(Icons.video_call), label: 'Video'),
      ],
      trailingNavRail: trailingNavRail,
      leadingUnExtendedNavRail: leadingUnExtendedNavRail,
      leadingExtendedNavRail: leadingExtendedNavRail,
      smallBody: (_) => ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 250,
            color: const Color.fromARGB(255, 255, 201, 197),
          ),
        ),
      ),
      body: (_) => GridView.count(crossAxisCount: 2, children: <Widget>[
        for (int i = 0; i < 10; i++)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: const Color.fromARGB(255, 255, 201, 197),
              height: 400,
            ),
          )
      ]),
      smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
      secondaryBody: (_) =>
          Container(color: const Color.fromARGB(255, 234, 158, 192)),
    );
  }
}
