part of mustache;

List<_Token> _scan(String source, bool lenient) => new _Scanner(source).scan();

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
const int _APOS = 39;
const int _HASH = 35;
const int _AMP = 38;
const int _FORWARD_SLASH = 47;
const int _LT = 60;
const int _GT = 62;
const int _CARET = 94;

const int _OPEN_MUSTACHE = 123;
const int _CLOSE_MUSTACHE = 125;

class _Token {
	_Token(this.type, this.value, this.line, this.column);
	final int type;
	final String value;
	final int line;
	final int column;
	toString() => "${tokenTypeString(type)}: \"${value.replaceAll('\n', '\\n')}\" $line:$column";
}

class _Scanner {
	_Scanner(String source) : _r = new _CharReader(source);

	_CharReader _r;
	List<_Token> _tokens = new List<_Token>();

	int _read() => _r.read();
	int _peek() => _r.peek();

	_addStringToken(int type) {
		int l = _r.line, c = _r.column;
		var value = _readString();
		_tokens.add(new _Token(type, value, l, c));
	}

	_addCharToken(int type) {
		int l = _r.line, c = _r.column;
		var value = new String.fromCharCode(_read());
		_tokens.add(new _Token(type, value, l, c));
	}

	_expect(int expectedCharCode) {
		int c = _read();

		if (c == _EOF) {
			throw new MustacheFormatException('Unexpected end of input.', _r.line, _r.column);

		} else if (c != expectedCharCode) {
			throw new MustacheFormatException('Unexpected character, '
				'expected: ${new String.fromCharCode(expectedCharCode)} ($expectedCharCode), '
				'was: ${new String.fromCharCode(c)} ($c), '
				'at: ${_r.line}:${_r.column}', _r.line, _r.column);
		}
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
					_addCharToken(_TEXT);
					break;
				default:
					_addStringToken(_TEXT);
			}
		}	
	}

	_scanMustacheTag() {
		_expect(_OPEN_MUSTACHE);

		// If just a single mustache, return this as a text token.
		if (_peek() != _OPEN_MUSTACHE) {
			_addCharToken(_TEXT);
			return;
		}

		_expect(_OPEN_MUSTACHE);

		switch(_peek()) {
			case _EOF:
				throw new MustacheFormatException('Unexpected end of input.', _r.line, _r.column);

			// Escaped text {{{ ... }}}
			case _OPEN_MUSTACHE:				
				throw new UnimplementedError('Escape tag {{{ ... }}}');
				//_read();
				//_addStringToken(_TEXT);
				//_expect(_CLOSE_MUSTACHE);
				//break;
      			
			// Escaped text {{& ... }}
			case _AMP:
				throw new UnimplementedError('Escape tag {{& ... }}');
				//_read();
				//_addStringToken(_TEXT);
				//break;

			// Comment {{! ... }}
			case _EXCLAIM:
				_read();
				_addStringToken(_COMMENT); //FIXME hmmm need to think about escaping rules here.
				break;

			// Partial {{> ... }}
			case _GT:
				_read();
				_addStringToken(_PARTIAL);
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
				break;

			// Variable {{ ... }}
			default:
				_addStringToken(_VARIABLE);
		}

		_expect(_CLOSE_MUSTACHE);
		_expect(_CLOSE_MUSTACHE);
	}
}

