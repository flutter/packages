library parser;

//TODO just import nodes.
import 'mustache_impl.dart' show Node, SectionNode, TextNode, PartialNode, VariableNode;
import 'scanner2.dart';
import 'template_exception.dart';
import 'token2.dart';

List<Node> parse(String source,
             bool lenient,
             String templateName,
             String delimiters) {
  var parser = new Parser(source, templateName, delimiters, lenient: lenient);
  return parser.parse();
}

class Tag {
  Tag(this.sigil, this.name, this.start, this.end);
  final String sigil;
  final String name;
  final int start;
  final int end;
  //TODO parse the tag contents.
  //final List<List<String>> arguments;
}

class Parser {
  
  Parser(this._source, this._templateName, this._delimiters, {lenient: false})
      : _lenient = lenient {
    // _scanner = new Scanner(_source, _templateName, _delimiters, _lenient);
  }
  
  //TODO do I need to keep all of these variables around?
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
  
  //TODO use a sync* generator once landed in Dart 1.10.
  Iterable<Token> _readWhile(bool predicate(Token t)) {
    var list = <Token>[];
    for (var t = _peek(); t != null && predicate(t); t = _peek()) {
      _read();
      list.add(t);
    }
    return list;
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
    switch (tag.sigil) {
      
      // Section and inverse section.
      case '#':
      case '^':
        _stack.last.children.add(node);
        _stack.add(node);
        break;
        
      // Close section tag
      case '/':
        if (tag.name != _stack.last.name) throw 'boom!'; //TODO error message.
        var node = _stack.removeLast();
        node.contentEnd = tag.start;
        break;        
        
      default:
        if (node != null) _stack.last.children.add(node);
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
          //TODO the first line can be a standalone line too, and there is
          // no lineEnd. Perhaps _parseLine(firstLine: true)?
          _parseLine();
          break;
          
        default:
          throw 'boom!'; //TODO error message.
      }
    }
    
    //TODO proper error message.
    assert(_stack.length == 1);
    
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
      }
      
      var followingWhitespace =
        _peek() != null && _peek().type == TokenType.whitespace ? _read() : null;

      // Need to emit leading whitespace if the last line was not a standalone
      // line. The consecutive flag keeps track of this.
      if (precedingLineEnd != null && !consecutive) {
        _appendTextToken(precedingLineEnd);
      }
      
      if (tag != null &&
          (_peek() == null || _peek().type == TokenType.lineEnd) &&
          const ['#', '/', '^', '>'].contains(tag.sigil)) {
                
        // This is a standalone line, so do not create text nodes for whitespace,
        // or the following newline.
            
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
    switch (tag.sigil) {
      
      // Section and inverse section.
      case '#':
      case '^':
        bool inverse = tag.sigil == '^';
        node = new SectionNode(tag.name, tag.start, tag.end, 
          _currentDelimiters, inverse: inverse);
        break;
                
      // Variable tag or unescaped variable tag.
      case '&':
      case '':
        bool escape = tag.sigil == '';
        node = new VariableNode(tag.name, tag.start, tag.end, escape: escape);
        break;
        
      // Partial tag.
      case '>': 
        node = new PartialNode(tag.name, tag.start, tag.end, partialIndent);
        break;
      
      default:
        node = null;
    }
    return node;
  }
    
  // Note the caller is responsible for pushing the returned node onto the
  // stack. Note this can return null, i.e. for a comment tag.
  Tag _readTag() {
    
    var open = _read();
    
    if (open.value == '{{{') {
      var open = _read();
      var name = _parseIdentifier();
      var close = _read();
      return new Tag('{', name, open.start, open.end);
    }
    
    if (_peek().type == TokenType.whitespace) _read();
    
    // sigil character, or empty string if a variable tag. A sigil is the
    // character which identifies which sort of tag it is,
    // i.e.  '#', '/', or '>'.
    var sigil = _peek().type == TokenType.sigil ? _read().value : '';
    
    if (_peek().type == TokenType.whitespace) _read();
    
    // TODO split up names here instead of during render.
    // Also check that they are valid token types.
    var name = _parseIdentifier();
    
    var close = _read();
    
    return new Tag(sigil, name, open.start, close.end);
  }
  
  //TODO shouldn't just return a string.
  String _parseIdentifier() {
    // TODO split up names here instead of during render.
    // Also check that they are valid token types.
    var name = _readWhile((t) => t.type != TokenType.closeDelimiter)
         .map((t) => t.value)
         .join()
         .trim();
    
    return name;
  } 
}

