import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExampleSimple extends StatefulWidget {
  const ExampleSimple({super.key});

  @override
  ExampleSimpleState createState() => ExampleSimpleState();
}

class ExampleSimpleState extends State<ExampleSimple> {
  int _counter = 0;
  late Future googleFontsPending;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();

    googleFontsPending = GoogleFonts.pendingFonts([
      GoogleFonts.poppins(),
      GoogleFonts.montserrat(fontStyle: FontStyle.italic),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final pushButtonTextStyle = GoogleFonts.poppins(
      textStyle: Theme.of(context).textTheme.headlineMedium,
    );
    final counterTextStyle = GoogleFonts.montserrat(
      fontStyle: FontStyle.italic,
      textStyle: Theme.of(context).textTheme.displayLarge,
    );

    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: googleFontsPending,
          builder: (context, snapshot) {
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
