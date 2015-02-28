library scanner2;

//import 'package:mustache/mustache.dart' as m;

class Scanner {
  
  Scanner(String source, this._templateName, String delimiters, {bool lenient: true})
   : _source = source,
     _lenient = lenient,
     _itr = source.runes.iterator {
    
    var delims = _parseDelimiterString(delimiters);
    _openDelimiter = delims[0];
    _openDelimiterInner = delims[1];
    _closeDelimiterInner = delims[2];
    _closeDelimiter = delims[3];
    
    if (source == '') {
      _c = _EOF;
    } else {
      _itr.moveNext();
      _c = _itr.current;
    }
  }

  final String _templateName;
  final String _source;
  final bool _lenient;
  
  final Iterator<int> _itr;
  int _offset = 0;
  int _c = 0;
  
  final List<Token> _tokens = new List<Token>();

  // These can be changed by the change delimiter tag.
  int _openDelimiter;
  int _openDelimiterInner;
  int _closeDelimiterInner;
  int _closeDelimiter;
  
  List<Token> scan() {
    while(true) {
      int c = _peek();
      if (c == _EOF) break;
      else if (c == _openDelimiter) _scanOpenDelimiter();
      else _scanText();
    }
    return _tokens;
  }
  
  int _peek() => _c;
  
  int _read() {
    int c = _c;
    _offset++;
    _c = _itr.moveNext() ? _itr.current : _EOF;
    return c;
  }
  
  String _readWhile(bool test(int charCode), [Function endOfFile]) {
    
    int start = _offset;  
    while (_peek() != _EOF && test(_peek())) {
      _read();
    }

    if (_peek() == _EOF && endOfFile != null) endOfFile();
    
    int end = _peek() == _EOF ? _source.length : _offset;
    return _source.substring(start, end);
  }
  
  _expect(int expectedCharCode) {
    int c = _read();

    if (c == _EOF) {
      throw new TemplateException('Unexpected end of input',
          _templateName, _source, _offset);

    } else if (c != expectedCharCode) {
      throw new TemplateException('Unexpected character, '
        'expected: ${new String.fromCharCode(expectedCharCode)} ($expectedCharCode), '
        'was: ${new String.fromCharCode(c)} ($c)', 
        _templateName, _source, _offset);
    }
  }
  
  bool _isWhitespace(int c)
    => const [_SPACE, _TAB , _NEWLINE, _RETURN].contains(c);
  
  // Scan text. This adds text tokens, line end tokens, and whitespace
  // tokens for whitespace at the begining of a line. This is because the
  // mustache spec requires special handing of whitespace.
  void _scanText() {
    int start = 0;
    TokenType token;
    String value;
  
    for (int c = _peek(); c != _EOF && c != _openDelimiter; c = _peek()) {
      start = _offset;
      
      switch (c) {
        case _SPACE:
        case _TAB:
          value = _readWhile((c) => c == _SPACE || c == _TAB);
          token = TokenType.whitespace;          
          break;
          
        case _NEWLINE:
          _read();
          token = TokenType.lineEnd;
          value = '\n';
          break;
        
        case _RETURN:
          _read();
          if (_peek() == _NEWLINE) {
            _read();
            token = TokenType.lineEnd;
            value = '\r\n';
          } else {
            token = TokenType.text;
            value = '\r';
          }
          break;
          
        default:
          value = _readWhile((c) => c != _openDelimiter && c != _NEWLINE);
          token = TokenType.text;
      }
      
      _tokens.add(new Token(token, value, start, _offset));
    }
  }

  //TODO remove this.
  var _errorEofInTag = null;
  
  void _scanOpenDelimiter() {
    int start = _offset;
    _expect(_openDelimiter); //TODO Change to assert.
    
    // If only a single delimiter then create a text token.
    if (_openDelimiterInner != null && _peek() != _openDelimiterInner) {
      var value = new String.fromCharCode(_openDelimiter);
      _tokens.add(new Token(TokenType.text, value, start, _offset));
      
    } else {
    
      if (_openDelimiterInner != null) _expect(_openDelimiterInner);
      
      //TODO consider only allowing if other delimiters are set to mustache.
      if (_peek() == _OPEN_MUSTACHE) {
        _read();
        
        var value = new String.fromCharCodes(_openDelimiterInner != null
                  ? [_openDelimiter, _openDelimiterInner, _OPEN_MUSTACHE]
                  : [_openDelimiter, _OPEN_MUSTACHE]);
        
        _tokens.add(new Token(TokenType.openTripleMustache, value, start, _offset));
      
        _scanTagContent();
        _scanCloseTripleMustache();
        
      } else {
  
        var value = _openDelimiterInner != null
          ? new String.fromCharCodes([_openDelimiter, _openDelimiterInner])
          : new String.fromCharCode(_openDelimiter);
          
        _tokens.add(new Token(TokenType.openDelimiter, value, start, _offset));    
      
        // Check to see if this is a change delimiter tag. {{= | | =}}
        // Need to skip whitespace and check for "=".
        int wsStart = _offset;
        var ws = _readWhile(
            (c) => const [_SPACE, _TAB, _NEWLINE, _RETURN].contains(c));
        
        if (_peek() == _EQUAL) {
          _scanChangeDelimiterTag(start);
        } else {
          if (ws.isNotEmpty) {
            _tokens.add(new Token(TokenType.whitespace, ws, wsStart, _offset));
          }
          _scanTagContent();
          _scanCloseDelimiter();
        }
      }
    }
  }
  
  // Scan contents of a tag and the end delimiter token.
  void _scanTagContent() {
    
    int start;
    TokenType token;
    String value;
    List<Token> result = <Token>[];
    
    bool isCloseDelimiter(int c) => 
          (_closeDelimiterInner == null && c == _closeDelimiter)
          || (_closeDelimiterInner != null && c == _closeDelimiterInner);      
    
    for (int c = _peek(); c != _EOF && !isCloseDelimiter(c); c = _peek()) {
      
      start = _offset;
      
      switch (c) {
        case _HASH:
        case _CARET:
        case _FORWARD_SLASH:
        case _GT:
        case _AMP:
        case _EXCLAIM:        
          _read();
          token = TokenType.sigil;
          value = new String.fromCharCode(c);
          break;
          
        case _SPACE:
        case _TAB:
        case _NEWLINE:
        case _RETURN:
          token = TokenType.whitespace;
          value = _readWhile(
              (c) => const [_SPACE, _TAB, _NEWLINE, _RETURN].contains(c));
          break;
          
        case _PERIOD:
          _read();
          token = TokenType.dot;
          value = '.';  
          break;
          
        default:          
          // Indentifier can be any other character in lenient mode.
          token = TokenType.identifier;
          value = _readWhile((c) => !(const [ _HASH, _CARET, _FORWARD_SLASH,
            _GT, _AMP, _EXCLAIM, _EQUAL, _SPACE, _TAB, _NEWLINE, _RETURN,
            _PERIOD].contains(c)) &&
            c != _closeDelimiterInner &&
            c != _closeDelimiter);
      }
      _tokens.add(new Token(token, value, start, _offset));    
    }    
  }
  
  // Scan close delimiter token.
  void _scanCloseDelimiter() {
    
    if (_peek() != _EOF) {
      int start = _offset;
      
      if (_closeDelimiterInner != null) _expect(_closeDelimiterInner);
      _expect(_closeDelimiter);
      
      String value = new String.fromCharCodes(_closeDelimiterInner == null
          ? [_closeDelimiter]
          : [_closeDelimiterInner, _closeDelimiter]);
      
      _tokens.add(new Token(TokenType.closeDelimiter, value, start, _offset));
    }    
  }

  // Scan close triple mustache delimiter token.
  //TODO consider forcing the delimiters to all be mustaches.
  void _scanCloseTripleMustache() {
    
    if (_peek() != _EOF) {
      int start = _offset;
      
      if (_closeDelimiterInner != null) _expect(_closeDelimiterInner);
      _expect(_closeDelimiter);      
      _expect(_CLOSE_MUSTACHE);
      
      String value = new String.fromCharCodes(_closeDelimiterInner == null
          ? [_closeDelimiter, _CLOSE_MUSTACHE]
          : [_closeDelimiterInner, _closeDelimiter, _CLOSE_MUSTACHE]);
      
      _tokens.add(new Token(TokenType.closeTripleMustache, value, start, _offset));
    }
    
  }  

  // Open delimiter characters and = have already been read.
  void _scanChangeDelimiterTag(int start) {
    
    var delimiterInner = _closeDelimiterInner;
    var delimiter = _closeDelimiter;
    
    _readWhile((c) => const [_SPACE, _TAB, _NEWLINE, _RETURN].contains(c));
    
    int c;
    c = _read();
    
    if (c == _EQUAL) throw _error('Incorrect change delimiter tag.');
    _openDelimiter = c;
    
    c = _read();
    if (_isWhitespace(c)) {
      _openDelimiterInner = null;
    } else {
      _openDelimiterInner = c;
    }
    
    _readWhile((c) => const [_SPACE, _TAB, _NEWLINE, _RETURN].contains(c));
    
    c = _read();
    
    if (_isWhitespace(c) || c == _EQUAL)
      throw _error('Incorrect change delimiter tag.');
    
    if (_isWhitespace(_peek()) || _peek() == _EQUAL) {
      _closeDelimiterInner = null;
      _closeDelimiter = c;
    } else {
      _closeDelimiterInner = c;
      _closeDelimiter = _read();
    }
    
    _readWhile((c) => const [_SPACE, _TAB, _NEWLINE, _RETURN].contains(c));
    
    _expect(_EQUAL);
    
    _readWhile((c) => const [_SPACE, _TAB, _NEWLINE, _RETURN].contains(c));     
     
    if (delimiterInner != null) _expect(delimiterInner);
     _expect(delimiter);
    
     var value = _delimiterString(
         _openDelimiter,
         _openDelimiterInner,
         _closeDelimiterInner,
         _closeDelimiter);
          
     _tokens.add(new Token(TokenType.changeDelimiter, value, start, _offset));
  }
  
  TemplateException _error(String message) {
    return new TemplateException(message, _templateName, _source, _offset);
  }

}

_delimiterString(int open, int openInner, int closeInner, int close) {
  var buffer = new StringBuffer();
  buffer.writeCharCode(open);
  if (openInner != null) buffer.writeCharCode(openInner);
  buffer.write(' ');
  if (closeInner != null) buffer.writeCharCode(closeInner);
  buffer.writeCharCode(close);
  return buffer.toString();
}

List<int> _parseDelimiterString(String s) {
  if (s == null) return [_OPEN_MUSTACHE, _OPEN_MUSTACHE,
                         _CLOSE_MUSTACHE, _CLOSE_MUSTACHE];
  if (s.length == 3) {
    return [s.codeUnits[0], null, null, s.codeUnits[2]];
  
  } else if (s.length == 5) {
    return [s.codeUnits[0],
            s.codeUnits[1],
            s.codeUnits[3],
            s.codeUnits[4]];
  } else {
    throw new TemplateException(
        'Invalid delimiter string $s', null, null, null);
  }  
}

const int _EOF = -1;
const int _TAB = 9;
const int _NEWLINE = 10;
const int _RETURN = 13;
const int _SPACE = 32;
const int _EXCLAIM = 33;
const int _QUOTE = 34;
const int _APOS = 39;
const int _HASH = 35;
const int _AMP = 38;
const int _PERIOD = 46;
const int _FORWARD_SLASH = 47;
const int _LT = 60;
const int _EQUAL = 61;
const int _GT = 62;
const int _CARET = 94;

const int _OPEN_MUSTACHE = 123;
const int _CLOSE_MUSTACHE = 125;

const int _A = 65;
const int _Z = 90;
const int _a = 97;
const int _z = 122;
const int _0 = 48;
const int _9 = 57;

const int _UNDERSCORE = 95;
const int _MINUS = 45;




class TokenType {
  
  const TokenType(this.name);
  
  final String name;
  
  String toString() => '(TokenType $name)';

  static const TokenType text = const TokenType('text');
  static const TokenType comment = const TokenType('comment');
  static const TokenType openDelimiter = const TokenType('openDelimiter');
  static const TokenType closeDelimiter = const TokenType('closeDelimiter');

  // A sigil is the word commonly used to describe the special character at the
  // start of mustache tag i.e. #, ^ or /.
  static const TokenType sigil = const TokenType('sigil');
  static const TokenType identifier = const TokenType('identifier');
  static const TokenType dot = const TokenType('dot');
  
  static const TokenType changeDelimiter = const TokenType('changeDelimiter');
  //TODO consider just using normal delimiter and checking the value to see if it is a triple
  static const TokenType openTripleMustache = const TokenType('openTripleMustache');
  static const TokenType closeTripleMustache = const TokenType('closeTripleMustache');
  static const TokenType whitespace = const TokenType('whitespace');
  static const TokenType lineEnd = const TokenType('lineEnd');

}


class Token {
  
  Token(this.type, this.value, this.start, this.end);
  
  final TokenType type;
  final String value;
  
  final int start;
  final int end;
  
  String toString() => "(Token ${type.name} \"$value\" $start $end)";
  
  // Only used for testing.
  bool operator ==(o) => o is Token
      && type == o.type
      && value == o.value
      && start == o.start
      && end == o.end;
  
  // TODO hashcode. import quiver.
}





class TemplateException { //implements m.TemplateException {

  TemplateException(this.message, this.templateName, this.source, this.offset);

  final String message;
  final String templateName;
  final String source;
  final int offset;
  
  bool _isUpdated = false;
  int _line;
  int _column;
  String _context;
  
  int get line {
    _update();
    return _line;
  }

  int get column {
    _update();
    return _column;
  }

  String get context {
    _update();
    return _context;
  }
    
  String toString() {
    var list = [];
    if (templateName != null) list.add(templateName);
    if (line != null) list.add(line);
    if (column != null) list.add(column);
    var location = list.isEmpty ? '' : ' (${list.join(':')})';     
    return '$message$location\n$context';
  }

  // This source code is a modified version of FormatException.toString().
  void _update() {
    if (_isUpdated) return;
    _isUpdated = true;
        
    if (source == null
        || offset == null
        || (offset < 0 || offset > source.length))
      return;
    
    // Find line and character column.
    int lineNum = 1;
    int lineStart = 0;
    bool lastWasCR;
    for (int i = 0; i < offset; i++) {
      int char = source.codeUnitAt(i);
      if (char == 0x0a) {
        if (lineStart != i || !lastWasCR) {
          lineNum++;
        }
        lineStart = i + 1;
        lastWasCR = false;
      } else if (char == 0x0d) {
        lineNum++;
        lineStart = i + 1;
        lastWasCR = true;
      }
    }
    
    _line = lineNum;
    _column = offset - lineStart + 1;

    // Find context.
    int lineEnd = source.length;
    for (int i = offset; i < source.length; i++) {
      int char = source.codeUnitAt(i);
      if (char == 0x0a || char == 0x0d) {
        lineEnd = i;
        break;
      }
    }
    int length = lineEnd - lineStart;
    int start = lineStart;
    int end = lineEnd;
    String prefix = "";
    String postfix = "";
    if (length > 78) {
      // Can't show entire line. Try to anchor at the nearest end, if
      // one is within reach.
      int index = offset - lineStart;
      if (index < 75) {
        end = start + 75;
        postfix = "...";
      } else if (end - offset < 75) {
        start = end - 75;
        prefix = "...";
      } else {
        // Neither end is near, just pick an area around the offset.
        start = offset - 36;
        end = offset + 36;
        prefix = postfix = "...";
      }
    }
    String slice = source.substring(start, end);
    int markOffset = offset - start + prefix.length;
    
    _context = "$prefix$slice$postfix\n${" " * markOffset}^\n";
  }

}