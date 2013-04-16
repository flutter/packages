part of mustache;

class _CharReader {

  String _source;
  Iterator<int> _itr;
  int _i, _c;
  int _line = 1, _column = 1;

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
  
  int get line => _line;
  int get column => _column;

  int read() {
    var c = _c;
    if (_itr.moveNext()) {
    	_i++;
    	_c = _itr.current;
    } else {
    	_c = _EOF;
    }

    if (c == _NEWLINE) {
    	_line++;
    	_column = 1;
    } else {
    	_column++;
    }

    return c;
  }
  
  int peek() => _c;
  
  String readWhile(bool test(int charCode)) {
    
    if (peek() == _EOF)
      throw new MustacheFormatException('Unexpected end of input.', line, column);
    
    int start = _i;
    
    while (peek() != _EOF && test(peek())) {
      read();
    }
    
    int end = peek() == _EOF ? _source.length : _i;
    return _source.substring(start, end);
  }
}