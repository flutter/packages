library mustache;

import 'dart:mirrors';

part 'char_reader.dart';
part 'scanner.dart';
part 'template.dart';
part 'template_renderer.dart';

/// [Mustache template documentation](http://mustache.github.com/mustache.5.html)

/// Returns a [Template] which can be used to render the mustache template 
/// with substituted values.
/// Tag names may only contain characters a-z, A-Z, 0-9, underscore, and minus,
/// unless lenient mode is specified.
/// Throws [MustacheFormatException] if the syntax of the source is invalid.
Template parse(String source,
 {bool lenient : false, String templateName}) => 
    _parse(source, lenient: lenient, templateName: templateName);


/// A Template can be rendered multiple times with different values.
abstract class Template {
  
	/// [values] can be a combination of Map, List, String. Any non-String object
	/// will be converted using toString(). Null values will cause a 
	/// [MustacheFormatException], unless lenient module is enabled.
	String renderString(values, {bool lenient : false, bool htmlEscapeValues : true});

	/// [values] can be a combination of Map, List, String. Any non-String object
	/// will be converted using toString(). Null values will cause a 
	/// FormatException, unless lenient module is enabled.
	void render(values, StringSink sink, {bool lenient : false, bool htmlEscapeValues : true});
}


/// [MustacheFormatException] is used to obtain the line and column numbers
/// of the token which caused parse or render to fail.
class MustacheFormatException implements Exception {
  
  factory MustacheFormatException(
      String message, String template, int line, int column) {
    
    var at = template == null
        ? '$line:$column'
        : '$template:$line:$column';
    
    return new MustacheFormatException._private(
      '$message, at: $at.', template, line, column);
  }  
  
  MustacheFormatException._private(
      this.message, this.templateName, this.line, this.column);
  
	final String message;

	final String templateName;
	
	/// The 1-based line number of the token where formatting error was found.
	final int line;

	/// The 1-based column number of the token where formatting error was found.
	final int column;	
	
	String toString() => message;
	
}


//TODO does this require some sort of context to find partials nested in subdirs?
typedef Template PartialResolver(String templateName);


// Required for handing partials
abstract class TemplateRenderer {

  factory TemplateRenderer(
      PartialResolver partialResolver,
      {bool lenient, // FIXME not sure if this lenient works right with the partial resolver, needs to be set twice?
       bool htmlEscapeValues}) = _TemplateRenderer;
  
  String renderString(String templateName, values);
  
  void render(String templateName, values, StringSink sink);
}

