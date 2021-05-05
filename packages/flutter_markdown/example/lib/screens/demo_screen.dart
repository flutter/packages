// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../shared/markdown_demo_widget.dart';
import '../shared/markdown_extensions.dart';

// ignore_for_file: public_member_api_docs

class DemoScreen extends StatelessWidget {
  const DemoScreen({Key? key, required this.child}) : super(key: key);

  static const String routeName = '/demoScreen';

  final MarkdownDemoWidget? child;

  static const List<String> _tabLabels = <String>['Formatted', 'Raw', 'Notes'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(child!.title),
          bottom: TabBar(
            indicatorPadding: const EdgeInsets.only(bottom: 8),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: <Widget>[
              for (String label in _tabLabels) Tab(text: label),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            DemoFormattedView(child: child),
            DemoRawDataView(data: child!.data),
            DemoNotesView(notes: child!.notes), //child.notes as String),
          ],
        ),
      ),
    );
  }
}

class DemoFormattedView extends StatelessWidget {
  const DemoFormattedView({Key? key, required this.child}) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1250),
        child: child,
      ),
    );
  }
}

class DemoRawDataView extends StatelessWidget {
  const DemoRawDataView({Key? key, required this.data}) : super(key: key);

  final Future<String> data;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: data,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                snapshot.data!,
                softWrap: true,
                style: Theme.of(context)
                    .primaryTextTheme
                    .bodyText1!
                    .copyWith(fontFamily: 'Roboto Mono', color: Colors.black),
              ),
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class DemoNotesView extends StatelessWidget {
  const DemoNotesView({Key? key, required this.notes}) : super(key: key);

  final Future<String> notes;

  // Handle the link. The [href] in the callback contains information
  // from the link. The url_launcher package or other similar package
  // can be used to execute the link.
  Future<void> linkOnTapHandler(
    BuildContext context,
    String text,
    String? href,
    String title,
  ) async {
    showDialog<Widget>(
      context: context,
      builder: (BuildContext context) =>
          _createDialog(context, text, href, title),
    );
  }

  Widget _createDialog(
    BuildContext context,
    String text,
    String? href,
    String title,
  ) =>
      AlertDialog(
        title: const Text('Reference Link'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'See the following link for more information:',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(height: 8),
              Text(
                'Link text: $text',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              const SizedBox(height: 8),
              Text(
                'Link destination: $href',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              const SizedBox(height: 8),
              Text(
                'Link title: $title',
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: notes,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Markdown(
            data: snapshot.data!,
            extensionSet: MarkdownExtensionSet.githubFlavored.value,
            onTapLink: (String text, String? href, String title) =>
                linkOnTapHandler(context, text, href, title),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
