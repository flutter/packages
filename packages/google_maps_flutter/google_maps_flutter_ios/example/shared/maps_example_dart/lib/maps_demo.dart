// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'page.dart';

/// MapsDemo is the Main Application.
class MapsDemo extends StatelessWidget {
  /// Default Constructor
  const MapsDemo(this.pages, {super.key});

  /// The list of demo pages.
  final List<GoogleMapExampleAppPage> pages;

  void _pushPage(BuildContext context, GoogleMapExampleAppPage page) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
              appBar: AppBar(title: Text(page.title)),
              body: page,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GoogleMaps examples')),
      body: ListView.builder(
        itemCount: pages.length,
        itemBuilder: (_, int index) => ListTile(
          leading: pages[index].leading,
          title: Text(pages[index].title),
          onTap: () => _pushPage(context, pages[index]),
        ),
      ),
    );
  }
}
