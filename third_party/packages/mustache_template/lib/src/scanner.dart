// TODO(stuartmorgan): Remove this. See https://github.com/flutter/flutter/issues/174722.
// ignore_for_file: public_member_api_docs

import 'template_exception.dart';
import 'token.dart';

class Scanner {
  Scanner(String source, this._templateName, String? delimiters)
    : _source = source,
      _itr = source.runes.iterator {
    if (source == '') {
      _c = _EOF;
    } else {
      _itr.moveNext();
      _c = _itr.current;
    }

    if (delimiters == null) {
      _openDelimiter = _openDelimiterInner = _OPEN_MUSTACHE;
      _closeDelimiter = _closeDelimiterInner = _CLOSE_MUSTACHE;
    } else if (delimiters.length == 3) {
      _openDelimiter = delimiters.codeUnits[0];
      _closeDelimiter = delimiters.codeUnits[2];
    } else if (delimiters.length == 5) {
      _openDelimiter = delimiters.codeUnits[0];
      _openDelimiterInner = delimiters.codeUnits[1];
      _closeDelimiterInner = delimiters.codeUnits[3];
      _closeDelimiter = delimiters.codeUnits[4];
    } else {
      throw TemplateException(
        'Invalid delimiter string $delimiters',
        null,
        null,
        null,
      );
    }
  }

  final String? _templateName;
  final String _source;

  final Iterator<int> _itr;
  int _offset = 0;
  int _c = 0;

  final List<Token> _tokens = <Token>[];

  // These can be changed by the change delimiter tag.
  int? _openDelimiter;
  int? _openDelimiterInner;
  int? _closeDelimiterInner;
  int? _closeDelimiter;

  List<Token> scan() {
    for (int c = _peek(); c != _EOF; c = _peek()) {
      // Scan text tokens.
      if (c != _openDelimiter) {
        _scanText();
        continue;
      }

      final int start = _offset;

      // Read first open delimiter character.
      _read();

      // If only a single delimiter character then create a text token.
      if (_openDelimiterInner != null && _peek() != _openDelimiterInner) {
        final String value = String.fromCharCode(_openDelimiter!);
        _append(TokenType.text, value, start, _offset);
        continue;
      }

      if (_openDelimiterInner != null) {
        _expect(_openDelimiterInner!);
      }

      // Handle triple mustache.
      if (_openDelimiterInner == _OPEN_MUSTACHE &&
          _openDelimiter == _OPEN_MUSTACHE &&
          _peek() == _OPEN_MUSTACHE) {
        _read();
        _append(TokenType.openDelimiter, '{{{', start, _offset);
        _scanTagContent();
        _scanCloseTripleMustache();
      } else {
        // Check to see if this is a change delimiter tag. {{= | | =}}
        // Need to skip whitespace and check for "=".
        final int wsStart = _offset;
        final String ws = _readWhile(_isWhitespace);

        if (_peek() == _EQUAL) {
          _parseChangeDelimiterTag(start);
        } else {
          // Scan standard mustache tag.
          final String value = String.fromCharCodes(
            _openDelimiterInner == null
                ? <int>[_openDelimiter!]
                : <int>[_openDelimiter!, _openDelimiterInner!],
          );

          _append(TokenType.openDelimiter, value, start, wsStart);

          if (ws != '') {
            _append(TokenType.whitespace, ws, wsStart, _offset);
          }

          _scanTagContent();
          _scanCloseDelimiter();
        }
      }
    }
    return _tokens;
  }

  int _peek() => _c;

  int _read() {
    final int c = _c;
    _offset++;
    _c = _itr.moveNext() ? _itr.current : _EOF;
    return c;
  }

  String _readWhile(bool Function(int charCode) test) {
    if (_c == _EOF) {
      return '';
    }
    final int start = _offset;
    while (_peek() != _EOF && test(_peek())) {
      _read();
    }
    final int end = _peek() == _EOF ? _source.length : _offset;
    return _source.substring(start, end);
  }

  void _expect(int expectedCharCode) {
    final int c = _read();

    if (c == _EOF) {
      throw TemplateException(
        'Unexpected end of input',
        _templateName,
        _source,
        _offset - 1,
      );
    }
    if (c != expectedCharCode) {
      throw TemplateException(
        'Unexpected character, '
        'expected: ${String.fromCharCode(expectedCharCode)}, '
        'was: ${String.fromCharCode(c)}',
        _templateName,
        _source,
        _offset - 1,
      );
    }
  }

  void _append(TokenType type, String value, int start, int end) =>
      _tokens.add(Token(type, value, start, end));

  bool _isWhitespace(int c) =>
      const <int>[_SPACE, _TAB, _NEWLINE, _RETURN].contains(c);

  // Scan text. This adds text tokens, line end tokens, and whitespace
  // tokens for whitespace at the beginning of a line. This is because the
  // mustache spec requires special handing of whitespace.
  void _scanText() {
    int start = 0;
    TokenType token;
    String value;

    for (int c = _peek(); c != _EOF && c != _openDelimiter; c = _peek()) {
      start = _offset;

      switch (c) {
        case _SPACE:
        case _TAB:
          value = _readWhile((int c) => c == _SPACE || c == _TAB);
          token = TokenType.whitespace;

        case _NEWLINE:
          _read();
          token = TokenType.lineEnd;
          value = '\n';

        case _RETURN:
          _read();
          if (_peek() == _NEWLINE) {
            _read();
            token = TokenType.lineEnd;
            value = '\r\n';
          } else {
            token = TokenType.text;
            value = '\r';
          }

        default:
          value = _readWhile((int c) => c != _openDelimiter && c != _NEWLINE);
          token = TokenType.text;
      }

      _append(token, value, start, _offset);
    }
  }

  // Scan contents of a tag and the end delimiter token.
  void _scanTagContent() {
    int start;
    TokenType token;
    String value;

    bool isCloseDelimiter(int c) =>
        (_closeDelimiterInner == null && c == _closeDelimiter) ||
        (_closeDelimiterInner != null && c == _closeDelimiterInner);

    for (int c = _peek(); c != _EOF && !isCloseDelimiter(c); c = _peek()) {
      start = _offset;

      switch (c) {
        case _HASH:
        case _CARET:
        case _FORWARD_SLASH:
        case _GT:
        case _AMP:
        case _EXCLAIM:
          _read();
          token = TokenType.sigil;
          value = String.fromCharCode(c);

        case _SPACE:
        case _TAB:
        case _NEWLINE:
        case _RETURN:
          token = TokenType.whitespace;
          value = _readWhile(_isWhitespace);

        case _PERIOD:
          _read();
          token = TokenType.dot;
          value = '.';

        default:
          // Identifier can be any other character in lenient mode.
          token = TokenType.identifier;
          value = _readWhile(
            (int c) =>
                !(const <int>[
                  _HASH,
                  _CARET,
                  _FORWARD_SLASH,
                  _GT,
                  _AMP,
                  _EXCLAIM,
                  _SPACE,
                  _TAB,
                  _NEWLINE,
                  _RETURN,
                  _PERIOD,
                ].contains(c)) &&
                c != _closeDelimiterInner &&
                c != _closeDelimiter,
          );
      }
      _append(token, value, start, _offset);
    }
  }

  // Scan close delimiter token.
  void _scanCloseDelimiter() {
    if (_peek() != _EOF) {
      final int start = _offset;

      if (_closeDelimiterInner != null) {
        _expect(_closeDelimiterInner!);
      }
      _expect(_closeDelimiter!);

      final String value = String.fromCharCodes(
        _closeDelimiterInner == null
            ? <int>[_closeDelimiter!]
            : <int>[_closeDelimiterInner!, _closeDelimiter!],
      );

      _append(TokenType.closeDelimiter, value, start, _offset);
    }
  }

  // Scan close triple mustache delimiter token.
  void _scanCloseTripleMustache() {
    if (_peek() != _EOF) {
      final int start = _offset;

      _expect(_CLOSE_MUSTACHE);
      _expect(_CLOSE_MUSTACHE);
      _expect(_CLOSE_MUSTACHE);

      _append(TokenType.closeDelimiter, '}}}', start, _offset);
    }
  }

  // Open delimiter characters have already been read.
  void _parseChangeDelimiterTag(int start) {
    _expect(_EQUAL);

    final int? delimiterInner = _closeDelimiterInner;
    final int? delimiter = _closeDelimiter;

    _readWhile(_isWhitespace);

    int c;
    c = _read();

    if (c == _EQUAL) {
      throw _error('Incorrect change delimiter tag.');
    }
    _openDelimiter = c;

    c = _read();
    if (_isWhitespace(c)) {
      _openDelimiterInner = null;
    } else {
      _openDelimiterInner = c;
    }

    _readWhile(_isWhitespace);

    c = _read();

    if (_isWhitespace(c) || c == _EQUAL) {
      throw _error('Incorrect change delimiter tag.');
    }

    if (_isWhitespace(_peek()) || _peek() == _EQUAL) {
      _closeDelimiterInner = null;
      _closeDelimiter = c;
    } else {
      _closeDelimiterInner = c;
      _closeDelimiter = _read();
    }

    _readWhile(_isWhitespace);

    _expect(_EQUAL);

    _readWhile(_isWhitespace);

    if (delimiterInner != null) {
      _expect(delimiterInner);
    }
    _expect(delimiter!);

    // Create delimiter string.
    final StringBuffer buffer = StringBuffer();
    buffer.writeCharCode(_openDelimiter!);
    if (_openDelimiterInner != null) {
      buffer.writeCharCode(_openDelimiterInner!);
    }
    buffer.write(' ');
    if (_closeDelimiterInner != null) {
      buffer.writeCharCode(_closeDelimiterInner!);
    }
    buffer.writeCharCode(_closeDelimiter!);
    final String value = buffer.toString();

    _append(TokenType.changeDelimiter, value, start, _offset);
  }

  TemplateException _error(String message) {
    return TemplateException(message, _templateName, _source, _offset);
  }
}

const int _EOF = -1;
const int _TAB = 9;
const int _NEWLINE = 10;
const int _RETURN = 13;
const int _SPACE = 32;
const int _EXCLAIM = 33;
const int _HASH = 35;
const int _AMP = 38;
const int _PERIOD = 46;
const int _FORWARD_SLASH = 47;
const int _EQUAL = 61;
const int _GT = 62;
const int _CARET = 94;

const int _OPEN_MUSTACHE = 123;
const int _CLOSE_MUSTACHE = 125;
