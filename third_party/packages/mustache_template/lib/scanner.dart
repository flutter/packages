part of mustache;

List<_Token> _scan(String source) => new _Scanner(source).scan();

const int _TEXT = 1;
const int _VARIABLE = 2;
const int _PARTIAL = 3;
const int _OPEN_SECTION = 4;
const int _OPEN_INV_SECTION = 5;
const int _CLOSE_SECTION = 6;
const int _COMMENT = 7;

tokenTypeString(int type) => ['?', 'Text', 'Var', 'Par', 'Open', 'OpenInv', 'Close', 'Comment'][type];

const int _EOF = -1;
const int _NEWLINE = 10;
const int _EXCLAIM = 33;
const int _QUOTE = 34;
const int _HASH = 35;
const int _AMP = 38;
const int _APOS = 39;
const int _FORWARD_SLASH = 47;
const int _LT = 60;
const int _GT = 62;
const int _CARET = 94;

const int _OPEN_MUSTACHE = 123;
const int _CLOSE_MUSTACHE = 125;

class _Token {
	_Token(this.type, this.value);
	_Token.fromChar(this.type, int charCode)
		: value = new String.fromCharCode(charCode);
	final int type;
	final String value;
	toString() => "${tokenTypeString(type)}: \"${value.replaceAll('\n', '\\n')}\"";
}

class _Scanner {
	_Scanner(String source) : _r = new _CharReader(source);

	_CharReader _r;
	List<_Token> _tokens = new List<_Token>();

	int _read() => _r.read();
	int _peek() => _r.peek();

	_add(_Token t) => _tokens.add(t);

	_expect(int c) {
		if (c != _read())
			throw new FormatException('Expected character: ${new String.fromCharCode(c)}');
	}

	String _readString() => _r.readWhile(
		(c) => c != _OPEN_MUSTACHE && c != _CLOSE_MUSTACHE && c != _EOF);

	List<_Token> scan() {
		while(true) {
			switch(_peek()) {
				case _EOF:
					return _tokens;
				case _OPEN_MUSTACHE:
					_scanMustacheTag();
					break;
				default:
					_scanText();
			}
		}
	}

	_scanText() {
		while(true) {
			switch(_peek()) {
				case _EOF:
					return;
				case _OPEN_MUSTACHE:
					return;
				case _CLOSE_MUSTACHE:
					_read();
					_add(new _Token.fromChar(_TEXT, _CLOSE_MUSTACHE));
					break;
				default:
					_add(new _Token(_TEXT, _readString()));
			}
		}	
	}

	_scanMustacheTag() {
		assert(_peek() == _OPEN_MUSTACHE);
		_read();

		if (_peek() != _OPEN_MUSTACHE) {
			_add(new _Token.fromChar(_TEXT, _OPEN_MUSTACHE));
			return;
		}

		_read();
		switch(_peek()) {
			case _EOF:
				throw new FormatException('Unexpected EOF.');

			// Escaped text {{{ ... }}}
			case _OPEN_MUSTACHE:
				_read();
				_add(new _Token(_TEXT, _readString()));
				_expect(_CLOSE_MUSTACHE);
				break;
      			
			// Escaped text {{& ... }}
			case _AMP:
				_read();
				_add(new _Token(_TEXT, _readString()));
				break;

			// Comment {{! ... }}
			case _EXCLAIM:
				_read();
				_add(new _Token(_COMMENT, _readString()));
				break;

			// Partial {{> ... }}
			case _GT:
				_read();
				_add(new _Token(_PARTIAL, _readString()));
				break;

			// Open section {{# ... }}
			case _HASH:
				_read();
				_add(new _Token(_OPEN_SECTION, _readString()));
				break;

			// Open inverted section {{^ ... }}
			case _CARET:
				_read();
				_add(new _Token(_OPEN_INV_SECTION, _readString()));
				break;

			// Close section {{/ ... }}
			case _FORWARD_SLASH:
				_read();
				_add(new _Token(_CLOSE_SECTION, _readString()));
				break;

			// Variable {{ ... }}
			default:
				_add(new _Token(_VARIABLE, _readString()));
		}

		_expect(_CLOSE_MUSTACHE);
		_expect(_CLOSE_MUSTACHE);
	}
}

class _CharReader {
  _CharReader(String source)
      : _source = source,
        _itr = source.runes.iterator {  //FIXME runes etc. Not sure if this is the right count.
        
    if (source == null)
      throw new ArgumentError('Source is null.');
    
    _i = 0;
    
    if (source == '') {
    	_c = _EOF;
    } else {
    	_itr.moveNext();
    	_c = _itr.current;
    }
  }
  
  String _source;
  Iterator<int> _itr;
  int _i, _c;
  
  int read() {
    var c = _c;
    if (_itr.moveNext()) {
    	_i++;
    	_c = _itr.current;
    } else {
    	_c = _EOF;
    }
    return c;
  }
  
  int peek() => _c;
  
  String readWhile(bool test(int charCode)) {
    
    if (peek() == _EOF)
      throw new FormatException('Unexpected end of input: $_i');
    
    int start = _i;
    
    while (peek() != _EOF && test(peek())) {
      read();
    }
    
    int end = peek() == _EOF ? _source.length : _i;
    return _source.slice(start, end);
  }
}