<?code-excerpt path-base="example/lib"?>

# Mustache templates

A Dart library to parse and render [mustache templates](https://mustache.github.io/).

See the [mustache manual](http://mustache.github.com/mustache.5.html) for detailed usage information.

This library passes all [mustache specification](https://github.com/mustache/spec/tree/master/specs) tests.

## Example usage

<?code-excerpt "main.dart (ExampleUsage)" plaster="none"?>
```dart
import 'package:mustache_template/mustache_template.dart';

void main() {
  const source = '''
{{# names }}
  <div>{{ lastname }}, {{ firstname }}</div>
{{/ names }}
{{^ names }}
  <div>No names.</div>
{{/ names }}
{{! I am a comment. }}
''';

  final template = Template(source, name: 'template-filename.html');

  final String output = template.renderString({
    'names': [
      {'firstname': 'Greg', 'lastname': 'Lowe'},
      {'firstname': 'Bob', 'lastname': 'Johnson'},
    ],
  });

  print(output);
}

```

A template is parsed when it is created, after parsing it can be rendered any number of times with different values. A TemplateException is thrown if there is a problem parsing or rendering the template.

The Template contstructor allows passing a name, this name will be used in error messages. When working with a number of templates, it is important to pass a name so that the error messages specify which template caused the error.

By default all output from `{{variable}}` tags is html escaped, this behaviour can be changed by passing htmlEscapeValues : false to the Template constructor. You can also use a `{{{triple mustache}}}` tag, or a unescaped variable tag `{{&unescaped}}`, the output from these tags is not escaped.

## Differences between strict mode and lenient mode.

### Strict mode (default)

* Tag names may only contain the characters a-z, A-Z, 0-9, underscore, period and minus. Other characters in tags will cause a TemplateException to be thrown during parsing.

* During rendering, if no map key or object member which matches the tag name is found, then a TemplateException will be thrown.

### Lenient mode

* Tag names may use any characters.
* During rendering, if no map key or object member which matches the tag name is found, then silently ignore and output nothing.

## Nested paths

<?code-excerpt "readme_excerpts.dart (NestedPaths)"?>
```dart
final t = Template('{{ author.name }}');
final output = t.renderString({
  'author': {'name': 'Greg Lowe'},
});
```

## Partials - example usage

<?code-excerpt "readme_excerpts.dart (Partials)"?>
```dart
final partial = Template('{{ foo }}', name: 'partial');

final resolver = (String name) {
  if (name == 'partial-name') {
    // Name of partial tag.
    return partial;
  }
  return null;
};

final t = Template('{{> partial-name }}', partialResolver: resolver);

final output = t.renderString({'foo': 'bar'}); // bar
```

## Lambdas - example usage

<?code-excerpt "readme_excerpts.dart (LambdaSimple)"?>
```dart
final t = Template('{{# foo }}{{/ foo }}');
final lambda = (_) => 'bar';
final output = t.renderString({'foo': lambda}); // bar
```

<?code-excerpt "readme_excerpts.dart (LambdaShown)"?>
```dart
final t = Template('{{# foo }}hidden{{/ foo }}');
final lambda = (_) => 'shown';
final output = t.renderString({'foo': lambda}); // shown
```

<?code-excerpt "readme_excerpts.dart (LambdaRender)"?>
```dart
final t = Template('{{# foo }}oi{{/ foo }}');
final lambda = (LambdaContext ctx) =>
    '<b>${ctx.renderString().toUpperCase()}</b>';
final output = t.renderString({'foo': lambda}); // <b>OI</b>
```

<?code-excerpt "readme_excerpts.dart (LambdaRenderBar)"?>
```dart
final t = Template('{{# foo }}{{bar}}{{/ foo }}');
final lambda = (LambdaContext ctx) =>
    '<b>${ctx.renderString().toUpperCase()}</b>';
final output = t.renderString({'foo': lambda, 'bar': 'pub'}); // <b>PUB</b>
```

In the following example `LambdaContext.renderSource(source)` re-parses the source string in the current context, this is the default behaviour in many mustache implementations. Since re-parsing the content is slow, and often not required, this library makes this step optional.

<?code-excerpt "readme_excerpts.dart (LambdaRenderSource)"?>
```dart
final t = Template('{{# foo }}{{bar}}{{/ foo }}');
final lambda = (LambdaContext ctx) =>
    ctx.renderSource('${ctx.source} {{cmd}}');
final output = t.renderString({
  'foo': lambda,
  'bar': 'pub',
  'cmd': 'build',
}); // pub build
```
