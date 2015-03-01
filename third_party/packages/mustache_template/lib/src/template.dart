library mustache.template;

import 'package:mustache/mustache.dart' as m;

import 'node.dart';
import 'parser.dart' as parser;
import 'render_context.dart';

class Template implements m.Template {
 
  Template.fromSource(String source, 
       {bool lenient: false,
        bool htmlEscapeValues : true,
        String name,
        m.PartialResolver partialResolver})
       :  source = source,
          _nodes = parser.parse(source, lenient, name, '{{ }}'),
          _lenient = lenient,
          _htmlEscapeValues = htmlEscapeValues,
          _name = name,
          _partialResolver = partialResolver;
  
  final String source;
  final List<Node> _nodes;
  final bool _lenient;
  final bool _htmlEscapeValues;
  final String _name;
  final m.PartialResolver _partialResolver;
  
  //TODO get rid of this. Only needed for rendering partials.
  List<Node> getNodes() => _nodes;
  
  String get name => _name;
  
  String renderString(values) {
    var buf = new StringBuffer();
    render(values, buf);
    return buf.toString();
  }

  void render(values, StringSink sink) {
    var ctx = new RenderContext(sink, [values], _lenient, _htmlEscapeValues,
        _partialResolver, _name, '', source);
    renderWithContext(ctx, _nodes);
  }
}
