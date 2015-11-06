library mustache.token;

class TokenType {
  const TokenType(this.name);

  final String name;

  String toString() => '(TokenType $name)';

  static const TokenType text = const TokenType('text');
  static const TokenType openDelimiter = const TokenType('openDelimiter');
  static const TokenType closeDelimiter = const TokenType('closeDelimiter');

  // A sigil is the word commonly used to describe the special character at the
  // start of mustache tag i.e. #, ^ or /.
  static const TokenType sigil = const TokenType('sigil');
  static const TokenType identifier = const TokenType('identifier');
  static const TokenType dot = const TokenType('dot');

  static const TokenType changeDelimiter = const TokenType('changeDelimiter');
  static const TokenType whitespace = const TokenType('whitespace');
  static const TokenType lineEnd = const TokenType('lineEnd');
}

class Token {
  Token(this.type, this.value, this.start, this.end);

  final TokenType type;
  final String value;

  final int start;
  final int end;

  String toString() => "(Token ${type.name} \"$value\" $start $end)";
}
