// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:xdg_directories/xdg_directories.dart';
import 'widgets/DirectoryDisplay.dart';

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
        child: ListView(
          shrinkWrap: true,
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
            DirectoryDisplay(
              title: 'Selected directory:',
              value: userDirectory,
            ),
            const SizedBox(
              height: 50,
            ),
            DirectoryDisplay(
              title: 'Runtime directory:',
              value: runtimeDir?.path,
            ),
            const SizedBox(
              height: 50,
            ),
            DirectoryDisplay(
              title: 'Cache home:',
              value: cacheHome.path,
            ),
            const SizedBox(
              height: 50,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, bottom: 5),
              child: Text(
                'Config directories:',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: configDirs.length,
              itemBuilder: (BuildContext context, int index) =>
                  directoryTextWidget(
                configDirs[index].path,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, bottom: 5),
              child: Text(
                'Data directories:',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: dataDirs.length,
              itemBuilder: (BuildContext context, int index) =>
                  DirectoryDisplay(
                title: 'Selected directory:',
                value: userDirectory,
              ),
              directoryTextWidget(
                dataDirs[index].path,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            DirectoryDisplay(
              title: 'Selected directory:',
              value: userDirectory,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, bottom: 5),
              child: Text(
                'Config home:',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                ),
              ),
            ),
            directoryTextWidget(configHome.path),
            const SizedBox(
              height: 50,
            ),
            DirectoryDisplay(
              title: 'Selected directory:',
              value: userDirectory,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, bottom: 5),
              child: Text(
                'Data home:',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                ),
              ),
            ),
            directoryTextWidget(dataHome.path),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
