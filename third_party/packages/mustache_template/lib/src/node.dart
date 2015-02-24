part of mustache;

abstract class _Node {
  
  _Node(this.start, this.end);
  
  void render(_Renderer renderer);
  
  // The offset of the start of the token in the file. Unless this is a section
  // or inverse section, then this stores the start of the content of the
  // section.
  final int start;
  final int end;
  
  int contentStart;
  int contentEnd;
  
}


class _TextNode extends _Node {
  
  _TextNode(this.text, int start, int end) : super(start, end);
  
  final String text;
  
  render(_Renderer renderer, {lastNode: false}) {
    if (text == '') return;
    if (renderer._indent == null || renderer._indent == '') {
      renderer._write(text);
    } else if (lastNode && text.runes.last == _NEWLINE) {
      var s = text.substring(0, text.length - 1);
      renderer._write(s.replaceAll('\n', '\n${renderer._indent}'));
      renderer._write('\n');
    } else {
      renderer._write(text.replaceAll('\n', '\n${renderer._indent}'));
    }
  }
}

class _VariableNode extends _Node {
  
  _VariableNode(this.name, int start, int end, {this.escape: false})
    : super(start, end);
  
  final String name;
  final bool escape;
  
  render(_Renderer renderer) {
    
    var value = renderer._resolveValue(name);
    
    if (value is Function) {
      var context = new _LambdaContext(this, renderer, isSection: false);
      value = value(context);
      context.close();
    }
    
    if (value == _noSuchProperty) {
      if (!renderer._lenient) 
        throw renderer._error('Value was missing for variable tag: ${name}.', this);
    } else {
      var valueString = (value == null) ? '' : value.toString();
      var output = !escape || !renderer._htmlEscapeValues
        ? valueString
        : renderer._htmlEscape(valueString);
      renderer._write(output);
    }
  }
}


class _SectionNode extends _Node {
  
  _SectionNode(this.name, int start, int end, this.delimiters,
      {this.inverse: false})
    : super(start, end);
  
  final String name;
  final String delimiters;
  final bool inverse;
  int contentStart;
  int contentEnd;
  final List<_Node> children = <_Node>[];
  
  //TODO can probably combine Inv and Normal to shorten.
  void render(_Renderer renderer) {
    // Keep track of delimiters for use in LambdaContext.renderSource().
    renderer._delimiters = delimiters;
    return inverse ? renderInv(renderer) : renderNormal(renderer);
  }
  
  void renderNormal(_Renderer renderer) {
    var value = renderer._resolveValue(name);
    
    if (value == null) {
      // Do nothing.
    
    } else if (value is Iterable) {
      value.forEach((v) => renderer._renderSectionWithValue(this, v)); //FIXME probably pull this code into the node?
    
    } else if (value is Map) {
      renderer._renderSectionWithValue(this, value);
    
    } else if (value == true) {
      renderer._renderSectionWithValue(this, value);
    
    } else if (value == false) {
      // Do nothing.
    
    } else if (value == _noSuchProperty) {
      if (!renderer._lenient)
        throw renderer._error('Value was missing for section tag: ${name}.', this);
    
    } else if (value is Function) {
      var context = new _LambdaContext(this, renderer, isSection: true);
      var output = value(context);
      context.close();        
      renderer._write(output);
      
    } else {
      throw renderer._error('Invalid value type for section, '
        'section: ${name}, '
        'type: ${value.runtimeType}.', this);
    }
  }
  
  void renderInv(_Renderer renderer) {
    var value = renderer._resolveValue(name);
    
    if (value == null) {
      renderer._renderSectionWithValue(this, null);
    
    } else if ((value is Iterable && value.isEmpty) || value == false) {
      renderer._renderSectionWithValue(this, name);
    
    } else if (value == true || value is Map || value is Iterable) {
      // Do nothing.
    
    } else if (value == _noSuchProperty) {
      if (renderer._lenient) {
        renderer._renderSectionWithValue(this, null);
      } else {
        throw renderer._error('Value was missing for inverse section: ${name}.', this);
      }
  
     } else if (value is Function) {       
      // Do nothing.
       //TODO in strict mode should this be an error?
  
    } else {
      throw renderer._error(
        'Invalid value type for inverse section, '
        'section: $name, '
        'type: ${value.runtimeType}.', this);
    }
  }
}

class _PartialNode extends _Node {

  _PartialNode(this.name, int start, int end, this.indent)
    : super(start, end);
  
  final String name;
  
  // Used to store the preceding whitespace before a partial tag, so that
  // it's content can be correctly indented.
  final String indent;
  
  void render(_Renderer renderer) {
    var partialName = name;
    _Template template = renderer._partialResolver == null
        ? null
        : renderer._partialResolver(partialName);
    if (template != null) {
      var r = new _Renderer.partial(renderer, template, this.indent);
      r.render();
    } else if (renderer._lenient) {
      // do nothing
    } else {
      throw renderer._error('Partial not found: $partialName.', this);
    }
  }
}

