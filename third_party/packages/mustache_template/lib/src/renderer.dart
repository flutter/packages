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
   
  final _Node _root;
  final StringSink _sink;
  final _values;
  final List _stack;
  final bool _lenient;
  final bool _htmlEscapeValues;
  final PartialResolver _partialResolver;
  final String _templateName;
  final String _indent;
  final String _source;

  String _delimiters;
  
  void render() {
    if (_indent == null || _indent == '') {
     _root.children.forEach(_renderNode);
    } else {
      _renderWithIndent();
    }
  }
  
  void _renderWithIndent() {
    // Special case to make sure there is not an extra indent after the last
    // line in the partial file.
    if (_root.children.isEmpty) return;
    
    _write(_indent);
    
    for (int i = 0; i < _root.children.length - 1; i++) {
      _renderNode(_root.children[i]);
    }
    
    var node = _root.children.last;
    if (node.type != _TEXT) {
      _renderNode(node);
    } else {
      _renderText(node, lastNode: true);
    }
  }
  
  _write(Object output) => _sink.write(output.toString());

  _renderNode(_Node node) {
    switch (node.type) {
      case _TEXT:
        _renderText(node);
        break;
      case _VARIABLE:
        _renderVariable(node);
        break;
      case _UNESC_VARIABLE:
        _renderVariable(node, escape: false);
        break;
      case _OPEN_SECTION:
        _renderSection(node);
        break;
      case _OPEN_INV_SECTION:
        _renderInvSection(node);
        break;
      case _PARTIAL:
        _renderPartial(node);
        break;
      case _COMMENT:
        break; // Do nothing.
      case _CHANGE_DELIMITER:
        _delimiters = node.value;
        break;
      default:
        throw new UnimplementedError();
    }
  }

  _renderText(_Node node, {bool lastNode: false}) {
    var s = node.value;
    if (s == '') return;
    if (_indent == null || _indent == '') {
      _write(s);
    } else if (lastNode && s.runes.last == _NEWLINE) {
      s = s.substring(0, s.length - 1);
      _write(s.replaceAll('\n', '\n$_indent'));
      _write('\n');
    } else {
      _write(s.replaceAll('\n', '\n$_indent'));
    }
  }

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
    
    var property = null;
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

  _renderVariable(_Node node, {bool escape : true}) {
    var value = _resolveValue(node.value);
    
    if (value is Function) {
      var context = new _LambdaContext(node, this, isSection: false);
      value = value(context);
      context.close();
    }
    
    if (value == _noSuchProperty) {
      if (!_lenient) 
        throw _error('Value was missing for variable tag: ${node.value}.', node);
    } else {
      var valueString = (value == null) ? '' : value.toString();
      var output = !escape || !_htmlEscapeValues
        ? valueString
        : _htmlEscape(valueString);
      _write(output);
    }
  }

  _renderSectionWithValue(node, value) {
    _stack.add(value);
    node.children.forEach(_renderNode);
    _stack.removeLast();
  }

  String _renderSubtree(node) {
    var sink = new StringBuffer();
    var renderer = new _Renderer.subtree(this, node, sink);
    renderer.render();
    return sink.toString();
  }
  
  _renderSection(_Node node) {
    var value = _resolveValue(node.value);
    
    if (value == null) {
      // Do nothing.
    
    } else if (value is Iterable) {
      value.forEach((v) => _renderSectionWithValue(node, v));
    
    } else if (value is Map) {
      _renderSectionWithValue(node, value);
    
    } else if (value == true) {
      _renderSectionWithValue(node, value);
    
    } else if (value == false) {
      // Do nothing.
    
    } else if (value == _noSuchProperty) {
      if (!_lenient)
        throw _error('Value was missing for section tag: ${node.value}.', node);
    
    } else if (value is Function) {
      var context = new _LambdaContext(node, this, isSection: true);
      var output = value(context);
      context.close();        
      _write(output);
      
    } else {
      throw _error('Invalid value type for section, '
        'section: ${node.value}, '
        'type: ${value.runtimeType}.', node);
    }
  }

  _renderInvSection(node) {
    var value = _resolveValue(node.value);
    
    if (value == null) {
      _renderSectionWithValue(node, null);
    
    } else if ((value is Iterable && value.isEmpty) || value == false) {
      _renderSectionWithValue(node, value);
    
    } else if (value == true || value is Map || value is Iterable) {
      // Do nothing.
    
    } else if (value == _noSuchProperty) {
      if (_lenient) {
        _renderSectionWithValue(node, null);
      } else {
        throw _error('Value was missing for inverse section: ${node.value}.', node);
      }

     } else if (value is Function) {       
      // Do nothing.
       //TODO in strict mode should this be an error?

    } else {
      throw _error(
        'Invalid value type for inverse section, '
        'section: ${node.value}, '
        'type: ${value.runtimeType}.', node);
    }
  }

  _renderPartial(_Node node) {
    var partialName = node.value;
    _Template template = _partialResolver == null
        ? null
        : _partialResolver(partialName);
    if (template != null) {
      var renderer = new _Renderer.partial(this, template, node.indent);
      renderer.render();      
    } else if (_lenient) {
      // do nothing
    } else {
      throw _error('Partial not found: $partialName.', node);
    }
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
