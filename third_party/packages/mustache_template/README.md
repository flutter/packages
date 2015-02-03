# Mustache templates

A Dart library to parse and render [mustache templates](http://mustache.github.com/mustache.5.html).

[![Build Status](https://drone.io/github.com/xxgreg/mustache/status.png)](https://drone.io/github.com/xxgreg/mustache/latest)

## Dart2js

This library uses mirrors. When compiling with dart2js you will need to pass the experimental mirrors flag. You also need to mark any objects which will be rendered with the @mustache annotation. There is also another version of this library available which doesn't use mirrors.

## Example
```dart
	import 'package:mustache/mustache.dart';

	main() {
		var source = '{{#names}}<div>{{lastname}}, {{firstname}}</div>{{/names}}';
		var template = new Template(source);
		var output = template.renderString({'names': [
			{'firstname': 'Greg', 'lastname': 'Lowe'},
			{'firstname': 'Bob', 'lastname': 'Johnson'}
		]});
		print(output);
	}
```

## API

```dart

abstract class Template {
	
	Template(String source, 
	    {bool lenient : false,
       bool htmlEscapeValues : true,
       String name,
       PartialResolver partialResolver});

	String renderString(values);
	void render(values, StringSink sink);
}

```

Once a template has been created it can be rendered any number of times.

Both parsing and render throw a TemplateException if there is a problem with the template or rendering the values.

When lenient mode is enabled tag names may use any characters, otherwise only a-z, A-Z, 0-9, underscore and minus. Lenient mode will also silently ignore nulls passed as values.

By default all variables are html escaped, this behaviour can be changed by passing htmlEscapeValues : false.


## Supported 
```
 Variables             {{var-name}}
 
 Sections              {{#section}}Blah{{/section}}
 
 Inverse sections      {{^section}}Blah{{/section}}
 
 Comments              {{! Not output. }}
 
 Unescaped variables   {{{var-name}}} and {{&var-name}}
 
 Partials              {{>include-other-file}}

 Lambdas               new Template('{{# foo }}oi{{/ foo }}')
                          .renderString({'foo': (s) => '<b>${s.toUpperCase()}</b>'});
```
See the [mustache templates tutorial](http://mustache.github.com/mustache.5.html) for more information.

Passing all [mustache specification](https://github.com/mustache/spec/tree/master/specs) tests for interpolation, sections, inverted, comments.

Lambdas are implemented differently from the specification. In this implementation, a lambda is provided with a String containing the rendered body of the template, and the output of the lambda is not re-interpolated. However this is sufficient for common use cases such as:

    new Template('{{# foo }}oi{{/ foo }}')
	     .renderString({'foo': (s) => '<b>${s.toUpperCase()}</b>'}); // <b>OI</b>

## To do
```
Implement auto-indenting for partials
Set Delimiter tags
```
