import 'package:mustache_template/mustache.dart';
import 'package:test/test.dart';

const String UNEXPECTED_EOF = 'Unexpected end of input';
const String BAD_VALUE_INV_SECTION = 'Invalid value type for inverse section';
const String BAD_TAG_NAME = 'Unless in lenient mode, tags may only contain';
const String VALUE_MISSING = 'Value was missing';
const String UNCLOSED_TAG = 'Unclosed tag';

Template parse(String source, {bool lenient = false}) =>
    Template(source, lenient: lenient);

void main() {
  group('Basic', () {
    test('Variable', () {
      final String output = parse(
        '_{{var}}_',
      ).renderString(<String, String>{'var': 'bob'});
      expect(output, equals('_bob_'));
    });
    test('Comment', () {
      final String output = parse(
        '_{{! i am a\n comment ! }}_',
      ).renderString(<dynamic, dynamic>{});
      expect(output, equals('__'));
    });
    test('Emoji', () {
      final String output = parse(
        'Hello! 🖖👍🏽\nBye! 🏳️‍🌈',
      ).renderString(<dynamic, dynamic>{});
      expect(output, equals('Hello! 🖖👍🏽\nBye! 🏳️‍🌈'));
    });
  });
  group('Section', () {
    test('Map', () {
      final String output = parse(
        '{{#section}}_{{var}}_{{/section}}',
      ).renderString(<String, Map<String, String>>{
        'section': <String, String>{'var': 'bob'},
      });
      expect(output, equals('_bob_'));
    });
    test('List', () {
      final String output = parse(
        '{{#section}}_{{var}}_{{/section}}',
      ).renderString(<String, List<Map<String, String>>>{
        'section': <Map<String, String>>[
          <String, String>{'var': 'bob'},
          <String, String>{'var': 'jim'},
        ],
      });
      expect(output, equals('_bob__jim_'));
    });
    test('Empty List', () {
      final String output = parse(
        '{{#section}}_{{var}}_{{/section}}',
      ).renderString(<String, List<dynamic>>{'section': <dynamic>[]});
      expect(output, equals(''));
    });
    test('False', () {
      final String output = parse(
        '{{#section}}_{{var}}_{{/section}}',
      ).renderString(<String, bool>{'section': false});
      expect(output, equals(''));
    });
    test('Invalid value', () {
      final Exception? ex = renderFail(
        '{{#section}}_{{var}}_{{/section}}',
        <String, int>{'section': 42},
      );
      if (ex is TemplateException) {
        expect(ex.message, startsWith(VALUE_MISSING));
      } else {
        fail('Unexpected type: $ex');
      }
    });
    test('Invalid value - lenient mode', () {
      final String output = parse(
        '{{#var}}_{{var}}_{{/var}}',
        lenient: true,
      ).renderString(<String, int>{'var': 42});
      expect(output, equals('_42_'));
    });

    test('True', () {
      final String output = parse(
        '{{#section}}_ok_{{/section}}',
      ).renderString(<String, bool>{'section': true});
      expect(output, equals('_ok_'));
    });

    test('Nested', () {
      final String output = parse(
        '{{#section}}.{{var}}.{{#nested}}_{{nestedvar}}_{{/nested}}.{{/section}}',
      ).renderString(<String, Map<String, Object>>{
        'section': <String, Object>{
          'var': 'bob',
          'nested': <Map<String, String>>[
            <String, String>{'nestedvar': 'jim'},
            <String, String>{'nestedvar': 'sally'},
          ],
        },
      });
      expect(output, equals('.bob._jim__sally_.'));
    });

    test('Whitespace in section tags', () {
      expect(
        parse('{{#foo.bar}}oi{{/foo.bar}}').renderString(
          <String, Map<String, bool>>{
            'foo': <String, bool>{'bar': true},
          },
        ),
        equals('oi'),
      );
      expect(
        parse('{{# foo.bar}}oi{{/foo.bar}}').renderString(
          <String, Map<String, bool>>{
            'foo': <String, bool>{'bar': true},
          },
        ),
        equals('oi'),
      );
      expect(
        parse('{{#foo.bar }}oi{{/foo.bar}}').renderString(
          <String, Map<String, bool>>{
            'foo': <String, bool>{'bar': true},
          },
        ),
        equals('oi'),
      );
      expect(
        parse('{{# foo.bar }}oi{{/foo.bar}}').renderString(
          <String, Map<String, bool>>{
            'foo': <String, bool>{'bar': true},
          },
        ),
        equals('oi'),
      );
      expect(
        parse('{{#foo.bar}}oi{{/ foo.bar}}').renderString(
          <String, Map<String, bool>>{
            'foo': <String, bool>{'bar': true},
          },
        ),
        equals('oi'),
      );
      expect(
        parse('{{#foo.bar}}oi{{/foo.bar }}').renderString(
          <String, Map<String, bool>>{
            'foo': <String, bool>{'bar': true},
          },
        ),
        equals('oi'),
      );
      expect(
        parse('{{#foo.bar}}oi{{/ foo.bar }}').renderString(
          <String, Map<String, bool>>{
            'foo': <String, bool>{'bar': true},
          },
        ),
        equals('oi'),
      );
      expect(
        parse('{{# foo.bar }}oi{{/ foo.bar }}').renderString(
          <String, Map<String, bool>>{
            'foo': <String, bool>{'bar': true},
          },
        ),
        equals('oi'),
      );
    });

    test('Whitespace in variable tags', () {
      expect(
        parse('{{foo.bar}}').renderString(<String, Map<String, bool>>{
          'foo': <String, bool>{'bar': true},
        }),
        equals('true'),
      );
      expect(
        parse('{{ foo.bar}}').renderString(<String, Map<String, bool>>{
          'foo': <String, bool>{'bar': true},
        }),
        equals('true'),
      );
      expect(
        parse('{{foo.bar }}').renderString(<String, Map<String, bool>>{
          'foo': <String, bool>{'bar': true},
        }),
        equals('true'),
      );
      expect(
        parse('{{ foo.bar }}').renderString(<String, Map<String, bool>>{
          'foo': <String, bool>{'bar': true},
        }),
        equals('true'),
      );
    });

    test('Odd whitespace in tags', () {
      void render(String source, dynamic values, dynamic output) => expect(
        parse(source, lenient: true).renderString(values),
        equals(output),
      );

      render('{{\t# foo}}oi{{\n/foo}}', <String, bool>{'foo': true}, 'oi');

      render(
        '{{ # # foo }} {{ oi }} {{ / # foo }}',
        <String, List<Map<String, String>>>{
          '# foo': <Map<String, String>>[
            <String, String>{'oi': 'OI!'},
          ],
        },
        ' OI! ',
      );

      render(
        '{{ #foo }} {{ oi }} {{ /foo }}',
        <String, List<Map<String, String>>>{
          'foo': <Map<String, String>>[
            <String, String>{'oi': 'OI!'},
          ],
        },
        ' OI! ',
      );

      render(
        '{{\t#foo }} {{ oi }} {{ /foo }}',
        <String, List<Map<String, String>>>{
          'foo': <Map<String, String>>[
            <String, String>{'oi': 'OI!'},
          ],
        },
        ' OI! ',
      );

      render('{{{ #foo }}} {{{ /foo }}}', <String, int>{
        '#foo': 1,
        '/foo': 2,
      }, '1 2');

      // Invalid - I'm ok with that for now.
      //      render(
      //        "{{{ { }}}",
      //        {'{': 1},
      //        '1');

      render('{{\nfoo}}', <String, String>{'foo': 'bar'}, 'bar');

      render('{{\tfoo}}', <String, String>{'foo': 'bar'}, 'bar');

      render('{{\t# foo}}oi{{\n/foo}}', <String, bool>{'foo': true}, 'oi');

      render('{{{\tfoo\t}}}', <String, bool>{'foo': true}, 'true');

      // TODO(stuartmorgan): Fix and enable this test, which was commented out
      //  when the source was first imported.
      // empty, or error in strict mode.
      //      render(
      //        "{{ > }}",
      //        {'>': 'oi'},
      //        '');
    });

    test('Empty source', () {
      final Template t = Template('');
      expect(t.renderString(<dynamic, dynamic>{}), equals(''));
    });

    test('Template name', () {
      final Template t = Template('', name: 'foo');
      expect(t.name, equals('foo'));
    });

    test('Bad tag', () {
      expect(() => Template('{{{ foo }|'), throwsException);
    });
  });

  group('Inverse Section', () {
    test('Map', () {
      final String output = parse(
        '{{^section}}_{{var}}_{{/section}}',
      ).renderString(<String, Map<String, String>>{
        'section': <String, String>{'var': 'bob'},
      });
      expect(output, equals(''));
    });
    test('List', () {
      final String output = parse(
        '{{^section}}_{{var}}_{{/section}}',
      ).renderString(<String, List<Map<String, String>>>{
        'section': <Map<String, String>>[
          <String, String>{'var': 'bob'},
          <String, String>{'var': 'jim'},
        ],
      });
      expect(output, equals(''));
    });
    test('Empty List', () {
      final String output = parse(
        '{{^section}}_ok_{{/section}}',
      ).renderString(<String, List<dynamic>>{'section': <dynamic>[]});
      expect(output, equals('_ok_'));
    });
    test('False', () {
      final String output = parse(
        '{{^section}}_ok_{{/section}}',
      ).renderString(<String, bool>{'section': false});
      expect(output, equals('_ok_'));
    });
    test('Invalid value', () {
      final Exception? ex = renderFail(
        '{{^section}}_{{var}}_{{/section}}',
        <String, int>{'section': 42},
      );
      expect(ex is TemplateException, isTrue);
      expect(
        (ex! as TemplateException).message,
        startsWith(BAD_VALUE_INV_SECTION),
      );
    });
    test('Invalid value - lenient mode', () {
      final String output = parse(
        '{{^var}}_ok_{{/var}}',
        lenient: true,
      ).renderString(<String, int>{'var': 42});
      expect(output, equals(''));
    });
    test('True', () {
      final String output = parse(
        '{{^section}}_ok_{{/section}}',
      ).renderString(<String, bool>{'section': true});
      expect(output, equals(''));
    });
  });

  group('Html escape', () {
    test('Escape at start', () {
      final String output = parse(
        '_{{var}}_',
      ).renderString(<String, String>{'var': '&.'});
      expect(output, equals('_&amp;._'));
    });

    test('Escape at end', () {
      final String output = parse(
        '_{{var}}_',
      ).renderString(<String, String>{'var': '.&'});
      expect(output, equals('_.&amp;_'));
    });

    test('&', () {
      final String output = parse(
        '_{{var}}_',
      ).renderString(<String, String>{'var': '&'});
      expect(output, equals('_&amp;_'));
    });

    test('<', () {
      final String output = parse(
        '_{{var}}_',
      ).renderString(<String, String>{'var': '<'});
      expect(output, equals('_&lt;_'));
    });

    test('>', () {
      final String output = parse(
        '_{{var}}_',
      ).renderString(<String, String>{'var': '>'});
      expect(output, equals('_&gt;_'));
    });

    test('"', () {
      final String output = parse(
        '_{{var}}_',
      ).renderString(<String, String>{'var': '"'});
      expect(output, equals('_&quot;_'));
    });

    test("'", () {
      final String output = parse(
        '_{{var}}_',
      ).renderString(<String, String>{'var': "'"});
      expect(output, equals('_&#x27;_'));
    });

    test('/', () {
      final String output = parse(
        '_{{var}}_',
      ).renderString(<String, String>{'var': '/'});
      expect(output, equals('_&#x2F;_'));
    });
  });

  group('Invalid format', () {
    test('Mismatched tag', () {
      const String source = '{{#section}}_{{var}}_{{/notsection}}';
      final Exception? ex = renderFail(source, <String, Map<String, String>>{
        'section': <String, String>{'var': 'bob'},
      });
      expectFail(ex, 1, 22, 'Mismatched tag');
    });

    test('Unexpected EOF', () {
      const String source = '{{#section}}_{{var}}_{{/section';
      final Exception? ex = renderFail(source, <String, Map<String, String>>{
        'section': <String, String>{'var': 'bob'},
      });
      expectFail(ex, 1, 31, UNEXPECTED_EOF);
    });

    test('Bad tag name, open section', () {
      const String source = r'{{#section$%$^%}}_{{var}}_{{/section}}';
      final Exception? ex = renderFail(source, <String, Map<String, String>>{
        'section': <String, String>{'var': 'bob'},
      });
      expectFail(ex, null, null, BAD_TAG_NAME);
    });

    test('Bad tag name, close section', () {
      const String source = r'{{#section}}_{{var}}_{{/section$%$^%}}';
      final Exception? ex = renderFail(source, <String, Map<String, String>>{
        'section': <String, String>{'var': 'bob'},
      });
      expectFail(ex, null, null, BAD_TAG_NAME);
    });

    test('Bad tag name, variable', () {
      const String source = r'{{#section}}_{{var$%$^%}}_{{/section}}';
      final Exception? ex = renderFail(source, <String, Map<String, String>>{
        'section': <String, String>{'var': 'bob'},
      });
      expectFail(ex, null, null, BAD_TAG_NAME);
    });

    test('Missing variable', () {
      const String source = r'{{#section}}_{{var}}_{{/section}}';
      final Exception? ex = renderFail(source, <String, Map<dynamic, dynamic>>{
        'section': <dynamic, dynamic>{},
      });
      expectFail(ex, null, null, VALUE_MISSING);
    });

    // Null variables shouldn't be a problem.
    test('Null variable', () {
      final Template t = Template('{{#section}}_{{var}}_{{/section}}');
      final String output = t.renderString(<String, Map<String, void>>{
        'section': <String, void>{'var': null},
      });
      expect(output, equals('__'));
    });

    test('Unclosed section', () {
      const String source = r'{{#section}}foo';
      final Exception? ex = renderFail(source, <String, Map<dynamic, dynamic>>{
        'section': <dynamic, dynamic>{},
      });
      expectFail(ex, null, null, UNCLOSED_TAG);
    });
  });

  group('Lenient', () {
    test('Odd section name', () {
      final String output = parse(
        r'{{#section$%$^%}}_{{var}}_{{/section$%$^%}}',
        lenient: true,
      ).renderString(<String, Map<String, String>>{
        r'section$%$^%': <String, String>{'var': 'bob'},
      });
      expect(output, equals('_bob_'));
    });

    test('Odd variable name', () {
      final String output = parse(
        r'{{#section}}_{{var$%$^%}}_{{/section}}',
        lenient: true,
      ).renderString(<String, Map<String, String>>{
        'section': <String, String>{r'var$%$^%': 'bob'},
      });
      expect(output, equals('_bob_'));
    });

    test('Null variable', () {
      final String output = parse(
        r'{{#section}}_{{var}}_{{/section}}',
        lenient: true,
      ).renderString(<String, Map<String, void>>{
        'section': <String, void>{'var': null},
      });
      expect(output, equals('__'));
    });

    test('Null section', () {
      final String output = parse(
        '{{#section}}_{{var}}_{{/section}}',
        lenient: true,
      ).renderString(<String, void>{'section': null});
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
      final String output = parse(
        '{{{blah}}}',
      ).renderString(<String, String>{'blah': '&'});
      expect(output, equals('&'));
    });
    test('{{& ... }}', () {
      final String output = parse(
        '{{{blah}}}',
      ).renderString(<String, String>{'blah': '&'});
      expect(output, equals('&'));
    });
  });

  group('Partial tag', () {
    String partialTest(
      Map<String, Object> values,
      Map<String, Object> sources,
      String renderTemplate, {
      bool lenient = false,
    }) {
      final Map<String, Template> templates = <String, Template>{};
      Template? resolver(String name) => templates[name];
      for (final String k in sources.keys) {
        templates[k] = Template(
          sources[k]! as String,
          name: k,
          lenient: lenient,
          partialResolver: resolver,
        );
      }
      final Template? t = resolver(renderTemplate);
      return t!.renderString(values);
    }

    test('basic', () {
      final String output = partialTest(
        <String, Object>{'foo': 'bar'},
        <String, Object>{'root': '{{>partial}}', 'partial': '{{foo}}'},
        'root',
      );
      expect(output, 'bar');
    });

    test('missing partial strict', () {
      bool threw = false;
      try {
        partialTest(
          <String, Object>{'foo': 'bar'},
          <String, Object>{'root': '{{>partial}}'},
          'root',
        );
      } on Exception catch (e) {
        expect(e is TemplateException, isTrue);
        threw = true;
      }
      expect(threw, isTrue);
    });

    test('missing partial lenient', () {
      final String output = partialTest(
        <String, Object>{'foo': 'bar'},
        <String, Object>{'root': '{{>partial}}'},
        'root',
        lenient: true,
      );
      expect(output, equals(''));
    });

    test('context', () {
      final String output = partialTest(
        <String, Object>{'text': 'content'},
        <String, Object>{'root': '"{{>partial}}"', 'partial': '*{{text}}*'},
        'root',
        lenient: true,
      );
      expect(output, equals('"*content*"'));
    });

    test('recursion', () {
      final String output = partialTest(
        <String, Object>{
          'content': 'X',
          'nodes': <Map<String, Object>>[
            <String, Object>{'content': 'Y', 'nodes': <dynamic>[]},
          ],
        },
        <String, Object>{
          'root': '{{>node}}',
          'node': '{{content}}<{{#nodes}}{{>node}}{{/nodes}}>',
        },
        'root',
        lenient: true,
      );
      expect(output, equals('X<Y<>>'));
    });

    test('standalone without previous', () {
      final String output = partialTest(
        <String, Object>{},
        <String, Object>{'root': '  {{>partial}}\n>', 'partial': '>\n>'},
        'root',
        lenient: true,
      );
      expect(output, equals('  >\n  >>'));
    });

    test('standalone indentation', () {
      final String output = partialTest(
        <String, Object>{'content': '<\n->'},
        <String, Object>{
          'root': '\\\n {{>partial}}\n/\n',
          'partial': '|\n{{{content}}}\n|\n',
        },
        'root',
        lenient: true,
      );
      expect(output, equals('\\\n |\n <\n->\n |\n/\n'));
    });
  });

  group('Lambdas', () {
    void lambdaTest({
      required String template,
      dynamic lambda,
      dynamic output,
    }) => expect(
      parse(template).renderString(<String, dynamic>{'lambda': lambda}),
      equals(output),
    );

    test('basic', () {
      lambdaTest(
        template: 'Hello, {{lambda}}!',
        lambda: (_) => 'world',
        output: 'Hello, world!',
      );
    });

    test('escaping', () {
      lambdaTest(
        template: '<{{lambda}}{{{lambda}}}',
        lambda: (_) => '>',
        output: '<&gt;>',
      );
    });

    test('sections', () {
      lambdaTest(
        template: '{{#lambda}}FILE{{/lambda}} != {{#lambda}}LINE{{/lambda}}',
        lambda: (LambdaContext ctx) => '__${ctx.renderString()}__',
        output: '__FILE__ != __LINE__',
      );
    });

    // TODO(stuartmorgan): Fix and re-enable this test, which was skipped when
    //  the package was first imported.
    test('inverted sections truthy', () {
      const String template = '<{{^lambda}}{{static}}{{/lambda}}>';
      final Map<String, Object> values = <String, Object>{
        'lambda': (_) => false,
        'static': 'static',
      };
      const String output = '<>';
      expect(parse(template).renderString(values), equals(output));
    }, skip: 'skip test');

    test("seth's use case", () {
      const String template = '<{{#markdown}}{{content}}{{/markdown}}>';
      final Map<String, Object> values = <String, Object>{
        'markdown': (LambdaContext ctx) => ctx.renderString().toLowerCase(),
        'content': 'OI YOU!',
      };
      const String output = '<oi you!>';
      expect(parse(template).renderString(values), equals(output));
    });

    test('Lambda v2', () {
      const String template = '<{{#markdown}}{{content}}{{/markdown}}>';
      final Map<String, Object> values = <String, Object>{
        'markdown': (LambdaContext ctx) => ctx.source,
        'content': 'OI YOU!',
      };
      const String output = '<{{content}}>';
      expect(parse(template).renderString(values), equals(output));
    });

    test('Lambda v2...', () {
      const String template =
          '<{{#markdown}}dsfsf dsfsdf dfsdfsd{{/markdown}}>';
      final Map<String, dynamic Function(dynamic ctx)> values =
          <String, dynamic Function(dynamic ctx)>{
            // ignore: avoid_dynamic_calls
            'markdown': (dynamic ctx) => ctx.source,
          };
      const String output = '<dsfsf dsfsdf dfsdfsd>';
      expect(parse(template).renderString(values), equals(output));
    });

    test('Alternate Delimiters', () {
      // A lambda's return value should parse with the default delimiters.

      const String template = '{{= | | =}}\nHello, (|&lambda|)!';

      //function() { return "|planet| => {{planet}}" }
      final Map<String, Object> values = <String, Object>{
        'planet': 'world',
        'lambda':
            (LambdaContext ctx) => ctx.renderSource('|planet| => {{planet}}'),
      };

      const String output = 'Hello, (|planet| => world)!';

      expect(parse(template).renderString(values), equals(output));
    });

    test('Alternate Delimiters 2', () {
      // Lambdas used for sections should parse with the current delimiters.

      const String template = '{{= | | =}}<|#lambda|-|/lambda|>';

      //function() { return "|planet| => {{planet}}" }
      final Map<String, Object> values = <String, Object>{
        'planet': 'Earth',
        'lambda': (LambdaContext ctx) {
          final String txt = ctx.source;
          return ctx.renderSource('$txt{{planet}} => |planet|$txt');
        },
      };

      const String output = '<-{{planet}} => Earth->';

      expect(parse(template).renderString(values), equals(output));
    });

    test('LambdaContext.lookup', () {
      final Template t = Template('{{ foo }}');
      final String s = t.renderString(<String, Object>{
        'foo': (LambdaContext lc) => lc.lookup('bar'),
        'bar': 'jim',
      });
      expect(s, equals('jim'));
    });

    test('LambdaContext.lookup closed', () {
      final Template t = Template('{{ foo }}');
      LambdaContext? lc2;
      t.renderString(<String, Object>{
        'foo': (LambdaContext lc) => lc2 = lc,
        'bar': 'jim',
      });
      expect(lc2, isNotNull);
      expect(() => lc2?.lookup('foo'), throwsException);
    });
  });

  group('Other', () {
    test('Standalone line', () {
      final String val = parse(
        '|\n{{#bob}}\n{{/bob}}\n|',
      ).renderString(<String, List<dynamic>>{'bob': <dynamic>[]});
      expect(val, equals('|\n|'));
    });
  });

  group('Array indexing', () {
    test('Basic', () {
      final String val = parse('{{array.1}}').renderString(<String, List<int>>{
        'array': <int>[1, 2, 3],
      });
      expect(val, equals('2'));
    });
    test('RangeError', () {
      final Exception? error = renderFail('{{array.5}}', <String, List<int>>{
        'array': <int>[1, 2, 3],
      });
      expect(error, isA<TemplateException>());
    });
  });

  group('Delimiters', () {
    test('Basic', () {
      final String val = parse(
        '{{=<% %>=}}(<%text%>)',
      ).renderString(<String, String>{'text': 'Hey!'});
      expect(val, equals('(Hey!)'));
    });

    test('Single delimiters', () {
      final String val = parse(
        '({{=[ ]=}}[text])',
      ).renderString(<String, String>{'text': 'It worked!'});
      expect(val, equals('(It worked!)'));
    });
  });

  group('Template with custom delimiters', () {
    test('Basic', () {
      final Template t = Template('(<%text%>)', delimiters: '<% %>');
      final String val = t.renderString(<String, String>{'text': 'Hey!'});
      expect(val, equals('(Hey!)'));
    });
  });

  group('Lambda context', () {
    test('LambdaContext write', () {
      const String template = '<{{#markdown}}{{content}}{{/markdown}}>';
      final Map<String, Null Function(LambdaContext ctx)> values =
          <String, Null Function(LambdaContext ctx)>{
            'markdown': (LambdaContext ctx) {
              ctx.write('foo');
            },
          };
      const String output = '<foo>';
      expect(parse(template).renderString(values), equals(output));
    });

    test('LambdaContext render', () {
      const String template = '<{{#markdown}}{{content}}{{/markdown}}>';
      final Map<String, Object> values = <String, Object>{
        'content': 'bar',
        'markdown': (LambdaContext ctx) {
          ctx.render();
        },
      };
      const String output = '<bar>';
      expect(parse(template).renderString(values), equals(output));
    });

    test('LambdaContext render with value', () {
      const String template = '<{{#markdown}}{{content}}{{/markdown}}>';
      final Map<String, Null Function(LambdaContext ctx)> values =
          <String, Null Function(LambdaContext ctx)>{
            'markdown': (LambdaContext ctx) {
              ctx.render(value: <String, String>{'content': 'oi!'});
            },
          };
      const String output = '<oi!>';
      expect(parse(template).renderString(values), equals(output));
    });

    test('LambdaContext renderString with value', () {
      const String template = '<{{#markdown}}{{content}}{{/markdown}}>';
      final Map<String, String Function(LambdaContext ctx)> values =
          <String, String Function(LambdaContext ctx)>{
            'markdown': (LambdaContext ctx) {
              return ctx.renderString(
                value: <String, String>{'content': 'oi!'},
              );
            },
          };
      const String output = '<oi!>';
      expect(parse(template).renderString(values), equals(output));
    });

    test('LambdaContext write and return', () {
      const String template = '<{{#markdown}}{{content}}{{/markdown}}>';
      final Map<String, String Function(LambdaContext ctx)> values =
          <String, String Function(LambdaContext ctx)>{
            'markdown': (LambdaContext ctx) {
              ctx.write('foo');
              return 'bar';
            },
          };
      const String output = '<foobar>';
      expect(parse(template).renderString(values), equals(output));
    });

    test('LambdaContext renderSource with value', () {
      const String template = '<{{#markdown}}{{content}}{{/markdown}}>';
      final Map<String, String Function(LambdaContext ctx)> values =
          <String, String Function(LambdaContext ctx)>{
            'markdown': (LambdaContext ctx) {
              return ctx.renderSource(
                ctx.source,
                value: <String, String>{'content': 'oi!'},
              );
            },
          };
      const String output = '<oi!>';
      expect(parse(template).renderString(values), equals(output));
    });
  });
}

Exception? renderFail(String source, Object values) {
  try {
    parse(source).renderString(values);
    return null;
  } on Exception catch (e) {
    return e;
  }
}

void expectFail(
  Exception? ex,
  int? line,
  int? column, [
  String? msgStartsWith,
]) {
  if (ex is! TemplateException) {
    fail('Unexpected type: $ex');
  }
  if (line != null) {
    expect(ex.line, equals(line));
  }
  if (column != null) {
    expect(ex.column, equals(column));
  }
  if (msgStartsWith != null) {
    expect(ex.message, startsWith(msgStartsWith));
  }
}
