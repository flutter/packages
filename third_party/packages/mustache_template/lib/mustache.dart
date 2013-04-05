library mustache;

part 'char_reader.dart';
part 'scanner.dart';
part 'template.dart';

/// Mustache docs http://mustache.github.com/mustache.5.html

/// Returns a [Template] which can be used to render the template with substituted
/// values.
/// Throws [FormatException] if the syntax of the source is invalid.
Template parse(String source) => new _Template(source);

/// A Template can be used multiple times to [render] content with different values.
abstract class Template {
	/// [values] can be a combination of Map, List, String. Any non-String object
	/// will be converted using toString().
	String render(values);
}

/// MustacheFormatException can be used to obtain the line and column numbers
/// of the token which caused [parse] to fail.
class MustacheFormatException implements FormatException {	
	final String message;

	/// The 1-based line number of the token where formatting error was found.
	final int line;

	/// The 1-based column number of the token where formatting error was found.
	final int column;

	MustacheFormatException(this.message, this.line, this.column);
	String toString() => message;
}
