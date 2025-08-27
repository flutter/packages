import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExampleFontSelection extends StatefulWidget {
  const ExampleFontSelection({super.key});

  @override
  ExampleFontSelectionState createState() => ExampleFontSelectionState();
}

class ExampleFontSelectionState extends State<ExampleFontSelection> {
  final Iterable<String> fonts = GoogleFonts.asMap().keys;

  final TextEditingController _textEditingController = TextEditingController(
    text: 'abcdefghijklmnopqrstuvwxyz',
  );

  late String _selectedFont;
  late Future _googleFontsPending;

  @override
  void initState() {
    _selectedFont = fonts.first;
    _googleFontsPending =
        GoogleFonts.pendingFonts([GoogleFonts.getFont(_selectedFont)]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Wrap(
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 20,
                    spacing: 20,
                    children: [
                      SizedBox(
                        width: 360,
                        child: TextField(
                          controller: _textEditingController,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      DropdownMenu<String>(
                        menuHeight: 400,
                        initialSelection: _selectedFont,
                        onSelected: (String? newValue) {
                          setState(() {
                            _selectedFont = newValue!;
                            _googleFontsPending = GoogleFonts.pendingFonts(
                              [GoogleFonts.getFont(_selectedFont)],
                            );
                          });
                        },
                        dropdownMenuEntries:
                            GoogleFonts.asMap().keys.map((String font) {
                          return DropdownMenuEntry<String>(
                            label: font,
                            value: font,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                  Expanded(
                    child: FutureBuilder(
                      future: _googleFontsPending,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const SizedBox();
                        }

                        return Text(
                          _textEditingController.text,
                          style: GoogleFonts.getFont(
                            _selectedFont,
                            fontSize: 50.0,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
