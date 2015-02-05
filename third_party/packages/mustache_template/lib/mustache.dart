library mustache;

@MirrorsUsed(metaTargets: const [mustache])
import 'dart:mirrors';

part 'src/char_reader.dart';
part 'src/prefixing_string_sink.dart';
part 'src/scanner.dart';
part 'src/template.dart';

/// [Mustache template documentation](http://mustache.github.com/mustache.5.html)

/// Use new Template(source) instead.
@deprecated
Template parse(String source, {bool lenient : false})
  => new Template(source, lenient: lenient);

/// A Template can be efficienctly rendered multiple times with different
/// values.
abstract class Template {

  /// The constructor parses the template source and throws [TemplateException]
  /// if the syntax of the source is invalid.
  /// Tag names may only contain characters a-z, A-Z, 0-9, underscore, and minus,
  /// unless lenient mode is specified.
  factory Template(String source,
      {bool lenient,
       bool htmlEscapeValues,
       String name,
       PartialResolver partialResolver}) = _Template.source;
  
  String get name;
  
	/// [values] can be a combination of Map, List, String. Any non-String object
	/// will be converted using toString(). Null values will cause a 
	/// [TemplateException], unless lenient module is enabled.
	String renderString(values);

	/// [values] can be a combination of Map, List, String. Any non-String object
	/// will be converted using toString(). Null values will cause a 
	/// FormatException, unless lenient module is enabled.
	void render(values, StringSink sink);
}


@deprecated
abstract class MustacheFormatException implements FormatException {  
}


/// [TemplateException] is used to obtain the line and column numbers
/// of the token which caused parse or render to fail.
class TemplateException implements MustacheFormatException, Exception {
  
  factory TemplateException(
      String message, String template, int line, int column) {
    
    var at = template == null
        ? '$line:$column'
        : '$template:$line:$column';
    
    return new TemplateException._private(
      '$message, at: $at.', template, line, column);
  }  
  
  TemplateException._private(
      this.message, this.templateName, this.line, this.column);
  
	final String message;

	final String templateName;
	
	/// The 1-based line number of the token where formatting error was found.
	final int line;

	/// The 1-based column number of the token where formatting error was found.
	final int column;	
	
	String toString() => message;
	
	@deprecated
	get source => '';
	
	@deprecated
	get offset => 1;
}


//TODO does this require some sort of context to find partials nested in subdirs?
typedef Template PartialResolver(String templateName);


const MustacheMirrorsUsedAnnotation mustache = const MustacheMirrorsUsedAnnotation();

class MustacheMirrorsUsedAnnotation {
  const MustacheMirrorsUsedAnnotation();
}
