library mustache;

import 'dart:mirrors';

part 'char_reader.dart';
part 'scanner.dart';
part 'template.dart';

/// [Mustache template documentation](http://mustache.github.com/mustache.5.html)

/// Returns a [Template] which can be used to render the mustache template 
/// with substituted values.
/// Tag names may only contain characters a-z, A-Z, 0-9, underscore, and minus,
/// unless lenient mode is specified.
/// Throws [FormatException] if the syntax of the source is invalid.
Template parse(String source,
	             {bool lenient : false}) => _parse(source, lenient: lenient);

/// A Template can be rendered multiple times with different values.
abstract class Template {
	/// [values] can be a combination of Map, List, String. Any non-String object
	/// will be converted using toString(). Null values will cause a 
	/// FormatException, unless lenient module is enabled.
	String renderString(values, {bool lenient : false, bool htmlEscapeValues : true});

	/// [values] can be a combination of Map, List, String. Any non-String object
	/// will be converted using toString(). Null values will cause a 
	/// FormatException, unless lenient module is enabled.
	void render(values, StringSink sink, {bool lenient : false, bool htmlEscapeValues : true});
}

/// MustacheFormatException is used to obtain the line and column numbers
/// of the token which caused parse or render to fail.
class MustacheFormatException implements FormatException {	
	final String message;

	/// The 1-based line number of the token where formatting error was found.
	final int line;

	/// The 1-based column number of the token where formatting error was found.
	final int column;

	MustacheFormatException(this.message, this.line, this.column);
	String toString() => message;
}
