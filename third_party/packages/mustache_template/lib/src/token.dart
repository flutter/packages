part of mustache;

class _Token {
  _Token(this.type, this.value, this.line, this.column, {this.indent});
  
  final int type;
  final String value; 
  final int line;
  final int column;
  final String indent;
  
  // Store offsets to extract text from source for lambdas.
  // Only used for section, inverse section and close section tags.
  int offset;
  
  toString() => "${_tokenTypeString(type)}: "
    "\"${value.replaceAll('\n', '\\n')}\" $line:$column";
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
