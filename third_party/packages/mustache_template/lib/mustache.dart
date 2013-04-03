library mustache;

part 'template.dart';
part 'scanner.dart';

/// http://mustache.github.com/mustache.5.html

render(String source, values) => new Template(source).render(values);

abstract class Template {
	factory Template(String source) => new _Template(source);
	String render(values);
}
