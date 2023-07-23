import 'package:flutter/material.dart';

/// This is a Widget that displays a title and a directory path for the XDG Directories demo.
class DirectoryDisplay extends StatelessWidget {
  /// Single Directory display
  const DirectoryDisplay({
    super.key,
    this.title = '',
    String? value,
  })  : assert(value != null),
        child = value;

  /// List of Directories display
  DirectoryDisplay.listOfValues({
    super.key,
    this.title = '',
    List<String>? values,
  })  : assert(values != null),
        assert(values!.isNotEmpty),
        child = values;

  /// This is the title for the DirectoryDisplay.
  /// i.e.: "Selected directory:"
  final String title;

  /// This is the directory or directories to be displayed.
  final dynamic child;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
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
        if (child is String)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            color: Colors.black38,
            child: Text(
              child as String,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          )
        else if (child is List<String>)
          ListView.builder(
            shrinkWrap: true,
            itemCount: (child as List<String>).length,
            itemBuilder: (BuildContext context, int index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              color: Colors.black38,
              child: Text(
                (child as List<String>)[index],
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
