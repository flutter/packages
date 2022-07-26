import 'package:flutter/material.dart';
import 'package:adaptive_helper/adaptive_helper.dart';

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
    return AdaptiveScaffold(
      selectedIndex: 0,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
        NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
        NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
        NavigationDestination(icon: Icon(Icons.video_call), label: 'Video'),
      ],
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
    );
  }
}
