// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';

/// Screen that allows the user to select a text file using `openFile`, then
/// displays its contents in a dialog.
class OpenTextPage extends StatelessWidget {
  /// Default Constructor
  const OpenTextPage({super.key});

  Future<void> _openTextFile(BuildContext context) async {
    const typeGroup = XTypeGroup(label: 'text', extensions: <String>['txt', 'json']);
    final XFile? file = await FileSelectorPlatform.instance!.openFile(
      options:  const OpenFileDialogOptions(acceptedTypeGroups: <XTypeGroup>[typeGroup]),
    );
    if (file == null) {
      // Operation was canceled by the user.
      return;
    }
    final String? fileName = await file.name();
    final String fileContent = await file.readAsString();

    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => TextDisplay(fileName ?? 'Unknown Filename', fileContent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open a text file')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Press to open a text file (json, txt)'),
              onPressed: () => _openTextFile(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays a text file in a dialog
class TextDisplay extends StatefulWidget {
  /// Default Constructor
  const TextDisplay(this.fileName, this.fileContent, {super.key});

  /// File's name
  final String fileName;

  /// File to display
  final String fileContent;

  @override
  State<TextDisplay> createState() => _TextDisplayState();
}

class _TextDisplayState extends State<TextDisplay> {
  late final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.fileName),
      content: Scrollbar(
        controller: scrollController,
        child: SingleChildScrollView(controller: scrollController, child: Text(widget.fileContent)),
      ),
      actions: <Widget>[
        TextButton(child: const Text('Close'), onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}
