library mustache;

part 'char_reader.dart';
part 'scanner.dart';
part 'template.dart';

/// http://mustache.github.com/mustache.5.html

// TODO list.
// moar tests.
// html escaping.
// strict mode :
//   - Limit chars allowed in tagnames.
//   - Error on null value. (Leniant mode, just print nothing)
// Passing functions as values.
// Async values. Support Stream, and Future values (Separate library).
// Allow incremental parsing. I.e. read from Stream<String>, return Stream<String>.

/// Returns a [Template] which can be used to render the template with substituted
/// values.
/// Throws [FormatException] if the syntax of the source is invalid.
Template parse(String source) => new _Template(source);

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
