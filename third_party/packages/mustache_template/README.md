# Mustache templates

A Dart library to parse and render [mustache templates](http://mustache.github.com/mustache.5.html).

# Example
```dart
import 'package:mustache/mustache.dart';

main() {
	var source = '{{#section}}_{{var}}_{{/section}}';
	var values = {"section": {"var": "bob"}};
	var template = parse(source);
	var output = template.render(values);
	print(output);
}
```
