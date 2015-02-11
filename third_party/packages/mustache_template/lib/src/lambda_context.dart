part of mustache;

/// Passed as an argument to a mustache lambda function.
class _LambdaContext implements LambdaContext {
  
  final _Node _node;
  final _Renderer _renderer;
  final bool _isSection;
  bool _closed = false;
  
  _LambdaContext(this._node, this._renderer, {bool isSection: true})
      : _isSection = isSection;
  
  void close() {
    _closed = true;
  }
  
  _checkClosed() {
    if (_closed) throw new _TemplateException(
        'LambdaContext accessed outside of callback.', 
        _renderer._templateName, _renderer._source, _node.start);
  }
  
  /// Render the current section tag in the current context and return the
  /// result as a string.
  String renderString() {
    _checkClosed();
    return _renderer._renderSubtree(_node);
  }

  //FIXME Currently only return values are supported.
  /// Render and directly output the current section tag.
//  void render() {
//    _checkClosed();
//  }

  //FIXME Currently only return values are supported.
  /// Output a string.
//  void write(Object object) {
//    _checkClosed();
//  }

  /// Get the unevaluated template source for the current section tag.
  String get source {
    _checkClosed();
    
    var nodes = _node.children;
    
    if (nodes.isEmpty) return '';
    
    if (nodes.length == 1 && nodes.first.type == _TEXT)
      return nodes.first.value;
    
    var source = _renderer._source.substring(
        _node.contentStart, _node.contentEnd);
    
    return source;
  }

  /// Evaluate the string as a mustache template using the current context.
  String renderSource(String source) {
    _checkClosed();
    var sink = new StringBuffer();
    // Lambdas used for sections should parse with the current delimiters.
    var delimiters = _isSection ? _renderer._delimiters : '{{ }}';
    var node = _parse(source,
        _renderer._lenient,
        _renderer._templateName,
        delimiters);
    var renderer = new _Renderer.lambda(
        _renderer,
        node,
        source,
        _renderer._indent,
        sink,
        _renderer._delimiters);
    renderer.render();
    return sink.toString();
  }

  /// Lookup the value of a variable in the current context.
  Object lookup(String variableName) {
    _checkClosed();
    return _renderer._resolveValue(variableName);
  }

}