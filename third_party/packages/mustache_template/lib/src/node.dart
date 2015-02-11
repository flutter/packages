part of mustache;

class _Node {
  
  _Node(this.type, this.value, this.start, this.end, {this.indent});
  
  _Node.fromToken(_Token token, {int start})
    : type = token.type,
      value = token.value,
      start = start == null ? token.start : start,
      end = token.end,
      indent = token.indent;
  
  final int type;
  final String value;
  final int start;
  int end;
  final String indent;
  final List<_Node> children = new List<_Node>();
  
  String toString() => '_Node: ${_tokenTypeString(type)}';
}
