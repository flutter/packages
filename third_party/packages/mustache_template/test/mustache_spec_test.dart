import 'dart:async';
import 'dart:io';
import 'package:mustache/mustache.dart' as mustache;
import 'dart:convert';

var verbose = false;
var testName = null;
var fileName = null; //'test/spec/sections.json';

main(List<String> args) {
	if (!args.isEmpty) {
		for (var arg in args) {
			if (arg == '--verbose' || arg == '-v') {
				verbose = true;
			} else if (arg.startsWith('-')) {
				print('Unknown argument: $arg');
				print('Usage: dart test/mustache_spec_test.dart [--verbose] [test name]');
				return;
			} else {
				testName = arg;
				verbose = true;
			}
		}
	}

	var specs = new Directory('test/spec')
		.listSync()
		.where((f) => f is File
			            && f.path.endsWith('.json')
			            && (fileName == null || f.path == fileName));

	Future.forEach(specs,
		(file) => file
			.readAsString()
			.then((s) => JSON.decode(s))
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
	if (testName != null && name != testName)
		return;

	var output;
	var exception;
	var trace;
	try {
		output = mustache.parse(template, lenient: true).renderString(data, lenient: true);
	} catch (ex, stacktrace) {
		exception = ex;
		trace = stacktrace;
	}

//	if (output != null)
//		output = output.replaceAll('\n', '\\n');

//	if (expected != null)
//		expected = expected.replaceAll('\n', '\\n');

	var passed = output == expected;
	var result = passed ? 'Pass' : 'Fail';
	print('    $result  $name');
	if (verbose && !passed) {
		print(desc);
		print('        Template: $template');
		print('        Data:     ${JSON.encode(data)}');
		print('        Expected: $expected');
		print('        Output:   $output');
		if (exception != null) print('        Exception: $exception');
		if (trace != null) print(trace);
		print('');
		print('');
	}
}

