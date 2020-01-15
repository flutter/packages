import 'package:flutter/material.dart';

import 'shared_axis_transition/shared_axis_transition.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData.from(
    colorScheme: const ColorScheme.light(),
  ).copyWith(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
      },
    ),
  ),
  home: _TransitionsHomePage(),
));

class _TransitionsHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Material Transitions')),
      body: Column(
        children: <Widget>[
          _TransitionListTile(
            title: 'Shared Axis',
            subtitle: 'Page transition where outgoing and incoming elements share a fade transition',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => SharedAxisTransitionDemo(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TransitionListTile extends StatelessWidget {
  const _TransitionListTile({
    this.onTap,
    this.title,
    this.subtitle,
  });

  final Function onTap;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 15.0,
      ),
      leading: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: Colors.black54,
          ),
        ),
        child: Icon(
          Icons.play_arrow,
          size: 35,
        ),
      ),
      onTap: onTap,
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
