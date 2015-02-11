part of mustache;

class _Node {
  
  _Node(this.type, this.value, this.start, this.end, {this.indent});
  
  _Node.fromToken(_Token token)
    : type = token.type,
      value = token.value,
      start = token.start,
      end = token.end,
      indent = token.indent;
  
  final int type;
  final String value;
  
  // The offset of the start of the token in the file. Unless this is a section
  // or inverse section, then this stores the start of the content of the
  // section.
  final int start;
  final int end;
  
  int contentStart;
  int contentEnd;
  
  // Used to store the preceding whitespace before a partial tag, so that
  // it's content can be correctly indented.
  final String indent;
  
  final List<_Node> children = new List<_Node>();
  
  String toString() => '_Node: ${_tokenTypeString(type)}';
}
