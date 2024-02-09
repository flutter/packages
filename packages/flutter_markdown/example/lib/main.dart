// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
///
/// The simplest use case that illustrates how to make use of the
/// flutter_markdown package is to include a Markdown widget in a widget tree
/// and supply it with a character string of text containing Markdown formatting
/// syntax. Here is a simple Flutter app that creates a Markdown widget that
/// formats and displays the text in the string _markdownData. The resulting
/// Flutter app demonstrates the use of headers, rules, and emphasis text from
/// plain text Markdown syntax.
///
/// import 'package:flutter/material.dart';
/// import 'package:flutter_markdown/flutter_markdown.dart';
///
/// const String _markdownData = """
/// # Minimal Markdown Test
/// ---
/// This is a simple Markdown test. Provide a text string with Markdown tags
/// to the Markdown widget and it will display the formatted output in a
/// scrollable widget.
///
/// ## Section 1
/// Maecenas eget **arcu egestas**, mollis ex vitae, posuere magna. Nunc eget
/// aliquam tortor. Vestibulum porta sodales efficitur. Mauris interdum turpis
/// eget est condimentum, vitae porttitor diam ornare.
///
/// ### Subsection A
/// Sed et massa finibus, blandit massa vel, vulputate velit. Vestibulum vitae
/// venenatis libero. **__Curabitur sem lectus, feugiat eu justo in, eleifend
/// accumsan ante.__** Sed a fermentum elit. Curabitur sodales metus id mi
/// ornare, in ullamcorper magna congue.
/// """;
///
/// void main() {
///   runApp(
///     MaterialApp(
///       title: "Markdown Demo",
///       home: Scaffold(
///         appBar: AppBar(
///           title: const Text('Simple Markdown Demo'),
///         ),
///         body: SafeArea(
///           child: Markdown(
///             data: _markdownData,
///           ),
///         ),
///       ),
///     ),
///   );
/// }
///
/// The flutter_markdown package has options for customizing and extending the
/// parsing of Markdown syntax and building of the formatted output. The demos
/// in this example app illustrate some of the potentials of the
/// flutter_markdown package.
library;

import 'package:flutter/material.dart';
import 'screens/demo_screen.dart';
import 'screens/home_screen.dart';
import 'shared/markdown_demo_widget.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Markdown Demos',
      initialRoute: '/',
      home: HomeScreen(),
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          builder: (_) => DemoScreen(
            child: settings.arguments as MarkdownDemoWidget?,
          ),
        );
      },
    ),
  );
}
