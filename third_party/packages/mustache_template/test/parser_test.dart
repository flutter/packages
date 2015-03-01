import 'package:unittest/unittest.dart';

import 'package:mustache/src/mustache_impl.dart' show TextNode, VariableNode, SectionNode, PartialNode;
import 'package:mustache/src/parser.dart';
import 'package:mustache/src/scanner2.dart';
import 'package:mustache/src/token2.dart';

main() {
  
  group('Scanner', () {

    test('scan text', () {
      var source = 'abc';
      var scanner = new Scanner(source, 'foo', '{{ }}', lenient: false);
      var tokens = scanner.scan();
      expect(tokens, orderedEquals([
        new Token(TokenType.text, 'abc', 0, 3),
        ]));
    });
    
    test('scan tag', () {
      var source = 'abc{{foo}}def';     
      var scanner = new Scanner(source, 'foo', '{{ }}', lenient: false);
      var tokens = scanner.scan();
      expect(tokens, orderedEquals([
        new Token(TokenType.text, 'abc', 0, 3),
        new Token(TokenType.openDelimiter, '{{', 3, 5),
        new Token(TokenType.identifier, 'foo', 5, 8),
        new Token(TokenType.closeDelimiter, '}}', 8, 10),
        new Token(TokenType.text, 'def', 10, 13)
      ]));
    });
     
   test('scan tag whitespace', () {
     var source = 'abc{{ foo }}def';
     var scanner = new Scanner(source, 'foo', '{{ }}', lenient: false);
     var tokens = scanner.scan();
     expect(tokens, orderedEquals([
       new Token(TokenType.text, 'abc', 0, 3),
       new Token(TokenType.openDelimiter, '{{', 3, 5),
       new Token(TokenType.whitespace, ' ', 5, 6),
       new Token(TokenType.identifier, 'foo', 6, 9),
       new Token(TokenType.whitespace, ' ', 9, 10),
       new Token(TokenType.closeDelimiter, '}}', 10, 12),
       new Token(TokenType.text, 'def', 12, 15)
     ]));
   });
   
   test('scan tag sigil', () {
     var source = 'abc{{ # foo }}def';
     var scanner = new Scanner(source, 'foo', '{{ }}', lenient: false);
     var tokens = scanner.scan();
     expect(tokens, orderedEquals([
       new Token(TokenType.text, 'abc', 0, 3),
       new Token(TokenType.openDelimiter, '{{', 3, 5),
       new Token(TokenType.whitespace, ' ', 5, 6),
       new Token(TokenType.sigil, '#', 6, 7),
       new Token(TokenType.whitespace, ' ', 7, 8),
       new Token(TokenType.identifier, 'foo', 8, 11),
       new Token(TokenType.whitespace, ' ', 11, 12),
       new Token(TokenType.closeDelimiter, '}}', 12, 14),
       new Token(TokenType.text, 'def', 14, 17)
     ]));
   });

   test('scan tag dot', () {
     var source = 'abc{{ foo.bar }}def';
     var scanner = new Scanner(source, 'foo', '{{ }}', lenient: false);
     var tokens = scanner.scan();
     expect(tokens, orderedEquals([
       new Token(TokenType.text, 'abc', 0, 3),
       new Token(TokenType.openDelimiter, '{{', 3, 5),
       new Token(TokenType.whitespace, ' ', 5, 6),
       new Token(TokenType.identifier, 'foo', 6, 9),
       new Token(TokenType.dot, '.', 9, 10),
       new Token(TokenType.identifier, 'bar', 10, 13),
       new Token(TokenType.whitespace, ' ', 13, 14),
       new Token(TokenType.closeDelimiter, '}}', 14, 16),
       new Token(TokenType.text, 'def', 16, 19)
     ]));
   });

   test('scan triple mustache', () {
     var source = 'abc{{{foo}}}def';     
     var scanner = new Scanner(source, 'foo', '{{ }}', lenient: false);
     var tokens = scanner.scan();
     expect(tokens, orderedEquals([
       new Token(TokenType.text, 'abc', 0, 3),
       new Token(TokenType.openDelimiter, '{{{', 3, 6),
       new Token(TokenType.identifier, 'foo', 6, 9),
       new Token(TokenType.closeDelimiter, '}}}', 9, 12),
       new Token(TokenType.text, 'def', 12, 15)
     ]));
   });

   
   test('scan triple mustache whitespace', () {
     var source = 'abc{{{ foo }}}def';
     var scanner = new Scanner(source, 'foo', '{{ }}', lenient: false);
     var tokens = scanner.scan();
     expect(tokens, orderedEquals([
       new Token(TokenType.text, 'abc', 0, 3),
       new Token(TokenType.openDelimiter, '{{{', 3, 6),
       new Token(TokenType.whitespace, ' ', 6, 7),
       new Token(TokenType.identifier, 'foo', 7, 10),
       new Token(TokenType.whitespace, ' ', 10, 11),
       new Token(TokenType.closeDelimiter, '}}}', 11, 14),
       new Token(TokenType.text, 'def', 14, 17)
     ]));
   });
  });
   
  group('Parser', () {
    
   test('parse variable', () {
     var source = 'abc{{foo}}def';
     var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
     var nodes = parser.parse();
     expect(nodes, orderedEquals([
       new TextNode('abc', 0, 3),
       new VariableNode('foo', 3, 10, escape: true),
       new TextNode('def', 10, 13)
     ]));
   });

   test('parse variable whitespace', () {
     var source = 'abc{{ foo }}def';
     var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
     var nodes = parser.parse();
     expect(nodes, orderedEquals([
       new TextNode('abc', 0, 3),
       new VariableNode('foo', 3, 12, escape: true),
       new TextNode('def', 12, 15)
     ]));
   });
   
   test('parse section', () {
     var source = 'abc{{#foo}}def{{/foo}}ghi';
     var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
     var nodes = parser.parse();
     expect(nodes, orderedEquals([
       new TextNode('abc', 0, 3),
       new SectionNode('foo', 3, 11, '{{ }}'),
       new TextNode('ghi', 22, 25)
     ]));
     expect(nodes[1].children, orderedEquals([new TextNode('def', 11, 14)]));
   });

   test('parse section whitespace', () {
     var source = 'abc\n{{#foo}}\ndef\n{{/foo}}\nghi';
     var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
     var nodes = parser.parse();
     expect(nodes, orderedEquals([
       new TextNode('abc\n', 0, 4),
       new SectionNode('foo', 4, 25, '{{ }}'),
       new TextNode('\nghi', 25, 29)
     ]));
     //TODO figure out correct behaviour.
     //expect(nodes[1].children, orderedEquals([new TextNode('def\n', 13, 17)]));
     expect(nodes[1].children, orderedEquals([new TextNode('\ndef\n', 12, 17)]));
   });

   test('parse whitespace', () {
     var source = 'abc\n   ';
     var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
     var nodes = parser.parse();
     expect(nodes, orderedEquals([
       new TextNode('abc\n   ', 0, 7),
     ]));
   });
   
   test('parse partial', () {
     var source = 'abc\n   {{>foo}}def';
     var parser = new Parser(source, 'foo', '{{ }}', lenient: false);
     var nodes = parser.parse();
     expect(nodes, orderedEquals([
       new TextNode('abc\n   ', 0, 7),
       new PartialNode('foo', 7, 15, '   '),
       new TextNode('def', 15, 18)
     ]));
   });
   
  });
  
}