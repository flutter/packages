part of mustache;

final RegExp _validTag = new RegExp(r'^[0-9a-zA-Z\_\-\.]+$');
final RegExp _integerTag = new RegExp(r'^[0-9]+$');

const Object _noSuchProperty = const Object();

class _Renderer {
  
  _Renderer(this._root,
      this._sink,
      this._values,
      List stack,
      this._lenient,
      this._htmlEscapeValues,
      this._partialResolver,
      this._templateName,
      this._indent,
      this._source,
      this._delimiters)
    : _stack = new List.from(stack); 
  
  _Renderer.partial(_Renderer renderer, _Template partial, String indent)
      : this(partial._root,
          renderer._sink,
          renderer._values,
          renderer._stack,
          renderer._lenient,
          renderer._htmlEscapeValues,
          renderer._partialResolver,
          renderer._templateName,
          renderer._indent + indent,
          partial.source,
          '{{ }}');

   _Renderer.subtree(_Renderer renderer, _Node node, StringSink sink)
       : this(node,
           sink,
           renderer._values,
           renderer._stack,
           renderer._lenient,
           renderer._htmlEscapeValues,
           renderer._partialResolver,
           renderer._templateName,
           renderer._indent,
           renderer._source,
           '{{ }}');

    _Renderer.lambda(
        _Renderer renderer,
        _Node node,
        String source,
        String indent,
        StringSink sink,
        String delimiters)
       : this(node,
           sink,
           renderer._values,
           renderer._stack,
           renderer._lenient,
           renderer._htmlEscapeValues,
           renderer._partialResolver,
           renderer._templateName,
           renderer._indent + indent,
           source,
           delimiters);
   
  final _SectionNode _root;
  final StringSink _sink;
  final _values;
  final List _stack;
  final bool _lenient;
  final bool _htmlEscapeValues;
  final PartialResolver _partialResolver;
  final String _templateName;
  final String _indent;
  final String _source;
  
  // Need to keep track of the current delimiters during rendering.
  // These are used in LambdaContext.renderSource().
  String _delimiters;
  
  void render() {
    if (_indent == null || _indent == '') {
     _root.children.forEach((n) => n.render(this));
    } else {
      _renderWithIndent();
    }
  }
  
  void _renderWithIndent() {
    // Special case to make sure there is not an extra indent after the last
    // line in the partial file.
    var nodes = _root.children; 
    if (nodes.isEmpty) return;
    
    _write(_indent);
    
    for (var n in nodes.take(nodes.length - 1)) {
      n.render(this);
    }
        
    var node = _root.children.last;
    if (node is _TextNode) {
      node.render(this, lastNode: true);
    } else {
      node.render(this);
    }
  }
  
  _write(Object output) => _sink.write(output.toString());

  // Walks up the stack looking for the variable.
  // Handles dotted names of the form "a.b.c".
  _resolveValue(String name) {
    if (name == '.') {
      return _stack.last;
    }
    var parts = name.split('.');
    var object = _noSuchProperty;
    for (var o in _stack.reversed) {
      object = _getNamedProperty(o, parts[0]);
      if (object != _noSuchProperty) {
        break;
      }
    }
    for (int i = 1; i < parts.length; i++) {
      if (object == null || object == _noSuchProperty) {
        return _noSuchProperty;
      }
      object = _getNamedProperty(object, parts[i]);
    }
    return object;
  }
  
  // Returns the property of the given object by name. For a map,
  // which contains the key name, this is object[name]. For other
  // objects, this is object.name or object.name(). If no property
  // by the given name exists, this method returns noSuchProperty.
  _getNamedProperty(object, name) {
    
    if (object is Map && object.containsKey(name))
      return object[name];
    
    if (object is List && _integerTag.hasMatch(name))
      return object[int.parse(name)];
    
    if (_lenient && !_validTag.hasMatch(name))
      return _noSuchProperty;
    
    var instance = reflect(object);
    var field = instance.type.instanceMembers[new Symbol(name)];
    if (field == null) return _noSuchProperty;
    
    var invocation = null;
    if ((field is VariableMirror) || ((field is MethodMirror) && (field.isGetter))) {
      invocation = instance.getField(field.simpleName);
    } else if ((field is MethodMirror) && (field.parameters.length == 0)) {
      invocation = instance.invoke(field.simpleName, []);
    }
    if (invocation == null) {
      return _noSuchProperty;
    }
    return invocation.reflectee;
  }

  void _renderSectionWithValue(node, value) {
    _stack.add(value);
    node.children.forEach((n) => n.render(this));
    _stack.removeLast();
  }

  String _renderSubtree(node) {
    var sink = new StringBuffer();
    var renderer = new _Renderer.subtree(this, node, sink);
    renderer.render();
    return sink.toString();
  }

  static const Map<String,String> _htmlEscapeMap = const {
    _AMP: '&amp;',
    _LT: '&lt;',
    _GT: '&gt;',
    _QUOTE: '&quot;',
    _APOS: '&#x27;',
    _FORWARD_SLASH: '&#x2F;' 
  };
  
  String _htmlEscape(String s) {
    
    var buffer = new StringBuffer();
    int startIndex = 0;
    int i = 0;
    for (int c in s.runes) {
      if (c == _AMP
          || c == _LT
          || c == _GT
          || c == _QUOTE
          || c == _APOS
          || c == _FORWARD_SLASH) {
        buffer.write(s.substring(startIndex, i));
        buffer.write(_htmlEscapeMap[c]);
        startIndex = i + 1;
      }
      i++;
    }
    buffer.write(s.substring(startIndex));
    return buffer.toString();
  }
  
  TemplateException _error(String message, _Node node)
    => new _TemplateException(message, _templateName, _source, node.start);
}
