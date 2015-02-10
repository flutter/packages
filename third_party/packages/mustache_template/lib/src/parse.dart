part of mustache;

final RegExp _validTag = new RegExp(r'^[0-9a-zA-Z\_\-\.]+$');
final RegExp _integerTag = new RegExp(r'^[0-9]+$');

_Node _parse(String source, bool lenient, String templateName,
             Delimiters delimiters) {
  if (source == null) throw new ArgumentError.notNull('Template source');
  var tokens = _scan(source, lenient, delimiters);
  var ast = _parseTokens(tokens, lenient, templateName);
  return ast;
}

_Node _parseTokens(List<_Token> tokens, bool lenient, String templateName) {
  
  var stack = new List<_Node>()..add(new _Node(_OPEN_SECTION, 'root', 0, 0));
  
  for (var t in tokens) {
    if (const [_TEXT, _VARIABLE, _UNESC_VARIABLE, _PARTIAL].contains(t.type)) {
      if (t.type == _VARIABLE || t.type == _UNESC_VARIABLE)
        _checkTagChars(t, lenient, templateName);
      stack.last.children.add(new _Node.fromToken(t));

    } else if (t.type == _OPEN_SECTION || t.type == _OPEN_INV_SECTION) {
      _checkTagChars(t, lenient, templateName);
      var child = new _Node.fromToken(t);
      child.start = t.offset;
      stack.last.children.add(child);
      stack.add(child);

    } else if (t.type == _CLOSE_SECTION) {
      _checkTagChars(t, lenient, templateName);

      if (stack.last.value != t.value) {
        throw new TemplateException(
          "Mismatched tag, expected: '${stack.last.value}', was: '${t.value}'",
          templateName, t.line, t.column);
      }

      stack.last.end = t.offset;
      
      stack.removeLast();

    } else if (t.type == _CHANGE_DELIMITER) {
      stack.last.children.add(new _Node.fromToken(t));
      
    } else if (t.type == _COMMENT) {
      // Do nothing

    } else {
      //FIXME Use switch with enums so this becomes a compile time error.
      throw new UnimplementedError();
    }
  }

  return stack.last;
}

_checkTagChars(_Token t, bool lenient, String templateName) {
    if (!lenient && !_validTag.hasMatch(t.value)) {
      throw new TemplateException(
        'Tag contained invalid characters in name, '
        'allowed: 0-9, a-z, A-Z, underscore, and minus',
        templateName, t.line, t.column);
    }
}
