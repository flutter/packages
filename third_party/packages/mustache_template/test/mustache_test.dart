library mustache_test;

import 'package:unittest/unittest.dart';
import 'package:mustache/mustache.dart';

const MISMATCHED_TAG = 'Mismatched tag';
const UNEXPECTED_EOF = 'Unexpected end of input';
const BAD_VALUE_SECTION = 'Invalid value type for section';
const BAD_VALUE_INV_SECTION = 'Invalid value type for inverse section';
const BAD_TAG_NAME = 'Tag contained invalid characters in name';
const VALUE_NULL = 'Value was null or missing';

main() {
	group('Basic', () {
		test('Variable', () {
			var output = parse('_{{var}}_')
				.renderString({"var": "bob"});
			expect(output, equals('_bob_'));
		});
		test('Comment', () {
			var output = parse('_{{! i am a comment ! }}_').renderString({});
			expect(output, equals('__'));
		});
	});
	group('Section', () {
		test('Map', () {
			var output = parse('{{#section}}_{{var}}_{{/section}}')
				.renderString({"section": {"var": "bob"}});
			expect(output, equals('_bob_'));
		});
		test('List', () {
			var output = parse('{{#section}}_{{var}}_{{/section}}')
				.renderString({"section": [{"var": "bob"}, {"var": "jim"}]});
			expect(output, equals('_bob__jim_'));
		});
		test('Empty List', () {
			var output = parse('{{#section}}_{{var}}_{{/section}}')
				.renderString({"section": []});
			expect(output, equals(''));
		});
		test('False', () {
			var output = parse('{{#section}}_{{var}}_{{/section}}')
				.renderString({"section": false});
			expect(output, equals(''));
		});
		test('Invalid value', () {
			var ex = renderFail(
				'{{#section}}_{{var}}_{{/section}}',
				{"section": 42});
			expect(ex is FormatException, isTrue);
			expect(ex.message, startsWith(BAD_VALUE_SECTION));
		});
		test('True', () {
			var output = parse('{{#section}}_ok_{{/section}}')
				.renderString({"section": true});
			expect(output, equals('_ok_'));
		});
		test('Nested', () {
			var output = parse('{{#section}}.{{var}}.{{#nested}}_{{nestedvar}}_{{/nested}}.{{/section}}')
				.renderString({"section": {
					"var": "bob",
					"nested": [
						{"nestedvar": "jim"},
						{"nestedvar": "sally"}
					]
				}});
			expect(output, equals('.bob._jim__sally_.'));
		});
	});

	group('Inverse Section', () {
		test('Map', () {
			var output = parse('{{^section}}_{{var}}_{{/section}}')
				.renderString({"section": {"var": "bob"}});
			expect(output, equals(''));
		});
		test('List', () {
			var output = parse('{{^section}}_{{var}}_{{/section}}')
				.renderString({"section": [{"var": "bob"}, {"var": "jim"}]});
			expect(output, equals(''));
		});
		test('Empty List', () {
			var output = parse('{{^section}}_ok_{{/section}}')
				.renderString({"section": []});
			expect(output, equals('_ok_'));
		});
		test('False', () {
			var output = parse('{{^section}}_ok_{{/section}}')
				.renderString({"section": false});
			expect(output, equals('_ok_'));
		});
		test('Invalid value', () {
			var ex = renderFail(
				'{{^section}}_{{var}}_{{/section}}',
				{"section": 42});
			expect(ex is FormatException, isTrue);
			expect(ex.message, startsWith(BAD_VALUE_INV_SECTION));
		});
		test('True', () {
			var output = parse('{{^section}}_ok_{{/section}}')
				.renderString({"section": true});
			expect(output, equals(''));
		});
	});

	group('Html escape', () {

		test('Escape at start', () {
			var output = parse('_{{var}}_')
				.renderString({"var": "&."});
			expect(output, equals('_&amp;._'));
		});

		test('Escape at end', () {
			var output = parse('_{{var}}_')
				.renderString({"var": ".&"});
			expect(output, equals('_.&amp;_'));
		});

		test('&', () {
			var output = parse('_{{var}}_')
				.renderString({"var": "&"});
			expect(output, equals('_&amp;_'));
		});

		test('<', () {
			var output = parse('_{{var}}_')
				.renderString({"var": "<"});
			expect(output, equals('_&lt;_'));
		});

		test('>', () {
			var output = parse('_{{var}}_')
				.renderString({"var": ">"});
			expect(output, equals('_&gt;_'));
		});

		test('"', () {
			var output = parse('_{{var}}_')
				.renderString({"var": '"'});
			expect(output, equals('_&quot;_'));
		});

		test("'", () {
			var output = parse('_{{var}}_')
				.renderString({"var": "'"});
			expect(output, equals('_&#x27;_'));
		});

		test("/", () {
			var output = parse('_{{var}}_')
				.renderString({"var": "/"});
			expect(output, equals('_&#x2F;_'));
		});

	});

	group('Invalid format', () {
		test('Mismatched tag', () {
			var source = '{{#section}}_{{var}}_{{/notsection}}';
			var ex = renderFail(source, {"section": {"var": "bob"}});
			expectFail(ex, 1, 25, 'Mismatched tag');
		});

		test('Unexpected EOF', () {
			var source = '{{#section}}_{{var}}_{{/section';
			var ex = renderFail(source, {"section": {"var": "bob"}});
			expectFail(ex, 1, source.length + 2, UNEXPECTED_EOF);
		});

		test('Bad tag name, open section', () {
			var source = r'{{#section$%$^%}}_{{var}}_{{/section}}';
			var ex = renderFail(source, {"section": {"var": "bob"}});
			expectFail(ex, null, null, BAD_TAG_NAME);
		});

		test('Bad tag name, close section', () {
			var source = r'{{#section}}_{{var}}_{{/section$%$^%}}';
			var ex = renderFail(source, {"section": {"var": "bob"}});
			expectFail(ex, null, null, BAD_TAG_NAME);
		});

		test('Bad tag name, variable', () {
			var source = r'{{#section}}_{{var$%$^%}}_{{/section}}';
			var ex = renderFail(source, {"section": {"var": "bob"}});
			expectFail(ex, null, null, BAD_TAG_NAME);
		});

		test('Null section', () {
			var source = '{{#section}}_{{var}}_{{/section}}';
			var ex = renderFail(source, {'section': null});
			expectFail(ex, null, null, VALUE_NULL);
		});

		test('Null inverse section', () {
			var source = '{{^section}}_{{var}}_{{/section}}';
			var ex = renderFail(source, {'section': null});
			expectFail(ex, null, null, VALUE_NULL);
		});

		test('Null variable', () {
			var source = '{{#section}}_{{var}}_{{/section}}';
			var ex = renderFail(source, {'section': {'var': null}});
			expectFail(ex, null, null, VALUE_NULL);
		});		
	});

	group('Lenient', () {
		test('Odd section name', () {
			var output = parse(r'{{#section$%$^%}}_{{var}}_{{/section$%$^%}}', lenient: true)
				.renderString({r'section$%$^%': {'var': 'bob'}}, lenient: true);
			expect(output, equals('_bob_'));
		});

		test('Odd variable name', () {
			var output = parse(r'{{#section}}_{{var$%$^%}}_{{/section}}', lenient: true)
				.renderString({'section': {r'var$%$^%': 'bob'}}, lenient: true);
		});

		test('Null variable', () {
			var output = parse(r'{{#section}}_{{var}}_{{/section}}', lenient: true)
				.renderString({'section': {'var': null}}, lenient: true);
			expect(output, equals('__'));
		});

		test('Null section', () {
			var output = parse('{{#section}}_{{var}}_{{/section}}', lenient: true)
				.renderString({"section": null}, lenient: true);
			expect(output, equals(''));
		});

// Known failure
//		test('Null inverse section', () {
//			var output = parse('{{^section}}_{{var}}_{{/section}}', lenient: true)
//				.renderString({"section": null}, lenient: true);
//			expect(output, equals(''));
//		});

	});

	group('Escape tags', () {
		test('{{{ ... }}}', () {
			var output = parse('{{{blah}}}')
				.renderString({'blah': '&'});
			expect(output, equals('&'));
		});
		test('{{& ... }}', () {
			var output = parse('{{{blah}}}')
				.renderString({'blah': '&'});
			expect(output, equals('&'));
		});
	});

	group('Patial tag', () {
		test('Unimplemented', () {
			var fn = () => parse('{{>partial}}').renderString({});
			expect(fn, throwsUnimplementedError);
		});
	});

	group('Other', () {
		test('Standalone line', () {
			var val = parse('|\n{{#bob}}\n{{/bob}}\n|').renderString({'bob': []});
			expect(val, equals('|\n|'));
		});
	});
}

renderFail(source, values) {
	try {
		parse(source).renderString(values);
		return null;
	} catch (e) {
		return e;
	}	
}

expectFail(ex, int line, int column, [String msgStartsWith]) {
		expect(ex, isFormatException);
		expect(ex is MustacheFormatException, isTrue);
		if (line != null)
			expect(ex.line, equals(line));
		if (column != null)
			expect(ex.column, equals(column));
		if (msgStartsWith != null)
			expect(ex.message, startsWith(msgStartsWith));
}