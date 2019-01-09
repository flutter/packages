library mustache.renderer;

@MirrorsUsed(metaTargets: const [m.MustacheMirrorsUsedAnnotation])
import 'dart:mirrors';
import 'package:mustache/mustache.dart' as m;
import 'lambda_context.dart';
import 'node.dart';
import 'template.dart';
import 'template_exception.dart';

final RegExp _validTag = new RegExp(r'^[0-9a-zA-Z\_\-\.]+$');
final RegExp _integerTag = new RegExp(r'^[0-9]+$');

const Object noSuchProperty = const Object();

class Renderer extends Visitor {
  Renderer(this.sink, List stack, this.lenient, this.htmlEscapeValues,
      this.partialResolver, this.templateName, this.indent, this.source)
      : _stack = new List.from(stack);

  Renderer.partial(Renderer ctx, Template partial, String indent)
      : this(
            ctx.sink,
            ctx._stack,
            ctx.lenient,
            ctx.htmlEscapeValues,
            ctx.partialResolver,
            ctx.templateName,
            ctx.indent + indent,
            partial.source);

  Renderer.subtree(Renderer ctx, StringSink sink)
      : this(sink, ctx._stack, ctx.lenient, ctx.htmlEscapeValues,
            ctx.partialResolver, ctx.templateName, ctx.indent, ctx.source);

  Renderer.lambda(Renderer ctx, String source, String indent, StringSink sink,
      String delimiters)
      : this(sink, ctx._stack, ctx.lenient, ctx.htmlEscapeValues,
            ctx.partialResolver, ctx.templateName, ctx.indent + indent, source);

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

  void write(Object output) => sink.write(output.toString());

  void render(List<Node> nodes) {
    if (indent == null || indent == '') {
      nodes.forEach((n) => n.accept(this));
    } else if (nodes.isNotEmpty) {
      // Special case to make sure there is not an extra indent after the last
      // line in the partial file.
      write(indent);

      nodes.take(nodes.length - 1).forEach((n) => n.accept(this));

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
    if (indent == null || indent == '') {
      write(node.text);
    } else if (lastNode && node.text.runes.last == _NEWLINE) {
      // Don't indent after the last line in a template.
      var s = node.text.substring(0, node.text.length - 1);
      write(s.replaceAll('\n', '\n${indent}'));
      write('\n');
    } else {
      write(node.text.replaceAll('\n', '\n${indent}'));
    }
  }

  void visitVariable(VariableNode node) {
    var value = resolveValue(node.name);

    if (value is Function) {
      var context = new LambdaContext(node, this);
      Function valueFunction = value;
      value = valueFunction(context);
      context.close();
    }

    if (value == noSuchProperty) {
      if (!lenient)
        throw error('Value was missing for variable tag: ${node.name}.', node);
    } else {
      var valueString = (value == null) ? '' : value.toString();
      var output = !node.escape || !htmlEscapeValues
          ? valueString
          : _htmlEscape(valueString);
      if (output != null) write(output);
    }
  }

  void visitSection(SectionNode node) {
    if (node.inverse)
      _renderInvSection(node);
    else
      _renderSection(node);
  }

  //TODO can probably combine Inv and Normal to shorten.
  void _renderSection(SectionNode node) {
    var value = resolveValue(node.name);

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
      if (!lenient)
        throw error('Value was missing for section tag: ${node.name}.', node);
    } else if (value is Function) {
      var context = new LambdaContext(node, this);
      var output = value(context);
      context.close();
      if (output != null) write(output);
    } else {
      // Assume the value might have accessible member values via mirrors.
      _renderWithValue(node, value);
    }
  }

  void _renderInvSection(SectionNode node) {
    var value = resolveValue(node.name);

    if (value == null) {
      _renderWithValue(node, null);
    } else if ((value is Iterable && value.isEmpty) || value == false) {
      _renderWithValue(node, node.name);
    } else if (value == true || value is Map || value is Iterable) {
      // Do nothing.

    } else if (value == noSuchProperty) {
      if (lenient) {
        _renderWithValue(node, null);
      } else {
        throw error(
            'Value was missing for inverse section: ${node.name}.', node);
      }
    } else if (value is Function) {
      // Do nothing.
      //TODO in strict mode should this be an error?

    } else if (lenient) {
      // We consider all other values as 'true' in lenient mode. Since this
      // is an inverted section, we do nothing.

    } else {
      throw error(
          'Invalid value type for inverse section, '
          'section: ${node.name}, '
          'type: ${value.runtimeType}.',
          node);
    }
  }

  void _renderWithValue(SectionNode node, value) {
    push(value);
    node.visitChildren(this);
    pop();
  }

  void visitPartial(PartialNode node) {
    var partialName = node.name;
    Template template =
        partialResolver == null ? null : partialResolver(partialName);
    if (template != null) {
      var renderer = new Renderer.partial(this, template, node.indent);
      var nodes = getTemplateNodes(template);
      renderer.render(nodes);
    } else if (lenient) {
      // do nothing
    } else {
      throw error('Partial not found: $partialName.', node);
    }
  }

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
    if (object is Map && object.containsKey(name)) return object[name];

    if (object is List && _integerTag.hasMatch(name))
      return object[int.parse(name)];

    if (lenient && !_validTag.hasMatch(name)) return noSuchProperty;

    var instance = reflect(object);
    var field = instance.type.instanceMembers[new Symbol(name)];
    if (field == null) return noSuchProperty;

    var invocation = null;
    if ((field is VariableMirror) ||
        ((field is MethodMirror) && (field.isGetter))) {
      invocation = instance.getField(field.simpleName);
    } else if ((field is MethodMirror) && (field.parameters.where((p) => !p.isOptional).length == 0)) {
      invocation = instance.invoke(field.simpleName, []);
    }
    if (invocation == null) {
      return noSuchProperty;
    }
    return invocation.reflectee;
  }

  m.TemplateException error(String message, Node node) =>
      new TemplateException(message, templateName, source, node.start);

  static const Map<int, String> _htmlEscapeMap = const {
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
      if (c == _AMP ||
          c == _LT ||
          c == _GT ||
          c == _QUOTE ||
          c == _APOS ||
          c == _FORWARD_SLASH) {
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
