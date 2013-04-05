library mustache_test;

import 'package:unittest/unittest.dart';
import 'package:mustache/mustache.dart';

const MISMATCHED_TAG = 'Mismatched tag';
const UNEXPECTED_EOF = 'Unexpected end of input';
const INVALID_VALUE_SECTION = 'Invalid value type for section';
const INVALID_VALUE_INV_SECTION = 'Invalid value type for inverse section';

main() {
	group('Section', () {
		test('Map', () {
			var output = parse('{{#section}}_{{var}}_{{/section}}')
				.render({"section": {"var": "bob"}});
			expect(output, equals('_bob_'));
		});
		test('List', () {
			var output = parse('{{#section}}_{{var}}_{{/section}}')
				.render({"section": [{"var": "bob"}, {"var": "jim"}]});
			expect(output, equals('_bob__jim_'));
		});
		test('Empty List', () {
			var output = parse('{{#section}}_{{var}}_{{/section}}')
				.render({"section": []});
			expect(output, equals(''));
		});
		test('False', () {
			var output = parse('{{#section}}_{{var}}_{{/section}}')
				.render({"section": false});
			expect(output, equals(''));
		});
		test('Null', () {
			var output = parse('{{#section}}_{{var}}_{{/section}}')
				.render({"section": null});
			expect(output, equals(''));
		});
		test('Invalid value', () {
			var ex = renderFail(
				'{{#section}}_{{var}}_{{/section}}',
				{"section": 42});
			expect(ex is FormatException, isTrue);
			expect(ex.message, startsWith(INVALID_VALUE_SECTION));
		});
		test('True', () {
			var output = parse('{{#section}}_ok_{{/section}}')
				.render({"section": true});
			expect(output, equals('_ok_'));
		});
		test('Nested', () {
			var output = parse('{{#section}}.{{var}}.{{#nested}}_{{nested_var}}_{{/nested}}.{{/section}}')
				.render({"section": {
					"var": "bob",
					"nested": [
						{"nested_var": "jim"},
						{"nested_var": "sally"}
					]
				}});
			expect(output, equals('.bob._jim__sally_.'));
		});
	});

	group('Inverse Section', () {
		test('Map', () {
			var output = parse('{{^section}}_{{var}}_{{/section}}')
				.render({"section": {"var": "bob"}});
			expect(output, equals(''));
		});
		test('List', () {
			var output = parse('{{^section}}_{{var}}_{{/section}}')
				.render({"section": [{"var": "bob"}, {"var": "jim"}]});
			expect(output, equals(''));
		});
		test('Empty List', () {
			var output = parse('{{^section}}_ok_{{/section}}')
				.render({"section": []});
			expect(output, equals('_ok_'));
		});
		test('False', () {
			var output = parse('{{^section}}_ok_{{/section}}')
				.render({"section": false});
			expect(output, equals('_ok_'));
		});
		test('Null', () {
			var output = parse('{{^section}}_ok_{{/section}}')
				.render({"section": null});
			expect(output, equals('_ok_'));
		});
		test('Invalid value', () {
			var ex = renderFail(
				'{{^section}}_{{var}}_{{/section}}',
				{"section": 42});
			expect(ex is FormatException, isTrue);
			expect(ex.message, startsWith(INVALID_VALUE_INV_SECTION));
		});
		test('True', () {
			var output = parse('{{^section}}_ok_{{/section}}')
				.render({"section": true});
			expect(output, equals(''));
		});
	});

	group('Html escape', () {

		test('Escape at start', () {
			var output = parse('_{{var}}_')
				.render({"var": "&."});
			expect(output, equals('_&amp;._'));
		});

		test('Escape at end', () {
			var output = parse('_{{var}}_')
				.render({"var": ".&"});
			expect(output, equals('_.&amp;_'));
		});

		test('&', () {
			var output = parse('_{{var}}_')
				.render({"var": "&"});
			expect(output, equals('_&amp;_'));
		});

		test('<', () {
			var output = parse('_{{var}}_')
				.render({"var": "<"});
			expect(output, equals('_&lt;_'));
		});

		test('>', () {
			var output = parse('_{{var}}_')
				.render({"var": ">"});
			expect(output, equals('_&gt;_'));
		});

		test('"', () {
			var output = parse('_{{var}}_')
				.render({"var": '"'});
			expect(output, equals('_&quot;_'));
		});

		test("'", () {
			var output = parse('_{{var}}_')
				.render({"var": "'"});
			expect(output, equals('_&#x27;_'));
		});

		test("/", () {
			var output = parse('_{{var}}_')
				.render({"var": "/"});
			expect(output, equals('_&#x2F;_'));
		});

	});

	group('Invalid format', () {
		test('Mismatched tag', () {
			var source = '{{#section}}_{{var}}_{{/not_section}}';
			var ex = renderFail(source, {"section": {"var": "bob"}});
			expectFail(ex, 1, 25, 'Mismatched tag');
		});
		test('Unexpected EOF', () {
			var source = '{{#section}}_{{var}}_{{/not_section';
			var ex = renderFail(source, {"section": {"var": "bob"}});
			expectFail(ex, 1, source.length + 2, UNEXPECTED_EOF);
		});
	});

}

renderFail(source, values) {
	try {
		parse(source).render(values);
		return null;
	} catch (e) {
		return e;
	}	
}

expectFail(ex, int line, int column, [String msgStartsWith]) {
		expect(ex, isFormatException);
		expect(ex is MustacheFormatException, isTrue);
		expect(ex.line, equals(line));
		expect(ex.column, equals(column));
		if (msgStartsWith != null)
			expect(ex.message, startsWith(msgStartsWith));
}