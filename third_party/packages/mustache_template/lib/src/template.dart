part of mustache;

class _Template implements Template {
 
  _Template.fromSource(String source, 
       {bool lenient: false,
        bool htmlEscapeValues : true,
        String name,
        PartialResolver partialResolver,
        Delimiters delimiters : const Delimiters.standard()})
       :  source = source,
          _root = _parse(source, lenient, name, delimiters),
          _lenient = lenient,
          _htmlEscapeValues = htmlEscapeValues,
          _name = name,
          _partialResolver = partialResolver;
  
  final String source;
  final _Node _root;
  final bool _lenient;
  final bool _htmlEscapeValues;
  final String _name;
  final PartialResolver _partialResolver;
  
  String get name => _name;
  
  String renderString(values) {
    var buf = new StringBuffer();
    render(values, buf);
    return buf.toString();
  }

  void render(values, StringSink sink) {
    var renderer = new _Renderer(_root, sink, values, [values],
        _lenient, _htmlEscapeValues, _partialResolver, _name, '', source,
        '{{ }}');
    renderer.render();
  }
}
