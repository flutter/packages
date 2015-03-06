library mustache.renderer;

import 'lambda_context.dart';
import 'node.dart';
import 'render_context.dart';
import 'template.dart';

class Renderer extends Visitor {
  
  Renderer(this.ctx);
  
  //TODO merge classes together.
  RenderContext ctx;

  void render(List<Node> nodes) {

    if (ctx.indent == null || ctx.indent == '') {      
     nodes.forEach((n) => n.accept(this));

    } else if (nodes.isNotEmpty) {
      // Special case to make sure there is not an extra indent after the last
      // line in the partial file.
      
      ctx.write(ctx.indent);
      
      for (var n in nodes.take(nodes.length - 1)) {
        n.accept(this);
      }
      
      var node = nodes.last;
      if (node is TextNode) {
        visitText(node, lastNode: true);  
      } else {
        node.accept(this);
      }
    }
  }
  
  void visitText(TextNode node, {bool lastNode: false}) {
    
    if (node.text == '') return;
    if (ctx.indent == null || ctx.indent == '') {
      ctx.write(node.text);
    } else if (lastNode && node.text.runes.last == _NEWLINE) {
      // Don't indent after the last line in a template.
      var s = node.text.substring(0, node.text.length - 1);
      ctx.write(s.replaceAll('\n', '\n${ctx.indent}'));
      ctx.write('\n');
    } else {
      ctx.write(node.text.replaceAll('\n', '\n${ctx.indent}'));
    }
  }
  
  void visitVariable(VariableNode node) {
    var value = ctx.resolveValue(node.name);
    
    if (value is Function) {
      var context = new LambdaContext(node, ctx, isSection: false);
      value = value(context);
      context.close();
    }
    
    if (value == noSuchProperty) {
      if (!ctx.lenient) 
        throw ctx.error('Value was missing for variable tag: ${node.name}.',
            node);
    } else {
      var valueString = (value == null) ? '' : value.toString();
      var output = !node.escape || !ctx.htmlEscapeValues
        ? valueString
        : _htmlEscape(valueString);
      if (output != null) ctx.write(output);
    }  
  }
  
  void visitSection(SectionNode node) {
    if (node.inverse) _renderInvSection(node); else _renderSection(node); 
  }
 
  //TODO can probably combine Inv and Normal to shorten.   
   void _renderSection(SectionNode node) {
     var value = ctx.resolveValue(node.name);
     
     if (value == null) {
       // Do nothing.
     
     } else if (value is Iterable) {
       value.forEach((v) => _renderWithValue(node, v));
     
     } else if (value is Map) {
       _renderWithValue(node, value);
     
     } else if (value == true) {
       _renderWithValue(node, value);
     
     } else if (value == false) {
       // Do nothing.
     
     } else if (value == noSuchProperty) {
       if (!ctx.lenient)
         throw ctx.error('Value was missing for section tag: ${node.name}.',
             node);
     
     } else if (value is Function) {
       var context = new LambdaContext(node, ctx, isSection: true);
       var output = value(context);
       context.close();        
       if (output != null) ctx.write(output);
       
     } else {
       throw ctx.error('Invalid value type for section, '
         'section: ${node.name}, '
         'type: ${value.runtimeType}.', node);
     }
   }
   
   void _renderInvSection(SectionNode node) {
     var value = ctx.resolveValue(node.name);
     
     if (value == null) {
       _renderWithValue(node, null);
     
     } else if ((value is Iterable && value.isEmpty) || value == false) {
       _renderWithValue(node, node.name);
     
     } else if (value == true || value is Map || value is Iterable) {
       // Do nothing.
     
     } else if (value == noSuchProperty) {
       if (ctx.lenient) {
         _renderWithValue(node, null);
       } else {
         throw ctx.error('Value was missing for inverse section: ${node.name}.', node);
       }
   
      } else if (value is Function) {       
       // Do nothing.
        //TODO in strict mode should this be an error?
   
     } else {
       throw ctx.error(
         'Invalid value type for inverse section, '
         'section: ${node.name}, '
         'type: ${value.runtimeType}.', node);
     }
   }
   
   void _renderWithValue(SectionNode node, value) {
     ctx.push(value);
     node.visitChildren(this);
     ctx.pop();
   }
  
  void visitPartial(PartialNode node) {
    var partialName = node.name;
    Template template = ctx.partialResolver == null
        ? null
        : ctx.partialResolver(partialName);
    if (template != null) {
      var partialCtx = new RenderContext.partial(ctx, template, node.indent);
      var renderer = new Renderer(partialCtx);
      var nodes = getTemplateNodes(template);
      renderer.render(nodes);
    } else if (ctx.lenient) {
      // do nothing
    } else {
      throw ctx.error('Partial not found: $partialName.', node);
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

const int _AMP = 38;
const int _LT = 60;
const int _GT = 62;
const int _QUOTE = 34;
const int _APOS = 39;
const int _FORWARD_SLASH = 47;
const int _NEWLINE = 10;
