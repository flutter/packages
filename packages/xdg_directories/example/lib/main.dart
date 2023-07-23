// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:xdg_directories/xdg_directories.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XDG Directories Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'XDG Directories Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userDirectory = '';

  @override
  Widget build(BuildContext context) {
    final Set<String> userDirectoryNames = getUserDirectoryNames();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Select a user directory name:',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 25,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: userDirectoryNames.length,
              itemBuilder: (BuildContext context, int index) => ListTile(
                title: Text(userDirectoryNames.elementAt(index)),
                visualDensity: VisualDensity.standard,
                onTap: () => setState(
                  () {
                    userDirectory =
                        getUserDirectory(userDirectoryNames.elementAt(index))
                                ?.path ??
                            '';
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, bottom: 5),
              child: Text(
                'User directory:',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              color: Colors.black38,
              child: Text(
                userDirectory,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
