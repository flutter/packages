library mustache;

part 'char_reader.dart';
part 'scanner.dart';
part 'template.dart';

/// http://mustache.github.com/mustache.5.html

String render(String source, values) => new Template(source).render(values);

abstract class Template {
	factory Template(String source) => new _Template(source);
	String render(values);
}
