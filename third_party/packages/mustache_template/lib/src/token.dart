part of mustache;

class _Token {
  
  _Token(this.type, this.value, this.start, this.end, {this.indent : ''});
  
  final int type;
  final String value;
  
  final int start;
  final int end;
  final String indent;
  
  toString() => "${_tokenTypeString(type)}: "
    "\"${value.replaceAll('\n', '\\n')}\"";
}

//FIXME use enums
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
const int _CHANGE_DELIMITER = 11;

_tokenTypeString(int type) => [
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
  'LineEnd',
  'ChangeDelimiter'][type];
