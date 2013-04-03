library mustache_test;

import 'package:mustache/mustache.dart';

var scannerTests = [
'_{{variable}}_',
'_{{variable}}',
'{{variable}}_',
'{{variable}}',
' { ',
' } ',
' {} ',
' }{} ',
'{{{escaped text}}}',
'{{&escaped text}}',
'{{!comment}}',
'{{#section}}oi{{/section}}',
'{{^section}}oi{{/section}}',
'{{>partial}}'
];

main() {
	tokens();
	
	var source = '{{#section}}_{{var}}_{{/section}}';
	var t = new Template(source);
	var output = t.render({"section": {"var": "bob"}});
	print(source);
	print(output);
}

tokens() {
	for (var src in scannerTests) {
		print('${_pad(src, 40)}${_scan(src)}');
	}	
}

_pad(String s, int len) {
	for (int i = s.length; i < len; i++)
		s = s + ' ';
	return s;
}

	_stringify(Node n, int indent) {
		var pad = '';
		for (int i = 0; i < indent; i++)
			pad = '$pad-';
		var s = '$pad${tokenTypeString(type)} $value\n';		
		++indent;
		for (var c in n.children) {
			s += _stringify(c, indent);
		}
		return s;
	}
