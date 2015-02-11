part of mustache;

class _Scanner {
  
	_Scanner(String source, this._templateName, String delimiters, {bool lenient: true})
	 : _r = new _CharReader(source),
	   _source = source,
	   _lenient = lenient {
	  
	  var delims = _parseDelimiterString(delimiters);
    _openDelimiter = delims[0];
    _openDelimiterInner = delims[1];
    _closeDelimiterInner = delims[2];
    _closeDelimiter = delims[3];
	}

	final String _templateName;
	final String _source;
	final bool _lenient;
	
	_CharReader _r;
	List<_Token> _tokens = new List<_Token>();

	// These can be changed by the change delimiter tag.
	int _openDelimiter;
  int _openDelimiterInner;
  int _closeDelimiterInner;
  int _closeDelimiter;

  List<_Token> scan() {
    while(true) {
      int c = _peek();
      if (c == _EOF) break;
      else if (c == _openDelimiter) _scanMustacheTag();
      else _scanText();
    }
    return _tokens;
  }
	
	int _read() => _r.read();
	int _peek() => _r.peek();
		
	_expect(int expectedCharCode) {
		int c = _read();

		if (c == _EOF) {
			throw new _TemplateException('Unexpected end of input',
			    _templateName, _source, _r.offset);

		} else if (c != expectedCharCode) {
			throw new _TemplateException('Unexpected character, '
				'expected: ${new String.fromCharCode(expectedCharCode)} ($expectedCharCode), '
				'was: ${new String.fromCharCode(c)} ($c)', 
				_templateName, _source, _r.offset);
		}
	}
	
	bool _isWhitespace(int c)
	  => const [_SPACE, _TAB , _NEWLINE, _RETURN].contains(c);
	
	// A sigil is the word commonly used to describe the special character at the
	// start of mustache tag i.e. #, ^ or /.
	bool _isSigil(int c)
	 => const [_HASH, _CARET, _FORWARD_SLASH, _GT, _AMP, _EXCLAIM, _EQUAL]
	   .contains(c);
	
	bool _isAlphanum(int c) 
    => (c >= _a && c <= _z)
        || (c >= _A && c <= _Z)
        || (c >= _0 && c <= _9)
        || c == _MINUS
        || c == _UNDERSCORE
        || c == _PERIOD;

	_scanText() {
	  
		while(true) {
		  int c = _peek();
		  int start = _r.offset;
		  
		  if (c == _EOF) {
		    return; 
		  
		  } else if (c == _openDelimiter) { 
			  return;
			  
      // Newlines and whitespace have separate tokens so the standalone lines
			// logic can be implemented.
		  } else if (c == _NEWLINE) {
        _read();
        var value = new String.fromCharCode(c);
        _tokens.add(new _Token(_LINE_END, value, start, _r.offset));
			  
		  } else if (c == _RETURN) {
        _read();
        if (_peek() == _NEWLINE) {
          _read();
          _tokens.add(new _Token(_LINE_END, '\r\n', start, _r.offset));
        } else {
          var value = new String.fromCharCode(_RETURN);
          _tokens.add(new _Token(_TEXT, '\n', start, _r.offset));
        }			  
			
			} else if (c == _SPACE || c == _TAB) {
        var value = _r.readWhile((c) => c == _SPACE || c == _TAB);
        _tokens.add(new _Token(_WHITESPACE, value, start, _r.offset));
        
			} else {
        var value = _r.readWhile((c) => c != _openDelimiter && c != _NEWLINE);
        _tokens.add(new _Token(_TEXT, value, start, _r.offset));
			}
		}	
	}
		
  void _scanMustacheTag() {
    int start = _r.offset;
    int sigil = 0;
     
    _expect(_openDelimiter);
    
    // If just a single delimeter character then this is a text token.
    if (_openDelimiterInner != null && _peek() != _openDelimiterInner) {
      var value = new String.fromCharCode(_openDelimiter);
      _tokens.add(new _Token(_TEXT, value, start, _r.offset));
      return;
    }
    
    if (_openDelimiterInner != null) _expect(_openDelimiterInner);
     
    if (_peek() == _OPEN_MUSTACHE) {
      _scanTripleMustacheTag(start);
      return;
    }
 
    _scanTagWhitespace();
 
    if (_isSigil(_peek())) sigil = _read();
 
    if (sigil == _EQUAL) {
      _scanChangeDelimiterTag(start);
      return;
    } else if (sigil == _EXCLAIM) {
      _scanCommentTag(start);
      return;
    }
 
    _scanTagWhitespace();
 
    var identifier = _scanTagIdentifier();
    
    if (identifier.isEmpty) throw _error('Expected tag identifier.');
    
    _scanTagWhitespace();
 
    if (_closeDelimiterInner != null) _expect(_closeDelimiterInner);
    _expect(_closeDelimiter);

    const sigils = const <int, int> {
      0: _VARIABLE,
      _HASH: _OPEN_SECTION,
      _FORWARD_SLASH: _CLOSE_SECTION,
      _CARET: _OPEN_INV_SECTION,
      _GT: _PARTIAL,
      _AMP: _UNESC_VARIABLE
    };
    
    var type = sigils[sigil];
    var indent = type == _PARTIAL ? _getPrecedingWhitespace() : ''; 
    
    _tokens.add(new _Token(type, identifier, start, _r.offset, indent: indent));
  }
	
  _errorEofInTag() => throw _error('Tag not closed before the end of the template.');
  
  _scanTagWhitespace() {
    const whitepsace = const [_SPACE, _NEWLINE, _RETURN, _TAB];
    if (_lenient) {
      _r.readWhile(_isWhitespace, _errorEofInTag);
    } else {
      _r.readWhile((c) => c == _SPACE, _errorEofInTag);
      if (_isWhitespace(_peek()))
        throw _error('Tags may not contain newlines or tabs.');
    }
  }
  
  String _scanTagIdentifier({bool tripleMo: false}) {
    var delim = _closeDelimiterInner != null
        ? _closeDelimiterInner
        : _closeDelimiter;
    if (_lenient) {
      return _r.readWhile(
          (c) => c != delim 
                 || tripleMo && c != _CLOSE_MUSTACHE,
          _errorEofInTag).trim();
    } else {
      var id = _r.readWhile(_isAlphanum, _errorEofInTag);
      _scanTagWhitespace();
      if (_peek() != delim) throw _error('Unless in lenient mode tags may only '
          'contain the characters a-z, A-Z, minus, underscore and period.');
      return id;
    }
  }
  
  // Capture whitespace preceding a partial tag so it can used for indentation
  // during rendering.
  String _getPrecedingWhitespace() {
    var indent = '';
    if (_tokens.isNotEmpty) {
      if (_tokens.length == 1 && _tokens.last.type == _WHITESPACE) {
        indent = _tokens.last.value;
      
      } else if (_tokens.length > 1) {
        if (_tokens.last.type == _WHITESPACE
            && _tokens[_tokens.length - 2].type == _NEWLINE) {
          indent = _tokens.last.value;
        }
      }
    }
    return indent;
  }
  
  void _scanTripleMustacheTag(int start) {
    _expect(_OPEN_MUSTACHE);
    var value = _scanTagIdentifier();
    _expect(_CLOSE_MUSTACHE);
    if (_closeDelimiterInner != null) _expect(_closeDelimiterInner);
    _expect(_closeDelimiter);
    _tokens.add(new _Token(_UNESC_VARIABLE, value, start, _r.offset));
  }
  
  void _scanCommentTag(int start) {
    var value = _closeDelimiterInner != null
        ? _r.readWhile((c) => c != _closeDelimiterInner, _errorEofInTag).trim()
        : _r.readWhile((c) => c != _closeDelimiter, _errorEofInTag).trim();
    if (_closeDelimiterInner != null) _expect(_closeDelimiterInner);
    _expect(_closeDelimiter);
    _tokens.add(new _Token(_COMMENT, value, start, _r.offset));
  }

  //TODO consider changing the parsing here to use a regexp. It will probably
  // be simpler to read.
  void _scanChangeDelimiterTag(int start) {
    // Open delimiter characters and = have already been read.
    
    var delimiterInner = _closeDelimiterInner;
    var delimiter = _closeDelimiter;
    
    _scanTagWhitespace();
    
    int c;
    c = _r.read();
    
    if (c == _EQUAL) throw _error('Incorrect change delimiter tag.');
    _openDelimiter = c;
    
    c = _r.read();
    if (_isWhitespace(c)) {
      _openDelimiterInner = null;
    } else {
      _openDelimiterInner = c;
    }
    
    _scanTagWhitespace();
    
    c = _r.read();
    
    if (_isWhitespace(c) || c == _EQUAL)
      throw _error('Incorrect change delimiter tag.');
    
    if (_isWhitespace(_peek()) || _peek() == _EQUAL) {
      _closeDelimiterInner = null;
      _closeDelimiter = c;
    } else {
      _closeDelimiterInner = c;
      _closeDelimiter = _read();
    }
    
    _scanTagWhitespace();
    _expect(_EQUAL);
    _scanTagWhitespace();
     
     _expect(delimiterInner);
     _expect(delimiter);
    
     var value = _delimiterString(
         _openDelimiter,
         _openDelimiterInner,
         _closeDelimiterInner,
         _closeDelimiter);
          
     _tokens.add(new _Token(_CHANGE_DELIMITER, value, start, _r.offset));
  }
  
	TemplateException _error(String message) {
	  return new _TemplateException(message, _templateName, _source, _r.offset);
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
    throw new _TemplateException(
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
