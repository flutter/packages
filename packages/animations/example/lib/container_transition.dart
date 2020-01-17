// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

const String _loremIpsumParagraph = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Vulputate dignissim suspendisse in est. Ut ornare lectus sit amet. Eget nunc lobortis mattis aliquam faucibus purus in. Hendrerit gravida rutrum quisque non tellus orci ac auctor. Mattis aliquam faucibus purus in massa. Tellus rutrum tellus pellentesque eu tincidunt tortor. Nunc eget lorem dolor sed. Nulla at volutpat diam ut venenatis tellus in metus. Tellus cras adipiscing enim eu turpis. Pretium fusce id velit ut tortor. Adipiscing enim eu turpis egestas pretium. Quis varius quam quisque id. Blandit aliquam etiam erat velit scelerisque. In nisl nisi scelerisque eu. Semper risus in hendrerit gravida rutrum quisque. Suspendisse in est ante in nibh mauris cursus mattis molestie. Adipiscing elit duis tristique sollicitudin nibh sit amet commodo nulla. Pretium viverra suspendisse potenti nullam ac tortor vitae.
''';

/// The demo page for [OpenContainerTransform].
class OpenContainerTransformDemo extends StatefulWidget {
  @override
  _OpenContainerTransformDemoState createState() =>
      _OpenContainerTransformDemoState();
}

class _OpenContainerTransformDemoState extends State<OpenContainerTransformDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Container Transform')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            _OpenContainerWrapper(
              closedBuilder: (BuildContext context, VoidCallback openContainer) {
                return _ExampleCard(openContainer: openContainer);
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
            ),
            _OpenContainerWrapper(
              closedBuilder: (BuildContext context, VoidCallback openContainer) {
                return _ExampleSingleTile(openContainer: openContainer);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenContainerWrapper extends StatelessWidget {
  const _OpenContainerWrapper({
    this.closedBuilder,
  });

  final OpenContainerBuilder closedBuilder;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      openBuilder: (BuildContext context, VoidCallback _) {
        return _DetailsPage();
      },
      closedBuilder: closedBuilder,
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({this.openContainer});

  final VoidCallback openContainer;

  @override
  Widget build(BuildContext context) {
    return _InkWellOverlay(
      openContainer: openContainer,
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.black38,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Image.asset(
                  'assets/placeholder_image.png',
                ),
              ),
            ),
          ),
          const ListTile(
            title: Text('Title'),
            subtitle: Text('Secondary text'),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Text(
              'Lorem ipsum dolor sit amet, consectetur '
              'adipiscing elit, sed do eiusmod tempor.',
              style: Theme.of(context).textTheme.body1
                .copyWith(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleSingleTile extends StatelessWidget {
  const _ExampleSingleTile({this.openContainer});

  final VoidCallback openContainer;

  @override
  Widget build(BuildContext context) {
    const double height = 100.0;

    return _InkWellOverlay(
      openContainer: openContainer,
      height: height,
      child: Row(
        children: <Widget>[
          Container(
            color: Colors.black38,
            height: height,
            width: height,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                'assets/placeholder_image.png',
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Title',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                  ),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur '
                    'adipiscing elit,',
                    style: Theme.of(context).textTheme.caption
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InkWellOverlay extends StatelessWidget {
  const _InkWellOverlay({
    this.openContainer,
    this.width,
    this.height,
    this.child,
  });

  final VoidCallback openContainer;
  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: <Widget>[
          child,
          InkWell(
            splashColor: Colors.black38,
            onTap: () {
              Future<void>.delayed(
                const Duration(milliseconds: 250),
                openContainer,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Container Transform')),
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.black38,
            height: 250,
            child: Padding(
              padding: const EdgeInsets.all(70.0),
              child: Image.asset(
                'assets/placeholder_image.png',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              left: 20.0,
              right: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Title',
                  style: Theme.of(context).textTheme.headline
                    .copyWith(
                      color: Colors.black54,
                      fontSize: 30.0,
                    ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                ),
                Text(
                  _loremIpsumParagraph,
                  style: Theme.of(context).textTheme.body1
                    .copyWith(
                      color: Colors.black54,
                      height: 1.5,
                      fontSize: 16.0,
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}