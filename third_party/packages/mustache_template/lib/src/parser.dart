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
  
  List<Node> parse() {
    _scanner = new Scanner(_source, _templateName, _delimiters,
        lenient: _lenient);
    
    _tokens = _scanner.scan();
    _tokens = _removeStandaloneWhitespace(_tokens);
    _tokens = _mergeAdjacentText(_tokens);
    
    _currentDelimiters = _delimiters;
    
    _stack.add(new SectionNode('root', 0, 0, _delimiters));    
    
    for (var token = _peek(); token != null; token = _peek()) {
      
      if (token.type == TokenType.text) {
        _read();
        _stack.last.children.add(
            new TextNode(token.value, token.start, token.end));
      
      } else if (token.type == TokenType.openDelimiter) {
        if (token.value == '{{{') {
          _parseTripleMustacheTag();
        } else {
          _parseTag();
        }
      } else if (token.type == TokenType.changeDelimiter) {
        _read();
        _currentDelimiters = token.value;
      } else {
        throw 'boom!';
      }
    }
    
    //TODO proper error message.
    assert(_stack.length == 1);
    
    return _stack.last.children;
  }
  
  void _parseTripleMustacheTag() {
    var open = _read();
    var name = _parseIdentifier();
    var close = _read();
    _stack.last.children.add(
      new VariableNode(name, open.start, open.end, escape: false));
  }
  
  void _parseTag() {
    var open = _read();
    
    if (_peek().type == TokenType.whitespace) _read();
    
    // sigil character, or null. A sigil is the character which identifies which
    // sort of tag it is, i.e.  '#', '/', or '>'.
    var sigil = _peek().type == TokenType.sigil ? _read().value : null;
    
    if (_peek().type == TokenType.whitespace) _read();
    
    // TODO split up names here instead of during render.
    // Also check that they are valid token types.
    var name = _parseIdentifier();
    
    var close = _read();
    
    if (sigil == '#' || sigil == '^') {
      // Section and inverser section.
      bool inverse = sigil == '^';
      var node = new SectionNode(name, open.start, close.end, 
          _currentDelimiters, inverse: inverse);
      _stack.last.children.add(node);
      _stack.add(node);
    
    } else if (sigil == '/') {
      // Close section tag
      if (name != _stack.last.name) throw 'boom!';
      _stack.removeLast();
    
    } else if (sigil == '&' || sigil == null) {
      // Variable and unescaped variable tag
      bool escape = sigil == null;
      _stack.last.children.add(
        new VariableNode(name, open.start, close.end, escape: escape));
      
    } else if (sigil == '>') {
      // Partial tag
      //TODO find precending whitespace.
      var indent = '';
      _stack.last.children.add(
          new PartialNode(name, open.start, close.end, indent));
    
    } else if (sigil == '!') {
      // Ignore comments
    
    } else {
      assert(false); //TODO  
    }
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

  // Takes a list of tokens, and removes _NEWLINE, and _WHITESPACE tokens.
  // This is used to implement mustache standalone lines.
  // Where TAG is one of: OPEN_SECTION, INV_SECTION, CLOSE_SECTION
  // LINE_END, [WHITESPACE], TAG, [WHITESPACE], LINE_END => LINE_END, TAG
  // WHITESPACE => TEXT
  // LINE_END => TEXT
  // TODO could rewrite this to use a generator, rather than creating an inter-
  // mediate list.
  List<Token> _removeStandaloneWhitespace(List<Token> tokens) {
    int i = 0;
    Token read() { var ret = i < tokens.length ? tokens[i++] : null; return ret; }
    Token peek([int n = 0]) => i + n < tokens.length ? tokens[i + n] : null;
    
    bool isTag(token) => token != null
       && const [TokenType.openDelimiter, TokenType.changeDelimiter].contains(token.type);
    
    bool isWhitespace(token) => token != null && token.type == TokenType.whitespace;
    bool isLineEnd(token) => token != null && token.type == TokenType.lineEnd;
    
    var result = new List<Token>();
    add(token) => result.add(token);
    
    standaloneLineCheck() {
     // Swallow leading whitespace 
     // Note, the scanner will only ever create a single whitespace token. There
     // is no need to handle multiple whitespace tokens.
     if (isWhitespace(peek())
         && isTag(peek(1))
         && (isLineEnd(peek(2)) || peek(2) == null)) { // null == EOF
       read();
     } else if (isWhitespace(peek())
         && isTag(peek(1))
         && isWhitespace(peek(2))
         && (isLineEnd(peek(3)) || peek(3) == null)) {
       read();
     }
    
     if ((isTag(peek()) && isLineEnd(peek(1)))
         || (isTag(peek()) 
             && isWhitespace(peek(1))
             && (isLineEnd(peek(2)) || peek(2) == null))) {      
    
       // Add tag
       add(read());
    
       // Swallow trailing whitespace.
       if (isWhitespace(peek()))
         read();
    
       // Swallow line end.
       assert(isLineEnd(peek()));
       read();
    
       standaloneLineCheck(); //FIXME don't use recursion.
     }
    }
    
    // Handle case where first line is a standalone tag.
    standaloneLineCheck();
    
    var t;
    while ((t = read()) != null) {
     if (t.type == TokenType.lineEnd) {
       // Convert line end to text token
       add(new Token(TokenType.text, t.value, t.start, t.end));
       standaloneLineCheck();
     } else if (t.type == TokenType.whitespace) {
       // Convert whitespace to text token
       add(new Token(TokenType.text, t.value, t.start, t.end));
     } else {
       // Preserve token
       add(t);
     }
    }
    
    return result;
  }
  
  // Merging adjacent text nodes will improve the render speed, but slow down
  // parsing. It will be beneficial where templates are parsed once and rendered
  // a number of times.
  List<Token> _mergeAdjacentText(List<Token> tokens) {
    if (tokens.isEmpty) return <Token>[];
    
    var result = new List<Token>();
    int i = 0;
    while(i < tokens.length) {
     var t = tokens[i];
     
     if (t.type != TokenType.text
         || (i < tokens.length - 1 && tokens[i + 1].type != TokenType.text)) {
       result.add(tokens[i]);
       i++;
     } else {
       var buffer = new StringBuffer();
       while(i < tokens.length && tokens[i].type == TokenType.text) {
         buffer.write(tokens[i].value);
         i++;
       }
       result.add(new Token(TokenType.text, buffer.toString(), t.start, t.end));
     }
    }
    return result;
  }

}

