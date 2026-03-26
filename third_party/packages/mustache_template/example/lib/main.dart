// This is a simple example demonstrating the mustache_template package.
//
// Run this file with: dart run example/lib/main.dart

import 'package:mustache_template/mustache_template.dart';

void main() {
  // Basic variable substitution
  final simple = Template('Hello, {{name}}!');
  print(simple.renderString({'name': 'World'}));
  // Output: Hello, World!

  // Section with a truthy value
  final withSection = Template('''
{{# show_greeting }}
  Welcome, {{user}}!
{{/ show_greeting }}
''');
  print(withSection.renderString({
    'show_greeting': true,
    'user': 'Alice',
  }));

  // Section with a falsy value (content is omitted)
  print(withSection.renderString({
    'show_greeting': false,
    'user': 'Bob',
  }));

  // List rendering with nested objects
  final listTemplate = Template('''
{{# items }}
  - {{name}}: {{price}}
{{/ items }}
''');
  print(listTemplate.renderString({
    'items': [
      {'name': 'Apple', 'price': 1.5},
      {'name': 'Banana', 'price': 0.75},
      {'name': 'Cherry', 'price': 3.0},
    ],
  }));

  // Inverted section (no items)
  final noItems = Template('''
{{# items }}
  - {{name}}
{{/ items }}
{{^ items }}
  No items found.
{{/ items }}
''');
  print(noItems.renderString({'items': []}));

  // HTML escaping (default)
  final htmlEscape = Template('{{description}}');
  print(htmlEscape.renderString({
    'description': '<script>alert("XSS")</script>',
  }));
  // Output: &lt;script&gt;alert(&quot;XSS&quot;)&lt;/script&gt;

  // Triple mustache (no HTML escaping)
  final noEscape = Template('{{{description}}}');
  print(noEscape.renderString({
    'description': '<b>Bold text</b>',
  }));
  // Output: <b>Bold text</b>

  // Comments are ignored
  final withComment = Template('''
{{! This is a comment and will not appear in the output. }}
Hello, {{name}}!{{! Another comment }}
''');
  print(withComment.renderString({'name': 'Dave'}));

  // Partial templates (using a resolver function)
  final partial = Template('{{> greeting }}', name: 'main');
  final greeting = Template('Hello, {{person}}!', name: 'greeting');
  final resolver = (String name) =>
      name == 'greeting' ? greeting : null;
  print(partial.renderString({'person': 'Eve'}, partialResolver: resolver));
  // Output: Hello, Eve!

  // Lambda functions
  final lambdaTemplate = Template('{{# bold }}hello{{/ bold }}');
  final lambda = (LambdaContext ctx) =>
      '<b>${ctx.renderString().toUpperCase()}</b>';
  print(lambdaTemplate.renderString({'bold': lambda}));
  // Output: <b>HELLO</b>

  // Strict mode (default): missing keys throw an error
  // Lenient mode: missing keys are silently ignored
  final lenientTemplate = Template(
    'Hello, {{name}} and {{missing}}!',
    lenient: true,
  );
  print(lenientTemplate.renderString({'name': 'Frank'}));
  // Output: Hello, Frank and !

  print('\nAll examples completed successfully!');
}
