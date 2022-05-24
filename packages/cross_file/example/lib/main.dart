import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Cross File Demo',
      home: CrossFileDemo(),
    ),
  );
}

class CrossFileDemo extends StatefulWidget {
  @override
  State<CrossFileDemo> createState() => _CrossFileDemoState();
}

class _CrossFileDemoState extends State<CrossFileDemo> {
  ImagePicker _imagePicker = ImagePicker();
  XFile? _image;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Cross File Example"),
      ),
      body: Center(
        child: Column(
          children: [
            XFileWidget(_image),
            MaterialButton(
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
          ],
        ),
      ),
    );
  }
}

class XFileWidget extends StatelessWidget {
  XFileWidget(this.xFile);

  XFile? xFile;

  @override
  Widget build(BuildContext context) {
    return xFile == null
        ? Container()
        : Builder(
        builder: (context) {
          final file = xFile!;
          return Column(
            children: [
              Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.5,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.5,
                  child: (kIsWeb)
                      ? Image.network(file.path,fit: BoxFit.cover,)
                      : Image.file(File(file.path),fit: BoxFit.cover)),
              Text("Name of file is ${file.name}"),
              Text("Path of file is ${file.path}"),
              FutureBuilder(builder: (_, snapshot) {
                if(snapshot.hasData) {
                  return Text("Last modified at ${snapshot.data}");
                }
                return Container();
              }, future: file.lastModified(),),
              FutureBuilder(builder: (_, snapshot) {
                if(snapshot.hasData) {
                  return Text("Size of the file in bytes is ${snapshot.data}");
                }
                return Container();
              }, future: file.length(),),
            ],
          );
        }
    );
  }
}
