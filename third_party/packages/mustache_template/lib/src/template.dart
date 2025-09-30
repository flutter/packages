// TODO(stuartmorgan): Remove this. See https://github.com/flutter/flutter/issues/174722.
// ignore_for_file: public_member_api_docs

import '../mustache.dart' as m;
import 'node.dart';
import 'parser.dart' as parser;
import 'renderer.dart';

class Template implements m.Template {
  Template.fromSource(
    this.source, {
    bool lenient = false,
    bool htmlEscapeValues = true,
    String? name,
    m.PartialResolver? partialResolver,
    String delimiters = '{{ }}',
  }) : _nodes = parser.parse(source, lenient, name, delimiters),
       _lenient = lenient,
       _htmlEscapeValues = htmlEscapeValues,
       _name = name,
       _partialResolver = partialResolver;

  @override
  final String source;
  final List<Node> _nodes;
  final bool _lenient;
  final bool _htmlEscapeValues;
  final String? _name;
  final m.PartialResolver? _partialResolver;

  @override
  String? get name => _name;

  @override
  String renderString(Object? values) {
    final StringBuffer buf = StringBuffer();
    render(values, buf);
    return buf.toString();
  }

  @override
  void render(Object? values, StringSink sink) {
    final Renderer renderer = Renderer(
      sink,
      <dynamic>[values],
      _lenient,
      _htmlEscapeValues,
      _partialResolver,
      _name,
      '',
      source,
    );
    renderer.render(_nodes);
  }
}

// Expose getter for nodes internally within this package.
List<Node> getTemplateNodes(Template template) => template._nodes;
