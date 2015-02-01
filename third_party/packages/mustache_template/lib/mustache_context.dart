part of mustache;

class _MustacheContext implements MustacheContext {

  _MustacheContext(PartialResolver partialResolver,
      {bool lenient: false, bool htmlEscapeValues: true})
      : _partialResolver = partialResolver,
        _lenient = lenient,
        _htmlEscapeValues = htmlEscapeValues;
  
  final PartialResolver _partialResolver;
  final bool _lenient;
  final bool _htmlEscapeValues;
  
  String renderString(String templateName, values) {
    var template = _partialResolver(templateName);
    return template.renderString(values, 
        lenient: _lenient, htmlEscapeValues: _htmlEscapeValues);
  }
  
  void render(String templateName, values, StringSink sink) {
    var template = _partialResolver(templateName);
    template.render(values, sink, 
        lenient: _lenient, htmlEscapeValues: _htmlEscapeValues);    
  }
  
}
