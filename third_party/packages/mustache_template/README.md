# Mustache templates

A Dart library to parse and render [mustache templates](https://mustache.github.io/).

See the [mustache manual](https://mustache.github.io/mustache.5.html) for detailed usage information.

This library passes all [mustache specification](https://github.com/mustache/spec/tree/master/specs) tests.

## Usage

A template is parsed when it is created, after which it can be rendered any
number of times with different values. A `TemplateException` is thrown if there
is a problem parsing or rendering the template.

<?code-excerpt "example/lib/main.dart (basic-usage)"?>
```dart
final greetingTemplate = Template('Hello, {{name}}!');
final greeting = greetingTemplate.renderString({'name': 'Flutter'});
```

## Sections

Sections render a block of content based on the value of a key.
Use `{{#key}}...{{/key}}` for truthy sections and `{{^key}}...{{/key}}` for
inverted (falsy) sections.

<?code-excerpt "example/lib/main.dart (section)"?>
```dart
final sectionTemplate = Template(
  '{{#names}}{{lastname}}, {{firstname}} | {{/names}}'
  '{{^names}}No names found.{{/names}}',
);
final withNames = sectionTemplate.renderString({
  'names': [
    {'firstname': 'Hiba', 'lastname': 'C'},
    {'firstname': 'Jihed', 'lastname': 'B'},
  ],
});
final withoutNames = sectionTemplate.renderString({'names': []});
```

## Lambdas

Lambdas allow dynamic rendering of sections.

<?code-excerpt "example/lib/main.dart (lambda)"?>
```dart
final lambdaTemplate = Template('{{#bold}}{{text}}{{/bold}}');
final lambdaOutput = lambdaTemplate.renderString({
  'text': 'Hello',
  'bold': (LambdaContext ctx) => '<b>${ctx.renderString()}</b>',
});
```

## Strict mode and lenient mode

### Strict mode (default)

- Tag names may only contain the characters a-z, A-Z, 0-9, underscore, period
  and minus. Other characters in tags will cause a `TemplateException` to be
  thrown during parsing.
- During rendering, if no map key or object member which matches the tag name
  is found, then a `TemplateException` will be thrown.

### Lenient mode

- Tag names may use any characters.
- During rendering, if no map key or object member which matches the tag name
  is found, then silently ignore and output nothing.

## Additional information

The `Template` constructor allows passing a `name`, which will be used in error
messages. When working with a number of templates, it is important to pass a
name so that error messages specify which template caused the error.

By default all output from `{{variable}}` tags is HTML escaped. This behaviour
can be changed by passing `htmlEscapeValues: false` to the `Template`
constructor. You can also use a `{{{triple mustache}}}` tag or an unescaped
variable tag `{{&unescaped}}` — the output from these tags is not escaped.

For more detailed examples including partials and nested paths, see the
[example app](example/lib/main.dart).