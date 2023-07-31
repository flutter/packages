// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:xdg_directories/xdg_directories.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'XDG Directories Demo',
      home: MyHomePage(title: 'XDG Directories Demo'),
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
  final Set<String> userDirectoryNames = getUserDirectoryNames();
  String selectedUserDirectory = '';

  @override
  Widget build(BuildContext context) {
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
                    selectedUserDirectory =
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
            _singleDirectoryPath(
              title: 'Selected directory:',
              path: selectedUserDirectory,
            ),
            const SizedBox(
              height: 50,
            ),
            _singleDirectoryPath(
              title: 'Data Home:',
              path: dataHome.path,
            ),
            const SizedBox(
              height: 50,
            ),
            _singleDirectoryPath(
              title: 'Config Home:',
              path: configHome.path,
            ),
            const SizedBox(
              height: 50,
            ),
            _listOfDirectoryPaths(
              title: 'Data Directories:',
              paths: dataDirs.map((Directory d) => d.path).toList(),
            ),
            const SizedBox(
              height: 50,
            ),
            _listOfDirectoryPaths(
              title: 'Config Directories:',
              paths: configDirs.map((Directory d) => d.path).toList(),
            ),
            const SizedBox(
              height: 50,
            ),
            _singleDirectoryPath(
              title: 'Cache Home:',
              path: cacheHome.path,
            ),
            const SizedBox(
              height: 50,
            ),
            _singleDirectoryPath(
              title: 'Runtime Directory:',
              path: runtimeDir?.path,
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}

/// This is a Widget that displays a title and a directory path.
Widget _singleDirectoryPath({
  required String title,
  String? path,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 5),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 5,
        ),
        color: Colors.black38,
        child: Text(
          path ?? '',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    ],
  );
}

/// This is a Widget that displays a title and a list of directory paths.
Widget _listOfDirectoryPaths({
  required String title,
  required List<String> paths,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 5),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
      ),
      ListView.builder(
        shrinkWrap: true,
        itemCount: paths.length,
        itemBuilder: (BuildContext context, int index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ),
          color: Colors.black38,
          child: Text(
            paths[index],
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    ],
  );
}
