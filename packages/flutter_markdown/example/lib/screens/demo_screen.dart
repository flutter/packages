// Copyright 2020 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../shared/markdown_demo_widget.dart';
import '../shared/markdown_extensions.dart';

class DemoScreen extends StatelessWidget {
  static const routeName = '/demoScreen';

  final MarkdownDemoWidget child;

  const DemoScreen({Key key, @required this.child}) : super(key: key);

  final _tabLabels = const <String>['Formatted', 'Raw', 'Notes'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(child.title),
          bottom: TabBar(
            indicatorPadding: EdgeInsets.only(bottom: 8),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              for (var label in _tabLabels) Tab(text: label),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DemoFormattedView(child: child),
            DemoRawDataView(data: child.data),
            DemoNotesView(notes: child.notes), //child.notes as String),
          ],
        ),
      ),
    );
  }
}

class DemoFormattedView extends StatelessWidget {
  final Widget child;

  const DemoFormattedView({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1250),
        child: child,
      ),
    );
  }
}

class DemoRawDataView extends StatelessWidget {
  final Future<String> data;

  const DemoRawDataView({Key key, @required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                snapshot.data,
                softWrap: true,
                style: Theme.of(context)
                    .primaryTextTheme
                    .bodyText1
                    .copyWith(fontFamily: 'Roboto Mono', color: Colors.black),
              ),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class DemoNotesView extends StatelessWidget {
  final Future<String> notes;

  const DemoNotesView({Key key, @required this.notes}) : super(key: key);

  // Handle the link. The [href] in the callback contains information
  // from the link. The url_launcher package or other similar package
  // can be used to execute the link.
  void linkOnTapHandler(BuildContext context, String href) async {
    showDialog(
      context: context,
      builder: (context) => _createDialog(context, href),
    );
  }

  Widget _createDialog(BuildContext context, String href) => AlertDialog(
        title: Text('Reference Link'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(
                'See the following link for more information:',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              SizedBox(height: 8),
              Text(
                '$href',
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
        ),
        actions: [
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: notes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Markdown(
            data: snapshot.data,
            extensionSet: MarkdownExtensionSet.githubFlavored.value,
            onTapLink: (href) => linkOnTapHandler(context, href),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
