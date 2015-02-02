library mustache_test;

import 'package:unittest/unittest.dart';
import 'package:mustache/mustache.dart';

const MISMATCHED_TAG = 'Mismatched tag';
const UNEXPECTED_EOF = 'Unexpected end of input';
const BAD_VALUE_SECTION = 'Invalid value type for section';
const BAD_VALUE_INV_SECTION = 'Invalid value type for inverse section';
const BAD_TAG_NAME = 'Tag contained invalid characters in name';
const VALUE_NULL = 'Value was null or missing';

Template parse(String source, {bool lenient: false})
  => new Template(source, lenient: lenient);

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
			expect(ex is TemplateException, isTrue);
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
			expect(ex is TemplateException, isTrue);
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

	});

	group('Lenient', () {
		test('Odd section name', () {
			var output = parse(r'{{#section$%$^%}}_{{var}}_{{/section$%$^%}}', lenient: true)
				.renderString({r'section$%$^%': {'var': 'bob'}});
			expect(output, equals('_bob_'));
		});

		test('Odd variable name', () {
			var output = parse(r'{{#section}}_{{var$%$^%}}_{{/section}}', lenient: true)
				.renderString({'section': {r'var$%$^%': 'bob'}});
		});

		test('Null variable', () {
			var output = parse(r'{{#section}}_{{var}}_{{/section}}', lenient: true)
				.renderString({'section': {'var': null}});
			expect(output, equals('__'));
		});

		test('Null section', () {
			var output = parse('{{#section}}_{{var}}_{{/section}}', lenient: true)
				.renderString({"section": null});
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

	group('Partial tag', () {

	  String _partialTest(Map values, Map sources, String renderTemplate, {bool lenient: false}) {
	    var templates = new Map<String, Template>();
	    var resolver = (name) => templates[name];
	    for (var k in sources.keys) {
	      templates[k] = new Template(sources[k],
	          name: k, lenient: lenient, partialResolver: resolver);
	    }
	    var t = resolver(renderTemplate);
	    return t.renderString(values);
	  }
	  
    test('basic', () {
      var output = _partialTest(
          {'foo': 'bar'},
          {'root': '{{>partial}}', 'partial': '{{foo}}'},
          'root');
      expect(output, 'bar');
    });

    test('missing partial strict', () {
      var threw = false;
      try {
        _partialTest(
          {'foo': 'bar'},
          {'root': '{{>partial}}'},
          'root',
          lenient: false);  
      } catch (e) {
        expect(e is TemplateException, isTrue);
        print(e);
        threw = true;
      }
      expect(threw, isTrue);
    });   

    test('missing partial lenient', () {
      var output = _partialTest(
          {'foo': 'bar'},
          {'root': '{{>partial}}'},
          'root',
          lenient: true);
      expect(output, equals(''));
    });

    test('context', () {
      var output = _partialTest(
          {'text': 'content'},
          {'root': '"{{>partial}}"',
            'partial': '*{{text}}*'},
          'root',
          lenient: true);
      expect(output, equals('"*content*"'));
    });

    test('recursion', () {
      var output = _partialTest(
          { 'content': "X", 'nodes': [ { 'content': "Y", 'nodes': [] } ] },
          {'root': '{{>node}}',
            'node': '{{content}}<{{#nodes}}{{>node}}{{/nodes}}>'},
          'root',
          lenient: true);
      expect(output, equals('X<Y<>>'));
    });
    
	});

  group('Lambdas', () {
    
    _lambdaTest({template, lambda, output}) =>
        expect(parse(template).renderString({'lambda': lambda}), equals(output));
    
    test('basic', () {
      _lambdaTest(
          template: 'Hello, {{lambda}}!',
          lambda: (_) => 'world',
          output: 'Hello, world!');
    });

    test('escaping', () {
      _lambdaTest(
          template: '<{{lambda}}{{{lambda}}}',
          lambda: (_) => '>',
          output: '<&gt;>');
    });

    test('sections', () {
      _lambdaTest(
          template: '{{#lambda}}FILE{{/lambda}} != {{#lambda}}LINE{{/lambda}}',
          lambda: (s) => '__${s}__',
          output: '__FILE__ != __LINE__');
    });

    test('inverted sections truthy', () {
      var template = '<{{^lambda}}{{static}}{{/lambda}}>';
      var values = {'lambda': (_) => false, 'static': 'static'};
      var output = '<>';
      expect(parse(template).renderString(values), equals(output));
    });
    
    test("seth's use case", () {
      var template = '<{{#markdown}}{{content}}{{/markdown}}>';
      var values = {'markdown': (s) => s.toLowerCase(), 'content': 'OI YOU!'};
      var output = '<oi you!>';
      expect(parse(template).renderString(values), equals(output));      
    });
  });
	
	group('Other', () {
		test('Standalone line', () {
			var val = parse('|\n{{#bob}}\n{{/bob}}\n|').renderString({'bob': []});
			expect(val, equals('|\n|'));
		});
	});

	group('Array indexing', () {
		test('Basic', () {
			var val = parse('{{array.1}}').renderString({'array': [1, 2, 3]});
			expect(val, equals('2'));
		});
		test('RangeError', () {
			var error = renderFail('{{array.5}}', {'array': [1, 2, 3]});
			expect(error, isRangeError);
		});
	});

// FIXME
//	group('Mirrors', () {
//    test('Simple field', () {
//      var output = parse('_{{bar}}_')
//        .renderString(new Foo()..bar = 'bob');
//      expect(output, equals('_bob_'));
//    });
//  });
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
		expect(ex is TemplateException, isTrue);
		if (line != null)
			expect(ex.line, equals(line));
		if (column != null)
			expect(ex.column, equals(column));
		if (msgStartsWith != null)
			expect(ex.message, startsWith(msgStartsWith));
}

class Foo {
  String bar;
}
