// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:meta/meta.dart';

import 'builder.dart';
import 'style_sheet.dart';

/// Signature for callbacks used by [MarkdownWidget] when the user taps a link.
///
/// Used by [MarkdownWidget.onTapLink].
typedef void MarkdownTapLinkCallback(String href);

/// Signature for custom image widget.
///
/// Used by [MarkdownWidget.imageBuilder]
typedef Widget MarkdownImageBuilder(Uri uri);

/// Signature for custom checkbox widget.
///
/// Used by [MarkdownWidget.checkboxBuilder]
typedef Widget MarkdownCheckboxBuilder(bool value);

/// Creates a format [TextSpan] given a string.
///
/// Used by [MarkdownWidget] to highlight the contents of `pre` elements.
abstract class SyntaxHighlighter {
  // ignore: one_member_abstracts
  /// Returns the formatted [TextSpan] for the given string.
  TextSpan format(String source);
}

/// Enum to specify which theme beeing used when creating [MarkdownStyleSheet]
///
/// [material] - create MarkdownStyelSheet based on MaterialTheme
/// [cupertino] - create MarkdownStyelSheet based on CupertinoTheme
/// [platform] - create MarkdownStyelSheet based on the Platform where the
/// is running on. Material on Android and Cupertino on iOS
enum MarkdownStyleSheetBaseTheme { material, cupertino, platform }

/// A base class for widgets that parse and display Markdown.
///
/// Supports all standard Markdown from the original
/// [Markdown specification](https://github.github.com/gfm/).
///
/// See also:
///
///  * [Markdown], which is a scrolling container of Markdown.
///  * [MarkdownBody], which is a non-scrolling container of Markdown.
///  * <https://github.github.com/gfm/>
abstract class MarkdownWidget extends StatefulWidget {
  /// Creates a widget that parses and displays Markdown.
  ///
  /// The [data] argument must not be null.
  const MarkdownWidget({
    Key key,
    @required this.data,
    this.styleSheet,
    this.syntaxHighlighter,
    this.onTapLink,
    this.imageDirectory,
    this.extensionSet,
    this.imageBuilder,
    this.checkboxBuilder,
    this.styleSheetTheme = MarkdownStyleSheetBaseTheme.material,
  })  : assert(data != null),
        super(key: key);

  /// The Markdown to display.
  final String data;

  /// The styles to use when displaying the Markdown.
  ///
  /// If null, the styles are inferred from the current [Theme].
  final MarkdownStyleSheet styleSheet;

  /// The syntax highlighter used to color text in `pre` elements.
  ///
  /// If null, the [MarkdownStyleSheet.code] style is used for `pre` elements.
  final SyntaxHighlighter syntaxHighlighter;

  /// Called when the user taps a link.
  final MarkdownTapLinkCallback onTapLink;

  /// The base directory holding images referenced by Img tags with local or network file paths.
  final String imageDirectory;

  /// Markdown syntax extension set
  ///
  /// Defaults to [md.ExtensionSet.gitHubFlavored]
  final md.ExtensionSet extensionSet;

  /// Call when build an image widget.
  final MarkdownImageBuilder imageBuilder;

  /// Call when build a checkbox widget.
  final MarkdownCheckboxBuilder checkboxBuilder;

  /// Setting to specify base theme for MarkdownStyleSheet
  ///
  /// Default to [MarkdownStyleSheetBaseTheme.material]
  final MarkdownStyleSheetBaseTheme styleSheetTheme;

  /// Subclasses should override this function to display the given children,
  /// which are the parsed representation of [data].
  @protected
  Widget build(BuildContext context, List<Widget> children);

  @override
  _MarkdownWidgetState createState() => _MarkdownWidgetState();
}

class _MarkdownWidgetState extends State<MarkdownWidget> implements MarkdownBuilderDelegate {
  List<Widget> _children;
  final List<GestureRecognizer> _recognizers = <GestureRecognizer>[];

  @override
  void didChangeDependencies() {
    _parseMarkdown();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(MarkdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data || widget.styleSheet != oldWidget.styleSheet) _parseMarkdown();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _parseMarkdown() {
    MarkdownStyleSheet customStyleSheet;
    switch (widget.styleSheetTheme) {
      case MarkdownStyleSheetBaseTheme.platform:
        customStyleSheet = (Platform.isIOS || Platform.isMacOS)
            ? MarkdownStyleSheet.fromCupertinoTheme(CupertinoTheme.of(context))
            : MarkdownStyleSheet.fromTheme(Theme.of(context));
        break;
      case MarkdownStyleSheetBaseTheme.cupertino:
        customStyleSheet = MarkdownStyleSheet.fromCupertinoTheme(CupertinoTheme.of(context));
        break;
      case MarkdownStyleSheetBaseTheme.material:
      default:
        customStyleSheet = MarkdownStyleSheet.fromTheme(Theme.of(context));
    }
    final MarkdownStyleSheet styleSheet = widget.styleSheet ?? customStyleSheet;

    _disposeRecognizers();

    final List<String> lines = widget.data.split(RegExp(r'\r?\n'));
    final md.Document document = md.Document(
      extensionSet: widget.extensionSet ?? md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: [TaskListSyntax()],
      encodeHtml: false,
    );
    final MarkdownBuilder builder = MarkdownBuilder(
      delegate: this,
      styleSheet: styleSheet,
      imageDirectory: widget.imageDirectory,
      imageBuilder: widget.imageBuilder,
      checkboxBuilder: widget.checkboxBuilder,
    );
    _children = builder.build(document.parseLines(lines));
  }

  void _disposeRecognizers() {
    if (_recognizers.isEmpty) return;
    final List<GestureRecognizer> localRecognizers = List<GestureRecognizer>.from(_recognizers);
    _recognizers.clear();
    for (GestureRecognizer recognizer in localRecognizers) recognizer.dispose();
  }

  @override
  GestureRecognizer createLink(String href) {
    final TapGestureRecognizer recognizer = TapGestureRecognizer()
      ..onTap = () {
        if (widget.onTapLink != null) widget.onTapLink(href);
      };
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  TextSpan formatText(MarkdownStyleSheet styleSheet, String code) {
    code = code.replaceAll(RegExp(r'\n$'), '');
    if (widget.syntaxHighlighter != null) {
      return widget.syntaxHighlighter.format(code);
    }
    return TextSpan(style: styleSheet.code, text: code);
  }

  @override
  Widget build(BuildContext context) => widget.build(context, _children);
}

/// A non-scrolling widget that parses and displays Markdown.
///
/// Supports all GitHub Flavored Markdown from the
/// [specification](https://github.github.com/gfm/).
///
/// See also:
///
///  * [Markdown], which is a scrolling container of Markdown.
///  * <https://github.github.com/gfm/>
class MarkdownBody extends MarkdownWidget {
  /// Creates a non-scrolling widget that parses and displays Markdown.
  const MarkdownBody({
    Key key,
    String data,
    MarkdownStyleSheet styleSheet,
    SyntaxHighlighter syntaxHighlighter,
    MarkdownTapLinkCallback onTapLink,
    String imageDirectory,
    md.ExtensionSet extensionSet,
    MarkdownImageBuilder imageBuilder,
    MarkdownCheckboxBuilder checkboxBuilder,
    this.shrinkWrap = false,
  }) : super(
          key: key,
          data: data,
          styleSheet: styleSheet,
          syntaxHighlighter: syntaxHighlighter,
          onTapLink: onTapLink,
          imageDirectory: imageDirectory,
          extensionSet: extensionSet,
          imageBuilder: imageBuilder,
          checkboxBuilder: checkboxBuilder,
        );

  /// See [ScrollView.shrinkWrap]
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context, List<Widget> children) {
    if (children.length == 1 && !shrinkWrap) return children.single;
    return Column(
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

/// A scrolling widget that parses and displays Markdown.
///
/// Supports all GitHub Flavored Markdown from the
/// [specification](https://github.github.com/gfm/).
///
/// See also:
///
///  * [MarkdownBody], which is a non-scrolling container of Markdown.
///  * <https://github.github.com/gfm/>
class Markdown extends MarkdownWidget {
  /// Creates a scrolling widget that parses and displays Markdown.
  const Markdown({
    Key key,
    String data,
    MarkdownStyleSheet styleSheet,
    SyntaxHighlighter syntaxHighlighter,
    MarkdownTapLinkCallback onTapLink,
    String imageDirectory,
    md.ExtensionSet extensionSet,
    MarkdownImageBuilder imageBuilder,
    MarkdownCheckboxBuilder checkboxBuilder,
    this.padding: const EdgeInsets.all(16.0),
    this.physics,
    this.shrinkWrap: false,
  }) : super(
          key: key,
          data: data,
          styleSheet: styleSheet,
          syntaxHighlighter: syntaxHighlighter,
          onTapLink: onTapLink,
          imageDirectory: imageDirectory,
          extensionSet: extensionSet,
          imageBuilder: imageBuilder,
          checkboxBuilder: checkboxBuilder,
        );

  /// The amount of space by which to inset the children.
  final EdgeInsets padding;

  /// How the scroll view should respond to user input.
  ///
  /// See also: [ScrollView.physics]
  final ScrollPhysics physics;

  /// Whether the extent of the scroll view in the scroll direction should be
  /// determined by the contents being viewed.
  ///
  /// See also: [ScrollView.shrinkWrap]
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return ListView(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: children,
    );
  }
}

/// Parse [task list items](https://github.github.com/gfm/#task-list-items-extension-).
class TaskListSyntax extends md.InlineSyntax {
  // FIXME: incorrect
  static final String _pattern = r'^ *\[([ xX])\] +';

  TaskListSyntax() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    md.Element el = md.Element.withTag('input');
    el.attributes['type'] = 'checkbox';
    el.attributes['disabled'] = 'true';
    el.attributes['checked'] = '${match[1].trim().isNotEmpty}';
    parser.addNode(el);
    return true;
  }
}
