part of mustache;

//FIXME Temporarily made public for testing.
//List<_Token> scan(String source, bool lenient) => _scan(source, lenient);
//List<_Token> trim(List<_Token> tokens) => _trim(tokens);

List<_Token> _scan(String source, bool lenient) //=> _trim(new _Scanner(source).scan());
{
	var tokens = new _Scanner(source).scan();
	print('Before');
	print(tokens);
	tokens = _trim(tokens);
	print('After');
	print(tokens);	
	return tokens;
}

const int _TEXT = 1;
const int _VARIABLE = 2;
const int _PARTIAL = 3;
const int _OPEN_SECTION = 4;
const int _OPEN_INV_SECTION = 5;
const int _CLOSE_SECTION = 6;
const int _COMMENT = 7;
const int _UNESC_VARIABLE = 8;
const int _WHITESPACE = 9; // Should be filtered out, before returned by scan.
const int _LINE_END = 10; // Should be filtered out, before returned by scan.

//FIXME make private
tokenTypeString(int type) => [
	'?', 
	'Text',
	'Var',
	'Par',
	'Open',
	'OpenInv',
	'Close',
	'Comment',
	'UnescVar',
	'Whitespace',
	'LineEnd'][type];

const int _EOF = -1;
const int _TAB = 9;
const int _NEWLINE = 10;
const int _SPACE = 32;
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

// Takes a list of tokens, and removes _NEWLINE, and _WHITESPACE tokens.
// This is used to implement mustache standalone lines.
// Where TAG is one of: OPEN_SECTION, INV_SECTION, CLOSE_SECTION
// LINE_END, [WHITESPACE], TAG, [WHITESPACE], LINE_END => LINE_END, TAG
// WHITESPACE => TEXT
// LINE_END => TEXT
//TODO Consecutive text tokens will also be merged into a single token. (Do in a separate merge func).
List<_Token> _trim(List<_Token> tokens) {
	int i = 0;
	_Token read() { var ret = i < tokens.length ? tokens[i++] : null; /* print('Read: $ret'); */ return ret; }
	_Token peek([int n = 0]) => i + n < tokens.length ? tokens[i + n] : null;

	bool isTag(token) => 
			token != null
			&& (token.type == _OPEN_SECTION
				  || token.type == _OPEN_INV_SECTION
				  || token.type == _CLOSE_SECTION
				  || token.type == _COMMENT);

	bool isWhitespace(token) => token != null && token.type == _WHITESPACE;
	bool isLineEnd(token) => token != null && token.type == _LINE_END;

	var result = new List<_Token>();
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
		}
	}

	// Handle case where first line is a standalone tag.
	standaloneLineCheck();

	var t;
	while ((t = read()) != null) {
		if (t.type == _LINE_END) {
			// Convert line end to text token
			add(new _Token(_TEXT, t.value, t.line, t.column));
			standaloneLineCheck();
		} else if (t.type == _WHITESPACE) {
			// Convert whitespace to text token
			add(new _Token(_TEXT, t.value, t.line, t.column));
		} else {
			// Preserve token
			add(t);
		}
	}

	return result;
}

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
		var value = type == _TEXT ? _readLine() : _readString();
		if (type != _TEXT && type != _COMMENT) value = value.trim();		
		_tokens.add(new _Token(type, value, l, c));
	}

	_addCharToken(int type, int charCode) {
		int l = _r.line, c = _r.column;
		var value = new String.fromCharCode(charCode);
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
		(c) => c != _OPEN_MUSTACHE
		    && c != _CLOSE_MUSTACHE
		    && c != _EOF);

String _readLine() => _r.readWhile(
		(c) => c != _OPEN_MUSTACHE
		    && c != _CLOSE_MUSTACHE
		    && c != _EOF
		    && c != _NEWLINE);

	// Actually excludes newlines.
	String _readWhitespace() => _r.readWhile(
		(c) => c == _SPACE 
		    || c == _TAB);

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
					_addCharToken(_TEXT, _CLOSE_MUSTACHE);
					break;
				case _NEWLINE:
					_read();
					_addCharToken(_LINE_END, _NEWLINE); //TODO handle \r\n
					break;
				case _SPACE:
				case _TAB:
					var value = _readWhitespace();
					_tokens.add(new _Token(_WHITESPACE, value, _r.line, _r.column));
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
			_addCharToken(_TEXT, _OPEN_MUSTACHE);
			return;
		}

		_expect(_OPEN_MUSTACHE);

		switch(_peek()) {
			case _EOF:
				throw new MustacheFormatException('Unexpected end of input.', _r.line, _r.column);

			// Escaped text {{{ ... }}}
			case _OPEN_MUSTACHE:				
				_read();
				_addStringToken(_UNESC_VARIABLE);
				_expect(_CLOSE_MUSTACHE);
				break;
      			
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

