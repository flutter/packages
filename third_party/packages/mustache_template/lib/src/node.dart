part of mustache.impl;

void renderWithContext(RenderContext ctx, List<Node> nodes) {
  if (ctx.indent == null || ctx.indent == '') {
   nodes.forEach((n) => n.render(ctx));

  } else if (nodes.isNotEmpty) {
    // Special case to make sure there is not an extra indent after the last
    // line in the partial file.
    
    ctx.write(ctx.indent);
    
    for (var n in nodes.take(nodes.length - 1)) {
      n.render(ctx);
    }
        
    var node = nodes.last;
    if (node is TextNode) {
      node.render(ctx, lastNode: true);
    } else {
      node.render(ctx);
    }
  }
}

abstract class Node {
  
  Node(this.start, this.end);
  
  void render(RenderContext renderer);
  
  // The offset of the start of the token in the file. Unless this is a section
  // or inverse section, then this stores the start of the content of the
  // section.
  final int start;
  final int end;  
}


class TextNode extends Node {
  
  TextNode(this.text, int start, int end) : super(start, end);
    
  final String text;
  
  String toString() => '(TextNode "$_debugText" $start $end)';
  
  String get _debugText {
    var t = text.replaceAll('\n', '\\n');
    return t.length < 50 ? t : t.substring(0, 48) + '...';
  }
  
  // Remove me.
  // Only used for testing.
  bool operator ==(o) => o is TextNode
      && text == o.text
      && start == o.start
      && end == o.end;
  
  // TODO hashcode. import quiver.
  
  void render(RenderContext ctx, {lastNode: false}) {
    if (text == '') return;
    if (ctx.indent == null || ctx.indent == '') {
      ctx.write(text);
    } else if (lastNode && text.runes.last == _NEWLINE) {
      // Don't indent after the last line in a template.
      var s = text.substring(0, text.length - 1);
      ctx.write(s.replaceAll('\n', '\n${ctx.indent}'));
      ctx.write('\n');
    } else {
      ctx.write(text.replaceAll('\n', '\n${ctx.indent}'));
    }
  }
}

class VariableNode extends Node {
  
  VariableNode(this.name, int start, int end, {this.escape: true})
    : super(start, end);
  
  final String name;
  final bool escape;
  
  String toString() => '(VariableNode "$name" escape: $escape $start $end)';
  
  // Only used for testing.
  bool operator ==(o) => o is VariableNode
      && name == o.name
      && escape == o.escape
      && start == o.start
      && end == o.end;
  
  // TODO hashcode. import quiver.

  
  void render(RenderContext ctx) {
    
    var value = ctx.resolveValue(name);
    
    if (value is Function) {
      var context = new LambdaContext(this, ctx, isSection: false);
      value = value(context);
      context.close();
    }
    
    if (value == _noSuchProperty) {
      if (!ctx.lenient) 
        throw ctx.error('Value was missing for variable tag: ${name}.', this);
    } else {
      var valueString = (value == null) ? '' : value.toString();
      var output = !escape || !ctx.htmlEscapeValues
        ? valueString
        : _htmlEscape(valueString);
      if (output != null) ctx.write(output);
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
}


class SectionNode extends Node {
  
  SectionNode(this.name, int start, int end, this.delimiters,
      {this.inverse: false})
    : contentStart = end,
      super(start, end);
  
  final String name;
  final String delimiters;
  final bool inverse;
  final int contentStart;
  int contentEnd; // Set in parser when close tag is parsed.
  final List<Node> children = <Node>[];

  toString() => '(SectionNode $name inverse: $inverse $start $end)';
  
  // TODO Only used for testing.
  //FIXME use deepequals in test for comparing children.
  //Perhaps shift all of this == code into test.
  bool operator ==(o) => o is SectionNode
      && name == o.name
      && delimiters == o.delimiters
      && inverse == o.inverse
      && start == o.start
      && end == o.end;
  
  // TODO hashcode. import quiver.

  
  //TODO can probably combine Inv and Normal to shorten.
  void render(RenderContext ctx) => inverse
      ? renderInv(ctx)
      : renderNormal(ctx);
  
  void renderNormal(RenderContext renderer) {
    var value = renderer.resolveValue(name);
    
    if (value == null) {
      // Do nothing.
    
    } else if (value is Iterable) {
      value.forEach((v) => _renderWithValue(renderer, v));
    
    } else if (value is Map) {
      _renderWithValue(renderer, value);
    
    } else if (value == true) {
      _renderWithValue(renderer, value);
    
    } else if (value == false) {
      // Do nothing.
    
    } else if (value == _noSuchProperty) {
      if (!renderer.lenient)
        throw renderer.error('Value was missing for section tag: ${name}.', this);
    
    } else if (value is Function) {
      var context = new LambdaContext(this, renderer, isSection: true);
      var output = value(context);
      context.close();        
      if (output != null) renderer.write(output);
      
    } else {
      throw renderer.error('Invalid value type for section, '
        'section: ${name}, '
        'type: ${value.runtimeType}.', this);
    }
  }
  
  void renderInv(RenderContext ctx) {
    var value = ctx.resolveValue(name);
    
    if (value == null) {
      _renderWithValue(ctx, null);
    
    } else if ((value is Iterable && value.isEmpty) || value == false) {
      _renderWithValue(ctx, name);
    
    } else if (value == true || value is Map || value is Iterable) {
      // Do nothing.
    
    } else if (value == _noSuchProperty) {
      if (ctx.lenient) {
        _renderWithValue(ctx, null);
      } else {
        throw ctx.error('Value was missing for inverse section: ${name}.', this);
      }
  
     } else if (value is Function) {       
      // Do nothing.
       //TODO in strict mode should this be an error?
  
    } else {
      throw ctx.error(
        'Invalid value type for inverse section, '
        'section: $name, '
        'type: ${value.runtimeType}.', this);
    }
  }
  
  void _renderWithValue(RenderContext ctx, value) {
    ctx.push(value);
    children.forEach((n) => n.render(ctx));
    ctx.pop();
  }
}

class PartialNode extends Node {

  PartialNode(this.name, int start, int end, this.indent)
    : super(start, end);
  
  final String name;
  
  // Used to store the preceding whitespace before a partial tag, so that
  // it's content can be correctly indented.
  final String indent;

  toString() => '(PartialNode $name $start $end "$indent")';
  
  //TODO move to test.
  bool operator ==(o) => o is PartialNode
      && name == o.name
      && indent == o.indent;
  
  // TODO hashcode. import quiver.

  
  void render(RenderContext ctx) {
    var partialName = name;
    Template template = ctx.partialResolver == null
        ? null
        : ctx.partialResolver(partialName);
    if (template != null) {
      var partialCtx = new RenderContext.partial(ctx, template, this.indent);
      renderWithContext(partialCtx, template._nodes);
    } else if (ctx.lenient) {
      // do nothing
    } else {
      throw ctx.error('Partial not found: $partialName.', this);
    }
  }
}
