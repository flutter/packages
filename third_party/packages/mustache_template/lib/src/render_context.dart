library mustache.render_context;

@MirrorsUsed(metaTargets: const [m.mustache])
import 'dart:mirrors';
import 'node.dart';
import 'package:mustache/mustache.dart' as m;
import 'template.dart';
import 'template_exception.dart';

final RegExp _validTag = new RegExp(r'^[0-9a-zA-Z\_\-\.]+$');
final RegExp _integerTag = new RegExp(r'^[0-9]+$');

const Object noSuchProperty = const Object();

class RenderContext {
  
  RenderContext(this.sink,
      List stack,
      this.lenient,
      this.htmlEscapeValues,
      this.partialResolver,
      this.templateName,
      this.indent,
      this.source)
    : _stack = new List.from(stack); 
  
  RenderContext.partial(RenderContext ctx, Template partial, String indent)
      : this(ctx.sink,
          ctx._stack,
          ctx.lenient,
          ctx.htmlEscapeValues,
          ctx.partialResolver,
          ctx.templateName,
          ctx.indent + indent,
          partial.source);

  RenderContext.subtree(RenderContext ctx, StringSink sink)
     : this(sink,
         ctx._stack,
         ctx.lenient,
         ctx.htmlEscapeValues,
         ctx.partialResolver,
         ctx.templateName,
         ctx.indent,
         ctx.source);

    RenderContext.lambda(
        RenderContext ctx,
        String source,
        String indent,
        StringSink sink,
        String delimiters)
       : this(sink,
           ctx._stack,
           ctx.lenient,
           ctx.htmlEscapeValues,
           ctx.partialResolver,
           ctx.templateName,
           ctx.indent + indent,
           source);
   
  final StringSink sink;
  final List _stack;
  final bool lenient;
  final bool htmlEscapeValues;
  final m.PartialResolver partialResolver;
  final String templateName;
  final String indent;
  final String source;

  void push(value) => _stack.add(value);
  
  Object pop() => _stack.removeLast();
  
  write(Object output) => sink.write(output.toString());
    
  // Walks up the stack looking for the variable.
  // Handles dotted names of the form "a.b.c".
  Object resolveValue(String name) {
    if (name == '.') {
      return _stack.last;
    }
    var parts = name.split('.');
    var object = noSuchProperty;
    for (var o in _stack.reversed) {
      object = _getNamedProperty(o, parts[0]);
      if (object != noSuchProperty) {
        break;
      }
    }
    for (int i = 1; i < parts.length; i++) {
      if (object == null || object == noSuchProperty) {
        return noSuchProperty;
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
    
    if (lenient && !_validTag.hasMatch(name))
      return noSuchProperty;
    
    var instance = reflect(object);
    var field = instance.type.instanceMembers[new Symbol(name)];
    if (field == null) return noSuchProperty;
    
    var invocation = null;
    if ((field is VariableMirror) || ((field is MethodMirror) && (field.isGetter))) {
      invocation = instance.getField(field.simpleName);
    } else if ((field is MethodMirror) && (field.parameters.length == 0)) {
      invocation = instance.invoke(field.simpleName, []);
    }
    if (invocation == null) {
      return noSuchProperty;
    }
    return invocation.reflectee;
  }
  
  m.TemplateException error(String message, Node node)
    => new TemplateException(message, templateName, source, node.start);
}
