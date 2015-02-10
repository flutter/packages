part of mustache;

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

class _Scanner {
  
	_Scanner(String source, this._templateName, String delimiters, {bool lenient: true})
	 : _r = new _CharReader(source),
	   _lenient = lenient {
	  
	  var delims = _parseDelimiterString(delimiters);
    _openDelimiter = delims[0];
    _openDelimiterInner = delims[1];
    _closeDelimiterInner = delims[2];
    _closeDelimiter = delims[3];
	}

	final String _templateName;
	
	//FIXME not used yet.
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

	_addStringToken(int type) {
		int l = _r.line, c = _r.column;
		var value = type == _TEXT ? _readLine() : _readString();
		if (type != _TEXT && type != _COMMENT) value = value.trim();		
		_tokens.add(new _Token(type, value, l, c));
	}

	_addCharToken(int type, int charCode) {
		int l = _r.line, c = _r.column;
		var value = new String.fromCharCode(charCode);
		_tokens.add(new _Token(type, value, l, c));
	}

	_addPartialToken() {
    // Capture whitespace preceding a partial tag so it can used for indentation during rendering.
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
	  
	  int l = _r.line, c = _r.column;
    var value = _readString().trim();
    _tokens.add(new _Token(_PARTIAL, value, l, c, indent: indent));
	}
	
	_expect(int expectedCharCode) {
		int c = _read();

		if (c == _EOF) {
			throw new TemplateException('Unexpected end of input',
			    _templateName, _r.line, _r.column);

		} else if (c != expectedCharCode) {
			throw new TemplateException('Unexpected character, '
				'expected: ${new String.fromCharCode(expectedCharCode)} ($expectedCharCode), '
				'was: ${new String.fromCharCode(c)} ($c)', 
				_templateName, _r.line, _r.column);
		}
	}

  // FIXME probably need to differentiate between searching for open, or close
  // delimiter.
	String _readString() => _r.readWhile(
		(c) => c != _closeDelimiterInner
		    //FIXME && (_closeDelimiterInner == null && c != _closeDelimiter)
		    && c != _closeDelimiter
		    && c != _openDelimiter
		    && c != _openDelimiterInner
		    && c != _EOF); //FIXME EOF should be error.

	// FIXME probably need to differentiate between searching for open, or close
	// delimiter.
	String _readLine() => _r.readWhile(
		(c) => c != _closeDelimiterInner
        //FIXME && (_closeDelimiterInner == null && c != _closeDelimiter)
        && c != _closeDelimiter
        && c != _openDelimiter
        && c != _openDelimiterInner
		    && c != _EOF   //FIXME EOF should be error.
		    && c != _NEWLINE);

  //FIXME unless in lenient mode only allow spaces.
	String _readTagWhitespace() => _r.readWhile(_isWhitespace);
	
	bool _isWhitespace(int c)
	  => const [_SPACE, _TAB , _NEWLINE, _RETURN].contains(c);
	
	_scanText() {
		while(true) {
		  int c = _peek();
			
		  if (c == _EOF) {
		    return; 
		  
		  } else if (c == _openDelimiter) { 
			  return;
			
		 } else if (c == _RETURN) {
        _read();
        if (_peek() == _NEWLINE) {
          _read();
          _tokens.add(new _Token(_LINE_END, '\r\n', _r.line, _r.column));
        } else {
          _addCharToken(_TEXT, _RETURN);
        }			  
			} else if (c == _NEWLINE) {
			  _read();
			  _addCharToken(_LINE_END, _NEWLINE);
			
			} else if (c == _SPACE || c == _TAB) {
        var value = _r.readWhile((c) => c == _SPACE || c == _TAB);
        _tokens.add(new _Token(_WHITESPACE, value, _r.line, _r.column));
			
      //FIXME figure out why this is required
			} else if (c == _closeDelimiter || c == _closeDelimiterInner) {
        _read();
        _addCharToken(_TEXT, c);
        
			} else {
			  _addStringToken(_TEXT);
			}
		}	
	}
	
	//TODO consider changing the parsing here to use a regexp. It will probably
	// be simpler to read.
	_scanChangeDelimiterTag() {
	  // Open delimiter characters have already been read.
	  _expect(_EQUAL);
	  
	  int line = _r.line;
	  int col = _r.column;
	  
    var delimiterInner = _closeDelimiterInner;
    var delimiter = _closeDelimiter;
    
    _readTagWhitespace();
    
    int c;
    c = _r.read();
    
    if (c == _EQUAL) throw 'syntax error'; //FIXME
    _openDelimiter = c;
    
    c = _r.read();
    if (_isWhitespace(c)) {
      _openDelimiterInner = null;
    } else {
      _openDelimiterInner = c;
    }
    
    _readTagWhitespace();
    
    c = _r.read();
    
    if (_isWhitespace(c) || c == _EQUAL) throw 'syntax error'; //FIXME
    
    if (_isWhitespace(_peek()) || _peek() == _EQUAL) {
      _closeDelimiterInner = null;
      _closeDelimiter = c;
    } else {
      _closeDelimiterInner = c;
      _closeDelimiter = _read();
    }
    
    _readTagWhitespace();
    _expect(_EQUAL);
    _readTagWhitespace();
     
     _expect(delimiterInner);
     _expect(delimiter);
    
     var value = _delimiterString(
         _openDelimiter,
         _openDelimiterInner,
         _closeDelimiterInner,
         _closeDelimiter);
          
     _tokens.add(new _Token(_CHANGE_DELIMITER, value, line, col));
	}
	
	_scanMustacheTag() {
	  int startOffset = _r.offset;
	  
		_expect(_openDelimiter);

		// If just a single mustache, return this as a text token.
		//FIXME is this missing a read call to advance ??
		if (_openDelimiterInner != null && _peek() != _openDelimiterInner) {
			_addCharToken(_TEXT, _openDelimiter);
			return;
		}

		if (_openDelimiterInner != null) _expect(_openDelimiterInner);

    // Escaped text {{{ ... }}}
		if (_peek() == _OPEN_MUSTACHE) {
		  _read();
      _addStringToken(_UNESC_VARIABLE);
      _expect(_CLOSE_MUSTACHE);
      _expect(_closeDelimiterInner);
      _expect(_closeDelimiter);
      return;
		}

    // Skip whitespace at start of tag. i.e. {{ # foo }}  {{ / foo }}
		_readTagWhitespace();
		
		switch(_peek()) {
			case _EOF:
				throw new TemplateException('Unexpected end of input',
				    _templateName, _r.line, _r.column);
  			
			// Escaped text {{& ... }}
			case _AMP:
				_read();
				_addStringToken(_UNESC_VARIABLE);
				break;

			// Comment {{! ... }}
			case _EXCLAIM:
				_read();
				_addStringToken(_COMMENT);
				break;

			// Partial {{> ... }}
			case _GT:
				_read();
				_addPartialToken();
				break;

			// Open section {{# ... }}
			case _HASH:
				_read();
				_addStringToken(_OPEN_SECTION);
				break;

			// Open inverted section {{^ ... }}
			case _CARET:
				_read();
				_addStringToken(_OPEN_INV_SECTION);
				break;

			// Close section {{/ ... }}
			case _FORWARD_SLASH:
				_read();
				_addStringToken(_CLOSE_SECTION);
		    // Store source file offset, so source substrings can be extracted for
        // lambdas.
				_tokens.last.offset = startOffset;
				break;
				
			// Change delimiter {{= ... =}}
			case _EQUAL:
			  _scanChangeDelimiterTag();
        return;

			// Variable {{ ... }}
			default:
				_addStringToken(_VARIABLE);
		}

		if (_closeDelimiterInner != null) _expect(_closeDelimiterInner);
		_expect(_closeDelimiter);
		
		// Store source file offset, so source substrings can be extracted for
		// lambdas.
		if (_tokens.isNotEmpty) {
		  var t = _tokens.last;
		  if (t.type == _OPEN_SECTION || t.type == _OPEN_INV_SECTION) {
		    t.offset = _r.offset;
		  }
		}
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
    throw 'Invalid delimiter string $s'; //FIXME
  }  
}