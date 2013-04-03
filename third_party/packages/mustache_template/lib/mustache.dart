library mustache;

part 'template.dart';
part 'scanner.dart';

render(String source, values) => new Template(source).render(values);

abstract class Template {
	factory Template(String source) => new _Template(source);
	String render(values);
}
