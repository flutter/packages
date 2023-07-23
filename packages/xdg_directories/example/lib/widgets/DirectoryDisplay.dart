import 'package:flutter/material.dart';

/// This is a Widget that displays a title and a directory path for the XDG Directories demo.
class DirectoryDisplay extends StatelessWidget {
  /// Constructor
  const DirectoryDisplay({
    super.key,
    this.title = '',
    this.value = '',
  });

  ///
  const DirectoryDisplay.listOfValues({
    super.key,
    this.title = '',
    this.values = const <String>[],
  });

  /// This is the title for the DirectoryDisplay.
  /// i.e.: "Selected directory:"
  final String title;

  /// This is the directory value to be displayed.
  /// i.e.: "/home/user/Videos"
  final String? value;

  ///
  final List<String>? values;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ),
          color: Colors.black38,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 5),
          child: Text(
            value ?? '',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
            ),
          ),
        )
      ],
    );
  }
}
