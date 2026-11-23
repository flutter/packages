// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: TitleColorTheme(titleColor: Colors.purple, child: Text('Hello')),
      ),
    );
  }
}

// #region body
/// A Widget that sets the ambient theme's title text color for its
/// descendants, while leaving other ambient theme attributes alone.
class TitleColorTheme extends StatelessWidget {
  const TitleColorTheme({
    super.key,
    required this.child,
    required this.titleColor,
  });

  final Color titleColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    // This partialTheme is incomplete: it only has the title style
    // defined. Just replacing theme.textTheme with partialTheme would
    // set the title, but everything else would be null. This isn't very
    // useful, so merge it with the existing theme to keep all of the
    // preexisting definitions for the other styles.
    final TextTheme partialTheme = TextTheme(
      titleLarge: TextStyle(color: titleColor),
    );
    theme = theme.copyWith(textTheme: theme.textTheme.merge(partialTheme));
    return Theme(data: theme, child: child);
  }
}

// #endregion body
