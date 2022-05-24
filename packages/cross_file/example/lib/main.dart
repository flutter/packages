// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'Cross File Demo',
      home: CrossFileDemo(),
    ),
  );
}

class CrossFileDemo extends StatefulWidget {
  const CrossFileDemo({Key? key}) : super(key: key);

  @override
  State<CrossFileDemo> createState() => _CrossFileDemoState();
}

class _CrossFileDemoState extends State<CrossFileDemo> {
  ImagePicker _imagePicker = ImagePicker();
  XFile? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cross File Example"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: Text("Pick an image"),
              onPressed: () async {
                final pickedFile =
                await _imagePicker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _image = pickedFile;
                  });
                }
              },
            ),
            XFileWidget(_image),

          ],
        ),
      ),
    );
  }
}

class XFileWidget extends StatelessWidget {
  XFileWidget(this.xFile);

  final XFile? xFile;

  @override
  Widget build(BuildContext context) {
    return xFile == null
        ? Container()
        : Builder(
        builder: (context) {
          final file = xFile!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Name of file is ${file.name}"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Path of file is ${file.path}"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Mime type of the file is ${file.mimeType}"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder(builder: (_, snapshot) {
                  if(snapshot.hasData) {
                    return Text("Last modified at ${snapshot.data}");
                  }
                  return Container();
                }, future: file.lastModified(),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder(builder: (_, snapshot) {
                  if(snapshot.hasData) {
                    return Text("Size of the file in bytes is ${snapshot.data}");
                  }
                  return Container();
                }, future: file.length(),),
              ),
            ],
          );
        }
    );
  }
}
