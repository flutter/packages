library mustache.lambda_context;

import 'package:mustache/mustache.dart' as m;

import 'node.dart';
import 'parser.dart' as parser;
import 'render_context.dart';
import 'renderer.dart';
import 'template_exception.dart';

/// Passed as an argument to a mustache lambda function.
class LambdaContext implements m.LambdaContext {
  
  final Node _node;
  final RenderContext _context;
  final bool _isSection;
  bool _closed = false;
  
  LambdaContext(this._node, this._context, {bool isSection: true})
      : _isSection = isSection;
  
  void close() {
    _closed = true;
  }
  
  void _checkClosed() {
    if (_closed) throw _error('LambdaContext accessed outside of callback.');
  }
  
  TemplateException _error(String msg) {
    return new TemplateException(msg, _context.templateName, _context.source,
        _node.start);    
  }
  
  /// Render the current section tag in the current context and return the
  /// result as a string.
  String renderString({Object value}) {
    _checkClosed();
    if (_node is! SectionNode) _error(
        'LambdaContext.renderString() can only be called on section tags.');
    var sink = new StringBuffer();
    _renderSubtree(sink, value);
    return sink.toString();
  }

  void _renderSubtree(StringSink sink, Object value) {
    var ctx = new RenderContext.subtree(_context, sink);
    var renderer = new Renderer(ctx);
    SectionNode section = _node;
    if (value != null) ctx.push(value);
    renderer.render(section.children);
  }
  
  void render({Object value}) {
    _checkClosed();
    if (_node is! SectionNode) _error(
        'LambdaContext.render() can only be called on section tags.');
    _renderSubtree(_context.sink, value);
  }

  void write(Object object) {
    _checkClosed();
    _context.write(object);
  }
  
  /// Get the unevaluated template source for the current section tag.
  String get source {
    _checkClosed();
    
    if (_node is! SectionNode) return '';
    
    SectionNode node = _node;
    
    var nodes = node.children;
    
    if (nodes.isEmpty) return '';
    
    if (nodes.length == 1 && nodes.first is TextNode) return nodes.first.text;
    
    return _context.source.substring(node.contentStart, node.contentEnd);
  }

  /// Evaluate the string as a mustache template using the current context.
  String renderSource(String source, {Object value}) {
    _checkClosed();
    var sink = new StringBuffer();
    
    // Lambdas used for sections should parse with the current delimiters.
    var delimiters = '{{ }}';
    if (_node is SectionNode) {
      SectionNode node = _node;
      delimiters = node.delimiters;
    }
    
    var nodes = parser.parse(source,
        _context.lenient,
        _context.templateName,
        delimiters);
    
    var ctx = new RenderContext.lambda(
        _context,
        source,
        _context.indent,
        sink,
        delimiters);
    
    var renderer = new Renderer(ctx);
    
    if (value != null) ctx.push(value);
    renderer.render(nodes);

    return sink.toString();
  }

  /// Lookup the value of a variable in the current context.
  Object lookup(String variableName) {
    _checkClosed();
    return _context.resolveValue(variableName);
  }

}