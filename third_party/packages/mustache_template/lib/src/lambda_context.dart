// TODO(stuartmorgan): Remove this. See https://github.com/flutter/flutter/issues/174722.
// ignore_for_file: public_member_api_docs

import '../mustache.dart' as m;

import 'node.dart';
import 'parser.dart' as parser;
import 'renderer.dart';
import 'template_exception.dart';

/// Passed as an argument to a mustache lambda function.
class LambdaContext implements m.LambdaContext {
  LambdaContext(this._node, this._renderer);
  final Node _node;
  final Renderer _renderer;
  bool _closed = false;

  void close() {
    _closed = true;
  }

  void _checkClosed() {
    if (_closed) {
      throw _error('LambdaContext accessed outside of callback.');
    }
  }

  TemplateException _error(String msg) {
    return TemplateException(
      msg,
      _renderer.templateName,
      _renderer.source,
      _node.start,
    );
  }

  @override
  String renderString({Object? value}) {
    _checkClosed();
    if (_node is! SectionNode) {
      // TODO(stuartmorgan): Fix the lack of `throw` here, which looks like a
      //  bug in the original code.
      _error(
        'LambdaContext.renderString() can only be called on section tags.',
      );
    }
    final sink = StringBuffer();
    _renderSubtree(sink, value);
    return sink.toString();
  }

  void _renderSubtree(StringSink sink, Object? value) {
    final renderer = Renderer.subtree(_renderer, sink);
    final section = _node as SectionNode;
    if (value != null) {
      renderer.push(value);
    }
    renderer.render(section.children);
  }

  @override
  void render({Object? value}) {
    _checkClosed();
    if (_node is! SectionNode) {
      // TODO(stuartmorgan): Fix the lack of `throw` here, which looks like a
      //  bug in the original code.
      _error('LambdaContext.render() can only be called on section tags.');
    }
    _renderSubtree(_renderer.sink, value);
  }

  @override
  void write(Object object) {
    _checkClosed();
    _renderer.write(object);
  }

  @override
  String get source {
    _checkClosed();

    if (_node is! SectionNode) {
      return '';
    }

    final SectionNode node = _node;
    final List<Node> nodes = node.children;
    if (nodes.isEmpty) {
      return '';
    }

    if (nodes.length == 1 && nodes.first is TextNode) {
      return (nodes.single as TextNode).text;
    }

    return _renderer.source.substring(node.contentStart, node.contentEnd);
  }

  @override
  String renderSource(String source, {Object? value}) {
    _checkClosed();
    final sink = StringBuffer();

    // Lambdas used for sections should parse with the current delimiters.
    var delimiters = '{{ }}';
    if (_node is SectionNode) {
      final SectionNode node = _node;
      delimiters = node.delimiters;
    }

    final List<Node> nodes = parser.parse(
      source,
      _renderer.lenient,
      _renderer.templateName,
      delimiters,
    );

    final renderer = Renderer.lambda(_renderer, source, _renderer.indent, sink);

    if (value != null) {
      renderer.push(value);
    }
    renderer.render(nodes);

    return sink.toString();
  }

  @override
  Object? lookup(String variableName) {
    _checkClosed();
    return _renderer.resolveValue(variableName);
  }
}
