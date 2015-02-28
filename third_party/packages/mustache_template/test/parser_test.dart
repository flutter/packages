import 'package:unittest/unittest.dart';

import 'package:mustache/src/scanner2.dart';

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
       new Token(TokenType.openTripleMustache, '{{{', 3, 6),
       new Token(TokenType.identifier, 'foo', 6, 9),
       new Token(TokenType.closeTripleMustache, '}}}', 9, 12),
       new Token(TokenType.text, 'def', 12, 15)
     ]));
   });

   
   test('scan triple mustache whitespace', () {
     var source = 'abc{{{ foo }}}def';     
     var scanner = new Scanner(source, 'foo', '{{ }}', lenient: false);
     var tokens = scanner.scan();
     expect(tokens, orderedEquals([
       new Token(TokenType.text, 'abc', 0, 3),
       new Token(TokenType.openTripleMustache, '{{{', 3, 6),
       new Token(TokenType.whitespace, ' ', 6, 7),
       new Token(TokenType.identifier, 'foo', 7, 10),
       new Token(TokenType.whitespace, ' ', 10, 11),
       new Token(TokenType.closeTripleMustache, '}}}', 11, 14),
       new Token(TokenType.text, 'def', 14, 17)
     ]));
   });
   
  });
}