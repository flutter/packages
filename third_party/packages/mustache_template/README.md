# Mustache templates

A Dart library to parse and render [mustache templates](http://mustache.github.com/mustache.5.html).

[![Build Status](https://drone.io/github.com/xxgreg/mustache/status.png)](https://drone.io/github.com/xxgreg/mustache/latest)

## Example
```dart
	import 'package:mustache/mustache.dart' as mustache;

	main() {
		var source = '{{#names}}<div>{{lastname}}, {{firstname}}</div>{{/names}}';
		var template = mustache.parse(source);
		var output = template.renderString({'names': [
			{'firstname': 'Greg', 'lastname': 'Lowe'},
			{'firstname': 'Bob', 'lastname': 'Johnson'}
		]});
		print(output);
	}
```

## API

```dart

Template parse(String source, {bool lenient : false});

abstract class Template {
	String renderString(values, {bool lenient : false, bool htmlEscapeValues : true});
	void render(values, StringSink sink, {bool lenient : false, bool htmlEscapeValues : true});
}

```

Once a template has been created it can be rendered any number of times.

Both parse and render throw a FormatException if there is a problem with the template or rendering the values.

When lenient mode is enabled tag names may use any characters, otherwise only a-z, A-Z, 0-9, underscore and minus. Lenient mode will also silently ignore nulls passed as values.

By default all variables are html escaped, this behaviour can be changed by passing htmlEscapeValues : false.


## Supported 
```
 Variables             {{var-name}}
 Sections              {{#section}}Blah{{/section}}
 Inverse sections      {{^section}}Blah{{/section}}
 Comments              {{! Not output. }}
 Unescaped variables   {{{var-name}}} and {{&var-name}}
```
See the [mustache templates tutorial](http://mustache.github.com/mustache.5.html) for more information.

## To do
```
I Broke lenient nulls in inverse sectins :(
Standalone lines
Dotted names   {{person.firstname}} == {{#person}}{{firstname}}{{/person}}
Partial tags   {{>partial}}
Allow functions as values (See mustache docs)
Pass all tests in mustache spec
Set Delimiter tags
```

