# Mustache templates

A Dart library to parse and render [mustache templates](https://mustache.github.io/).

See the [mustache manual](https://mustache.github.io/mustache.5.html) for detailed usage information.

This library passes all [mustache specification](https://github.com/mustache/spec/tree/master/specs) tests.

## Example usage

<?code-excerpt "example/main.dart (basic-usage)"?>
```dart
void main() {
  var source = '''
    {{# names }}
      <div>{{ lastname }}, {{ firstname }}</div>
    {{/ names }}
    {{^ names }}
      <div>No names.</div>
    {{/ names }}
    {{! I am a comment. }}
  ''';

  var template = Template(source, name: 'template-filename.html');

  var output = template.renderString({
    'names': [
      {'firstname': 'Greg', 'lastname': 'Lowe'},
      {'firstname': 'Bob', 'lastname': 'Johnson'}
    ]
  });

  print(output);
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

<?code-excerpt "example/main.dart (nested-paths)"?>
```dart
var t = Template('{{ author.name }}');
var nestedOutput = t.renderString({
  'author': {'name': 'Greg Lowe'}
});
print(nestedOutput);
```

## Partials - example usage

<?code-excerpt "example/main.dart (partials)"?>
```dart
var partial = Template('{{ foo }}', name: 'partial');

var resolver = (String name) => name == 'partial-name' ? partial : null;

var pt = Template('{{> partial-name }}', partialResolver: resolver);

var partialOutput = pt.renderString({'foo': 'bar'}); // bar
print(partialOutput);
```

## Lambdas - example usage

<?code-excerpt "example/main.dart (lambdas)"?>
```dart
var lt = Template('{{# foo }}{{bar}}{{/ foo }}');
var lambda =
    (LambdaContext ctx) => '<b>${ctx.renderString().toUpperCase()}</b>';
print(lt.renderString({'foo': lambda, 'bar': 'pub'})); // <b>PUB</b>
```

In the following example `LambdaContext.renderSource(source)` re-parses the source string in the current context, this is the default behaviour in many mustache implementations. Since re-parsing the content is slow, and often not required, this library makes this step optional.

<?code-excerpt "example/main.dart (lambda-render-source)"?>
```dart
var rst = Template('{{# foo }}{{bar}}{{/ foo }}');
var renderSourceLambda =
    (LambdaContext ctx) => ctx.renderSource('${ctx.source} {{cmd}}');
print(rst.renderString(
    {'foo': renderSourceLambda, 'bar': 'pub', 'cmd': 'build'})); // pub build
```
