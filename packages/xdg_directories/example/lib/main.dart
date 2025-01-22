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
      color: Colors.blue,
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
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.only(left: 20),
          shrinkWrap: true,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: userDirectoryNames.length,
              itemBuilder: (BuildContext context, int index) => Text(
                '${userDirectoryNames.elementAt(index)}: \n${getUserDirectory(userDirectoryNames.elementAt(index))?.path}\n',
              ),
            ),
            Text('Data Home: \n${dataHome.path}\n'),
            Text('Config Home: \n${configHome.path}\n'),
            Text(
                'Data Directories: \n${dataDirs.map((Directory directory) => directory.path).toList().join('\n')}\n'),
            Text(
                'Config Directories: \n${configDirs.map((Directory directory) => directory.path).toList().join('\n')}\n'),
            Text('Cache Home: \n${cacheHome.path}\n'),
            Text('Runtime Directory: \n${runtimeDir?.path}\n'),
            Text('State Home: \n${stateHome.path}\n'),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
