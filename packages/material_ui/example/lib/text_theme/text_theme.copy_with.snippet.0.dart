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
        body: TitleColorThemeCopy(
          titleColor: Colors.purple,
          child: Text('Hello'),
        ),
      ),
    );
  }
}

// #region body
/// A Widget that sets the ambient theme's title text color for its
/// descendants, while leaving other ambient theme attributes alone.
class TitleColorThemeCopy extends StatelessWidget {
  const TitleColorThemeCopy({
    super.key,
    required this.titleColor,
    required this.child,
  });

  final Color titleColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.copyWith(
          titleLarge: theme.textTheme.titleLarge!.copyWith(color: titleColor),
        ),
      ),
      child: child,
    );
  }
}

// #endregion body
