library mustache.parser;

import 'node.dart';
import 'scanner.dart';
import 'template_exception.dart';
import 'token.dart';

List<Node> parse(String source,
             bool lenient,
             String templateName,
             String delimiters) {
  var parser = new Parser(source, templateName, delimiters, lenient: lenient);
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
  
  static const TagType openSection = const TagType('openSection');
  static const TagType openInverseSection = const TagType('openInverseSection');
  static const TagType closeSection = const TagType('closeSection');
  static const TagType variable = const TagType('variable');
  static const TagType tripleMustache = const TagType('tripleMustache');
  static const TagType unescapedVariable = const TagType('unescapedVariable');
  static const TagType partial = const TagType('partial');
  static const TagType comment = const TagType('comment');
  static const TagType changeDelimiter = const TagType('changeDelimiter');
}


class Parser {
  
  Parser(this._source, this._templateName, this._delimiters, {lenient: false})
      : _lenient = lenient {
    // _scanner = new Scanner(_source, _templateName, _delimiters, _lenient);
  }
  
  final String _source;
  final bool _lenient;
  final String _templateName;
  final String _delimiters;  
  Scanner _scanner; //TODO make final
  List<Token> _tokens;
  final List<SectionNode> _stack = <SectionNode>[];
  String _currentDelimiters;
  
  int _i = 0;
  
  //TODO EOF??
  Token _peek() => _i < _tokens.length ? _tokens[_i] : null;
  
  // TODO EOF?? return null on EOF?
  Token _read() {
    var t = null;
    if (_i < _tokens.length) {
      t = _tokens[_i];
      _i++;
    }
    return t;
  }
  
  //TODO fail on eof unless setting passed.
  //TODO use a sync* generator once landed in Dart 1.10.
  Iterable<Token> _readWhile(bool predicate(Token t)) {
    var list = <Token>[];
    for (var t = _peek(); t != null && predicate(t); t = _peek()) {
      _read();
      list.add(t);
    }
    return list;
  }
  
  _checkEof() {
    if (_peek() == null) throw 'End of file!'; //TODO error message;
  }
  
  Token _expect(TokenType type) {
    var token = _read();
    if (token == null) throw 'End of file!'; //TODO error message.
    if (token.type != type) throw 'boom!'; //TODO error message
    return token;
  }
  
  Token _readIf(TokenType type) {
    var token = _peek();
    if (token == null) throw 'End of file!'; //TODO error message.
    return token.type == type ? _read() : null;
  }
  
  // Add a text node to top most section on the stack and merge consecutive
  // text nodes together.
  void _appendTextToken(Token token) {
    assert(const [TokenType.text, TokenType.lineEnd, TokenType.whitespace]
      .contains(token.type));
    var children = _stack.last.children;
    if (children.isEmpty || children.last is! TextNode) {
      children.add(new TextNode(token.value, token.start, token.end));
    } else {
      var last = children.removeLast();
      var node = new TextNode(last.text + token.value, last.start, token.end);
      children.add(node);
    }
  }
  
  // Add the node to top most section on the stack. If a section node then
  // push it onto the stack, if a close section tag, then pop the stack.
  void _appendTag(Tag tag, Node node) {
    switch (tag.type) {
      
      // {{#...}}  {{^...}}
      case TagType.openSection:
      case TagType.openInverseSection:
        _stack.last.children.add(node);
        _stack.add(node);
        break;
        
      // {{/...}}
      case TagType.closeSection:
        if (tag.name != _stack.last.name) {
          throw new TemplateException("Mismatched tag, expected: "
              "'${_stack.last.name}', was: '${tag.name}'",
              _templateName, _source, tag.start);
        }
        var node = _stack.removeLast();
        node.contentEnd = tag.start;
        break;        
      
      // {{...}} {{&...}} {{{...}}}
      case TagType.variable:
      case TagType.unescapedVariable:
      case TagType.tripleMustache:
      case TagType.partial:
        if (node != null) _stack.last.children.add(node);
        break;
      
      case TagType.comment:
      case TagType.changeDelimiter:
        // Ignore.
        break;

      default:
        throw new Exception('Unreachable code.');
    }
  }
  
  List<Node> parse() {
    _scanner = new Scanner(_source, _templateName, _delimiters,
        lenient: _lenient);
    
    _tokens = _scanner.scan();
    
    _currentDelimiters = _delimiters;
    
    _stack.add(new SectionNode('root', 0, 0, _delimiters));    
  
    // Handle standalone tag on first line.
    _parseLine();
    
    for (var token = _peek(); token != null; token = _peek()) {
      switch(token.type) {
        
        case TokenType.text:
        case TokenType.whitespace:            
            _read();
            _appendTextToken(token);
          break;
        
        case TokenType.openDelimiter:
          var tag = _readTag();
          var node = _createNodeFromTag(tag);
          if (tag != null) _appendTag(tag, node);
          break;
                 
        case TokenType.changeDelimiter:
          _read();
          _currentDelimiters = token.value;
          break;
          
        case TokenType.lineEnd:
          _parseLine();
          break;
          
        default:
          throw new Exception('Unreachable code.');
      }
    }
    
    if (_stack.length != 1) {
      throw new TemplateException("Unclosed tag: '${_stack.last.name}'.",
          _templateName, _source, _stack.last.start);
    }
    
    return _stack.last.children;
  }
  
  // Handle standalone tags and indented partials.
  //
  // A "standalone tag" in the spec is a tag one a line where the line only
  // contains whitespace. During rendering the whitespace is ommitted.
  // Standalone partials also indent their content to match the tag during 
  // rendering.
  
  // match:
  // newline whitespace openDelimiter any* closeDelimiter whitespace newline
  //
  // Where newline can also mean start/end of the source.
  void _parseLine() {
    //TODO handle EOFs. i.e. check for null return from peek.
    //TODO make this EOF handling clearer.
    
    // Continue parsing standalone lines until we find one than isn't a
    // standalone line.
    bool consecutive = false;
    while (_peek() != null) {
    
      assert(_peek().type == TokenType.lineEnd || _i == 0);
  
      //TODO _readIf(TokenType) helper.
      var precedingLineEnd = _peek() != null && _peek().type == TokenType.lineEnd
          ? _read() : null;
      
      // The scanner guarantees that there will only be a single whitespace token,
      // there are never consecutive whitespace tokens.
      var precedingWhitespace =
        _peek() != null && _peek().type == TokenType.whitespace ? _read() : null;
          
      Tag tag;
      Node tagNode;
      if (_peek() != null && _peek().type == TokenType.openDelimiter) {
        tag = _readTag();
        tagNode = _createNodeFromTag(tag,
            partialIndent: precedingWhitespace == null
              ? ''
              : precedingWhitespace.value);
        
      } else if (_peek() != null && _peek().type == TokenType.changeDelimiter) {
        // Need to handle standalone lines for change delimiter tags too.
        // The change delimiter token actually represents the entire tag which
        // was already parsed in the scanner.
        var token = _read();
        tag = new Tag(TagType.changeDelimiter, token.value, token.start, token.end);
        tagNode = null;
        _currentDelimiters = token.value;
      }
      
      var followingWhitespace =
        _peek() != null && _peek().type == TokenType.whitespace ? _read() : null;

      // Need to emit leading whitespace if the last line was not a standalone
      // line. The consecutive flag keeps track of this.
      if (precedingLineEnd != null && !consecutive) {
        _appendTextToken(precedingLineEnd);
      }
      
      const standaloneTypes = const [
        TagType.openSection,
        TagType.closeSection,
        TagType.openInverseSection,
        TagType.partial,
        TagType.comment,
        TagType.changeDelimiter]; 
      
      if (tag != null &&
          (_peek() == null || _peek().type == TokenType.lineEnd) &&
          standaloneTypes.contains(tag.type)) {
                
        // This is a tag on a "standalone line", so do not create text nodes
        // for whitespace, or the following newline.
            
        _appendTag(tag, tagNode);
       
        // Continue loop parse another line.
        consecutive = true;
        
      } else {
  
        // This is not a standalone line so add the whitespace to the ast.        
        if (precedingWhitespace != null) _appendTextToken(precedingWhitespace);
        if (tag != null) _appendTag(tag, tagNode);
        if (followingWhitespace != null) _appendTextToken(followingWhitespace);
        
        // Done parsing standalone lines. Exit the loop.
        break;
      }
    }
  }
  
  Node _createNodeFromTag(Tag tag, {String partialIndent: ''}) {
    Node node = null;
    switch (tag.type) {
      
      case TagType.openSection:
      case TagType.openInverseSection:
        bool inverse = tag.type == TagType.openInverseSection;
        node = new SectionNode(tag.name, tag.start, tag.end, 
          _currentDelimiters, inverse: inverse);
        break;
   
      case TagType.variable:
      case TagType.unescapedVariable:
      case TagType.tripleMustache:
        bool escape = tag.type == TagType.variable;
        node = new VariableNode(tag.name, tag.start, tag.end, escape: escape);
        break;
        
      case TagType.partial:
        node = new PartialNode(tag.name, tag.start, tag.end, partialIndent);
        break;
            
      // Return null for close section.
      case TagType.closeSection:
      case TagType.comment:
        node = null;
        break;

      default:
        throw new Exception('Unreachable code');
    }
    return node;
  }
  
  final RegExp _validIdentifier = new RegExp(r'^[0-9a-zA-Z\_\-\.]+$');
  
  static const _tagTypeMap = const {
          '#': TagType.openSection,
          '^': TagType.openInverseSection,
          '/': TagType.closeSection,
          '&': TagType.unescapedVariable,
          '>': TagType.partial,
          '!': TagType.comment};
  
  //TODO clean up EOF handling.
  Tag _readTag() {
    
    var open = _expect(TokenType.openDelimiter);
    
    _readIf(TokenType.whitespace);
    
    // A sigil is the character which identifies which sort of tag it is,
    // i.e.  '#', '/', or '>'.
    // Variable tags and triple mustache tags don't have a sigil.
    TagType tagType;
    
    if (open.value == '{{{') {
      tagType = TagType.tripleMustache;
    } else {
      var sigil = _readIf(TokenType.sigil);
      tagType = sigil == null ? TagType.variable : _tagTypeMap[sigil.value];
    }
      
    _readIf(TokenType.whitespace);
    
    // TODO split up names here instead of during render.
    // Also check that they are valid token types.
    // TODO split up names here instead of during render.
    // Also check that they are valid token types.
    var name = _readWhile((t) => t.type != TokenType.closeDelimiter)
         .map((t) => t.value)
         .join()
         .trim();
  
    //TODO incorporate this into _readWhile()
    _checkEof();
    
    // Check to see if tag name is valid.
    if (tagType != TagType.comment) {    
      if (name == '') throw _error('Empty tag', open.start);
      
      if (name.contains('\t') || name.contains('\n') || name.contains('\r')) {
        throw _error('Tags may not contain newlines or tabs.', open.start);
      }    
      
      if (!_lenient && !_validIdentifier.hasMatch(name)) {
        throw _error('Unless in lenient mode, tags may only contain the '
            'characters a-z, A-Z, minus, underscore and period.', open.start);
      }    
    }
    
    var close = _expect(TokenType.closeDelimiter);
        
    return new Tag(tagType, name, open.start, close.end);
  }
    
  TemplateException _error(String msg, int offset) => 
      new TemplateException(msg, _templateName, _source, offset);
}
