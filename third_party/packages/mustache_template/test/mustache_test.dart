library mustache_test;

import 'package:mustache/mustache.dart';

//FIXME I am not a real test :(
main() {
	var source = '{{#section}}_{{var}}_{{/section}}';
	var t = new Template(source);
	var output = t.render({"section": {"var": "bob"}});
	print(source);
	print(output);
}
