library mustache;

@MirrorsUsed(metaTargets: const [mustache])
import 'dart:mirrors';

part 'src/char_reader.dart';
part 'src/lambda_context.dart';
part 'src/node.dart';
part 'src/parse.dart';
part 'src/renderer.dart';
part 'src/scanner.dart';
part 'src/template.dart';
part 'src/token.dart';

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
       PartialResolver partialResolver,
       Delimiters delimiters}) = _Template.fromSource;
  
  String get name;
  String get source;
  
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


typedef Template PartialResolver(String templateName);

typedef Object LambdaFunction(LambdaContext context);

/// Passed as an argument to a mustache lambda function. The methods on
/// this object may only be called before the lambda function returns. If a 
/// method is called after it has returned an exception will be thrown.
abstract class LambdaContext {
  
  /// Render the current section tag in the current context and return the
  /// result as a string.
  String renderString();
  
  /// Render and directly output the current section tag.
  //TODO note in variable case need to capture output in a string buffer and escape.
  //void render();
  
  /// Output a string.
  //TODO note in variable case need to capture output in a string buffer and escape.
  //void write(Object object);
  
  /// Get the unevaluated template source for the current section tag.
  String get source;
  
  /// Evaluate the string as a mustache template using the current context.
  String renderSource(String source);  
  
  /// Lookup the value of a variable in the current context.
  Object lookup(String variableName);
}


const MustacheMirrorsUsedAnnotation mustache = const MustacheMirrorsUsedAnnotation();

class MustacheMirrorsUsedAnnotation {
  const MustacheMirrorsUsedAnnotation();
}


//FIXME Don't expose this. Just take a string in the api.
class Delimiters {
  
  const Delimiters.standard() : this(
      _OPEN_MUSTACHE,
      _OPEN_MUSTACHE,
      _CLOSE_MUSTACHE,
      _CLOSE_MUSTACHE);
  
  // Assume single space between delimiters.
  factory Delimiters.fromString(String delimiters) {
    if (delimiters.length == 3) {
      return new Delimiters(
          delimiters.codeUnits[0],
          null,
          null,
          delimiters.codeUnits[2]);
    
    } else if (delimiters.length == 5) {
      return new Delimiters(
                delimiters.codeUnits[0],
                delimiters.codeUnits[1],
                delimiters.codeUnits[3],
                delimiters.codeUnits[4]);
    } else {
      throw 'Invalid delimiter string'; //FIXME
    }
  }
  
  const Delimiters(this.open, this.openInner, this.closeInner, this.close);
  
  final int open;
  final int openInner;
  final int closeInner;
  final int close;
  
  String toString() {
    var value = new String.fromCharCode(open);
    
    if (openInner != null)
      value += new String.fromCharCode(openInner);
    
    value += ' ';
    
    if (closeInner != null)
      value += new String.fromCharCode(closeInner);
    
    value += new String.fromCharCode(close);
    
    return value;
  }
}
