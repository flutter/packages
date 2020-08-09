// Copyright 2020 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../screens/demo_screen.dart';
import '../shared/markdown_demo_widget.dart';

class DemoCard extends StatelessWidget {
  final MarkdownDemoWidget widget;

  const DemoCard({Key key, @required this.widget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        DemoScreen.routeName,
        arguments: widget,
      ),
      child: Container(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minHeight: 50, minWidth: 425, maxWidth: 425),
          child: Card(
              color: Colors.blue,
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).primaryTextTheme.headline5,
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      widget.description,
                      style: Theme.of(context).primaryTextTheme.bodyText1,
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
