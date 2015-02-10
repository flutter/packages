part of mustache;

class _Node {
  
  _Node(this.type, this.value, this.line, this.column, {this.indent});
  
  _Node.fromToken(_Token token)
    : type = token.type,
      value = token.value,
      line = token.line,
      column = token.column,
      indent = token.indent;

  final int type;
  final String value;
  final int line;
  final int column;
  final String indent;
  final List<_Node> children = new List<_Node>();
  
   //TODO ideally these could be made final.
   int start;
   int end;
  
  String toString() => '_Node: ${_tokenTypeString(type)}';
}
