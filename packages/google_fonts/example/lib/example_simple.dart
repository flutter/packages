// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExampleSimple extends StatefulWidget {
  const ExampleSimple({super.key});

  @override
  ExampleSimpleState createState() => ExampleSimpleState();
}

class ExampleSimpleState extends State<ExampleSimple> {
  int _counter = 0;
  late Future<List<void>> googleFontsPending;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();

    googleFontsPending = GoogleFonts.pendingFonts(<TextStyle>[
      GoogleFonts.poppins(),
      GoogleFonts.montserrat(fontStyle: FontStyle.italic),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle pushButtonTextStyle = GoogleFonts.poppins(
      textStyle: Theme.of(context).textTheme.headlineMedium,
    );
    final TextStyle counterTextStyle = GoogleFonts.montserrat(
      fontStyle: FontStyle.italic,
      textStyle: Theme.of(context).textTheme.displayLarge,
    );

    return Scaffold(
      body: Center(
        child: FutureBuilder<List<void>>(
          future: googleFontsPending,
          builder: (BuildContext context, AsyncSnapshot<List<void>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox();
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'You have pushed the button this many times:',
                  style: pushButtonTextStyle,
                ),
                Text('$_counter', style: counterTextStyle),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
