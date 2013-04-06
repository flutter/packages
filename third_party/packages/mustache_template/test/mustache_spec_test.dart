import 'dart:async';
import 'dart:io';
import 'package:mustache/mustache.dart' as mustache;
import 'dart:json' as json;

var verbose = false;

main() {
	var specs = new Directory('test/spec')
		.listSync()
		.where((f) => f is File && f.path.endsWith('.json'));

	Future.forEach(specs,
		(file) => file
			.readAsString()
			.then((s) => json.parse(s))
			.then((spec) {
				print('Specification: ${file.path}');
				spec['tests'].forEach((map) => runTest(
					map['name'],
					map['desc'],
					map['data'],
					map['template'],
					map['expected']));
				print('');
			}));
}

runTest(String name, String desc, Map data, String template, String expected) {
	var output;
	var exception;
	try {
		output = mustache.parse(template, lenient: true).renderString(data, lenient: true);
	} catch (ex) {
		exception = ex;
	}
	var passed = output == expected;
	var result = passed ? 'Pass' : 'Fail';
	print('    $result  $name');
	if (verbose && !passed) {
		print('        Template: $template');
		print('        Data:     ${json.stringify(data)}');
		print('        Expected: $expected');
		if (exception != null) print('        Exception: $exception'); // TODO stack trace.
	}
}

