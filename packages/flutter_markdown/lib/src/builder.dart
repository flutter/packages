// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;

import '_functions_io.dart' if (dart.library.html) '_functions_web.dart';
import 'style_sheet.dart';
import 'widget.dart';

const List<String> _kBlockTags = const <String>[
  'p',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'li',
  'blockquote',
  'pre',
  'ol',
  'ul',
  'hr',
  'table',
  'thead',
  'tbody',
  'tr'
];

const List<String> _kListTags = const <String>['ul', 'ol'];

bool _isBlockTag(String tag) => _kBlockTags.contains(tag);

bool _isListTag(String tag) => _kListTags.contains(tag);

class _BlockElement {
  _BlockElement(this.tag);

  final String tag;
  final List<Widget> children = <Widget>[];

  int nextListIndex = 0;
}

class _TableElement {
  final List<TableRow> rows = <TableRow>[];
}

/// A collection of widgets that should be placed adjacent to (inline with)
/// other inline elements in the same parent block.
///
/// Inline elements can be textual (a/em/strong) represented by [RichText]
/// widgets or images (img) represented by [Image.network] widgets.
///
/// Inline elements can be nested within other inline elements, inheriting their
/// parent's style along with the style of the block they are in.
///
/// When laying out inline widgets, first, any adjacent RichText widgets are
/// merged, then, all inline widgets are enclosed in a parent [Wrap] widget.
class _InlineElement {
  _InlineElement(this.tag, {this.style});

  final String tag;

  /// Created by merging the style defined for this element's [tag] in the
  /// delegate's [MarkdownStyleSheet] with the style of its parent.
  final TextStyle style;

  final List<Widget> children = <Widget>[];
}

/// A delegate used by [MarkdownBuilder] to control the widgets it creates.
abstract class MarkdownBuilderDelegate {
  /// Returns a gesture recognizer to use for an `a` element with the given
  /// `href` attribute.
  GestureRecognizer createLink(String href);

  /// Returns formatted text to use to display the given contents of a `pre`
  /// element.
  ///
  /// The `styleSheet` is the value of [MarkdownBuilder.styleSheet].
  TextSpan formatText(MarkdownStyleSheet styleSheet, String code);
}

/// Builds a [Widget] tree from parsed Markdown.
///
/// See also:
///
///  * [Markdown], which is a widget that parses and displays Markdown.
class MarkdownBuilder implements md.NodeVisitor {
  /// Creates an object that builds a [Widget] tree from parsed Markdown.
  MarkdownBuilder({
    @required this.delegate,
    @required this.selectable,
    @required this.styleSheet,
    @required this.imageDirectory,
    @required this.imageBuilder,
    @required this.checkboxBuilder,
    @required this.builders,
    this.fitContent = false,
  });

  /// A delegate that controls how link and `pre` elements behave.
  final MarkdownBuilderDelegate delegate;

  /// If true, the text is selectable.
  ///
  /// Defaults to false.
  final bool selectable;

  /// Defines which [TextStyle] objects to use for each type of element.
  final MarkdownStyleSheet styleSheet;

  /// The base directory holding images referenced by Img tags with local or network file paths.
  final String imageDirectory;

  /// Call when build an image widget.
  final MarkdownImageBuilder imageBuilder;

  /// Call when build a checkbox widget.
  final MarkdownCheckboxBuilder checkboxBuilder;

  /// Call when build a custom widget.
  final Map<String, MarkdownElementBuilder> builders;

  /// Whether to allow the widget to fit the child content.
  final bool fitContent;

  final List<String> _listIndents = <String>[];
  final List<_BlockElement> _blocks = <_BlockElement>[];
  final List<_TableElement> _tables = <_TableElement>[];
  final List<_InlineElement> _inlines = <_InlineElement>[];
  final List<GestureRecognizer> _linkHandlers = <GestureRecognizer>[];
  String _currentBlockTag;
  bool _isInBlockquote = false;
  final List<String> _tags = <String>[];

  /// Returns widgets that display the given Markdown nodes.
  ///
  /// The returned widgets are typically used as children in a [ListView].
  List<Widget> build(List<md.Node> nodes) {
    _listIndents.clear();
    _blocks.clear();
    _tables.clear();
    _inlines.clear();
    _linkHandlers.clear();
    _isInBlockquote = false;
    _tags.clear();

    _blocks.add(_BlockElement(null));

    for (md.Node node in nodes) {
      assert(_blocks.length == 1);
      node.accept(this);
    }

    assert(_tables.isEmpty);
    assert(_inlines.isEmpty);
    assert(!_isInBlockquote);
    assert(_tags.isEmpty);
    return _blocks.single.children;
  }

  @override
  bool visitElementBefore(md.Element element) {
    final String tag = element.tag;
    if (_currentBlockTag == null) _currentBlockTag = tag;

    if (builders.containsKey(tag)) {
      builders[tag].visitElementBefore(element);
    }

    if (_isBlockTag(tag)) {
      _addAnonymousBlockIfNeeded();
      if (_isListTag(tag)) {
        _listIndents.add(tag);
      } else if (tag == 'blockquote') {
        _isInBlockquote = true;
      } else if (tag == 'table') {
        _tables.add(_TableElement());
      } else if (tag == 'tr') {
        final length = _tables.single.rows.length;
        BoxDecoration decoration = styleSheet.tableCellsDecoration;
        if (length == 0 || length % 2 == 1) decoration = null;
        _tables.single.rows.add(TableRow(
          decoration: decoration,
          children: <Widget>[],
        ));
      }
      _blocks.add(_BlockElement(tag));
    } else {
      _addParentInlineIfNeeded(_blocks.last.tag);

      TextStyle parentStyle = _inlines.last.style;
      _inlines.add(_InlineElement(
        tag,
        style: parentStyle.merge(styleSheet.styles[tag]),
      ));
    }

    if (tag == 'a') {
      _linkHandlers.add(delegate.createLink(element.attributes['href']));
    }

    return true;
  }

  @override
  void visitText(md.Text text) {
    // Don't allow text directly under the root.
    if (_blocks.last.tag == null) return;

    _addParentInlineIfNeeded(_blocks.last.tag);

    Widget child;
    if (_tags.isNotEmpty && builders.containsKey(_tags.last)) {
      child =
          builders[_tags.last].visitText(text, styleSheet.styles[_tags.last]);
    } else if (_blocks.last.tag == 'pre') {
      child = Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: styleSheet.codeblockPadding,
          child: _buildRichText(delegate.formatText(styleSheet, text.text)),
        ),
      );
    } else {
      child = _buildRichText(
        TextSpan(
          style: _isInBlockquote
              ? _inlines.last.style.merge(styleSheet.blockquote)
              : _inlines.last.style,
          text: text.text.replaceAll(RegExp(r" ?\n"), " "),
          recognizer: _linkHandlers.isNotEmpty ? _linkHandlers.last : null,
        ),
        textAlign: _textAlignForBlockTag(_currentBlockTag),
      );
    }
    _inlines.last.children.add(child);
  }

  @override
  void visitElementAfter(md.Element element) {
    final String tag = element.tag;

    if (_isBlockTag(tag)) {
      _addAnonymousBlockIfNeeded();

      final _BlockElement current = _blocks.removeLast();
      Widget child;

      if (current.children.isNotEmpty) {
        child = Column(
          crossAxisAlignment: fitContent
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.stretch,
          children: current.children,
        );
      } else {
        child = const SizedBox();
      }

      if (_isListTag(tag)) {
        assert(_listIndents.isNotEmpty);
        _listIndents.removeLast();
      } else if (tag == 'li') {
        if (_listIndents.isNotEmpty) {
          if (element.children.length == 0) {
            element.children.add(md.Text(''));
          }
          Widget bullet;
          dynamic el = element.children[0];
          if (el is md.Element && el.attributes['type'] == 'checkbox') {
            bool val = el.attributes['checked'] != 'false';
            bullet = _buildCheckbox(val);
          } else {
            bullet = _buildBullet(_listIndents.last);
          }
          // See #147 and #169
          child = Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: <Widget>[
              SizedBox(
                width: styleSheet.listIndent,
                child: bullet,
              ),
              Expanded(child: child)
            ],
          );
        }
      } else if (tag == 'table') {
        child = Table(
          defaultColumnWidth: styleSheet.tableColumnWidth,
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: styleSheet.tableBorder,
          children: _tables.removeLast().rows,
        );
      } else if (tag == 'blockquote') {
        _isInBlockquote = false;
        child = DecoratedBox(
          decoration: styleSheet.blockquoteDecoration,
          child: Padding(
            padding: styleSheet.blockquotePadding,
            child: child,
          ),
        );
      } else if (tag == 'pre') {
        child = DecoratedBox(
          decoration: styleSheet.codeblockDecoration,
          child: child,
        );
      } else if (tag == 'hr') {
        child = Container(decoration: styleSheet.horizontalRuleDecoration);
      }

      _addBlockChild(child);
    } else {
      final _InlineElement current = _inlines.removeLast();
      final _InlineElement parent = _inlines.last;

      if (builders.containsKey(tag)) {
        final Widget child =
            builders[tag].visitElementAfter(element, styleSheet.styles[tag]);
        if (child != null) current.children[0] = child;
      } else if (tag == 'img') {
        // create an image widget for this image
        current.children.add(_buildImage(
          element.attributes['src'],
          element.attributes['title'],
          element.attributes['alt'],
        ));
      } else if (tag == 'br') {
        current.children.add(_buildRichText(const TextSpan(text: '\n')));
      } else if (tag == 'th' || tag == 'td') {
        TextAlign align;
        String style = element.attributes['style'];
        if (style == null) {
          align = tag == 'th' ? styleSheet.tableHeadAlign : TextAlign.left;
        } else {
          RegExp regExp = RegExp(r'text-align: (left|center|right)');
          Match match = regExp.matchAsPrefix(style);
          switch (match[1]) {
            case 'left':
              align = TextAlign.left;
              break;
            case 'center':
              align = TextAlign.center;
              break;
            case 'right':
              align = TextAlign.right;
              break;
          }
        }
        Widget child = _buildTableCell(
          _mergeInlineChildren(current.children, align),
          textAlign: align,
        );
        _tables.single.rows.last.children.add(child);
      } else if (tag == 'a') {
        _linkHandlers.removeLast();
      }

      if (current.children.isNotEmpty) {
        parent.children.addAll(current.children);
      }
    }
    if (_currentBlockTag == tag) _currentBlockTag = null;
  }

  Widget _buildImage(String src, String title, String alt) {
    final List<String> parts = src.split('#');
    if (parts.isEmpty) return const SizedBox();

    final String path = parts.first;
    double width;
    double height;
    if (parts.length == 2) {
      final List<String> dimensions = parts.last.split('x');
      if (dimensions.length == 2) {
        width = double.parse(dimensions[0]);
        height = double.parse(dimensions[1]);
      }
    }

    Uri uri = Uri.parse(path);
    Widget child;
    if (imageBuilder != null) {
      child = imageBuilder(uri, title, alt);
    } else {
      child = kDefaultImageBuilder(uri, imageDirectory, width, height);
    }

    if (_linkHandlers.isNotEmpty) {
      TapGestureRecognizer recognizer = _linkHandlers.last;
      return GestureDetector(child: child, onTap: recognizer.onTap);
    } else {
      return child;
    }
  }

  Widget _buildCheckbox(bool checked) {
    if (checkboxBuilder != null) {
      return checkboxBuilder(checked);
    }
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Icon(
        checked ? Icons.check_box : Icons.check_box_outline_blank,
        size: styleSheet.checkbox.fontSize,
        color: styleSheet.checkbox.color,
      ),
    );
  }

  Widget _buildBullet(String listTag) {
    if (listTag == 'ul') {
      return Text(
        '•',
        textAlign: TextAlign.center,
        style: styleSheet.listBullet,
      );
    }

    final int index = _blocks.last.nextListIndex;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        '${index + 1}.',
        textAlign: TextAlign.right,
        style: styleSheet.listBullet,
      ),
    );
  }

  Widget _buildTableCell(List<Widget> children, {TextAlign textAlign}) {
    return TableCell(
      child: Padding(
        padding: styleSheet.tableCellsPadding,
        child: DefaultTextStyle(
          style: styleSheet.tableBody,
          textAlign: textAlign,
          child: Wrap(children: children),
        ),
      ),
    );
  }

  void _addParentInlineIfNeeded(String tag) {
    if (_inlines.isEmpty) {
      _inlines.add(_InlineElement(
        tag,
        style: styleSheet.styles[tag],
      ));
    }
  }

  void _addBlockChild(Widget child) {
    final _BlockElement parent = _blocks.last;
    if (parent.children.isNotEmpty) {
      parent.children.add(SizedBox(height: styleSheet.blockSpacing));
    }
    parent.children.add(child);
    parent.nextListIndex += 1;
  }

  void _addAnonymousBlockIfNeeded() {
    if (_inlines.isEmpty) return;

    WrapAlignment blockAlignment = WrapAlignment.start;
    TextAlign textAlign = TextAlign.start;
    if (_isBlockTag(_currentBlockTag)) {
      blockAlignment = _wrapAlignmentForBlockTag(_currentBlockTag);
      textAlign = _textAlignForBlockTag(_currentBlockTag);
    }

    final _InlineElement inline = _inlines.single;
    if (inline.children.isNotEmpty) {
      List<Widget> mergedInlines = _mergeInlineChildren(
        inline.children,
        textAlign,
      );
      final Wrap wrap = Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: mergedInlines,
        alignment: blockAlignment,
      );
      _addBlockChild(wrap);
      _inlines.clear();
    }
  }

  /// Merges adjacent [TextSpan] children
  List<Widget> _mergeInlineChildren(
    List<Widget> children,
    TextAlign textAlign,
  ) {
    List<Widget> mergedTexts = <Widget>[];
    for (Widget child in children) {
      if (mergedTexts.isNotEmpty &&
          mergedTexts.last is RichText &&
          child is RichText) {
        RichText previous = mergedTexts.removeLast();
        TextSpan previousTextSpan = previous.text;
        List<TextSpan> children = previousTextSpan.children != null
            ? List.from(previousTextSpan.children)
            : [previousTextSpan];
        children.add(child.text);
        TextSpan mergedSpan = TextSpan(children: children);
        mergedTexts.add(_buildRichText(
          mergedSpan,
          textAlign: textAlign,
        ));
      } else if (mergedTexts.isNotEmpty &&
          mergedTexts.last is SelectableText &&
          child is SelectableText) {
        SelectableText previous = mergedTexts.removeLast();
        TextSpan previousTextSpan = previous.textSpan;
        List<TextSpan> children = previousTextSpan.children != null
            ? List.from(previousTextSpan.children)
            : [previousTextSpan];
        children.add(child.textSpan);
        TextSpan mergedSpan = TextSpan(children: children);
        mergedTexts.add(
          _buildRichText(
            mergedSpan,
            textAlign: textAlign,
          ),
        );
      } else {
        mergedTexts.add(child);
      }
    }
    return mergedTexts;
  }

  TextAlign _textAlignForBlockTag(String blockTag) {
    WrapAlignment wrapAlignment = _wrapAlignmentForBlockTag(blockTag);
    switch (wrapAlignment) {
      case WrapAlignment.start:
        return TextAlign.start;
      case WrapAlignment.center:
        return TextAlign.center;
      case WrapAlignment.end:
        return TextAlign.end;
      case WrapAlignment.spaceAround:
        return TextAlign.justify;
      case WrapAlignment.spaceBetween:
        return TextAlign.justify;
      case WrapAlignment.spaceEvenly:
        return TextAlign.justify;
    }
    return TextAlign.start;
  }

  WrapAlignment _wrapAlignmentForBlockTag(String blockTag) {
    if (blockTag == "p") return styleSheet.textAlign;
    if (blockTag == "h1") return styleSheet.h1Align;
    if (blockTag == "h2") return styleSheet.h2Align;
    if (blockTag == "h3") return styleSheet.h3Align;
    if (blockTag == "h4") return styleSheet.h4Align;
    if (blockTag == "h5") return styleSheet.h5Align;
    if (blockTag == "h6") return styleSheet.h6Align;
    if (blockTag == "ul") return styleSheet.unorderedListAlign;
    if (blockTag == "ol") return styleSheet.orderedListAlign;
    if (blockTag == "blockquote") return styleSheet.blockquoteAlign;
    if (blockTag == "pre") return styleSheet.codeblockAlign;
    if (blockTag == "hr") print("Markdown did not handle hr for alignment");
    if (blockTag == "li") print("Markdown did not handle li for alignment");
    return WrapAlignment.start;
  }

  Widget _buildRichText(TextSpan text, {TextAlign textAlign}) {
    if (selectable) {
      return SelectableText.rich(
        text,
        //textScaleFactor: styleSheet.textScaleFactor,
        textAlign: textAlign ?? TextAlign.start,
      );
    } else {
      return RichText(
        text: text,
        textScaleFactor: styleSheet.textScaleFactor,
        textAlign: textAlign ?? TextAlign.start,
      );
    }
  }
}
