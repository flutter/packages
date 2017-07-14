import 'package:mustache/src/node.dart';
import 'package:mustache/src/parser.dart';
import 'package:mustache/src/scanner.dart';
import 'package:mustache/src/template_exception.dart';
import 'package:mustache/src/token.dart';
import 'package:test/test.dart';

main() {
  group('Scanner', () {
    test('scan text', () {
      var source = 'abc';
      var scanner = new Scanner(source, 'foo', '{{ }}');
      var tokens = scanner.scan();
      expectTokens(tokens, [new Token(TokenType.text, 'abc', 0, 3)]);
    });

    test('scan tag', () {
      var source = 'abc{{foo}}def';
      var scanner = new Scanner(source, 'foo', '{{ }}');
      var tokens = scanner.scan();
      expectTokens(tokens, [
        new Token(TokenType.text, 'abc', 0, 3),
        new Token(TokenType.openDelimiter, '{{', 3, 5),
        new Token(TokenType.identifier, 'foo', 5, 8),
        new Token(TokenType.closeDelimiter, '}}', 8, 10),
        new Token(TokenType.text, 'def', 10, 13)
      ]);
    });

    test('scan tag whitespace', () {
      var source = 'abc{{ foo }}def';
      var scanner = new Scanner(source, 'foo', '{{ }}');
      var tokens = scanner.scan();
      expectTokens(tokens, [
        new Token(TokenType.text, 'abc', 0, 3),
        new Token(TokenType.openDelimiter, '{{', 3, 5),
        new Token(TokenType.whitespace, ' ', 5, 6),
        new Token(TokenType.identifier, 'foo', 6, 9),
        new Token(TokenType.whitespace, ' ', 9, 10),
        new Token(TokenType.closeDelimiter, '}}', 10, 12),
        new Token(TokenType.text, 'def', 12, 15)
      ]);
    });

    test('scan tag sigil', () {
      var source = 'abc{{ # foo }}def';
      var scanner = new Scanner(source, 'foo', '{{ }}');
      var tokens = scanner.scan();
      expectTokens(tokens, [
        new Token(TokenType.text, 'abc', 0, 3),
        new Token(TokenType.openDelimiter, '{{', 3, 5),
        new Token(TokenType.whitespace, ' ', 5, 6),
        new Token(TokenType.sigil, '#', 6, 7),
        new Token(TokenType.whitespace, ' ', 7, 8),
        new Token(TokenType.identifier, 'foo', 8, 11),
        new Token(TokenType.whitespace, ' ', 11, 12),
        new Token(TokenType.closeDelimiter, '}}', 12, 14),
        new Token(TokenType.text, 'def', 14, 17)
      ]);
    });

    test('scan tag dot', () {
      var source = 'abc{{ foo.bar }}def';
      var scanner = new Scanner(source, 'foo', '{{ }}');
      var tokens = scanner.scan();
      expectTokens(tokens, [
        new Token(TokenType.text, 'abc', 0, 3),
        new Token(TokenType.openDelimiter, '{{', 3, 5),
        new Token(TokenType.whitespace, ' ', 5, 6),
        new Token(TokenType.identifier, 'foo', 6, 9),
        new Token(TokenType.dot, '.', 9, 10),
        new Token(TokenType.identifier, 'bar', 10, 13),
        new Token(TokenType.whitespace, ' ', 13, 14),
        new Token(TokenType.closeDelimiter, '}}', 14, 16),
        new Token(TokenType.text, 'def', 16, 19)
      ]);
    });

    test('scan triple mustache', () {
      var source = 'abc{{{foo}}}def';
      var scanner = new Scanner(source, 'foo', '{{ }}');
      var tokens = scanner.scan();
      expectTokens(tokens, [
        new Token(TokenType.text, 'abc', 0, 3),
        new Token(TokenType.openDelimiter, '{{{', 3, 6),
        new Token(TokenType.identifier, 'foo', 6, 9),
        new Token(TokenType.closeDelimiter, '}}}', 9, 12),
        new Token(TokenType.text, 'def', 12, 15)
      ]);
    });

    test('scan triple mustache whitespace', () {
      var source = 'abc{{{ foo }}}def';
      var scanner = new Scanner(source, 'foo', '{{ }}');
      var tokens = scanner.scan();
      expectTokens(tokens, [
        new Token(TokenType.text, 'abc', 0, 3),
        new Token(TokenType.openDelimiter, '{{{', 3, 6),
        new Token(TokenType.whitespace, ' ', 6, 7),
        new Token(TokenType.identifier, 'foo', 7, 10),
        new Token(TokenType.whitespace, ' ', 10, 11),
        new Token(TokenType.closeDelimiter, '}}}', 11, 14),
        new Token(TokenType.text, 'def', 14, 17)
      ]);
    });

    test('scan tag with equals', () {
      var source = '{{foo=bar}}';
      var scanner = new Scanner(source, 'foo', '{{ }}');
      var tokens = scanner.scan();
      expectTokens(tokens, [
        new Token(TokenType.openDelimiter, '{{', 0, 2),
        new Token(TokenType.identifier, 'foo=bar', 2, 9),
        new Token(TokenType.closeDelimiter, '}}', 9, 11),
      ]);
    });

    test('scan comment with equals', () {
      var source = '{{!foo=bar}}';
      var scanner = new Scanner(source, 'foo', '{{ }}');
      var tokens = scanner.scan();
      expectTokens(tokens, [
        new Token(TokenType.openDelimiter, '{{', 0, 2),
        new Token(TokenType.sigil, '!', 2, 3),
        new Token(TokenType.identifier, 'foo=bar', 3, 10),
        new Token(TokenType.closeDelimiter, '}}', 10, 12),
      ]);
    });
  });

  group('Parser', () {
    test('parse variable', () {
      var source = 'abc{{foo}}def';
      var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
      var nodes = parser.parse();
      expectNodes(nodes, [
        new TextNode('abc', 0, 3),
        new VariableNode('foo', 3, 10, escape: true),
        new TextNode('def', 10, 13)
      ]);
    });

    test('parse variable whitespace', () {
      var source = 'abc{{ foo }}def';
      var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
      var nodes = parser.parse();
      expectNodes(nodes, [
        new TextNode('abc', 0, 3),
        new VariableNode('foo', 3, 12, escape: true),
        new TextNode('def', 12, 15)
      ]);
    });

    test('parse section', () {
      var source = 'abc{{#foo}}def{{/foo}}ghi';
      var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
      var nodes = parser.parse();
      expectNodes(nodes, [
        new TextNode('abc', 0, 3),
        new SectionNode('foo', 3, 11, '{{ }}'),
        new TextNode('ghi', 22, 25)
      ]);
      expectNodes((nodes[1] as SectionNode).children, [new TextNode('def', 11, 14)]);
    });

    test('parse section standalone tag whitespace', () {
      var source = 'abc\n{{#foo}}\ndef\n{{/foo}}\nghi';
      var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
      var nodes = parser.parse();
      expectNodes(nodes, [
        new TextNode('abc\n', 0, 4),
        new SectionNode('foo', 4, 12, '{{ }}'),
        new TextNode('ghi', 26, 29)
      ]);
      expectNodes((nodes[1] as SectionNode).children, [new TextNode('def\n', 13, 17)]);
    });

    test('parse section standalone tag whitespace consecutive', () {
      var source = 'abc\n{{#foo}}\ndef\n{{/foo}}\n{{#foo}}\ndef\n{{/foo}}\nghi';
      var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
      var nodes = parser.parse();
      expectNodes(nodes, [
        new TextNode('abc\n', 0, 4),
        new SectionNode('foo', 4, 12, '{{ }}'),
        new SectionNode('foo', 26, 34, '{{ }}'),
        new TextNode('ghi', 48, 51),
      ]);
      expectNodes((nodes[1] as SectionNode).children, [new TextNode('def\n', 13, 17)]);
    });

    test('parse section standalone tag whitespace on first line', () {
      var source = '  {{#foo}}  \ndef\n{{/foo}}\nghi';
      var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
      var nodes = parser.parse();
      expectNodes(nodes, [
        new SectionNode('foo', 2, 10, '{{ }}'),
        new TextNode('ghi', 26, 29)
      ]);
      expectNodes((nodes[0] as SectionNode).children, [new TextNode('def\n', 13, 17)]);
    });

    test('parse section standalone tag whitespace on last line', () {
      var source = '{{#foo}}def\n  {{/foo}}  ';
      var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
      var nodes = parser.parse();
      expectNodes(nodes, [new SectionNode('foo', 0, 8, '{{ }}')]);
      expectNodes((nodes[0] as SectionNode).children, [new TextNode('def\n', 8, 12)]);
    });

    test('parse variable newline', () {
      var source = 'abc\n\n{{foo}}def';
      var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
      var nodes = parser.parse();
      expectNodes(nodes, [
        new TextNode('abc\n\n', 0, 5),
        new VariableNode('foo', 5, 12, escape: true),
        new TextNode('def', 12, 15)
      ]);
    });

    test('parse section standalone tag whitespace v2', () {
      var source = 'abc\n\n{{#foo}}\ndef\n{{/foo}}\nghi';
      var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
      var nodes = parser.parse();
      expectNodes(nodes, [
        new TextNode('abc\n\n', 0, 5),
        new SectionNode('foo', 5, 13, '{{ }}'),
        new TextNode('ghi', 27, 30)
      ]);
      expectNodes((nodes[1] as SectionNode).children, [new TextNode('def\n', 14, 18)]);
    });

    test('parse whitespace', () {
      var source = 'abc\n   ';
      var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
      var nodes = parser.parse();
      expectNodes(nodes, [
        new TextNode('abc\n   ', 0, 7),
      ]);
    });

    test('parse partial', () {
      var source = 'abc\n   {{>foo}}def';
      var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
      var nodes = parser.parse();
      expectNodes(nodes, [
        new TextNode('abc\n   ', 0, 7),
        new PartialNode('foo', 7, 15, '   '),
        new TextNode('def', 15, 18)
      ]);
    });

    test('parse change delimiters', () {
      var source = '{{= | | =}}<|#lambda|-|/lambda|>';
      var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
      var nodes = parser.parse();
      expectNodes(nodes, [
        new TextNode('<', 11, 12),
        new SectionNode('lambda', 12, 21, '| |'),
        new TextNode('>', 31, 32),
      ]);
      expect((nodes[1] as SectionNode).delimiters, equals('| |'));
      expectNodes((nodes[1] as SectionNode).children, [new TextNode('-', 21, 22)]);
    });

    test('corner case strict', () {
      var source = "{{{ #foo }}} {{{ /foo }}}";
      var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
      try {
        parser.parse();
        fail('Should fail.');
      } catch (e) {
        expect(e is TemplateException, isTrue);
      }
    });

    test('corner case lenient', () {
      var source = "{{{ #foo }}} {{{ /foo }}}";
      var parser = new Parser(source, 'foo', '{{ }}', lenient: true);
      var nodes = parser.parse();
      expectNodes(nodes, [
        new VariableNode('#foo', 0, 12, escape: false),
        new TextNode(' ', 12, 13),
        new VariableNode('/foo', 13, 25, escape: false)
      ]);
    });

    test('toString', () {
      new TextNode('foo', 1, 3).toString();
      new VariableNode('foo', 1, 3).toString();
      new PartialNode('foo', 1, 3, ' ').toString();
      new SectionNode('foo', 1, 3, '{{ }}').toString();
      new Token(TokenType.closeDelimiter, 'foo', 1, 3).toString();
      TokenType.closeDelimiter.toString();
    });

    test('exception', () {
      var source = "'{{ foo }} sdfffffffffffffffffffffffffffffffffffffffffffff "
          "dsfsdf sdfdsa fdsfads fsdfdsfadsf dsfasdfsdf sdfdsfsadf sdfadsfsdf ";
      var ex = new TemplateException('boom!', 'foo.mustache', source, 2);
      ex.toString();
    });

    parseFail(source) {
      try {
        var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
        parser.parse();
        fail('Did not throw.');
        return null;
      } catch (ex, st) {
        if (ex is! TemplateException) {
          print(ex);
          print(st);
        }
        return ex;
      }
    }

    test('parse eof', () {
      expectTemplateEx(ex) => expect(ex is TemplateException, isTrue);

      expectTemplateEx(parseFail('{{#foo}}{{bar}}{{/foo}'));
      expectTemplateEx(parseFail('{{#foo}}{{bar}}{{/foo'));
      expectTemplateEx(parseFail('{{#foo}}{{bar}}{{/'));
      expectTemplateEx(parseFail('{{#foo}}{{bar}}{{'));
      expectTemplateEx(parseFail('{{#foo}}{{bar}}{'));
      expectTemplateEx(parseFail('{{#foo}}{{bar}}'));
      expectTemplateEx(parseFail('{{#foo}}{{bar}'));
      expectTemplateEx(parseFail('{{#foo}}{{bar'));
      expectTemplateEx(parseFail('{{#foo}}{{'));
      expectTemplateEx(parseFail('{{#foo}}{'));
      expectTemplateEx(parseFail('{{#foo}}'));
      expectTemplateEx(parseFail('{{#foo}'));
      expectTemplateEx(parseFail('{{#'));
      expectTemplateEx(parseFail('{{'));
      expectTemplateEx(parseFail('{{ # foo }}{{ bar }}{{ / foo }'));
      expectTemplateEx(parseFail('{{ # foo }}{{ bar }}{{ / foo '));
      expectTemplateEx(parseFail('{{ # foo }}{{ bar }}{{ / foo'));
      expectTemplateEx(parseFail('{{ # foo }}{{ bar }}{{ / '));
      expectTemplateEx(parseFail('{{ # foo }}{{ bar }}{{ /'));
      expectTemplateEx(parseFail('{{ # foo }}{{ bar }}{{ '));
      expectTemplateEx(parseFail('{{ # foo }}{{ bar }}{{'));
      expectTemplateEx(parseFail('{{ # foo }}{{ bar }}{'));
      expectTemplateEx(parseFail('{{ # foo }}{{ bar }}'));
      expectTemplateEx(parseFail('{{ # foo }}{{ bar }'));
      expectTemplateEx(parseFail('{{ # foo }}{{ bar '));
      expectTemplateEx(parseFail('{{ # foo }}{{ bar'));
      expectTemplateEx(parseFail('{{ # foo }}{{ '));
      expectTemplateEx(parseFail('{{ # foo }}{{'));
      expectTemplateEx(parseFail('{{ # foo }}{'));
      expectTemplateEx(parseFail('{{ # foo }}'));
      expectTemplateEx(parseFail('{{ # foo }'));
      expectTemplateEx(parseFail('{{ # foo '));
      expectTemplateEx(parseFail('{{ # foo'));
      expectTemplateEx(parseFail('{{ # '));
      expectTemplateEx(parseFail('{{ #'));
      expectTemplateEx(parseFail('{{ '));
      expectTemplateEx(parseFail('{{'));

      expectTemplateEx(parseFail('{{= || || =}'));
      expectTemplateEx(parseFail('{{= || || ='));
      expectTemplateEx(parseFail('{{= || || '));
      expectTemplateEx(parseFail('{{= || ||'));
      expectTemplateEx(parseFail('{{= || |'));
      expectTemplateEx(parseFail('{{= || '));
      expectTemplateEx(parseFail('{{= ||'));
      expectTemplateEx(parseFail('{{= |'));
      expectTemplateEx(parseFail('{{= '));
      expectTemplateEx(parseFail('{{='));
    });
  });
}

nodeEqual(a, b) {
  if (a is TextNode) {
    return b is TextNode &&
        a.text == b.text &&
        a.start == b.start &&
        a.end == b.end;
  } else if (a is VariableNode) {
    return a is VariableNode &&
        a.name == b.name &&
        a.escape == b.escape &&
        a.start == b.start &&
        a.end == b.end;
  } else if (a is SectionNode) {
    return a is SectionNode &&
        a.name == b.name &&
        a.delimiters == b.delimiters &&
        a.inverse == b.inverse &&
        a.start == b.start &&
        a.end == b.end;
  } else if (a is PartialNode) {
    return a is PartialNode && a.name == b.name && a.indent == b.indent;
  } else {
    return false;
  }
}

tokenEqual(Token a, Token b) {
  return a is Token &&
      a.type == b.type &&
      a.value == b.value &&
      a.start == b.start &&
      a.end == b.end;
}

expectTokens(List<Token> a, List<Token> b) {
  expect(a.length, equals(b.length), reason: "$a != $b");
  for (var i = 0; i < a.length; i++) {
    expect(tokenEqual(a[i], b[i]), isTrue, reason: "$a != $b");
  }
}

expectNodes(List<Node> a, List<Node> b) {
  expect(a.length, equals(b.length), reason: "$a != $b");
  for (var i = 0; i < a.length; i++) {
    expect(nodeEqual(a[i], b[i]), isTrue, reason: "$a != $b");
  }
}
