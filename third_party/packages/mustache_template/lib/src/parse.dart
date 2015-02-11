part of mustache;

final RegExp _validTag = new RegExp(r'^[0-9a-zA-Z\_\-\.]+$');
final RegExp _integerTag = new RegExp(r'^[0-9]+$');

_Node _parse(String source,
             bool lenient,
             String templateName,
             String delimiters) {
  
  if (source == null) throw new ArgumentError.notNull('Template source');
  
  var tokens = 
      new _Scanner(source, templateName, delimiters, lenient: lenient).scan();
  
  tokens = _removeStandaloneWhitespace(tokens);
  tokens = _mergeAdjacentText(tokens);

  //FIXME this should be handled by scanner now.
  checkTagChars(_Token t) {
      if (!lenient && !_validTag.hasMatch(t.value)) {
        throw new _TemplateException(
          'Tag contained invalid characters in name, '
          'allowed: 0-9, a-z, A-Z, underscore, and minus',
          templateName, source, t.start);
      }
  }

  
  var stack = new List<_Node>()..add(new _Node(_OPEN_SECTION, 'root', 0, 0));

  for (var t in tokens) {
    switch (t.type) {
      case _TEXT:
      case _VARIABLE:
      case _UNESC_VARIABLE:
      case _PARTIAL:
        if (t.type == _VARIABLE || t.type == _UNESC_VARIABLE)
          checkTagChars(t);
        stack.last.children.add(new _Node.fromToken(t));
        break;

      case _OPEN_SECTION:
      case _OPEN_INV_SECTION:
        checkTagChars(t);
        // Store the start, end of the inner string content not
        // including the tag.
        var child = new _Node.fromToken(t, start: t.end);
        stack.last.children.add(child);
        stack.add(child);
        break;

      case _CLOSE_SECTION:
        checkTagChars(t);

        if (stack.last.value != t.value) {
          throw new _TemplateException(
            "Mismatched tag, expected: '${stack.last.value}', was: '${t.value}'",
            templateName, source, t.start);
        }
  
        stack.last.end = t.start;
        
        stack.removeLast();
        break;
      
      case _CHANGE_DELIMITER:
        stack.last.children.add(new _Node.fromToken(t));
        break;
        
      case _COMMENT:
        // Do nothing
        break;
      
      //FIXME change constants to enums, and then remove this default clause.
      default:
        throw new StateError('Unkown node type: $t');
    }
  }

  return stack.last;
}

// Takes a list of tokens, and removes _NEWLINE, and _WHITESPACE tokens.
// This is used to implement mustache standalone lines.
// Where TAG is one of: OPEN_SECTION, INV_SECTION, CLOSE_SECTION
// LINE_END, [WHITESPACE], TAG, [WHITESPACE], LINE_END => LINE_END, TAG
// WHITESPACE => TEXT
// LINE_END => TEXT
// TODO could rewrite this to use a generator, rather than creating an inter-
// mediate list.
List<_Token> _removeStandaloneWhitespace(List<_Token> tokens) {
  int i = 0;
  _Token read() { var ret = i < tokens.length ? tokens[i++] : null; /* print('Read: $ret'); */ return ret; }
  _Token peek([int n = 0]) => i + n < tokens.length ? tokens[i + n] : null;

  bool isTag(token) => token != null
      && const [_OPEN_SECTION, _OPEN_INV_SECTION, _CLOSE_SECTION, _COMMENT,
                _PARTIAL, _CHANGE_DELIMITER].contains(token.type);

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

      standaloneLineCheck(); //FIXME don't use recursion.
    }
  }

  // Handle case where first line is a standalone tag.
  standaloneLineCheck();

  var t;
  while ((t = read()) != null) {
    if (t.type == _LINE_END) {
      // Convert line end to text token
      add(new _Token(_TEXT, t.value, t.start, t.end));
      standaloneLineCheck();
    } else if (t.type == _WHITESPACE) {
      // Convert whitespace to text token
      add(new _Token(_TEXT, t.value, t.start, t.end));
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
List<_Token> _mergeAdjacentText(List<_Token> tokens) {
  if (tokens.isEmpty) return <_Token>[];
  
  var result = new List<_Token>();
  int i = 0;
  while(i < tokens.length) {
    var t = tokens[i];
    
    if (t.type != _TEXT
        || (i < tokens.length - 1 && tokens[i + 1].type != _TEXT)) {
      result.add(tokens[i]);
      i++;
    } else {
      var buffer = new StringBuffer();
      while(i < tokens.length && tokens[i].type == _TEXT) {
        buffer.write(tokens[i].value);
        i++;
      }
      result.add(new _Token(_TEXT, buffer.toString(), t.start, t.end));
    }
  }
  return result;
}
