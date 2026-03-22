# Mustache templates

A Dart library to parse and render [mustache templates](https://mustache.github.io/). See the [mustache manual](http://mustache.github.com/mustache.5.html) for detailed usage information.

This library passes all [mustache specification](https://github.com/mustache/spec/tree/master/specs) tests.

## Example usage

<?code-excerpt "example/lib/readme_excerpts.dart (ExampleUsage)"?>
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

  final output = template.renderString(<String, Object>{
    'names': <Map<String, String>>[
      <String, String>{'firstname': 'Greg', 'lastname': 'Lowe'},
      <String, String>{'firstname': 'Bob', 'lastname': 'Johnson'},
    ],
  });

  print(output);
}
```

A template is parsed when it is created. After parsing, it can be rendered any number of times with different values. A `TemplateException` is thrown if there is a problem parsing or rendering the template.

The `Template` constructor allows a name to be passed, which is used in error messages. When working with multiple templates, consider passing a name so that error messages specify which template caused the error.

By default, all output from `{{variable}}` tags is HTML escaped. This behaviour can be changed by passing `htmlEscapeValues: false` to the `Template` constructor. Output can also be left unescaped using a `{{{triple mustache}}}` tag or an
`{{&unescaped}}` tag.

## Differences between strict mode and lenient mode

### Strict mode (default)

Tag names may only contain the characters a-z, A-Z, 0-9, underscore, period and minus. Other characters in tags will cause a `TemplateException` to be thrown during parsing.

During rendering, if no map key or object member matching the tag name is found, a `TemplateException` will be thrown.

### Lenient mode
Tag names may use any characters.

During rendering, if no map key or object member matching the tag name is found, the missing tag is silently ignored and nothing is output.

## Nested paths

<?code-excerpt "example/lib/readme_excerpts.dart (NestedPaths)"?>
```dart
final t = Template('{{ author.name }}');
final output = t.renderString(<String, Object>{
  'author': <String, String>{'name': 'Greg Lowe'},
});
```

## Partials

<?code-excerpt "example/lib/readme_excerpts.dart (Partials)"?>
```dart
final partial = Template('{{ foo }}', name: 'partial');

final resolver = (String name) {
  if (name == 'partial-name') {
    return partial;
  }
  return null;
};

final t = Template('{{> partial-name }}', partialResolver: resolver);
final output = t.renderString(<String, String>{'foo': 'bar'});
```

## Lambdas

<?code-excerpt "example/lib/readme_excerpts.dart (LambdaSimple)"?>
```dart
final t = Template('{{# foo }}');
final lambda = (LambdaContext _) => 'bar';
final output = t.renderString(<String, Object>{'foo': lambda});
```

<?code-excerpt "example/lib/readme_excerpts.dart (LambdaShown)"?>
```dart
final t = Template('{{# foo }}hidden{{/ foo }}');
final lambda = (LambdaContext _) => 'shown';
final output = t.renderString(<String, Object>{'foo': lambda});
```

<?code-excerpt "example/lib/readme_excerpts.dart (LambdaRender)"?>
```dart
final t = Template('{{# foo }}oi{{/ foo }}');
final lambda = (LambdaContext ctx) =>
    '<b>${ctx.renderString().toUpperCase()}</b>';
final output = t.renderString(<String, Object>{'foo': lambda});
```

<?code-excerpt "example/lib/readme_excerpts.dart (LambdaRenderBar)"?>
```dart
final t = Template('{{# foo }}{{bar}}{{/ foo }}');
final lambda = (LambdaContext ctx) =>
    '<b>${ctx.renderString().toUpperCase()}</b>';
final output = t.renderString(<String, Object>{'foo': lambda, 'bar': 'pub'});
```

`LambdaContext.renderSource` re-parses the source string in the current context. Since re-parsing is often not required, this step is optional.

<?code-excerpt "example/lib/readme_excerpts.dart (LambdaRenderSource)"?>
```dart
final t = Template('{{# foo }}{{bar}}{{/ foo }}');
final lambda = (LambdaContext ctx) =>
    ctx.renderSource('${ctx.source} {{cmd}}');
final output = t.renderString(
    <String, Object>{'foo': lambda, 'bar': 'pub', 'cmd': 'build'});
```
