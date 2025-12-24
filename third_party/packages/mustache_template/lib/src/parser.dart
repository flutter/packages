// TODO(stuartmorgan): Remove this. See https://github.com/flutter/flutter/issues/174722.
// ignore_for_file: public_member_api_docs

import 'node.dart';
import 'scanner.dart';
import 'template_exception.dart';
import 'token.dart';

List<Node> parse(
  String source,
  bool lenient,
  String? templateName,
  String delimiters,
) {
  final parser = Parser(source, templateName, delimiters, lenient: lenient);
  return parser.parse();
}

class Tag {
  Tag(this.type, this.name, this.start, this.end);
  final TagType type;
  final String name;
  final int start;
  final int end;
}

class TagType {
  const TagType(this.name);
  final String name;

  static const TagType openSection = TagType('openSection');
  static const TagType openInverseSection = TagType('openInverseSection');
  static const TagType closeSection = TagType('closeSection');
  static const TagType variable = TagType('variable');
  static const TagType tripleMustache = TagType('tripleMustache');
  static const TagType unescapedVariable = TagType('unescapedVariable');
  static const TagType partial = TagType('partial');
  static const TagType comment = TagType('comment');
  static const TagType changeDelimiter = TagType('changeDelimiter');
}

class Parser {
  Parser(
    String source,
    String? templateName,
    String delimiters, {
    bool lenient = false,
  }) : _source = source,
       _templateName = templateName,
       _delimiters = delimiters,
       _lenient = lenient,
       _scanner = Scanner(source, templateName, delimiters);

  final String _source;
  final bool _lenient;
  final String? _templateName;
  final String _delimiters;
  final Scanner _scanner;
  final List<SectionNode> _stack = <SectionNode>[];
  late List<Token> _tokens;
  late String _currentDelimiters;
  int _offset = 0;

  List<Node> parse() {
    _tokens = _scanner.scan();
    _currentDelimiters = _delimiters;
    _stack.clear();
    _stack.add(SectionNode('root', 0, 0, _delimiters));

    // Handle a standalone tag on first line, including special case where the
    // first line is empty.
    final Token? lineEnd = _readIf(TokenType.lineEnd, eofOk: true);
    if (lineEnd != null) {
      _appendTextToken(lineEnd);
    }
    _parseLine();

    for (Token? token = _peek(); token != null; token = _peek()) {
      switch (token.type) {
        case TokenType.text:
        case TokenType.whitespace:
          _read();
          _appendTextToken(token);

        case TokenType.openDelimiter:
          final Tag? tag = _readTag();
          final Node? node = _createNodeFromTag(tag);
          if (tag != null) {
            _appendTag(tag, node);
          }

        case TokenType.changeDelimiter:
          _read();
          _currentDelimiters = token.value;

        case TokenType.lineEnd:
          _appendTextToken(_read()!);
          _parseLine();

        default:
          // TODO(stuartmorgan): Convert to StateError.
          throw Exception('Unreachable code.');
      }
    }

    if (_stack.length != 1) {
      throw TemplateException(
        "Unclosed tag: '${_stack.last.name}'.",
        _templateName,
        _source,
        _stack.last.start,
      );
    }

    return _stack.last.children;
  }

  // Returns null on EOF.
  Token? _peek() => _offset < _tokens.length ? _tokens[_offset] : null;

  // Returns null on EOF.
  Token? _read() {
    Token? t;
    if (_offset < _tokens.length) {
      t = _tokens[_offset];
      _offset++;
    }
    return t;
  }

  Token _expect(TokenType type) {
    final Token? token = _read();
    if (token == null) {
      throw _errorEof();
    }
    if (token.type != type) {
      throw _error('Expected: $type found: ${token.type}.', _offset);
    }
    return token;
  }

  Token? _readIf(TokenType type, {bool eofOk = false}) {
    final Token? token = _peek();
    if (!eofOk && token == null) {
      throw _errorEof();
    }
    return token != null && token.type == type ? _read() : null;
  }

  TemplateException _errorEof() =>
      _error('Unexpected end of input.', _source.length - 1);

  TemplateException _error(String msg, int offset) =>
      TemplateException(msg, _templateName, _source, offset);

  // Add a text node to top most section on the stack and merge consecutive
  // text nodes together.
  void _appendTextToken(Token token) {
    assert(
      const <TokenType>[
        TokenType.text,
        TokenType.lineEnd,
        TokenType.whitespace,
      ].contains(token.type),
    );
    final List<Node> children = _stack.last.children;
    if (children.isEmpty || children.last is! TextNode) {
      children.add(TextNode(token.value, token.start, token.end));
    } else {
      final last = children.removeLast() as TextNode;
      final node = TextNode(last.text + token.value, last.start, token.end);
      children.add(node);
    }
  }

  // Add the node to top most section on the stack. If a section node then
  // push it onto the stack, if a close section tag, then pop the stack.
  void _appendTag(Tag tag, Node? node) {
    switch (tag.type) {
      // {{#...}}  {{^...}}
      case TagType.openSection:
      case TagType.openInverseSection:
        _stack.last.children.add(node!);
        _stack.add(node as SectionNode);

      // {{/...}}
      case TagType.closeSection:
        if (tag.name != _stack.last.name) {
          throw TemplateException(
            'Mismatched tag, expected: '
            "'${_stack.last.name}', was: '${tag.name}'",
            _templateName,
            _source,
            tag.start,
          );
        }
        final SectionNode node = _stack.removeLast();
        node.contentEnd = tag.start;

      // {{...}} {{&...}} {{{...}}}
      case TagType.variable:
      case TagType.unescapedVariable:
      case TagType.tripleMustache:
      case TagType.partial:
        if (node != null) {
          _stack.last.children.add(node);
        }

      case TagType.comment:
      case TagType.changeDelimiter:
        // Ignore.
        break;

      default:
        // TODO(stuartmorgan): Convert to StateError.
        throw Exception('Unreachable code.');
    }
  }

  // Handle standalone tags and indented partials.
  //
  // A "standalone tag" in the spec is a tag one a line where the line only
  // contains whitespace. During rendering the whitespace is omitted.
  // Standalone partials also indent their content to match the tag during
  // rendering.

  // match:
  // lineEnd whitespace openDelimiter any* closeDelimiter whitespace lineEnd
  //
  // Where lineEnd can also mean start/end of the source.
  void _parseLine() {
    // If first token is a newline append it.
    final Token? t = _peek();
    if (t != null && t.type == TokenType.lineEnd) {
      _appendTextToken(t);
    }

    // Continue parsing standalone lines until we find one than isn't a
    // standalone line.
    while (_peek() != null) {
      _readIf(TokenType.lineEnd, eofOk: true);
      final Token? precedingWhitespace = _readIf(
        TokenType.whitespace,
        eofOk: true,
      );
      final String indent = precedingWhitespace == null
          ? ''
          : precedingWhitespace.value;
      final Tag? tag = _readTag();
      final Node? tagNode = _createNodeFromTag(tag, partialIndent: indent);
      final Token? followingWhitespace = _readIf(
        TokenType.whitespace,
        eofOk: true,
      );

      const standaloneTypes = <TagType>[
        TagType.openSection,
        TagType.closeSection,
        TagType.openInverseSection,
        TagType.partial,
        TagType.comment,
        TagType.changeDelimiter,
      ];

      if (tag != null &&
          (_peek() == null || _peek()!.type == TokenType.lineEnd) &&
          standaloneTypes.contains(tag.type)) {
        // This is a tag on a "standalone line", so do not create text nodes
        // for whitespace, or the following newline.
        _appendTag(tag, tagNode);
        // Now continue to loop and parse the next line.
      } else {
        // This is not a standalone line so add the whitespace to the ast.
        if (precedingWhitespace != null) {
          _appendTextToken(precedingWhitespace);
        }
        if (tag != null) {
          _appendTag(tag, tagNode);
        }
        if (followingWhitespace != null) {
          _appendTextToken(followingWhitespace);
        }
        // Done parsing standalone lines. Exit the loop.
        break;
      }
    }
  }

  final RegExp _validIdentifier = RegExp(r'^[0-9a-zA-Z\_\-\.]+$');

  static const Map<String, TagType> _tagTypeMap = <String, TagType>{
    '#': TagType.openSection,
    '^': TagType.openInverseSection,
    '/': TagType.closeSection,
    '&': TagType.unescapedVariable,
    '>': TagType.partial,
    '!': TagType.comment,
  };

  // If open delimiter, or change delimiter token then return a tag.
  // If EOF or any another token then return null.
  Tag? _readTag() {
    final Token? t = _peek();
    if (t == null ||
        (t.type != TokenType.changeDelimiter &&
            t.type != TokenType.openDelimiter)) {
      return null;
    } else if (t.type == TokenType.changeDelimiter) {
      _read();
      // Remember the current delimiters.
      _currentDelimiters = t.value;

      // Change delimiter tags are already parsed by the scanner.
      // So just create a tag and return it.
      return Tag(TagType.changeDelimiter, t.value, t.start, t.end);
    }

    // Start parsing a typical tag.

    final Token open = _expect(TokenType.openDelimiter);

    _readIf(TokenType.whitespace);

    // A sigil is the character which identifies which sort of tag it is,
    // i.e.  '#', '/', or '>'.
    // Variable tags and triple mustache tags don't have a sigil.
    TagType? tagType;

    if (open.value == '{{{') {
      tagType = TagType.tripleMustache;
    } else {
      final Token? sigil = _readIf(TokenType.sigil);
      tagType = sigil == null ? TagType.variable : _tagTypeMap[sigil.value];
    }

    _readIf(TokenType.whitespace);

    // TODOsplit up names here instead of during render.
    // Also check that they are valid token types.
    // TODOsplit up names here instead of during render.
    // Also check that they are valid token types.
    final list = <Token>[];
    for (
      Token? t = _peek();
      t != null && t.type != TokenType.closeDelimiter;
      t = _peek()
    ) {
      _read();
      list.add(t);
    }
    final String name = list.map((Token t) => t.value).join().trim();
    if (_peek() == null) {
      throw _errorEof();
    }

    // Check to see if the tag name is valid.
    if (tagType != TagType.comment) {
      if (name == '') {
        throw _error('Empty tag name.', open.start);
      }
      if (!_lenient) {
        if (name.contains('\t') || name.contains('\n') || name.contains('\r')) {
          throw _error('Tags may not contain newlines or tabs.', open.start);
        }

        if (!_validIdentifier.hasMatch(name)) {
          throw _error(
            'Unless in lenient mode, tags may only contain the '
            'characters a-z, A-Z, minus, underscore and period.',
            open.start,
          );
        }
      }
    }

    final Token close = _expect(TokenType.closeDelimiter);

    return Tag(tagType!, name, open.start, close.end);
  }

  Node? _createNodeFromTag(Tag? tag, {String partialIndent = ''}) {
    // Handle EOF case.
    if (tag == null) {
      return null;
    }

    Node? node;
    switch (tag.type) {
      case TagType.openSection:
      case TagType.openInverseSection:
        final inverse = tag.type == TagType.openInverseSection;
        node = SectionNode(
          tag.name,
          tag.start,
          tag.end,
          _currentDelimiters,
          inverse: inverse,
        );

      case TagType.variable:
      case TagType.unescapedVariable:
      case TagType.tripleMustache:
        final escape = tag.type == TagType.variable;
        node = VariableNode(tag.name, tag.start, tag.end, escape: escape);

      case TagType.partial:
        node = PartialNode(tag.name, tag.start, tag.end, partialIndent);

      case TagType.closeSection:
      case TagType.comment:
      case TagType.changeDelimiter:
        node = null;

      default:
        // TODO(stuartmorgan): Convert to StateError.
        throw Exception('Unreachable code');
    }
    return node;
  }
}
