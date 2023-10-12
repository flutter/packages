import 'dart:io';

import 'package:flutter/material.dart';
import 'package:process/process.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // implemembation of loacal process manager and get the process result
  LocalProcessManager processManager = const LocalProcessManager();

  void run() async {
    // start the process
    final ProcessResult processResult = await processManager.run(<String>[
      'ls',
    ]);

    // print the result
    debugPrint(processResult.stdout);
  }

  void canRun() async {
    // check if the process can run
    bool test = processManager.canRun('python3');

    // print the result
    debugPrint(test.toString());
  }

  @override
  void initState() {
    super.initState();
    run();
    canRun();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
