// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '_functions_io.dart' if (dart.library.html) '_functions_web.dart';

/// Signature for callbacks used by [MarkdownWidget] when the user taps a link.
/// The callback will return the link text, destination, and title from the
/// Markdown link tag in the document.
///
/// Used by [MarkdownWidget.onTapLink].
typedef MarkdownTapLinkCallback = void Function(
    String text, String? href, String title);

/// Signature for custom image widget.
///
/// Used by [MarkdownWidget.imageBuilder]
typedef MarkdownImageBuilder = Widget Function(
    Uri uri, String? title, String? alt);

/// Signature for custom checkbox widget.
///
/// Used by [MarkdownWidget.checkboxBuilder]
typedef MarkdownCheckboxBuilder = Widget Function(bool value);

/// Signature for custom bullet widget.
///
/// Used by [MarkdownWidget.bulletBuilder]
typedef MarkdownBulletBuilder = Widget Function(int index, BulletStyle style);

/// Enumeration sent to the user when calling [MarkdownBulletBuilder]
///
/// Use this to differentiate the bullet styling when building your own.
enum BulletStyle {
  /// An ordered list.
  orderedList,

  /// An unordered list.
  unorderedList,
}

/// Creates a format [TextSpan] given a string.
///
/// Used by [MarkdownWidget] to highlight the contents of `pre` elements.
abstract class SyntaxHighlighter {
  // ignore: one_member_abstracts
  /// Returns the formatted [TextSpan] for the given string.
  TextSpan format(String source);
}

/// An interface for an element builder.
abstract class MarkdownElementBuilder {
  /// Called when an Element has been reached, before its children have been
  /// visited.
  void visitElementBefore(md.Element element) {}

  /// Called when a text node has been reached.
  ///
  /// If [MarkdownWidget.styleSheet] has a style of this tag, will passing
  /// to [preferredStyle].
  ///
  /// If you needn't build a widget, return null.
  Widget? visitText(md.Text text, TextStyle? preferredStyle) => null;

  /// Called when an Element has been reached, after its children have been
  /// visited.
  ///
  /// If [MarkdownWidget.styleSheet] has a style of this tag, will passing
  /// to [preferredStyle].
  ///
  /// If you needn't build a widget, return null.
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) =>
      null;
}

/// Enum to specify which theme being used when creating [MarkdownStyleSheet]
///
/// [material] - create MarkdownStyleSheet based on MaterialTheme
/// [cupertino] - create MarkdownStyleSheet based on CupertinoTheme
/// [platform] - create MarkdownStyleSheet based on the Platform where the
/// is running on. Material on Android and Cupertino on iOS
enum MarkdownStyleSheetBaseTheme {
  /// Creates a MarkdownStyleSheet based on MaterialTheme.
  material,

  /// Creates a MarkdownStyleSheet based on CupertinoTheme.
  cupertino,

  /// Creates a MarkdownStyleSheet whose theme is based on the current platform.
  platform,
}

/// Enumeration of alignment strategies for the cross axis of list items.
enum MarkdownListItemCrossAxisAlignment {
  /// Uses [CrossAxisAlignment.baseline] for the row the bullet and the list
  /// item are placed in.
  ///
  /// This alignment will ensure that the bullet always lines up with
  /// the list text on the baseline.
  ///
  /// However, note that this alignment does not support intrinsic height
  /// measurements because [RenderFlex] does not support it for
  /// [CrossAxisAlignment.baseline].
  /// See https://github.com/flutter/flutter_markdown/issues/311 for cases,
  /// where this might be a problem for you.
  ///
  /// See also:
  /// * [start], which allows for intrinsic height measurements.
  baseline,

  /// Uses [CrossAxisAlignment.start] for the row the bullet and the list item
  /// are placed in.
  ///
  /// This alignment will ensure that intrinsic height measurements work.
  ///
  /// However, note that this alignment might not line up the bullet with the
  /// list text in the way you would expect in certain scenarios.
  /// See https://github.com/flutter/flutter_markdown/issues/169 for example
  /// cases that do not produce expected results.
  ///
  /// See also:
  /// * [baseline], which will position the bullet and list item on the
  ///   baseline.
  start,
}

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
    Key? key,
    required this.data,
    this.anchorController,
    this.selectable = false,
    this.styleSheet,
    this.styleSheetTheme = MarkdownStyleSheetBaseTheme.material,
    this.syntaxHighlighter,
    this.onTapLink,
    this.onTapText,
    this.imageDirectory,
    this.blockSyntaxes,
    this.inlineSyntaxes,
    this.extensionSet,
    this.imageBuilder,
    this.checkboxBuilder,
    this.bulletBuilder,
    this.builders = const <String, MarkdownElementBuilder>{},
    this.paddingBuilders = const <String, MarkdownPaddingBuilder>{},
    this.fitContent = false,
    this.listItemCrossAxisAlignment =
        MarkdownListItemCrossAxisAlignment.baseline,
    this.softLineBreak = false,
  }) : super(key: key);

  /// The Markdown to display.
  final String data;

  /// If true, the text is selectable.
  ///
  /// Defaults to false.
  final bool selectable;

  /// The styles to use when displaying the Markdown.
  ///
  /// If null, the styles are inferred from the current [Theme].
  final MarkdownStyleSheet? styleSheet;

  /// Setting to specify base theme for MarkdownStyleSheet
  ///
  /// Default to [MarkdownStyleSheetBaseTheme.material]
  final MarkdownStyleSheetBaseTheme? styleSheetTheme;

  /// The syntax highlighter used to color text in `pre` elements.
  ///
  /// If null, the [MarkdownStyleSheet.code] style is used for `pre` elements.
  final SyntaxHighlighter? syntaxHighlighter;

  /// Called when the user taps a link.
  final MarkdownTapLinkCallback? onTapLink;

  /// Default tap handler used when [selectable] is set to true
  final VoidCallback? onTapText;

  /// The base directory holding images referenced by Img tags with local or network file paths.
  final String? imageDirectory;

  /// Collection of custom block syntax types to be used parsing the Markdown data.
  final List<md.BlockSyntax>? blockSyntaxes;

  /// Collection of custom inline syntax types to be used parsing the Markdown data.
  final List<md.InlineSyntax>? inlineSyntaxes;

  /// Markdown syntax extension set
  ///
  /// Defaults to [md.ExtensionSet.gitHubFlavored]
  final md.ExtensionSet? extensionSet;

  /// Call when build an image widget.
  final MarkdownImageBuilder? imageBuilder;

  /// Call when build a checkbox widget.
  final MarkdownCheckboxBuilder? checkboxBuilder;

  /// Called when building a bullet
  final MarkdownBulletBuilder? bulletBuilder;

  /// Render certain tags, usually used with [extensionSet]
  ///
  /// For example, we will add support for `sub` tag:
  ///
  /// ```dart
  /// builders: {
  ///   'sub': SubscriptBuilder(),
  /// }
  /// ```
  ///
  /// The `SubscriptBuilder` is a subclass of [MarkdownElementBuilder].
  final Map<String, MarkdownElementBuilder> builders;

  /// Add padding for different tags (use only for block elements and img)
  ///
  /// For example, we will add padding for `img` tag:
  ///
  /// ```dart
  /// paddingBuilders: {
  ///   'img': ImgPaddingBuilder(),
  /// }
  /// ```
  ///
  /// The `ImgPaddingBuilder` is a subclass of [MarkdownPaddingBuilder].
  final Map<String, MarkdownPaddingBuilder> paddingBuilders;

  /// Whether to allow the widget to fit the child content.
  final bool fitContent;

  /// Controls the cross axis alignment for the bullet and list item content
  /// in lists.
  ///
  /// Defaults to [MarkdownListItemCrossAxisAlignment.baseline], which
  /// does not allow for intrinsic height measurements.
  final MarkdownListItemCrossAxisAlignment listItemCrossAxisAlignment;

  /// The soft line break is used to identify the spaces at the end of aline of
  /// text and the leading spaces in the immediately following the line of text.
  ///
  /// Default these spaces are removed in accordance with the Markdown
  /// specification on soft line breaks when lines of text are joined.
  final bool softLineBreak;

  final AnchorController? anchorController;

  /// Subclasses should override this function to display the given children,
  /// which are the parsed representation of [data].
  @protected
  Widget build(BuildContext context, List<Widget>? children);

  @override
  _MarkdownWidgetState createState() => _MarkdownWidgetState();
}

class _MarkdownWidgetState extends State<MarkdownWidget>
    implements MarkdownBuilderDelegate {
  List<Widget>? _children;
  final List<GestureRecognizer> _recognizers = <GestureRecognizer>[];

  @override
  void didChangeDependencies() {
    _parseMarkdown();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(MarkdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data ||
        widget.styleSheet != oldWidget.styleSheet) {
      _parseMarkdown();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _parseMarkdown() {
    final MarkdownStyleSheet fallbackStyleSheet =
        kFallbackStyle(context, widget.styleSheetTheme);
    final MarkdownStyleSheet styleSheet =
        fallbackStyleSheet.merge(widget.styleSheet);

    _disposeRecognizers();

    final md.Document document = md.Document(
      blockSyntaxes: widget.blockSyntaxes,
      inlineSyntaxes: (widget.inlineSyntaxes ?? <md.InlineSyntax>[])
        ..add(TaskListSyntax()),
      extensionSet: widget.extensionSet ?? md.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    );

    // Parse the source Markdown data into nodes of an Abstract Syntax Tree.
    final List<String> lines = const LineSplitter().convert(widget.data);
    final List<md.Node> astNodes = document.parseLines(lines);

    // Configure a Markdown widget builder to traverse the AST nodes and
    // create a widget tree based on the elements.
    final MarkdownBuilder builder = MarkdownBuilder(
      delegate: this,
      selectable: widget.selectable,
      styleSheet: styleSheet,
      imageDirectory: widget.imageDirectory,
      imageBuilder: widget.imageBuilder,
      checkboxBuilder: widget.checkboxBuilder,
      bulletBuilder: widget.bulletBuilder,
      builders: widget.builders,
      paddingBuilders: widget.paddingBuilders,
      fitContent: widget.fitContent,
      listItemCrossAxisAlignment: widget.listItemCrossAxisAlignment,
      onTapText: widget.onTapText,
      softLineBreak: widget.softLineBreak,
    );

    widget.anchorController?.registerMarkdownBuilder(builder);

    _children = builder.build(astNodes);
  }

  void _disposeRecognizers() {
    if (_recognizers.isEmpty) {
      return;
    }
    final List<GestureRecognizer> localRecognizers =
        List<GestureRecognizer>.from(_recognizers);
    _recognizers.clear();
    for (final GestureRecognizer recognizer in localRecognizers)
      recognizer.dispose();
  }

  @override
  GestureRecognizer createLink(String text, String? href, String title) {
    final TapGestureRecognizer recognizer = TapGestureRecognizer()
      ..onTap = () {
        if (widget.onTapLink != null) {
          widget.onTapLink!(text, href, title);
        }
      };
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  TextSpan formatText(MarkdownStyleSheet styleSheet, String code) {
    code = code.replaceAll(RegExp(r'\n$'), '');
    if (widget.syntaxHighlighter != null) {
      return widget.syntaxHighlighter!.format(code);
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
    Key? key,
    required String data,
    AnchorController? anchorController,
    bool selectable = false,
    MarkdownStyleSheet? styleSheet,
    MarkdownStyleSheetBaseTheme? styleSheetTheme,
    SyntaxHighlighter? syntaxHighlighter,
    MarkdownTapLinkCallback? onTapLink,
    VoidCallback? onTapText,
    String? imageDirectory,
    List<md.BlockSyntax>? blockSyntaxes,
    List<md.InlineSyntax>? inlineSyntaxes,
    md.ExtensionSet? extensionSet,
    MarkdownImageBuilder? imageBuilder,
    MarkdownCheckboxBuilder? checkboxBuilder,
    MarkdownBulletBuilder? bulletBuilder,
    Map<String, MarkdownElementBuilder> builders =
        const <String, MarkdownElementBuilder>{},
    Map<String, MarkdownPaddingBuilder> paddingBuilders =
        const <String, MarkdownPaddingBuilder>{},
    MarkdownListItemCrossAxisAlignment listItemCrossAxisAlignment =
        MarkdownListItemCrossAxisAlignment.baseline,
    this.shrinkWrap = true,
    bool fitContent = true,
    bool softLineBreak = false,
  }) : super(
          key: key,
          data: data,
          anchorController: anchorController,
          selectable: selectable,
          styleSheet: styleSheet,
          styleSheetTheme: styleSheetTheme,
          syntaxHighlighter: syntaxHighlighter,
          onTapLink: onTapLink,
          onTapText: onTapText,
          imageDirectory: imageDirectory,
          blockSyntaxes: blockSyntaxes,
          inlineSyntaxes: inlineSyntaxes,
          extensionSet: extensionSet,
          imageBuilder: imageBuilder,
          checkboxBuilder: checkboxBuilder,
          builders: builders,
          paddingBuilders: paddingBuilders,
          listItemCrossAxisAlignment: listItemCrossAxisAlignment,
          bulletBuilder: bulletBuilder,
          fitContent: fitContent,
          softLineBreak: softLineBreak,
        );

  /// See [ScrollView.shrinkWrap]
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context, List<Widget>? children) {
    if (children!.length == 1) {
      return children.single;
    }
    return Column(
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment:
          fitContent ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class AnchorController {
  factory AnchorController({
    ItemPositionsListener? itemPositionsListener,
    ItemScrollController? itemScrollController,
  }) {
    return AnchorController._(
      itemPositionsListener ?? ItemPositionsListener.create(),
      itemScrollController ?? ItemScrollController(),
    );
  }

  AnchorController._(
    this._itemPositionsListener,
    this._itemScrollController,
  ) {
    _itemPositionsListener.itemPositions.addListener(() {
      _anchorPositions.value =
          _filterAnchorPositions(_itemPositionsListener.itemPositions.value);
    });
  }

  final ItemPositionsListener _itemPositionsListener;
  final ItemScrollController _itemScrollController;
  int? Function(String anchorId)? _getIndexOfAnchor;
  List<IndexedAnchorData> Function()? _getIndexedAnchors;
  // TODO: We used this before? Should we cache _getIndexedAnchors?
  // List<IndexedAnchorData>? _indexedAnchors;
  List<IndexedAnchorData> get _indexedAnchors => _getIndexedAnchors != null
      ? _getIndexedAnchors!()
      : <IndexedAnchorData>[];

  final ValueNotifier<Iterable<AnchorPosition>> _anchorPositions =
      ValueNotifier<Iterable<AnchorPosition>>(const <AnchorPosition>[]);

  void registerMarkdownBuilder(MarkdownBuilder builder) {
    _getIndexOfAnchor = builder.getIndexForAnchor;
    _getIndexedAnchors = builder.getIndexedAnchors;
  }

  Future<void> scrollToAnchor(
    String anchorId, {
    double alignment = 0,
    required Duration duration,
    Curve curve = Curves.linear,
    List<double> opacityAnimationWeights = const <double>[40, 20, 40],
  }) {
    final int? index = _getIndexOfAnchor!(anchorId);
    if (index == null) {
      throw ArgumentError('Unknown anchorId');
    }
    return _itemScrollController.scrollTo(
      index: index,
      alignment: alignment,
      duration: duration,
      curve: curve,
      opacityAnimationWeights: opacityAnimationWeights,
    );
  }

  /// The position of anchors that are at least partially visible in the viewport.
  ValueListenable<Iterable<AnchorPosition>> get anchorPositions {
    return _anchorPositions;
  }

  Iterable<AnchorPosition> _filterAnchorPositions(
      Iterable<ItemPosition> itemPositions) {
    final List<AnchorPosition> _anchorPositions = <AnchorPosition>[];

    for (final ItemPosition itemPosition in itemPositions) {
      final Iterable<IndexedAnchorData> anchorsWithIndex =
          _indexedAnchors.where((IndexedAnchorData indexedAnchor) =>
              itemPosition.index == indexedAnchor.index);

      if (anchorsWithIndex.isEmpty) {
        continue;
      }

      _anchorPositions.add(AnchorPosition(
          anchor: anchorsWithIndex.first,
          itemLeadingEdge: itemPosition.itemLeadingEdge,
          itemTrailingEdge: itemPosition.itemTrailingEdge));
    }

    return _anchorPositions;
  }
}

/// The Position of an Anchor on screen.
/// Can be observed by using [AnchorController.anchorPositions].
/// ```dart
/// // Table of contents heading at the top of the screen
/// AnchorPosition(
///   anchor: AnchorData('table-of-contents', 'table of contents'),
///   itemLeadingEdge: 0.0,
///   itemTrailingEdge: 0.1,
/// );
/// ```
/// Akin to an [ItemPosition] returned by [ScrollablePositionedList],
/// but only specific for [AnchorData].
class AnchorPosition {
  AnchorPosition({
    required this.anchor,
    required this.itemLeadingEdge,
    required this.itemTrailingEdge,
  });

  final AnchorData anchor;
  final double itemLeadingEdge;
  final double itemTrailingEdge;

  @override
  String toString() =>
      'AnchorPosition(anchor: $anchor, itemLeadingEdge: $itemLeadingEdge, itemTrailingEdge: $itemTrailingEdge)';
}

/// A scrolling widget for markdown that supports relative anchors.
/// Relative anchors are used to scroll to a specific position inside markdown
/// text.
///
/// The scrolling can be controlled via [AnchorController].
class RelativeAnchorsMarkdown extends MarkdownWidget {
  /// Creates a scrolling widget that parses and displays Markdown.
  const RelativeAnchorsMarkdown({
    Key? key,
    required String data,
    required this.anchorController,
    bool selectable = false,
    MarkdownStyleSheet? styleSheet,
    MarkdownStyleSheetBaseTheme? styleSheetTheme,
    SyntaxHighlighter? syntaxHighlighter,
    MarkdownTapLinkCallback? onTapLink,
    VoidCallback? onTapText,
    String? imageDirectory,
    List<md.BlockSyntax>? blockSyntaxes,
    List<md.InlineSyntax>? inlineSyntaxes,
    md.ExtensionSet? extensionSet,
    MarkdownImageBuilder? imageBuilder,
    MarkdownCheckboxBuilder? checkboxBuilder,
    MarkdownBulletBuilder? bulletBuilder,
    Map<String, MarkdownElementBuilder> builders =
        const <String, MarkdownElementBuilder>{},
    Map<String, MarkdownPaddingBuilder> paddingBuilders =
        const <String, MarkdownPaddingBuilder>{},
    MarkdownListItemCrossAxisAlignment listItemCrossAxisAlignment =
        MarkdownListItemCrossAxisAlignment.baseline,
    this.padding = const EdgeInsets.all(16.0),
    this.physics,
    this.shrinkWrap = false,
    bool softLineBreak = false,
  }) : super(
          key: key,
          data: data,
          anchorController: anchorController,
          selectable: selectable,
          styleSheet: styleSheet,
          styleSheetTheme: styleSheetTheme,
          syntaxHighlighter: syntaxHighlighter,
          onTapLink: onTapLink,
          onTapText: onTapText,
          imageDirectory: imageDirectory,
          blockSyntaxes: blockSyntaxes,
          inlineSyntaxes: inlineSyntaxes,
          extensionSet: extensionSet,
          imageBuilder: imageBuilder,
          checkboxBuilder: checkboxBuilder,
          builders: builders,
          paddingBuilders: paddingBuilders,
          listItemCrossAxisAlignment: listItemCrossAxisAlignment,
          bulletBuilder: bulletBuilder,
          softLineBreak: softLineBreak,
        );

  /// The amount of space by which to inset the children.
  final EdgeInsets padding;

  final AnchorController anchorController;

  /// How the scroll view should respond to user input.
  ///
  /// See also: [ScrollView.physics]
  final ScrollPhysics? physics;

  /// Whether the extent of the scroll view in the scroll direction should be
  /// determined by the contents being viewed.
  ///
  /// See also: [ScrollView.shrinkWrap]
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context, List<Widget>? children) {
    children!;
    return ScrollablePositionedList.builder(
      padding: padding,
      itemCount: children.length,
      itemBuilder: (BuildContext context, int index) => children[index],
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemScrollController: anchorController._itemScrollController,
      itemPositionsListener: anchorController._itemPositionsListener,
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
    Key? key,
    required String data,
    AnchorController? anchorController,
    bool selectable = false,
    MarkdownStyleSheet? styleSheet,
    MarkdownStyleSheetBaseTheme? styleSheetTheme,
    SyntaxHighlighter? syntaxHighlighter,
    MarkdownTapLinkCallback? onTapLink,
    VoidCallback? onTapText,
    String? imageDirectory,
    List<md.BlockSyntax>? blockSyntaxes,
    List<md.InlineSyntax>? inlineSyntaxes,
    md.ExtensionSet? extensionSet,
    MarkdownImageBuilder? imageBuilder,
    MarkdownCheckboxBuilder? checkboxBuilder,
    MarkdownBulletBuilder? bulletBuilder,
    Map<String, MarkdownElementBuilder> builders =
        const <String, MarkdownElementBuilder>{},
    Map<String, MarkdownPaddingBuilder> paddingBuilders =
        const <String, MarkdownPaddingBuilder>{},
    MarkdownListItemCrossAxisAlignment listItemCrossAxisAlignment =
        MarkdownListItemCrossAxisAlignment.baseline,
    this.padding = const EdgeInsets.all(16.0),
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    bool softLineBreak = false,
  }) : super(
          key: key,
          data: data,
          anchorController: anchorController,
          selectable: selectable,
          styleSheet: styleSheet,
          styleSheetTheme: styleSheetTheme,
          syntaxHighlighter: syntaxHighlighter,
          onTapLink: onTapLink,
          onTapText: onTapText,
          imageDirectory: imageDirectory,
          blockSyntaxes: blockSyntaxes,
          inlineSyntaxes: inlineSyntaxes,
          extensionSet: extensionSet,
          imageBuilder: imageBuilder,
          checkboxBuilder: checkboxBuilder,
          builders: builders,
          paddingBuilders: paddingBuilders,
          listItemCrossAxisAlignment: listItemCrossAxisAlignment,
          bulletBuilder: bulletBuilder,
          softLineBreak: softLineBreak,
        );

  /// The amount of space by which to inset the children.
  final EdgeInsets padding;

  /// An object that can be used to control the position to which this scroll view is scrolled.
  ///
  /// See also: [ScrollView.controller]
  final ScrollController? controller;

  /// How the scroll view should respond to user input.
  ///
  /// See also: [ScrollView.physics]
  final ScrollPhysics? physics;

  /// Whether the extent of the scroll view in the scroll direction should be
  /// determined by the contents being viewed.
  ///
  /// See also: [ScrollView.shrinkWrap]
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context, List<Widget>? children) {
    return ListView(
      padding: padding,
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: children!,
    );
  }
}

/// Parse [task list items](https://github.github.com/gfm/#task-list-items-extension-).
class TaskListSyntax extends md.InlineSyntax {
  /// Cretaes a new instance.
  TaskListSyntax() : super(_pattern);

  // FIXME: Waiting for dart-lang/markdown#269 to land
  static const String _pattern = r'^ *\[([ xX])\] +';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final md.Element el = md.Element.withTag('input');
    el.attributes['type'] = 'checkbox';
    el.attributes['disabled'] = 'true';
    el.attributes['checked'] = '${match[1]!.trim().isNotEmpty}';
    parser.addNode(el);
    return true;
  }
}

/// An interface for an padding builder for element.
abstract class MarkdownPaddingBuilder {
  /// Called when an Element has been reached, before its children have been
  /// visited.
  void visitElementBefore(md.Element element) {}

  /// Called when a widget node has been rendering and need tag padding.
  EdgeInsets getPadding() => EdgeInsets.zero;
}
